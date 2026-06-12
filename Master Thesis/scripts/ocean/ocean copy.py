# %%
import numpy as np
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
max_workers = min(8, os.cpu_count() or 1)
# %%
ds = xr.open_mfdataset(files, chunks={"time": 30}, engine="netcdf4", combine="by_coords")
# %%
vel = ds[["EVEL", "NVEL"]].sel(
    Z=slice(0, -10),    # only surface water (top level)
    time=slice("1990-01-01", "2020-01-31")
    #time=slice("2010-01-01", "2020-01-31")
)


# %%
def day_to_datavec(data, time_idx, z_idx=0):
    one_day = data.isel(time=time_idx, Z=z_idx, drop=True)
    vector = (
        one_day[["EVEL", "NVEL"]]
        .to_array(dim="component")
        .transpose(..., "component")
        .to_numpy()
        .astype(np.float32, copy=False)
        .ravel()
    )
    return np.nan_to_num(vector, nan=0.0, copy=False)


# %%
stride = 1
delay = 14
mean_radius = 14
mean_window = 2 * mean_radius + 1
season_months = np.array([4, 5, 6, 7, 8, 9])

# %%
distances_dir = base_dir / "distances"
cache_dir = base_dir / "distances" / "cache"

time_count = vel.sizes["time"]

months = vel.time.dt.month.to_numpy()
center_indices = np.arange(mean_radius, time_count - mean_radius, stride)
seasonal_center_indices = center_indices[
    np.isin(months[center_indices], season_months)
]

K = len(seasonal_center_indices)
M = K - delay

first_vector = day_to_datavec(vel, 0)
dimension = first_vector.size
block_size = 32

# %%
vectors = np.memmap(
    cache_dir / "day_vectors.float32.mmap",
    dtype="float32",
    mode="r",
    shape=(K, dimension),
)


# %%
def cache_centered_anomaly_vectors():
    window = np.empty((mean_window, dimension), dtype=np.float32)
    rolling_sum = np.zeros(dimension, dtype=np.float64)
    keep_center = np.zeros(time_count, dtype=bool)
    keep_center[seasonal_center_indices] = True

    out_idx = 0
    with tqdm(total=time_count, desc="Caching centered anomaly vectors") as progress:
        for time_idx in range(mean_window):
            vector = first_vector if time_idx == 0 else day_to_datavec(vel, time_idx)
            window[time_idx % mean_window] = vector
            rolling_sum += window[time_idx % mean_window]
            progress.update()

        for center_idx in range(mean_radius, time_count - mean_radius):
            if center_idx > mean_radius:
                incoming_idx = center_idx + mean_radius
                incoming_slot = incoming_idx % mean_window

                rolling_sum -= window[incoming_slot]
                window[incoming_slot] = day_to_datavec(vel, incoming_idx)
                rolling_sum += window[incoming_slot]
                progress.update()

            if keep_center[center_idx]:
                vectors[out_idx] = (
                    window[center_idx % mean_window] - rolling_sum / mean_window
                )
                out_idx += 1

    if out_idx != K:
        raise RuntimeError(f"Expected to cache {K} vectors, cached {out_idx}.")

    vectors.flush()


# cache_centered_anomaly_vectors()

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

# %%
np.savetxt(distances_dir / "distances_XX.csv", distances_XX, delimiter=",")
np.savetxt(distances_dir / "distances_XY.csv", distances_XY, delimiter=",")
np.savetxt(distances_dir / "distances_YY.csv", distances_YY, delimiter=",")

# %%
candidates = np.loadtxt(base_dir / "candidates.csv", delimiter=",", dtype=np.float32)
candidates_spatial = candidates @ vectors
np.savetxt(base_dir / "candidates_spatial.csv", candidates_spatial, delimiter=",")
# %%
