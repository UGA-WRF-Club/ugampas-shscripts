#!/bin/bash
# Downloads data from the 3km NAM CONUS Nest.
DATA_DIR="/home/mpas_uga/mpas/MPAS_Files/DATA/NAM3k"
START_FHR=0
END_FHR=$1 # takes in a number of hours to download as argument
# --- End Configuration ---

# --- Main Script ---
mkdir -p "$DATA_DIR"
cd "$DATA_DIR" || exit
rm -f nam.*

hour_utc=$(date -u +"%H")
utc_date=$(date -u +"%Y%m%d")

echo "Current UTC date is: $utc_date"
echo "Current UTC hour is: $hour_utc"

if (( hour_utc >= 2 && hour_utc < 8 )); then run_hour="00"
elif (( hour_utc >= 8 && hour_utc < 14 )); then run_hour="06"
elif (( hour_utc >= 14 && hour_utc < 20 )); then run_hour="12"
else
    run_hour="18"
    if (( hour_utc < 2 )); then
        utc_date=$(date -u -d "yesterday" +"%Y%m%d")
    fi
fi

echo "Selected NAM run: ${run_hour}Z for date $utc_date"

BASE_URL="https://nomads.ncep.noaa.gov/pub/data/nccf/com/nam/prod/nam.${utc_date}/"

echo "Downloading NAM 3km Nest forecast hours from F${START_FHR} to F${END_FHR}..."
for fhr_num in $(seq $START_FHR $END_FHR); do
    fhr=$(printf "%02d" $fhr_num)
    
    FILENAME="nam.t${run_hour}z.conusnest.hiresf${fhr}.tm00.grib2"
    FULL_URL="${BASE_URL}/${FILENAME}"
    
    echo "Queueing download: ${FILENAME}"

    wget -c "$FULL_URL" &
done

wait

echo "All NAM 3km files downloaded successfully to ${DATA_DIR}"


