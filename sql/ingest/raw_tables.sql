-- Load the DE-SynPUF CSV files into a raw schema.
-- Every column is read as text (all_varchar) so codes keep their leading zeros
-- (ICD-9 codes, NDC codes, HCPCS). Dates are converted later, in the ETL step.
-- @raw_dir is replaced by the R runner with the folder holding the unzipped CSVs.

CREATE SCHEMA IF NOT EXISTS raw;

-- Beneficiary summary: one file per year (2008, 2009, 2010), stacked with a file_year column
CREATE OR REPLACE TABLE raw.beneficiary AS
SELECT
  CAST(regexp_extract(filename, '(2008|2009|2010)_Beneficiary', 1) AS INTEGER) AS file_year,
  * EXCLUDE (filename)
FROM read_csv('@raw_dir/**/*Beneficiary_Summary*.csv',
              all_varchar = true, union_by_name = true, filename = true, header = true);

CREATE OR REPLACE TABLE raw.inpatient AS
SELECT * FROM read_csv('@raw_dir/**/*Inpatient_Claims*.csv',
                       all_varchar = true, union_by_name = true, header = true);

CREATE OR REPLACE TABLE raw.outpatient AS
SELECT * FROM read_csv('@raw_dir/**/*Outpatient_Claims*.csv',
                       all_varchar = true, union_by_name = true, header = true);

-- Carrier claims arrive split in two files (1A and 1B), read together here
CREATE OR REPLACE TABLE raw.carrier AS
SELECT * FROM read_csv('@raw_dir/**/*Carrier_Claims*.csv',
                       all_varchar = true, union_by_name = true, header = true);

CREATE OR REPLACE TABLE raw.pde AS
SELECT * FROM read_csv('@raw_dir/**/*Prescription_Drug_Events*.csv',
                       all_varchar = true, union_by_name = true, header = true);
