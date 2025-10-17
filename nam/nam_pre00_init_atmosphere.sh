#!/bin/bash
# Parent script to setup IC/LBCs from current NAM data for UGA-MPAS
set -e

cd /home/mpas_uga/mpas/MPAS_Files/SCRIPTS
echo "(Preproc Parent) Starting MPAS preprocessing for NAM..."

echo "(Preproc Parent) Starting download of NAM data..."
./nam_pre01_download.sh $1 # argument determines how many hours of NAM data to download

echo "(Preproc Parent) Ungribbing NAM data..."
./nam_pre02_ungrib.sh

echo "(Preproc Parent) Running init_atmosphere for ICs..."
./nam_pre03_init_conds.sh

echo "(Preproc Parent) Running init_atmosphere for LBCs..."
./nam_pre04_lbc.sh

echo "(Preproc Parent) All done! Ready to pass off to atmosphere model..."

