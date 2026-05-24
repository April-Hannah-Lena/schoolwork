# %%
import numpy as np
import pandas as pd
import xarray as xr
import glob
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from tqdm.auto import tqdm

# %%
base_dir = Path(__file__).resolve().parent
dataset_dir = Path("/Volumes/Extreme SSD/oceandata").resolve()
files = sorted(glob.glob(str(dataset_dir / "*.nc")))
# %%
ds = xr.open_mfdataset(files, chunks={"time": 30}, engine="netcdf4", combine="by_coords")
# %%
vel = ds[["EVEL", "NVEL", "WVEL"]].sel(
    Z=slice(0, -10),    # only surface water (top level)
    time=slice("1990-01-01", "2020-01-31")
)
vel = vel.where(vel.time.dt.month.isin([4, 5, 6, 7, 8, 9]), drop=True)
# %%
def day_to_datavec(data, time_idx, z_idx=0):
    one_day = data.isel(time=time_idx, Z=z_idx, drop=True)
    vector = (
        one_day[["EVEL", "NVEL", "WVEL"]]
        .to_array(dim="component")
        .transpose(..., "component")
        .to_numpy()
        .astype(np.float32, copy=False)
        .ravel()
    )
    return np.nan_to_num(vector, nan=0.0, copy=False)


# %%
stride = 1
delay = 1
time_indices = range(0, vel.sizes["time"], stride)
M = len(time_indices) - delay

# %%
distances_dir = base_dir / "distances"
cache_dir = base_dir / "distances" / "cache"

time_indices = list(time_indices)
first_vector = day_to_datavec(vel, time_indices[0])
dimension = first_vector.size
block_size = 32
max_workers = min(4, os.cpu_count() or 1)

#%%
vectors = np.memmap(
    cache_dir / "day_vectors.float32.mmap",
    dtype="float32",
    mode="w+",
    shape=(M+delay, dimension),
)

with tqdm(total=M+delay, desc="Caching day vectors") as progress:
    vectors[0] = first_vector
    progress.update()
    for i, t in enumerate(time_indices[1:], start=1):
        vectors[i] = day_to_datavec(vel, t)
        progress.update()

vectors.flush()

# %%
distances_XX = np.memmap(
    cache_dir / "distances_XX.float32.mmap",
    dtype="float32",
    mode="w+",
    shape=(M, M),
)

distances_XY = np.memmap(
    cache_dir / "distances_XY.float32.mmap",
    dtype="float32",
    mode="w+",
    shape=(M, M),
)

distances_YY = np.memmap(
    cache_dir / "distances_YY.float32.mmap",
    dtype="float32",
    mode="w+",
    shape=(M, M),
)

# %%
def fill_distance_row(output, row_idx, left_offset=0, right_offset=0):
    x1 = vectors[row_idx + left_offset].copy()
    for j0 in range(0, M, block_size):
        j1 = min(j0 + block_size, M)
        diffs = vectors[j0 + right_offset:j1 + right_offset] - x1
        output[row_idx, j0:j1] = np.sqrt(np.einsum("ij,ij->i", diffs, diffs))
    return M


def populate_distance_matrix(name, output, left_offset=0, right_offset=0):
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = [
            executor.submit(fill_distance_row, output, i, left_offset, right_offset)
            for i in range(M)
        ]
        with tqdm(total=M * M, desc=f"Populating {name}") as progress:
            for future in as_completed(futures):
                progress.update(future.result())
    output.flush()


populate_distance_matrix("XX", distances_XX)
populate_distance_matrix("XY", distances_XY, right_offset=delay)
populate_distance_matrix("YY", distances_YY, left_offset=delay, right_offset=delay)

# this is unimportant, only kept for later reference
""" 
distances_XY = np.array([[ # | xi - S(xj) |_{i j}
    np.linalg.norm(
        np.nan_to_num(day_to_datavec(vel, t1), nan=0) - np.nan_to_num(day_to_datavec(vel, t2 + delay), nan=0)
    ) 
    for t2 in time_indices] for t1 in time_indices])

distances_YY = np.array([[ # | xi - S(xj) |_{i j}
    np.linalg.norm(
        np.nan_to_num(day_to_datavec(vel, t1 + delay), nan=0) - np.nan_to_num(day_to_datavec(vel, t2 + delay), nan=0)
    ) 
    for t2 in time_indices] for t1 in time_indices])
"""
# %%
np.savetxt(distances_dir / "distances_XX.csv", distances_XX, delimiter=",")
np.savetxt(distances_dir / "distances_XY.csv", distances_XY, delimiter=",")
np.savetxt(distances_dir / "distances_YY.csv", distances_YY, delimiter=",")

""" 
pd.DataFrame(distances_XY).to_csv(base_dir / "distances/distances_XY.csv", index=False, header=False)
pd.DataFrame(distances_YY).to_csv(base_dir / "distances/distances_YY.csv", index=False, header=False)
 """
# %%
