# synpuf-omop-etl

A reproducible, validated conversion of the CMS 2008 to 2010 Data Entrepreneurs' Synthetic Public Use File (DE-SynPUF) to the OMOP Common Data Model v5.4, built in R and SQL on DuckDB.

> **Status.** Phase 1 of 6 (foundation tables). See the roadmap below.

## Background

Real-world evidence studies in pharmacoepidemiology increasingly run on claims data converted to a common data model, so that one analysis can run unchanged across many databases. The OMOP Common Data Model, maintained by the OHDSI community, is the most widely used of these.

Every conversion involves judgment calls. Claims data has no clean definition of when a person is observed, codes must be mapped across vocabularies, and visits have to be built from individual claim lines. These choices are rarely tested. This project builds the conversion openly, documents every decision, and then asks how sensitive cohort sizes and effect estimates are to those decisions.

## Data

**DE-SynPUF Sample 1** (CMS). A synthetic Medicare claims file covering about 116,000 beneficiaries, with beneficiary summaries, inpatient, outpatient, carrier, and prescription drug event claims. CMS built it so code written against it runs on real Medicare Limited Data Sets. The synthesis process deliberately breaks relationships between variables, so **clinical findings from this data are not meaningful.** The value here is the method.

**OHDSI Standardized Vocabularies** (Athena, release v20260829), with CPT-4 names added through the UMLS license utility.

Neither is redistributed in this repository. See *How to run* for download steps.

## Methods

The pipeline loads raw CSVs into a DuckDB database, then builds each CDM table with plain SQL files that can be read and reviewed on their own. R orchestrates the steps and runs the quality checks.

Each run produces the following outputs in `output/`.
- **Raw profile** with rows, beneficiaries, and date range per source file
- **Vocabulary summary** with concept counts per vocabulary, including a check that the CPT-4 names were filled in
- **Hard-coded concept check** verifying every concept ID in the SQL against the vocabulary
- **QC checks**, where *error* checks must be zero and *info* checks describe the data

Every mapping choice and its effect on the data is recorded in [docs/mapping_decisions.md](docs/mapping_decisions.md).

## Phase 1 results (Sample 1)

| CDM table | Rows |
|---|---|
| person | 116,352 |
| death | 5,461 |
| observation_period | 116,352 |

All error-level checks pass. The informative checks surfaced two issues that shape the next phases.
1. **4.7% of beneficiary-years show no Part A or Part B coverage** but are still counted as observed time under the simple observation period rule.
2. **536 inpatient and outpatient claims begin in late 2007**, before any observation period starts.

Both are documented as candidates for the sensitivity analysis.

## Repository layout

```
run_all.R                  builds the database and runs all checks
R/                         config, SQL runner helpers, package install
sql/ingest/                raw SynPUF and vocabulary loaders
sql/ddl/                   CDM v5.4 table definitions
sql/etl/                   one file per CDM table
sql/qc/                    profiling and quality checks
reference/                 hard-coded concept IDs with expected names
docs/                      mapping decisions
output/                    QC results from the latest run
```

## How to run

1. **Install R (4.3 or later) and RStudio.** Then run `R/00_install_packages.R` once.
2. **Download the vocabulary** from [Athena](https://athena.ohdsi.org) with SNOMED, ICD9CM, ICD9Proc, HCPCS, CPT4, NDC, RxNorm, RxNorm Extension, and ATC selected. Run the included `cpt.bat` (or `cpt.sh`) with a free [UMLS API key](https://uts.nlm.nih.gov) to fill in CPT-4 names.
3. **Download DE-SynPUF Sample 1** (all eight files) from [CMS](https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/DESample01) and unzip them.
4. **Arrange the folders** so the data sits next to the repo, or set `SYNPUF_DATA_ROOT` in `.Renviron`.
   ```
   CMS_mapping/
     OHDSI_Vocabularies_v20260829/
     synpuf_raw/sample_01/
     synpuf-omop-etl/        (this repo)
   ```
5. **Open `synpuf-omop-etl.Rproj` and run `run_all.R`.** The first run takes a few minutes while the vocabulary loads.

## Roadmap

1. ~~Setup and foundation tables (person, death, observation period)~~
2. Clinical event tables (visits, conditions, procedures, drugs) with vocabulary mapping
3. Mapping coverage report by domain
4. Validation with the OHDSI Data Quality Dashboard and against the official OHDSI SynPUF conversion
5. Pre-registered methods demonstration (new users of metformin versus sulfonylureas) with negative control outcomes
6. ETL sensitivity analysis, rerunning the study under alternative mapping decisions

## Limitations

DE-SynPUF is synthetic, and CMS deliberately altered relationships between variables to protect privacy. Results describe the behavior of the pipeline, not Medicare patients. Death dates are only accurate to the month. Observation periods are inferred because SynPUF has no enrollment dates.

## Acknowledgments

Built with Claude as an AI coding assistant. Design decisions, review, and interpretation are my own. The OHDSI [ETL-CMS](https://github.com/OHDSI/ETL-CMS) project, an earlier Python conversion of the same data, served as a reference.
