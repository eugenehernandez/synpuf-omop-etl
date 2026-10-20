# Paths used by the pipeline.
# By default the data lives one folder above the repo, so nothing large or licensed
# ever sits inside the Git working tree:
#
#   CMS_mapping/
#     OHDSI_Vocabularies_v20260829/   Athena download (CPT4 names filled in)
#     synpuf_raw/sample_01/           unzipped DE-SynPUF Sample 1 CSVs
#     synpuf_cdm.duckdb               database built by this repo
#     synpuf-omop-etl/                this repo
#
# To use a different location, set SYNPUF_DATA_ROOT in your .Renviron file.

data_root <- Sys.getenv("SYNPUF_DATA_ROOT", unset = normalizePath("..", winslash = "/"))

paths <- list(
  raw_dir   = file.path(data_root, "synpuf_raw", "sample_01"),
  vocab_dir = file.path(data_root, "OHDSI_Vocabularies_v20260829"),
  db_file   = file.path(data_root, "synpuf_cdm.duckdb"),
  ref_dir   = normalizePath("reference", winslash = "/"),
  out_dir   = "output"
)

check_paths <- function() {
  needed <- c(paths$raw_dir, paths$vocab_dir, paths$ref_dir)
  missing <- needed[!dir.exists(needed)]
  if (length(missing) > 0) {
    stop("These folders were not found:\n  ", paste(missing, collapse = "\n  "),
         "\nOpen the project from synpuf-omop-etl.Rproj, or set SYNPUF_DATA_ROOT.")
  }
  if (!file.exists(file.path(paths$vocab_dir, "CONCEPT.csv"))) {
    stop("CONCEPT.csv not found in ", paths$vocab_dir)
  }
  dir.create(paths$out_dir, showWarnings = FALSE)
  invisible(TRUE)
}
