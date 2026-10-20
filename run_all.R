# Build the OMOP CDM v5.4 database from CMS DE-SynPUF Sample 1 and run the QC checks.
# Open synpuf-omop-etl.Rproj in RStudio, then run this whole file (Ctrl+Shift+S).
#
# Phase 1 builds: vocabulary, person, death, observation_period.
# The first run loads the vocabulary (a few minutes). Later runs reuse it unless
# rebuild_vocab is set to TRUE.

rebuild_vocab <- FALSE

library(DBI)
library(duckdb)
source("R/config.R")
source("R/run_sql.R")

check_paths()
con <- dbConnect(duckdb::duckdb(), dbdir = paths$db_file)

tryCatch({

  if (rebuild_vocab || !table_exists(con, "cdm", "concept")) {
    step("Load OHDSI vocabulary", run_sql_file(con, "sql/ingest/vocab_tables.sql",
                                               list(vocab_dir = paths$vocab_dir)))
  } else {
    message("Vocabulary already loaded, skipping (set rebuild_vocab <- TRUE to reload)")
  }

  step("Load raw SynPUF files", run_sql_file(con, "sql/ingest/raw_tables.sql",
                                             list(raw_dir = paths$raw_dir)))
  step("Create CDM tables",     run_sql_file(con, "sql/ddl/cdm_phase1.sql"))
  step("Build person",          run_sql_file(con, "sql/etl/person.sql"))
  step("Build death",           run_sql_file(con, "sql/etl/death.sql"))
  step("Build observation_period", run_sql_file(con, "sql/etl/observation_period.sql"))

  # ---- QC ----
  profile  <- query_sql_file(con, "sql/qc/profile.sql")
  vocab    <- query_sql_file(con, "sql/qc/vocab_summary.sql")
  concepts <- query_sql_file(con, "sql/qc/concept_constants_check.sql",
                             list(ref_dir = paths$ref_dir))
  checks   <- query_sql_file(con, "sql/qc/phase1_checks.sql")
  checks$pct_flagged <- round(100 * checks$n_flagged / pmax(checks$n_base, 1), 2)

  write.csv(profile,  file.path(paths$out_dir, "raw_profile.csv"),          row.names = FALSE)
  write.csv(vocab,    file.path(paths$out_dir, "vocab_summary.csv"),        row.names = FALSE)
  write.csv(concepts, file.path(paths$out_dir, "concept_constants_check.csv"), row.names = FALSE)
  write.csv(checks,   file.path(paths$out_dir, "qc_phase1.csv"),            row.names = FALSE)

  cat("\n== Raw profile ==\n");            print(profile, row.names = FALSE)
  cat("\n== Vocabulary summary ==\n");     print(vocab, row.names = FALSE)
  cat("\n== Hard-coded concept check ==\n")
  print(concepts[, c("concept_id", "expected_concept_name", "result")], row.names = FALSE)
  cat("\n== Phase 1 QC checks ==\n")
  print(checks[, c("check_name", "severity", "n_flagged", "n_base", "pct_flagged")], row.names = FALSE)

  n_concept_fail <- sum(concepts$result != "pass")
  n_error_fail   <- sum(checks$severity == "error" & checks$n_flagged > 0)
  cat(sprintf("\nConcept check failures: %d   Error-level QC failures: %d\n",
              n_concept_fail, n_error_fail))
  if (n_concept_fail + n_error_fail > 0) {
    warning("Some checks failed. See the output folder before moving on.")
  } else {
    cat("All error-level checks passed. Results are in the output folder.\n")
  }

}, finally = dbDisconnect(con))
