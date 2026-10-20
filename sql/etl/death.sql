-- DEATH
-- A death date can appear in more than one yearly file. Keep the earliest one,
-- and only for people who made it into cdm.person.

INSERT INTO cdm.death
SELECT
  p.person_id,
  MIN(CAST(try_strptime(b.BENE_DEATH_DT, '%Y%m%d') AS DATE)) AS death_date,
  NULL  AS death_datetime,
  32810 AS death_type_concept_id,
  0     AS cause_concept_id,
  NULL  AS cause_source_value,
  0     AS cause_source_concept_id
FROM raw.beneficiary b
JOIN stage.person_map m USING (DESYNPUF_ID)
JOIN cdm.person p ON p.person_id = m.person_id
WHERE try_strptime(b.BENE_DEATH_DT, '%Y%m%d') IS NOT NULL
GROUP BY p.person_id;
