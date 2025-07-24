#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
import os

# Laad de gecombineerde data
CSV_FILE = './processed_data/combined_data.csv'
OUTPUT_DIR = './reports'
GRAPH_FILE = os.path.join(OUTPUT_DIR, 'temp_vs_energy.png')

os.makedirs(OUTPUT_DIR, exist_ok=True)

df = pd.read_csv(CSV_FILE, parse_dates=['timestamp'])

# Alleen geldige rijen gebruiken
valid_df = df.dropna(subset=["timestamp", "temp_celsius", "energy_euro"])
valid_df = valid_df[valid_df["timestamp"].astype(str).str.len() > 5]  # filter korte/ongeldige timestamps

valid_df = valid_df.sort_values(by='timestamp')  # sorteer chronologisch

fig, ax1 = plt.subplots(figsize=(12, 6))
ax2 = ax1.twinx()

ax1.plot(valid_df['timestamp'], valid_df['temp_celsius'], label='Temperature (°C)', color='red', marker='o')
ax2.plot(valid_df['timestamp'], valid_df['energy_euro'], label='Energy Price (EUR)', color='blue', linestyle='--', marker='x')

ax1.set_xlabel('Timestamp')
ax1.set_ylabel('Temperature (°C)', color='red')
ax2.set_ylabel('Energy Price (EUR)', color='blue')

plt.title('Temperature and Energy Price over Time')
fig.autofmt_xdate(rotation=45)

# Legenda
handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(handles1 + handles2, labels1 + labels2, loc='upper left')

ax1.grid(True)
plt.tight_layout()
plt.savefig(GRAPH_FILE, bbox_inches='tight')
print(f"Lijnplot gegenereerd: {GRAPH_FILE}")
