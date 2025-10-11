#!/bin/bash
# Adapted from UGA-WRF ungrib script
WPS_DIR="$HOME/mpas/WPS"

GRIB_DIR="$HOME/mpas/MPAS_Files/DATA/GFS"

MET_OUTPUT_DIR="$HOME/mpas/MPAS_Files/MET_DATA/GFS"
# --- End Configuration ---


# --- Main Script ---
echo "starting ungrib process for GFS data..."

echo "changing to WPS directory: $WPS_DIR"
cd "$WPS_DIR" || { echo "error: could not change to WPS directory. exiting."; exit 1; }

echo "updating namelist.wps..."
hour_utc=$(date -u +"%H")
utc_date=$(date -u +"%Y%m%d")
if (( hour_utc >= 4 && hour_utc < 10 )); then run_hour="00"
elif (( hour_utc >= 10 && hour_utc < 16 )); then run_hour="06"
elif (( hour_utc >= 16 && hour_utc < 22 )); then run_hour="12"
else
    run_hour="18"
    if (( hour_utc < 4 )); then utc_date=$(date -u -d "yesterday" +"%Y%m%d"); fi
fi
echo "model run: ${utc_date} at ${run_hour}Z"
grib_files=("$GRIB_DIR"/gfs.*.f*)
if [ ${#grib_files[@]} -eq 0 ] || [ ! -f "${grib_files[0]}" ]; then
    echo "Error: no GRIB files found in $GRIB_DIR. use gfs_download.sh first"
    exit 1
fi

sorted_grib_files=($(for f in "${grib_files[@]}"; do echo "$f"; done | sort -V))
first_fhr_str=$(basename "${sorted_grib_files[0]}" | grep -o 'f[0-9]*$' | sed 's/f//')
last_fhr_str=$(basename "${sorted_grib_files[-1]}" | grep -o 'f[0-9]*$' | sed 's/f//')
start_fhr=$((10#$first_fhr_str))
end_fhr=$((10#$last_fhr_str))
echo "forecast hours ranging from F${start_fhr} to F${end_fhr}"

run_timestamp_str="${utc_date} ${run_hour}:00:00 UTC"
new_start_date=$(date -u -d "$run_timestamp_str + $start_fhr hours" +"%Y-%m-%d_%H:%M:%S")
new_end_date=$(date -u -d "$run_timestamp_str + $end_fhr hours" +"%Y-%m-%d_%H:%M:%S")
new_interval=3600

echo "updating namelist.wps with:"
echo "  start_date = '$new_start_date'"
echo "  end_date   = '$new_end_date'"
echo "  interval   = $new_interval"
echo "  prefix     = 'GFS'"
cp namelist.wps namelist.wps.bak
sed -i -e "s#^ *start_date *=.*# start_date = '$new_start_date',#" \
       -e "s#^ *end_date *=.*# end_date = '$new_end_date',#" \
       -e "s#^ *interval_seconds *=.*# interval_seconds = $new_interval,#" \
       -e "s#^ *prefix *=.*# prefix = 'GFS',#" \
       namelist.wps

echo "cleaning up files from previous runs..."
rm -f GRIBFILE.*
rm -f Vtable
rm -f GFS:*
rm -f PFILE:*

mkdir -p "$MET_OUTPUT_DIR"
rm -f "$MET_OUTPUT_DIR"/*
echo "output directory prepped: $MET_OUTPUT_DIR"

echo "Linking Vtable.GFS..."
ln -sf ./ungrib/Variable_Tables/Vtable.GFS Vtable
if [ ! -L "Vtable" ]; then
    echo "Vtable link failed!"
    exit 1
fi

echo "linking gribbed files from $GRIB_DIR"
./link_grib.csh "$GRIB_DIR"/gfs.*.f*
if [ $? -ne 0 ]; then
    echo "Error: link_grib.csh failed. Are there GRIB files in $GRIB_DIR?"
    exit 1
fi

echo "running ungrib"
./ungrib.exe >& ungrib.log

if grep -q "Successful completion of ungrib" ungrib.log; then
    echo "ungrib finished!"
    
    echo "moving GFS:* files to $MET_OUTPUT_DIR"
    mv GFS:* "$MET_OUTPUT_DIR"/
    
    if [ $? -eq 0 ]; then
        echo "moved your files"
    else
        echo "can't find your files to move!"
    fi
else
    echo "ungrib failed! :-( please check the ungrib.log file in $WPS_DIR for details."
    exit 1
fi

echo "yayyyy your ungribbed files are in $MET_OUTPUT_DIR"
