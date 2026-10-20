-- PERSON
-- One row per beneficiary (DESYNPUF_ID). A beneficiary appears in up to three
-- yearly files, and the synthetic data can disagree across years, so demographics
-- come from the most recent year in which the person appears (see docs/mapping_decisions.md).

CREATE SCHEMA IF NOT EXISTS stage;

-- Crosswalk from the SynPUF id to an integer person_id, reused by every later table
CREATE OR REPLACE TABLE stage.person_map AS
SELECT
  ROW_NUMBER() OVER (ORDER BY DESYNPUF_ID) AS person_id,
  DESYNPUF_ID
FROM (SELECT DISTINCT DESYNPUF_ID FROM raw.beneficiary WHERE DESYNPUF_ID IS NOT NULL);

CREATE OR REPLACE TABLE stage.bene_latest AS
SELECT *
FROM (
  SELECT
    b.*,
    ROW_NUMBER() OVER (PARTITION BY b.DESYNPUF_ID ORDER BY b.file_year DESC) AS rn
  FROM raw.beneficiary b
)
WHERE rn = 1;

INSERT INTO cdm.person
SELECT
  m.person_id,
  CASE b.BENE_SEX_IDENT_CD WHEN '1' THEN 8507 WHEN '2' THEN 8532 ELSE 0 END AS gender_concept_id,
  year(try_strptime(b.BENE_BIRTH_DT, '%Y%m%d'))   AS year_of_birth,
  month(try_strptime(b.BENE_BIRTH_DT, '%Y%m%d'))  AS month_of_birth,
  day(try_strptime(b.BENE_BIRTH_DT, '%Y%m%d'))    AS day_of_birth,
  try_strptime(b.BENE_BIRTH_DT, '%Y%m%d')         AS birth_datetime,
  CASE b.BENE_RACE_CD WHEN '1' THEN 8527 WHEN '2' THEN 8516 ELSE 0 END AS race_concept_id,
  CASE WHEN b.BENE_RACE_CD = '5' THEN 38003563 ELSE 38003564 END        AS ethnicity_concept_id,
  NULL AS location_id,
  NULL AS provider_id,
  NULL AS care_site_id,
  b.DESYNPUF_ID        AS person_source_value,
  b.BENE_SEX_IDENT_CD  AS gender_source_value,
  0                    AS gender_source_concept_id,
  b.BENE_RACE_CD       AS race_source_value,
  0                    AS race_source_concept_id,
  b.BENE_RACE_CD       AS ethnicity_source_value,
  0                    AS ethnicity_source_concept_id
FROM stage.bene_latest b
JOIN stage.person_map m USING (DESYNPUF_ID)
WHERE try_strptime(b.BENE_BIRTH_DT, '%Y%m%d') IS NOT NULL;
