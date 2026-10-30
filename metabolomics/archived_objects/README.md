# Archived MetMiner R objects

These 29 files are copied byte-for-byte from the supplied `02.MaizeTeosintePro.zip` under `03.progress/05.metabolomics/`. The two original project subdirectories are preserved:

- `01.mrm_selection/`: 14 objects (7 stages for each polarity).
- `02.TQMSDataProcessing/`: 14 stage objects and `Result/Data_Export/object_merge.rda`.

Stage names are those in the archive: `raw`, `mv`, `outlier`, `impute`, `norm`, `anno`, and `af`. They are recorded intermediate objects, not original instrument files. The similarly named files in the two project directories are distinct; retain their directory context.

[SHA256SUMS.txt](SHA256SUMS.txt) lists source-byte SHA-256 checksums. Loading these objects in R may require compatible tidyMass/massdataset package versions. They may contain historical processing metadata and local paths; their presence does not establish the complete execution script or all parameters.
