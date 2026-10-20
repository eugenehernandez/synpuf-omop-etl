# Run once to install the packages Phase 1 needs.
# Later phases will add OHDSI packages (CDMConnector, DataQualityDashboard, CohortMethod).

pkgs <- c("DBI", "duckdb", "renv")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) install.packages(missing)

# Record exact package versions for reproducibility (creates renv.lock)
# renv::init(bare = TRUE); renv::snapshot()
