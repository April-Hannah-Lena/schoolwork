# Villin HP35 Dataset Notes

## Source

Folding@home project PROJ3037, villin headpiece (HP35) simulations. Files downloaded via `getGromacsFiles.py`. The download script requests trajectories in `backbone-PDB` format, but the server ignores the format parameter and returns raw XTC files regardless. The `.pdb.gz` extension is therefore misleading — the files are GROMACS XTC trajectories and must be opened with an explicit `"XTC"` format specifier (e.g. `Trajectory(file, 'r', "XTC")` in Chemfiles). The same issue affects the PROJ3036 dataset.

The associated GROMACS topology files (`.tpr`) are format version 40 (GROMACS 3.3, circa 2005). No current tool — including modern GROMACS, MDAnalysis, or MDTraj — can read this version.

## System composition

Each XTC frame contains **9684 atoms**. The reference structure `2F4K.pdb` (villin HP35 NMR structure from RCSB) contains **654 atoms**: 601 protein heavy and hydrogen atoms, plus 53 crystallographic water oxygens.

The difference 9684 − 654 = 9030 = 3 × 3010 is an exact multiple of 3, consistent with 3010 TIP3P water molecules (3 atoms each: O, HW1, HW2) making up the explicit solvent. The AMBER99 force field and TIP3P water model were confirmed from the TPR binary's atom-type table.

## Atom index selection in `villin.jl`

The script selects heavy (non-hydrogen) protein atom indices from `2F4K.pdb` and uses them to slice positions from each XTC frame. The trailing 53 crystallographic water oxygens from `2F4K.pdb` are excluded, leaving only the 601 protein atoms as the index reference. Heavy atoms are identified by filtering out atoms whose Chemfiles `fullname` is `"Hydrogen"`.

### Why this is justified

1. **Standard GROMACS atom ordering.** GROMACS places the solute (protein) atoms first in the topology, followed by solvent. This convention is universal across GROMACS versions and force fields.

2. **Arithmetic consistency.** The exact factorisation 9684 = 654 + 3 × 3010 means there is essentially no other plausible decomposition: the first 654 atoms must be the protein + crystal waters, and the remainder must be TIP3P water.

3. **Coordinate geometry.** The standard deviation of positions of the first 654 atoms across one frame is ~8 Å (0.8 nm), consistent with a compact folded protein of ~3 nm diameter. The standard deviation of the remaining 9030 atoms is ~13 Å (1.3 nm), consistent with water molecules filling a ~4.5 nm simulation box at bulk density. A random or misaligned selection would not produce this contrast.

4. **Symbol table confirmation.** Partial extraction of the TPR binary's symbol table (readable despite the unsupported format version) shows all residue and atom names expected for villin HP35: LEU, SER, ASP, GLU, PHE, ALA, VAL, GLY, MET, THR, ARG, ASN, PRO, TRP, GLN, HIE, along with SOL (water), HW1, HW2.

### What may cause it to be incorrect

1. **Atom ordering not directly verified.** The TPR v40 topology could not be parsed to confirm the per-atom name sequence. The ordering assumption rests on GROMACS convention and indirect evidence, not a direct read of the simulation topology.

2. **C-terminal naming discrepancy.** The TPR symbol table contains `OC1`/`OC2` (AMBER-style C-terminal carboxylate oxygens), while `2F4K.pdb` uses `OXT`. This does not affect heavy-atom filtering (neither starts with H), but it is evidence that some atom names in the simulation differ from the PDB reference. Other naming differences may exist for non-standard residues.

3. **Crystallographic waters.** `2F4K.pdb` lists 53 structural water oxygens (lines 602–654) with no hydrogen atoms. It is not confirmed whether the simulation includes these as single-oxygen sites or replaces them with full TIP3P molecules (which would change the atom count and break the index mapping). The arithmetic only holds if they are stored as single oxygens matching the PDB exactly.

4. **Sequence or protonation differences.** If the simulation was prepared from a modified version of 2F4K (different protonation states, capped termini, or mutated residues), the atom count per residue could differ, shifting all subsequent indices.
