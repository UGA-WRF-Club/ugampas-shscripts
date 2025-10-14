#!/bin/bash
# 
MPAS_DIR="$HOME/mpas/uga_mpas"
# NOT THE MODEL SOURCE DIRECTORY!

MET_DATA_DIR="$HOME/mpas/MPAS_Files/MET_DATA/GFS"

NAMELIST_TEMPLATE_DIR="$MPAS_DIR/templates/namelist"
STREAMS_TEMPLATE_DIR="$MPAS_DIR/templates/streams"

GFS_PREFIX="GFS"
# --- End Configuration ---


# --- Main Script ---
echo "starting MPAS init_atmosphere init conds"

cd "$MPAS_DIR" || { echo "error: could not change to MPAS directory: $MPAS_DIR. exiting!"; exit 1; }
echo "navigated to $MPAS_DIR"

echo "moving GFS met data from $MET_DATA_DIR..."
if [ -z "$(ls -A $MET_DATA_DIR)" ]; then
    echo "error: no met data found in $MET_DATA_DIR. did the ungrib script run successfully?"
    exit 1
fi
rm -f namelist.init_atmosphere streams.init_atmosphere GFS:*
cp "$MET_DATA_DIR"/* .
echo "met data moved successfully."

cp "$NAMELIST_TEMPLATE_DIR/namelist.init_atmosphere_01inits" ./namelist.init_atmosphere
cp "$STREAMS_TEMPLATE_DIR/streams.init_atmosphere_01inits" ./streams.init_atmosphere
echo "namelist and streams files are in place"

echo "updating config_start_time in the namelist..."
first_gfs_file=$(ls -1 ./"$GFS_PREFIX":* | head -n 1)
if [ -z "$first_gfs_file" ]; then
    echo "error: could not find any GFS files with prefix '$GFS_PREFIX' to determine start time."
    exit 1
fi

new_start_time=$(basename "$first_gfs_file" | sed "s/${GFS_PREFIX}://")

sed -i "s#^ *config_start_time *=.*# config_start_time = '$new_start_time:00:00'#" namelist.init_atmosphere
echo "namelist updated with start time: $new_start_time"

echo "cleaning up old logs and output files..."
rm -f *.init.nc log.init_atmosphere.*

echo -e "running init_atmosphere_model with 60 cores."

mpiexec -np 60 ./init_atmosphere_model >& log.init_atmosphere.0000.out

if grep -q "    Finished running the init_atmosphere core" log.init_atmosphere.0000.out; then
    echo -e "IC generation completed!!!"
else
    echo -e "IC generation may have failed. please check the log files"
fi
