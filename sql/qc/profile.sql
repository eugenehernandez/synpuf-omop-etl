-- Raw profile: rows, distinct beneficiaries, and date range for each source table.
-- The claims tables use different date columns, so each block names its own.

SELECT 'beneficiary' AS source_table, COUNT(*) AS n_rows,
       COUNT(DISTINCT DESYNPUF_ID) AS n_beneficiaries,
       CAST(MIN(file_year) AS VARCHAR) AS first_date, CAST(MAX(file_year) AS VARCHAR) AS last_date
FROM raw.beneficiary
UNION ALL
SELECT 'inpatient', COUNT(*), COUNT(DISTINCT DESYNPUF_ID),
       CAST(MIN(try_strptime(CLM_FROM_DT, '%Y%m%d')::DATE) AS VARCHAR),
       CAST(MAX(try_strptime(CLM_FROM_DT, '%Y%m%d')::DATE) AS VARCHAR)
FROM raw.inpatient
UNION ALL
SELECT 'outpatient', COUNT(*), COUNT(DISTINCT DESYNPUF_ID),
       CAST(MIN(try_strptime(CLM_FROM_DT, '%Y%m%d')::DATE) AS VARCHAR),
       CAST(MAX(try_strptime(CLM_FROM_DT, '%Y%m%d')::DATE) AS VARCHAR)
FROM raw.outpatient
UNION ALL
SELECT 'carrier', COUNT(*), COUNT(DISTINCT DESYNPUF_ID),
       CAST(MIN(try_strptime(CLM_FROM_DT, '%Y%m%d')::DATE) AS VARCHAR),
       CAST(MAX(try_strptime(CLM_FROM_DT, '%Y%m%d')::DATE) AS VARCHAR)
FROM raw.carrier
UNION ALL
SELECT 'pde', COUNT(*), COUNT(DISTINCT DESYNPUF_ID),
       CAST(MIN(try_strptime(SRVC_DT, '%Y%m%d')::DATE) AS VARCHAR),
       CAST(MAX(try_strptime(SRVC_DT, '%Y%m%d')::DATE) AS VARCHAR)
FROM raw.pde
