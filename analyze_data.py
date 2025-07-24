#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt

# Inlezen van de CSV
df = pd.read_csv("./processed_data/combined_data.csv", parse_dates=["timestamp"])
df = df.sort_values("timestamp")

# Check op voldoende datapunten
if df.shape[0] < 2:
    print("❌ Niet genoeg datapunten om trends te tonen.")
    exit(1)

# Grafiek
fig, ax1 = plt.subplots(figsize=(10, 5))
ax2 = ax1.twinx()

# Temperatuur op linker y-as
ax1.plot(
    df["timestamp"],
    df["temp_celsius"],
    color="red",
    marker="o",
    linestyle="-",
    label="Temperatuur (°C)"
)
ax1.set_ylabel("Temperatuur (°C)", color="red")
ax1.tick_params(axis="y", labelcolor="red")

# Energieprijs op rechter y-as
ax2.plot(
    df["timestamp"],
    df["energy_euro"],
    color="blue",
    marker="x",
    linestyle="--",
    label="Energieprijs (EUR)"
)
ax2.set_ylabel("Energieprijs (EUR)", color="blue")
ax2.tick_params(axis="y", labelcolor="blue")

# X-as: tijdstempels onderaan
ax1.set_xlabel("Tijdstip")
fig.autofmt_xdate(rotation=45)

# Titel
plt.title("Temperatuur en Energieprijs over Tijd")
ax1.grid(True)

# Legenda combineren
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc="upper left")

# Layout
plt.tight_layout()
plt.savefig("./reports/temp_vs_energy.png")
plt.show()
