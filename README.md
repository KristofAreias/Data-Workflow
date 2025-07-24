## Proof-of-concept geautomatiseerde data workflow

**Student**: Kristof Areias  
**Studentennummer**: 202186424  
**Klasgroep**: 2E1

---

## README Structuur

- Toelichting
- Data
- Directorystructuur
- Scripts en hun werking
- Data visualisatie
- GitHub Actions Automatisering
- Extra’s
- Slot

---

## Toelichting

Voor deze workflow-opdracht onderzoek ik de mogelijke invloed van temperatuur op energieprijzen.  
Hiervoor verzamel ik elk uur gegevens via twee API’s:

- **Open-Meteo**: levert temperatuurmetingen op het moment van ophalen.
- **spot.56k.guru**: geeft de uurprijs van elektriciteit in België.

Deze data wordt automatisch verwerkt, gecombineerd, geanalyseerd en gerapporteerd. De workflow is geautomatiseerd met **GitHub Actions**, waardoor elk uur de scripts draaien zonder handmatige tussenkomst. Uiteindelijk wordt een **PDF-rapport** gegenereerd met daarin een grafiek van de temperatuur tegenover de energieprijs.

---

## Data

### API Bronnen

- **Weerdata**: [Open-Meteo API](https://open-meteo.com/)
- **Energieprijzen**: [spot.56k.guru API](https://spot.56k.guru/)

### Beschrijving data

- **Temperatuur**: Wordt elk uur opgehaald voor een vaste locatie (bijvoorbeeld Berlijn).
- **Energieprijs**: Prijs in euro per kWh, per uur voor België.
- **Combinatie**: Data wordt samengevoegd op basis van tijdstempels, zodat bij elke temperatuurmeting de juiste energieprijs gezocht wordt.

---

## Directorystructuur

```
data-workflow/
├── .github/workflows/
│   └── data_collect.yml
├── logs/
│   ├── data_collect.log
│   └── raport_data.log
├── processed_data/
│   └── combined_data.csv
├── raw_data/
│   ├── energy-data.csv
│   └── weer-data.csv
├── reports/
│   ├── report.md
│   ├── report.pdf
│   └── temp_vs_energy.png
├── .gitignore
├── analyze_data.py
├── data_collect.sh
├── data_transform.sh
├── raport_data.sh
└── README.md
```

---

## Scripts en hun werking

### `Makefile`

Startpunt van de workflow. Wordt elke dag (of elk uur) automatisch uitgevoerd via GitHub Actions. Roept de andere scripts aan in volgorde.

### `data_collect.sh`

Verzamelt de ruwe data:

- Roept beide API’s aan via `curl`.
- Slaat de ruwe JSON-data op in `raw_data/`.
- Logt fouten of successen naar `logs/data_collect.log`.

### `data_transform.sh`

Verwerkt de ruwe JSON-data:

- Filtert alleen de nodige velden (tijdstip en temperatuur/prijs).
- Combineert temperatuurmetingen met bijhorende energieprijzen op basis van uur.
- Voegt deze toe aan `processed_data/combined_data.csv` (zonder duplicaten).

### `analyze_data.py`

Maakt een visualisatie:

- Leest de gecombineerde CSV in.
- Genereert een lijnplot met tijd op de x-as, temperatuur en energieprijs op de y-assen.
- Slaat de grafiek op als PNG in `reports/temp_vs_energy.png`.
- Logt naar `logs/analyze_data.log`.

### `raport_data.sh`

Genereert het rapport:

- Schrijft een markdown-bestand (`report.md`) met een timestamp, toelichting en grafiek.
- Converteert het naar PDF (`report.pdf`) via `pandoc`.
- Logt naar `logs/raport_data.log`.

---

## Data visualisatie

Onder `reports/` vind je de output van de workflow:

- `report.md`: overzichtelijk rapport in Markdown.
- `report.pdf`: printklare PDF-versie van het rapport.
- `temp_vs_energy.png`: grafiek die temperatuur en energieprijs toont over tijd.

---

## Automatisering via GitHub Actions

De volledige workflow draait automatisch via een GitHub Actions YAML-bestand:

```yaml
.github/workflows/data_collect.yml
```

- Triggert elk uur
- Voert de shell- en Python-scripts uit in de juiste volgorde
- Verwerkt nieuwe data automatisch

GitHub Actions zorgt ervoor dat:

- De data altijd up-to-date is
- Je geen handmatige cronjobs hoeft in te stellen
- Rapportage consistent gebeurt

---

## Extra's

---

## Slot

Het hele project is beschikbaar op GitHub:  
🔗 [**https://github.com/KristofAreias/Data-Workflow**](https://github.com/KristofAreias/Data-Workflow)

Met deze geautomatiseerde workflow toon ik aan hoe publieke data gecombineerd en gevisualiseerd kan worden om inzichten te verkrijgen in hoe temperatuur mogelijk invloed heeft op de uurprijs van energie.
