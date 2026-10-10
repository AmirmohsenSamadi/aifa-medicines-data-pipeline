# Report Summary: Construction of an AIFA Dataset on Italian Medicines

## Objective
Build and analyse a structured dataset of medicines authorised in Italy, combining regulatory information from the Italian Medicines Agency (AIFA) with clinical information from each medicine's Summary of Product Characteristics (SmPC).

## Data collection and preprocessing
- Downloaded the official lists of Class A (over 10,000 entries) and Class H (over 2,000 entries) medicines from AIFA.
- Merged them into one dataset, keeping:
  - active ingredient
  - group description
  - product name and packaging
  - marketing authorisation holder
  - AIC code
  - equivalence group code
- Added `Class` and `URL` columns. No empty rows or duplicates were found.

## Clinical information extraction
- Queried the official AIFA API with each medicine's AIC code to retrieve its company code (`codiceSis`) and ATC code.
- Used these identifiers to build direct links to each SmPC PDF, then downloaded and parsed the documents.
- Extracted ten mandatory sections with text matching:
  - 4.1 therapeutic indications
  - 4.2 posology
  - 4.3 contraindications
  - 4.4 special warnings
  - 4.5 interactions
  - 4.6 fertility, pregnancy and lactation
  - 4.7 effects on driving
  - 4.8 undesirable effects
  - 4.9 overdose
  - 6.2 incompatibilities
- Headers were detected with rules combining the section number, its position at the start of a line and the first letter of the title, ignoring case and whitespace.
- Missing PDFs or undetectable sections were marked "not available", and the text was cleaned of icons and stray symbols.

## Final dataset and database
- One row per medicine (AIC code), saved as a UTF-8, comma-separated CSV.
- Imported into MySQL and normalised into four tables linked by AIC through foreign keys:
  - **Medicines:** active ingredient, group, ATC code, equivalence group
  - **Commercial_information:** product name, packaging, holder
  - **Consumption:** indications, dosage, pregnancy
  - **Contraindications:** warnings, interactions, side effects, overdose, incompatibilities
- SQL analyses:
  - medicines by equivalence group and by ATC class
  - medicines and products per manufacturer
  - dosage forms per active ingredient
  - an estimate of side-effect counts per active ingredient

## Power BI dashboard
- An interactive dashboard with two word clouds, a bar chart, a pie chart and a search bar.
- It shows the most frequent active ingredients, common therapeutic indications, undesirable effects and contraindications, with filters for exploring subsets.

## Challenges and solutions
- **Leading zeros:** Excel removed the leading zeros of AIC codes, so they were restored and kept as text.
- **Missing company code:** the code needed for PDF links wasn't in the lists, so it was retrieved from the AIFA API.
- **Unavailable PDFs and inconsistent headers:** marked "not available", with header-detection rules made stricter.
- **Unwanted symbols and very long fields:** cleaned during preprocessing, with long fields capped to stay within Excel's cell limit.
- **Wrong separator for MySQL:** the CSV was re-saved with comma separators.
- **Uninformative words in word clouds:** filtered out with a custom stop-word list.
