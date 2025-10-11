For a full run (preproc with GFS init + model run),

`./gfs_fullrun.sh`

runs `gfs_pre00_init_atmosphere.sh` -> `gfs_run_mpas.sh`

For just pre-proc,

`./gfs_pre00_init_atmosphere.sh`

runs `gfs_pre01_download.sh` -> `gfs_pre02_ungrib.sh` -> `gfs_pre03_init_conds.sh` -> `gfs_pre04_lbc.sh`

For just the model run (assuming you already have preproc'd files),

`./gfs_run_mpas.sh`

A lot of this code is adapted from UGA-WRF preproc/download scripts.
