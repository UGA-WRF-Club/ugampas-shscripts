#!/bin/bash
# Used to generate static fields on a new mesh.
MPAS_DIR="$HOME/mpas/uga_mpas"
# NOT THE MODEL SOURCE DIRECTORY!

MET_DATA_DIR="$HOME/mpas/MPAS_Files/MET_DATA/GFS"

NAMELIST_TEMPLATE_DIR="$MPAS_DIR/templates/namelist"
STREAMS_TEMPLATE_DIR="$MPAS_DIR/templates/streams"

MESH_NAME="AthensScaled.grid.nc"
# --- End Configuration ---


# --- Main Script ---
echo "starting MPAS init_atmosphere static fields"

cd "$MPAS_DIR" || { echo "error: could not change to MPAS directory: $MPAS_DIR. Exiting."; exit 1; }
echo "navigated to $MPAS_DIR"

rm -f namelist.init_atmosphere streams.init_atmosphere
cp "$NAMELIST_TEMPLATE_DIR/namelist.init_atmosphere_00statics" ./namelist.init_atmosphere
cp "$STREAMS_TEMPLATE_DIR/streams.init_atmosphere_00statics" ./streams.init_atmosphere
echo "namelist and streams files are in place"

echo "updating stream input in the streams file..."

sed -i "s/AthensVarNew/${MESH_NAME%.grid.nc}/g" streams.init_atmosphere
echo "Namelist updated with start time: $new_start_time"

echo "cleaning up old logs and output files..."
rm -f AthensVar.static.nc log.init_atmosphere.*

echo -e "running init_atmosphere_model with 60 cores."
mpiexec -np 60 ./init_atmosphere_model >& log.init_atmosphere.0000.out

if grep -q "    Finished running the init_atmosphere core" log.init_atmosphere.0000.out; then
    echo -e "Static generation completed!!!"
else
    echo -e "Static generation may have failed. please check the log files"
fi
