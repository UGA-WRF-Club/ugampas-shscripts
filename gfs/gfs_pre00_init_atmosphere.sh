#!/bin/bash
# Parent script to setup IC/LBCs from current GFS data for UGA-MPAS
set -e

cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS/gfs
echo "(Preproc Parent) Starting MPAS preprocessing..."

echo "(Preproc Parent) Starting download of GFS data..."
./gfs_pre01_download.sh $1 # argument determines how many hours of GFS data to download

echo "(Preproc Parent) Ungribbing GFS data..."
./gfs_pre02_ungrib.sh

echo "(Preproc Parent) Running init_atmosphere for ICs..."
./gfs_pre03_init_conds.sh

echo "(Preproc Parent) Running init_atmosphere for LBCs..."
./gfs_pre04_lbc.sh

echo "(Preproc Parent) All done! Ready to pass off to atmosphere model..."
