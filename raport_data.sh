#!/bin/bash

# Variabelen
OUTPUT_DIR="./reports"
GRAPH_FILE="${OUTPUT_DIR}/temp_vs_energy.png"
CSV_FILE="./processed_data/combined_data.csv"
LOG_OUTPUT="./logs/raport_data.log"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Map aanmaken
mkdir -p "$OUTPUT_DIR"

REPORT_MD="${OUTPUT_DIR}/report.md"
REPORT_PDF="${OUTPUT_DIR}/report.pdf"

# Tel het aantal datarijen
rowcount=$(awk -F, 'END{print NR-1}' "$CSV_FILE")

if [ "$rowcount" -le 1 ]; then
    # Te weinig data voor statistiek of plot
    cat <<EOL > "$REPORT_MD"
# Analysis report
Generated on: $timestamp

## Overview
Niet genoeg data om statistiek of trends te berekenen. Voeg meer datapunten toe.

## Data
| Timestamp       | Temperature (°C) | Energy Price (EUR) |
EOL

    while IFS=',' read -r timestamp temp price; do
      if [[ "$timestamp" != "timestamp" ]]; then
        echo "| $timestamp | $temp | $price |" >> "$REPORT_MD"
      fi
    done < "$CSV_FILE"

else
    # Statistieken berekenen (met veilige fallback naar 0)
    energy_mean=$(awk -F, 'NR>1 && $3 != "" {sum+=$3; count++} END {if(count>0) print sum/count; else print 0}' "$CSV_FILE")
    energy_std=$(awk -F, -v mean="$energy_mean" 'NR>1 && $3 != "" {sum+=($3-mean)^2; count++} END {if(count>0) print sqrt(sum/count); else print 0}' "$CSV_FILE")
    temp_mean=$(awk -F, 'NR>1 && $2 != "" {sum+=$2; count++} END {if(count>0) print sum/count; else print 0}' "$CSV_FILE")
    temp_std=$(awk -F, -v mean="$temp_mean" 'NR>1 && $2 != "" {sum+=($2-mean)^2; count++} END {if(count>0) print sqrt(sum/count); else print 0}' "$CSV_FILE")

    # Correlatie berekenen
    correlation=$(awk -F, 'NR>1 && $2 != "" && $3 != "" {
        x+=$2; y+=$3; xx+=$2*$2; yy+=$3*$3; xy+=$2*$3; n++
    } END {
        if (n>1 && (n*xx - x*x)*(n*yy - y*y) > 0)
            print (n*xy - x*y)/sqrt((n*xx - x*x)*(n*yy - y*y));
        else
            print 0
    }' "$CSV_FILE")

    # Markdown rapport genereren
    cat <<EOL > "$REPORT_MD"
# Analysis report
Generated on: $timestamp

## Overview
This report analyzes the relationship between temperature (°C) and energy price (EUR).

## Graph
![Temperature vs Energy Price](${GRAPH_FILE})

## Summary statistics
- **Temperature**: Mean = ${temp_mean}, Std Dev = ${temp_std}
- **Energy Price**: Mean = ${energy_mean}, Std Dev = ${energy_std}
- **Correlation (Pearson)**: ${correlation}

## Data
| Timestamp       | Temperature (°C) | Energy Price (EUR) |
EOL

    while IFS=',' read -r timestamp temp price; do
      if [[ "$timestamp" == "timestamp" ]] || [[ -z "$timestamp" || -z "$temp" || -z "$price" ]]; then
        continue
      fi
      echo "| $timestamp | $temp | $price |" >> "$REPORT_MD"
    done < "$CSV_FILE"

fi

# Markdown naar PDF met pandoc
if pandoc "$REPORT_MD" -o "$REPORT_PDF" --pdf-engine=weasyprint; then
    echo "[$(date)] PDF report generated: $REPORT_PDF" >> "$LOG_OUTPUT"
else
    echo "[$(date)] Failed to generate PDF report." >> "$LOG_OUTPUT"
    exit 1
fi
