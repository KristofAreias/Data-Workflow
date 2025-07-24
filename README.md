# README.md
## Proof-of-concept geautomatiseerde data workflow
Student: Kristof Areias
Studentennummer: 202186424
Klasgroep: 2E1

## README Structuur
- Toelichting
- Data
  - Stock URL
  - Polygon URL
  - Beschrijving data
- Directorystructuur
- Data bekijken
  - Markdown
  - PDF
  - PNG
- Overlopen workflow
  - start.sh
  - data_collect.sh
  - data_transform.sh
  - analyze_data.sh
  - raport_data.sh
- Extra's
  - testSH.sh
  - crontabTest.sh

## Toelichting
Voor mijn workflow-opdracht voer ik een onderzoek uit waarin ik de prijs van goud vergelijk met de openingsprijs van het aandeel Apple (AAPL). 
Om deze gegevens te verzamelen maak ik gebruik van GoldAPI voor de goudprijs en Polygon API voor aandeleninformatie. 
Het doel van dit onderzoek is om te analyseren of er enige correlatie bestaat tussen de prijs van goud en de opening van AAPL. 
Deze correlatie kan interessante inzichten bieden in hoe de markten op elkaar reageren of bepaalde trends aangeven.

Omdat de workflow geautomatiseerd moest worden, maak ik gebruik van crontab om het proces dagelijks uit te voeren. 
Crontab zorgt ervoor dat mijn script automatisch draait zonder handmatige tussenkomst. 
Elke dag wordt de data van de vorige dag opgehaald en verwerkt, omdat de Polygon API alleen historische gegevens aanbiedt en geen live data.
Opmerkelijk is ook dat in het weekend stock data niet op te vragen is, dit komt doordat de beursen sluiten in het weekend en feestdagen.
Hierdoor is bij de laatste uitvoering NaN als data meegegeven.

## Data
### Stock URL
- **STOCK**:
  - Aandeel ticker symbool
- **POLYGON_DATE**:
  - Datum volgens formaat YYYY-MM-DD
- **ADJUSTED**:
  - Aanpassing, standaard op true
- **POLYGON_API_KEY**:
  - Api sleutel die in apart .env bestand staat voor veiligheid
### Polygon URL
- **METAL**:
  - Metaalsoort afkorting
- **CURRENCY**:
  - Munteenheid volgens ISO 4217
- **GOLD_DATE**:
  - Datum volgens formaat YYYYMMDD
### Beschrijving data
- **Goud**:
  - Prijs van goud in USD op het opgehaalde moment.
- **Aandeel**:
  - Open prijs van AAPL (Apple Inc.) van de opgehaalde dag. Kon enkel opgehaald worden van gepaseerde dagen, daarom word steeds de data van gisteren opgehaald.
- **Automatisering**:
  - **Periode**:
    - De data werd elke dag opgehaald om 13:29 sinds 5/12/2024
  - **Bronnen**:
    - Met behulp van GoldApi en Polygon werden de data opgehaald.
   
  ## Directorystructuur
  data-workflow/
  - .github/workflows/
    - data_collect.yml
  - logs/
    - analyze_data.log
    - cron_log.log
    - data_collect.log
    - data_transform.log
    - raport_data.log
    - scripts_check.log
  - processed_data/
    - combined_data.csv
  - raw_data/
    - ...Gold data
    - ...Polygon data
  - reports/
    - report.md
    - report.pdf
    - XAU_VS_AAPL.png
  - .env
  - .gitignore
  - analyze_data.py
  - crontabTest.sh
  - data_collect.sh
  - data_transform.sh
  - raport_data.sh
  - README.md
  - start.sh
  - testSH.sh
 
