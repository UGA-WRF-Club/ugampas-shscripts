#!/bin/bash
# Parent script to setup IC/LBCs from current NAM data for UGA-MPAS AND to run the model.
set -e

cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS
echo "(fullrun.sh) Running prepoc parent script for NAM data"
./nam_pre00_init_atmosphere.sh $1 # 1st argument determines how many hours of NAM data to download, ungrib, and prepare IC/LBCs off of
echo "(fullrun.sh) preprocessing finished at $(date +"%Y-%m-%d %r")."

echo "(fullrun.sh) running model..."
./nam_run_mpas.sh $2 # 2nd argument determines how many hours to run the model out to

echo "(fullrun.sh) all done! (hopefully)"
echo "(fullrun.sh) model finished at $(date +"%Y-%m-%d %r")."

