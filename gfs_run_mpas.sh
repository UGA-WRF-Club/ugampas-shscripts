#!/bin/bash
# You MUST run the preprocessing scripts first (gfs_pre0*.sh)
MPAS_DIR="$HOME/mpas/uga_mpas"

GFS_PREFIX="GFS"
# --- End Configuration ---


# --- Main Script ---
echo "prepping atmosphere model"

cd "$MPAS_DIR" || { echo "error: could not change to MPAS directory: $MPAS_DIR. Exiting."; exit 1; }
echo "navigated to $MPAS_DIR"

echo "updating config_start_time in namelist.atmosphere..."
first_gfs_file=$(ls -1 ./"$GFS_PREFIX":* | sort -V | head -n 1)
if [ -z "$first_gfs_file" ]; then
    echo "error: Could not find any GFS files to determine the start time."
    exit 1
fi

new_start_time=$(basename "$first_gfs_file" | sed "s/${GFS_PREFIX}://")

# Use sed to replace the placeholder start time in the namelist.
sed -i "s#^ *config_start_time *=.*# config_start_time = '$new_start_time:00:00'#" namelist.atmosphere
echo "namelist updated with start time: $new_start_time"

echo "preparing output directory and cleaning up old logs..."
mkdir -p outputs
rm -f outputs/*
rm -f log.atmosphere.*
echo "Cleanup complete."

echo -e "running the atmosphere model with 60 cores!"

mpiexec -np 60 ./atmosphere_model >& log.atmosphere.0000.out

if grep -q "    Finished running the atmosphere core" log.atmosphere.0000.out; then
    echo -e "model run completed!!! Yay!!!"
else
    echo -e "model may have failed. please check the log files"
fi