## Data bekijken
Het hele project en alle data kan je terugvinden op mijn github. Surf hiervoor naar https://github.com/HoGentTIN/datalinux-labs-2425-zhebii/tree/main/data-workflow .
Onder de map "reports/" kan je 3 bestanden terugvinden die hieronder besproken worden. 
### Markdown
- Het eerste bestand is een Markdown bestand dat het report mooi samensteld en overzichtelijk weergeeft.
### PDF
- Als tweede bestand kan je een pdf versie bekijken van het Markdown bestand.
### PNG
- Ten laatste word er een png gemaakt die de grafiek weergeeft van de data.

## Overlopen workflow
### start.sh
De workflow begint bij het script "start.sh". Dit script word automatisch aangeroepen door crontab, elke dag om 13:29.
In dit startbestand worden de andere scripts 1 voor 1 aangeroepen en uitgevoerd zodat alles verloopt zoals het hoord.
Deze scripts worden hieronder besproken.
### data_collect.sh
Nadat het start.sh script is aangeroepen zal dit script als eerste uitgevoerd worden. Dit script maakt gebruik van ```curl```.
```curl``` roept beide api's aan zodat de data opgehaald word. Door foutafhandeling kom je snel te weten als hier iets fout loopt.
Er word voor elk script een log bijgehouden zodat errors zeker niet gemist worden, maar ook zodat je zeker bent dat het script wel is uitgevoerd.

Er worden variabelen gebruikt uit .env om de api sleutels niet te hoeven tonen. Verder worden er variabelen aangemaakt om het project robuuster te maken.
De opgehaalde data word in JSON-formaat onder map "raw_data" geplaatst. Deze folder wordt gemaakt indien deze er nog niet zou zijn, hetzelfde voor de log directory.
### data_transform.sh
In dit script word de opgehaalde data in de raw_data directory omgezet en gefiltert zodat enkel de nodige informatie overblijft. De overblijvende informatie word dan
overgeschreven naar "combined_data.csv" onder de processed_data directory. Ook hier word een log voor bijgehouden. 
### analyze_data.py
Dit python-script zet de data die in het combined_data.csv bestand is geschreven om naar een grafiek.
Hiervoor word mathplotlib en pandas gebruikt. Ik heb hier geprobeerd om variabelen te gebruiken uit data_collect om het project heel robuust te maken 
maar na vele problemen heb ik hier helaas geen succes mee gehad. De data word ingeladen met ```data = pd.read_csv(CSV_FILE)``` en daarna
door vele plt commandos in een grafiek gevormd. 

Als dit succesvol is uitgevoerd komt in het log bestand een bevestiging te staan. De uitgewerkte word als PNG onder
de map reports geplaatst met een passende titel door ```GRAPH_FILE = os.path.join(OUTPUT_DIR, "XAU_VS_AAPL.png")```.
### raport_data.sh
Het laatste script dat aangeroepen word is raport_data.sh. Hierin word een markdown bestand gegenereerd en vervolgens omgezet naar
pdf door pandoc. In het markdown bestand word een timestamp geplaatst bovenaan gevolgd door woorden met weinig betekenis om het wat op te vullen. 
Ook een link naar de png staat hierin zodat de grafiek meegegeven word. Eens de markdown gegenereerd is word dit gelogd en omgezet naar pdf.

Beide raportten zijn terug te vinden onder de map "reports". Alle logs van alle scripts, inclusief deze zijn uiteraard te vinden
onder de map "logs". Hierin kan je ook een log terugvinden van crontab. Ik doe dit zowel voor mezelf, om te zien of crontab wel is uitgevoerd maar
ook voor de lesgevers als bevestiging dat dit automatisch gebeurd.

## Extra's
### testSH.sh
Een klein scriptje dat alle testen op de bash-bestanden uitvoert. Dit scriptje maakt het zeer snel en heel gemakkelijk om in 1 keer alle scripten te testen.
### crontabTest.sh
Een nutteloos scriptje dat enkel maar gebruikt werd omdat ik enorm veel problemen ondervond met crontab. Ik heb heel veel troubleshooting moeten doen en dit scriptje heeft me hier
zeker in geholpen. Problemen zoals timezone, pathing na uitvoeren en uitvoeringsrechten waren de hoofdzaken van de problemen. 
