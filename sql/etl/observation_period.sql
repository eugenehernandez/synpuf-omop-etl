-- OBSERVATION_PERIOD
-- SynPUF has no enrollment start and end dates, so this ETL uses a simple rule
-- (documented in docs/mapping_decisions.md):
--   start = January 1 of the first year the person appears in a beneficiary file
--   end   = December 31 of the last year they appear, cut off at the death date
-- People whose rule produces an end before the start are left out here and
-- counted by the QC step instead of being silently "fixed".

INSERT INTO cdm.observation_period
SELECT
  ROW_NUMBER() OVER (ORDER BY person_id) AS observation_period_id,
  person_id,
  start_date AS observation_period_start_date,
  end_date   AS observation_period_end_date,
  32880      AS period_type_concept_id
FROM (
  SELECT
    p.person_id,
    make_date(MIN(b.file_year), 1, 1) AS start_date,
    CASE
      WHEN d.death_date IS NOT NULL AND d.death_date < make_date(MAX(b.file_year), 12, 31)
        THEN d.death_date
      ELSE make_date(MAX(b.file_year), 12, 31)
    END AS end_date
  FROM raw.beneficiary b
  JOIN stage.person_map m USING (DESYNPUF_ID)
  JOIN cdm.person p ON p.person_id = m.person_id
  LEFT JOIN cdm.death d ON d.person_id = p.person_id
  GROUP BY p.person_id, d.death_date
)
WHERE end_date >= start_date;
