#!/bin/bash
# Generates lateral boundary conditions (LBCs) from NAM data
MPAS_DIR="$HOME/mpas/uga_mpas"

NAMELIST_TEMPLATE_DIR="$MPAS_DIR/templates/namelist"
STREAMS_TEMPLATE_DIR="$MPAS_DIR/templates/streams"

NAM_PREFIX="NAM"
# --- End Configuration ---


# --- Main Script ---
echo "LBC generation from NAM data is starting"

cd "$MPAS_DIR" || { echo "Error: Could not change to MPAS directory: $MPAS_DIR. Exiting."; exit 1; }
echo "navigated to $MPAS_DIR"
rm -f namelist.init_atmosphere streams.init_atmosphere
echo "setting up namelist and streams files for the LBC run..."
cp "$NAMELIST_TEMPLATE_DIR/namelist.init_atmosphere_02lbc" ./namelist.init_atmosphere
cp "$STREAMS_TEMPLATE_DIR/streams.init_atmosphere_02lbc" ./streams.init_atmosphere
echo "namelist and streams files are now configured for LBC generation"

echo "updating start/stop times and met prefix in the namelist..."
nam_files=($(ls -1 ./"$NAM_PREFIX":* | sort -V))
if [ ${#nam_files[@]} -eq 0 ]; then
    echo "error: could not find any NAM files in the run directory to determine start/stop times."
    exit 1
fi

first_nam_file="${nam_files[0]}"
last_nam_file="${nam_files[-1]}"

new_start_time=$(basename "$first_nam_file" | sed "s/${NAM_PREFIX}://")
new_stop_time=$(basename "$last_nam_file" | sed "s/${NAM_PREFIX}://")

sed -i -e "s#^ *config_start_time *=.*# config_start_time = '$new_start_time:00:00'#" \
       -e "s#^ *config_stop_time *=.*# config_stop_time = '$new_stop_time:00:00'#" \
       -e "s#^ *config_met_prefix *=.*# config_met_prefix = '$NAM_PREFIX'#" \
       namelist.init_atmosphere

echo "namelist updated successfully:"
echo "  start_time = $new_start_time"
echo "  stop_time  = $new_stop_time"
echo "  met_prefix = $NAM_PREFIX"

echo "cleaning up old logs and previous LBC files..."
rm -f log.init_atmosphere.*
rm -f lbc.*.nc
echo "cleanup complete"

echo -e "starting LBC run with 60 cores..."

mpiexec -np 60 ./init_atmosphere_model >& log.init_atmosphere.0000.out

if grep -q "    Finished running the init_atmosphere core" log.init_atmosphere.0000.out; then
    echo -e "LBC generation completed!!!"
else
    echo -e "LBC generation may have failed. Please check the log files"
fi


