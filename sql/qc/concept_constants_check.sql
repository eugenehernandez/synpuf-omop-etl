-- Verify every concept_id hard-coded in the ETL against the loaded vocabulary.
-- A row passes when the concept exists, has the expected name and domain, and is
-- a standard concept. concept_id 0 ("No matching concept") is skipped by design.
-- @ref_dir is replaced by the R runner.

SELECT
  r.source_field,
  r.source_code,
  r.concept_id,
  r.expected_concept_name,
  c.concept_name     AS vocab_concept_name,
  c.domain_id        AS vocab_domain_id,
  c.standard_concept AS vocab_standard_concept,
  CASE
    WHEN c.concept_id IS NULL                       THEN 'FAIL concept not found'
    WHEN c.concept_name <> r.expected_concept_name  THEN 'FAIL name differs'
    WHEN c.domain_id <> r.domain_id                 THEN 'FAIL domain differs'
    WHEN coalesce(c.standard_concept, '') <> 'S'    THEN 'FAIL not standard'
    ELSE 'pass'
  END AS result
FROM read_csv('@ref_dir/concept_constants.csv', header = true, all_varchar = true) r
LEFT JOIN cdm.concept c ON c.concept_id = CAST(r.concept_id AS INTEGER)
WHERE r.concept_id <> '0'
ORDER BY r.source_field, r.source_code
