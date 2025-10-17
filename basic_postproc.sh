#!/bin/bash

source ~/anaconda3/etc/profile.d/conda.sh
cd /home/mpas_uga/mpas/postproc/
conda run -n mpas_postproc --live-stream /home/mpas_uga/mpas/postproc/start_postproc.sh

