-- Vocabulary summary for the vocabularies this ETL uses: concept counts, how many
-- are standard, and how many have a name. CPT4 names are filled in by the cpt4.jar
-- step (UMLS key), so a low named count for CPT4 means that step did not run.

SELECT
  c.vocabulary_id,
  v.vocabulary_version,
  COUNT(*)                                                AS n_concepts,
  COUNT(*) FILTER (WHERE c.standard_concept = 'S')        AS n_standard,
  COUNT(*) FILTER (WHERE coalesce(c.concept_name, '') <> '') AS n_named
FROM cdm.concept c
LEFT JOIN cdm.vocabulary v USING (vocabulary_id)
WHERE c.vocabulary_id IN ('SNOMED', 'ICD9CM', 'ICD9Proc', 'HCPCS', 'CPT4', 'NDC',
                          'RxNorm', 'RxNorm Extension', 'ATC', 'Gender', 'Race',
                          'Ethnicity', 'Visit', 'Type Concept')
GROUP BY c.vocabulary_id, v.vocabulary_version
ORDER BY c.vocabulary_id
