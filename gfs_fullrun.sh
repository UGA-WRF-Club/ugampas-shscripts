#!/bin/bash
# Parent script to setup IC/LBCs from current GFS data for UGA-MPAS AND to run the model.
set -e

cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS
echo "running prepoc parent script"
./gfs_pre00_init_atmosphere.sh
echo "preprocessing finished at $(date +"%Y-%m-%d %r")."

echo "running model..."
./gfs_run_mpas.sh

echo "all done! (hopefully)"
echo "model finished at $(date +"%Y-%m-%d %r")."
