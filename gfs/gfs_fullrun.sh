#!/bin/bash
# Parent script to setup IC/LBCs from current GFS data for UGA-MPAS AND to run the model.
set -e

cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS/gfs
echo "(fullrun.sh) Running prepoc parent script"
./gfs_pre00_init_atmosphere.sh $1 # argument determines how many hours of GFS data to download
echo "(fullrun.sh) preprocessing finished at $(date +"%Y-%m-%d %r")."

echo "(fullrun.sh) running model..."
./gfs_run_mpas.sh $2 # 2nd argument determines how many hours to run the model out to

echo "(fullrun.sh) all done! (hopefully)"
echo "(fullrun.sh) model finished at $(date +"%Y-%m-%d %r")."

echo "(fullrun.sh) passing off to basic postproc..."
cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS/
./basic_postproc.sh
echo "(fullrun.sh) basic postproc concluded in some way. moving outputs to temporary directory for storage..."
cp /home/mpas_uga/mpas/uga_mpas/outputs/* /home/mpas_uga/mpas/output_dir/
