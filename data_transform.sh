#!/bin/bash

ENERGY_FILE="./raw_data/energy-data.csv"
WEATHER_FILE="./raw_data/weer-data.csv"
OUTPUT_FILE="./processed_data/combined_data.csv"

# Zorg dat de output directory bestaat
mkdir -p "$(dirname "$OUTPUT_FILE")"
#header alleen toevoegen als bestand niet bestaat
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "timestamp,temp_celsius,energy_euro" > "$OUTPUT_FILE"
fi


tail -n +2 "$WEATHER_FILE" | while IFS=, read -r _ weather_json; do
    # JSON uitpakken
    clean_weather_json=$(echo "$weather_json" | sed 's/^"//;s/"$//' | sed 's/\\"/"/g')

    # Valideer en haal temperature + timestamp
    if ! echo "$clean_weather_json" | jq . >/dev/null 2>&1; then
        continue
    fi

    temp=$(echo "$clean_weather_json" | jq -r '.current.temperature_2m // empty')
    timestamp=$(echo "$clean_weather_json" | jq -r '.current.time // empty')

    if [[ -z "$temp" || -z "$timestamp" ]]; then
        continue
    fi

    # Bepaal heel uur → 12:45 → 12:00:00.000Z
    hour_key=$(date -u -d "$timestamp" +"%Y-%m-%dT%H:00:00.000Z")

    tail -n +2 "$ENERGY_FILE" | while IFS=, read -r _ energy_json; do
        clean_energy_json=$(echo "$energy_json" | sed 's/^"//;s/"$//' | sed 's/\\"/"/g')

        # Valideer JSON
        if ! echo "$clean_energy_json" | jq . >/dev/null 2>&1; then
            continue
        fi

        # Zoek prijs bij correcte tijd
        price=$(echo "$clean_energy_json" | jq -r --arg key "$hour_key" '.data[] | select(.st==$key) | .p // empty')

        if [[ -n "$price" ]]; then
            # Alleen toevoegen als deze combinatie nog niet bestaat
            if ! grep -q "^$timestamp,$temp,$price$" "$OUTPUT_FILE"; then
                echo "$timestamp,$temp,$price" >> "$OUTPUT_FILE"
            fi
            break
        fi
    done
done

echo "✅ Gecombineerde CSV opgeslagen in: $OUTPUT_FILE"
