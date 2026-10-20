-- Load the OHDSI standardized vocabularies (Athena download) into the cdm schema.
-- Athena files are tab separated with no quoting, and some concept names contain
-- stray quote marks, so quoting and escaping are turned off. Dates are YYYYMMDD.
-- Column types follow the OMOP CDM v5.4 DDL. concept_code stays text (codes like 0001M).
-- @vocab_dir is replaced by the R runner. This step takes a few minutes, so the
-- runner skips it when the vocabulary is already loaded.

CREATE SCHEMA IF NOT EXISTS cdm;

CREATE OR REPLACE TABLE cdm.concept AS
SELECT * FROM read_csv('@vocab_dir/CONCEPT.csv', delim = '\t', quote = '', escape = '',
  header = true, dateformat = '%Y%m%d',
  columns = {'concept_id': 'INTEGER', 'concept_name': 'VARCHAR', 'domain_id': 'VARCHAR',
             'vocabulary_id': 'VARCHAR', 'concept_class_id': 'VARCHAR',
             'standard_concept': 'VARCHAR', 'concept_code': 'VARCHAR',
             'valid_start_date': 'DATE', 'valid_end_date': 'DATE', 'invalid_reason': 'VARCHAR'});

CREATE OR REPLACE TABLE cdm.concept_relationship AS
SELECT * FROM read_csv('@vocab_dir/CONCEPT_RELATIONSHIP.csv', delim = '\t', quote = '', escape = '',
  header = true, dateformat = '%Y%m%d',
  columns = {'concept_id_1': 'INTEGER', 'concept_id_2': 'INTEGER', 'relationship_id': 'VARCHAR',
             'valid_start_date': 'DATE', 'valid_end_date': 'DATE', 'invalid_reason': 'VARCHAR'});

CREATE OR REPLACE TABLE cdm.concept_ancestor AS
SELECT * FROM read_csv('@vocab_dir/CONCEPT_ANCESTOR.csv', delim = '\t', quote = '', escape = '',
  header = true,
  columns = {'ancestor_concept_id': 'INTEGER', 'descendant_concept_id': 'INTEGER',
             'min_levels_of_separation': 'INTEGER', 'max_levels_of_separation': 'INTEGER'});

CREATE OR REPLACE TABLE cdm.concept_synonym AS
SELECT * FROM read_csv('@vocab_dir/CONCEPT_SYNONYM.csv', delim = '\t', quote = '', escape = '',
  header = true,
  columns = {'concept_id': 'INTEGER', 'concept_synonym_name': 'VARCHAR', 'language_concept_id': 'INTEGER'});

CREATE OR REPLACE TABLE cdm.vocabulary AS
SELECT * FROM read_csv('@vocab_dir/VOCABULARY.csv', delim = '\t', quote = '', escape = '',
  header = true,
  columns = {'vocabulary_id': 'VARCHAR', 'vocabulary_name': 'VARCHAR', 'vocabulary_reference': 'VARCHAR',
             'vocabulary_version': 'VARCHAR', 'vocabulary_concept_id': 'INTEGER'});

CREATE OR REPLACE TABLE cdm.domain AS
SELECT * FROM read_csv('@vocab_dir/DOMAIN.csv', delim = '\t', quote = '', escape = '',
  header = true,
  columns = {'domain_id': 'VARCHAR', 'domain_name': 'VARCHAR', 'domain_concept_id': 'INTEGER'});

CREATE OR REPLACE TABLE cdm.concept_class AS
SELECT * FROM read_csv('@vocab_dir/CONCEPT_CLASS.csv', delim = '\t', quote = '', escape = '',
  header = true,
  columns = {'concept_class_id': 'VARCHAR', 'concept_class_name': 'VARCHAR', 'concept_class_concept_id': 'INTEGER'});

CREATE OR REPLACE TABLE cdm.relationship AS
SELECT * FROM read_csv('@vocab_dir/RELATIONSHIP.csv', delim = '\t', quote = '', escape = '',
  header = true,
  columns = {'relationship_id': 'VARCHAR', 'relationship_name': 'VARCHAR', 'is_hierarchical': 'VARCHAR',
             'defines_ancestry': 'VARCHAR', 'reverse_relationship_id': 'VARCHAR',
             'relationship_concept_id': 'INTEGER'});

CREATE OR REPLACE TABLE cdm.drug_strength AS
SELECT * FROM read_csv('@vocab_dir/DRUG_STRENGTH.csv', delim = '\t', quote = '', escape = '',
  header = true, dateformat = '%Y%m%d',
  columns = {'drug_concept_id': 'INTEGER', 'ingredient_concept_id': 'INTEGER',
             'amount_value': 'DOUBLE', 'amount_unit_concept_id': 'INTEGER',
             'numerator_value': 'DOUBLE', 'numerator_unit_concept_id': 'INTEGER',
             'denominator_value': 'DOUBLE', 'denominator_unit_concept_id': 'INTEGER',
             'box_size': 'INTEGER', 'valid_start_date': 'DATE', 'valid_end_date': 'DATE',
             'invalid_reason': 'VARCHAR'});
