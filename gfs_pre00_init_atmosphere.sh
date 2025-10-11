#!/bin/bash
# Parent script to setup IC/LBCs from current GFS data for UGA-MPAS
set -e

cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS
echo "Starting MPAS preprocessing..."

echo "Starting download of GFS data..."
./gfs_pre01_download.sh

echo "Ungribbing GFS data..."
./gfs_pre02_ungrib.sh

echo "Running init_atmosphere for ICs..."
./gfs_pre03_init_conds.sh

echo "Running init_atmosphere for LBCs..."
./gfs_pre04_lbc.sh

echo "All done! Ready to pass off to atmosphere model..."
