#!/bin/bash
# cd /home/hogent/datalinux-labs-2425-zhebii/data-workflow || exit
#Vars
OUTPUT_DIR="./raw_data"
LOG_DIR="./logs"
LOG_FILE="./logs/data_collect.log"
WEATHER_API_URL="https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current=temperature_2m"
ENERGY_API_URL="https://spot.56k.guru/api/v2/hass?currency=EUR&area=BE&decimals=5"
#Timestamp
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

#Directories aanmaken als ze nog niet bestaan
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

#Bestandsnamen zetten
WEER_OUTPUT="${OUTPUT_DIR}/weer-data.csv"
ENERGY_OUTPUT="${OUTPUT_DIR}/energy-data.csv"

if [[ ! -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE"
    echo "[$(date)] Logbestand aangemaakt." >> "$LOG_FILE"
fi

#Data ophalen weer
raw_data=$(curl -s "$WEATHER_API_URL")
if [[ ! -f "$WEER_OUTPUT" ]]; then
    echo "timestamp,raw_json" > "$WEER_OUTPUT"
fi
echo "$TIMESTAMP,\"$raw_data\"" >> "$WEER_OUTPUT"
echo "[$(date)] Weer data toegevoegd aan $WEER_OUTPUT" >> "$LOG_FILE"

#Data ophalen energy
raw_data=$(curl -s "$ENERGY_API_URL")
if [[ ! -f "$ENERGY_OUTPUT" ]]; then
    echo "timestamp,raw_json" > "$ENERGY_OUTPUT"
fi
echo "$TIMESTAMP,\"$raw_data\"" >> "$ENERGY_OUTPUT"
echo "[$(date)] Energy data toegevoegd aan $ENERGY_OUTPUT" >> "$LOG_FILE"
