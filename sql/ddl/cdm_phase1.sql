-- OMOP CDM v5.4 tables needed for Phase 1 (person, observation_period, death).
-- Column names and types follow the CDM v5.4 specification. Phase 2 will add the
-- event tables (visit_occurrence, condition_occurrence, drug_exposure, procedure_occurrence).

CREATE SCHEMA IF NOT EXISTS cdm;

CREATE OR REPLACE TABLE cdm.person (
  person_id                   BIGINT  NOT NULL,
  gender_concept_id           INTEGER NOT NULL,
  year_of_birth               INTEGER NOT NULL,
  month_of_birth              INTEGER,
  day_of_birth                INTEGER,
  birth_datetime              TIMESTAMP,
  race_concept_id             INTEGER NOT NULL,
  ethnicity_concept_id        INTEGER NOT NULL,
  location_id                 BIGINT,
  provider_id                 BIGINT,
  care_site_id                BIGINT,
  person_source_value         VARCHAR,
  gender_source_value         VARCHAR,
  gender_source_concept_id    INTEGER,
  race_source_value           VARCHAR,
  race_source_concept_id      INTEGER,
  ethnicity_source_value      VARCHAR,
  ethnicity_source_concept_id INTEGER
);

CREATE OR REPLACE TABLE cdm.observation_period (
  observation_period_id         BIGINT  NOT NULL,
  person_id                     BIGINT  NOT NULL,
  observation_period_start_date DATE    NOT NULL,
  observation_period_end_date   DATE    NOT NULL,
  period_type_concept_id        INTEGER NOT NULL
);

CREATE OR REPLACE TABLE cdm.death (
  person_id               BIGINT  NOT NULL,
  death_date              DATE    NOT NULL,
  death_datetime          TIMESTAMP,
  death_type_concept_id   INTEGER,
  cause_concept_id        INTEGER,
  cause_source_value      VARCHAR,
  cause_source_concept_id INTEGER
);
