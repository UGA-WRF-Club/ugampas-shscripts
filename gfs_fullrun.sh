#!/bin/bash
# Parent script to setup IC/LBCs from current GFS data for UGA-MPAS AND to run the model.
set -e

cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS
echo "(fullrun.sh) Running prepoc parent script"
./gfs_pre00_init_atmosphere.sh
echo "(fullrun.sh) preprocessing finished at $(date +"%Y-%m-%d %r")."

echo "(fullrun.sh) running model..."
./gfs_run_mpas.sh

echo "(fullrun.sh) all done! (hopefully)"
echo "(fullrun.sh) model finished at $(date +"%Y-%m-%d %r")."
