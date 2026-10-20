-- Phase 1 QC checks. Each row is one check:
--   n_flagged = records that fail or are worth a look, n_base = what they are counted out of.
-- "error" checks should be zero. "info" checks describe the data and are expected to be nonzero
-- in a synthetic file, and they belong in the README findings.

SELECT 'person_id is unique' AS check_name, 'error' AS severity,
       COUNT(*) - COUNT(DISTINCT person_id) AS n_flagged, COUNT(*) AS n_base
FROM cdm.person

UNION ALL
SELECT 'every person has exactly one observation period', 'error',
       (SELECT COUNT(*) FROM cdm.person p
        WHERE (SELECT COUNT(*) FROM cdm.observation_period o WHERE o.person_id = p.person_id) <> 1),
       (SELECT COUNT(*) FROM cdm.person)

UNION ALL
SELECT 'observation period end on or after start', 'error',
       COUNT(*) FILTER (WHERE observation_period_end_date < observation_period_start_date), COUNT(*)
FROM cdm.observation_period

UNION ALL
SELECT 'death date on or after birth', 'error',
       COUNT(*) FILTER (WHERE d.death_date < CAST(p.birth_datetime AS DATE)), COUNT(*)
FROM cdm.death d JOIN cdm.person p USING (person_id)

UNION ALL
SELECT 'beneficiaries dropped for a missing or invalid birth date', 'info',
       (SELECT COUNT(*) FROM stage.person_map) - (SELECT COUNT(*) FROM cdm.person),
       (SELECT COUNT(*) FROM stage.person_map)

UNION ALL
SELECT 'persons dropped from observation_period (death before first file year)', 'info',
       (SELECT COUNT(*) FROM cdm.person) - (SELECT COUNT(DISTINCT person_id) FROM cdm.observation_period),
       (SELECT COUNT(*) FROM cdm.person)

UNION ALL
SELECT 'beneficiaries whose sex differs across yearly files', 'info',
       COUNT(*) FILTER (WHERE n_sex > 1), COUNT(*)
FROM (SELECT DESYNPUF_ID, COUNT(DISTINCT BENE_SEX_IDENT_CD) AS n_sex FROM raw.beneficiary GROUP BY 1)

UNION ALL
SELECT 'beneficiaries whose birth date differs across yearly files', 'info',
       COUNT(*) FILTER (WHERE n_dob > 1), COUNT(*)
FROM (SELECT DESYNPUF_ID, COUNT(DISTINCT BENE_BIRTH_DT) AS n_dob FROM raw.beneficiary GROUP BY 1)

UNION ALL
SELECT 'beneficiaries whose race code differs across yearly files', 'info',
       COUNT(*) FILTER (WHERE n_race > 1), COUNT(*)
FROM (SELECT DESYNPUF_ID, COUNT(DISTINCT BENE_RACE_CD) AS n_race FROM raw.beneficiary GROUP BY 1)

UNION ALL
SELECT 'beneficiaries appearing in a yearly file after their death year', 'info',
       COUNT(DISTINCT b.DESYNPUF_ID), (SELECT COUNT(*) FROM cdm.death)
FROM raw.beneficiary b
JOIN stage.person_map m USING (DESYNPUF_ID)
JOIN cdm.death d ON d.person_id = m.person_id
WHERE b.file_year > year(d.death_date)

UNION ALL
SELECT 'inpatient claims starting after the death date', 'info',
       COUNT(*) FILTER (WHERE CAST(try_strptime(i.CLM_FROM_DT, '%Y%m%d') AS DATE) > d.death_date),
       COUNT(*)
FROM raw.inpatient i
JOIN stage.person_map m USING (DESYNPUF_ID)
JOIN cdm.death d ON d.person_id = m.person_id

UNION ALL
SELECT 'inpatient claims starting before the observation period', 'info',
       COUNT(*) FILTER (WHERE CAST(try_strptime(i.CLM_FROM_DT, '%Y%m%d') AS DATE) < o.observation_period_start_date),
       COUNT(*)
FROM raw.inpatient i
JOIN stage.person_map m USING (DESYNPUF_ID)
JOIN cdm.observation_period o ON o.person_id = m.person_id

UNION ALL
SELECT 'outpatient claims starting before the observation period', 'info',
       COUNT(*) FILTER (WHERE CAST(try_strptime(x.CLM_FROM_DT, '%Y%m%d') AS DATE) < o.observation_period_start_date),
       COUNT(*)
FROM raw.outpatient x
JOIN stage.person_map m USING (DESYNPUF_ID)
JOIN cdm.observation_period o ON o.person_id = m.person_id

UNION ALL
SELECT 'beneficiary-years with zero Part A and zero Part B coverage months', 'info',
       COUNT(*) FILTER (WHERE BENE_HI_CVRAGE_TOT_MONS = '0' AND BENE_SMI_CVRAGE_TOT_MONS = '0'),
       COUNT(*)
FROM raw.beneficiary

UNION ALL
SELECT 'inpatient claim rows with no matching beneficiary', 'info',
       COUNT(*) FILTER (WHERE m.person_id IS NULL), COUNT(*)
FROM raw.inpatient i LEFT JOIN stage.person_map m USING (DESYNPUF_ID)

UNION ALL
SELECT 'outpatient claim rows with no matching beneficiary', 'info',
       COUNT(*) FILTER (WHERE m.person_id IS NULL), COUNT(*)
FROM raw.outpatient o LEFT JOIN stage.person_map m USING (DESYNPUF_ID)

UNION ALL
SELECT 'carrier claim rows with no matching beneficiary', 'info',
       COUNT(*) FILTER (WHERE m.person_id IS NULL), COUNT(*)
FROM raw.carrier c LEFT JOIN stage.person_map m USING (DESYNPUF_ID)

UNION ALL
SELECT 'prescription drug event rows with no matching beneficiary', 'info',
       COUNT(*) FILTER (WHERE m.person_id IS NULL), COUNT(*)
FROM raw.pde x LEFT JOIN stage.person_map m USING (DESYNPUF_ID)
