# Helpers for running the SQL files in sql/.
# The SQL lives in plain .sql files so it can be read, reviewed, and reused outside R.
# Placeholders such as @raw_dir are filled in from the params list.

read_sql_file <- function(path, params = list()) {
  sql <- paste(readLines(path, warn = FALSE), collapse = "\n")
  for (nm in names(params)) {
    sql <- gsub(paste0("@", nm), params[[nm]], sql, fixed = TRUE)
  }
  lines <- strsplit(sql, "\n", fixed = TRUE)[[1]]
  lines <- lines[!grepl("^\\s*--", lines)]   # drop full-line comments
  paste(lines, collapse = "\n")
}

# Run every statement in a file (DDL and INSERTs)
run_sql_file <- function(con, path, params = list()) {
  sql   <- read_sql_file(path, params)
  stmts <- trimws(strsplit(sql, ";\\s*(\n|$)", perl = TRUE)[[1]])
  stmts <- stmts[nzchar(stmts)]
  for (s in stmts) DBI::dbExecute(con, s)
  invisible(length(stmts))
}

# Run a single SELECT and return a data frame
query_sql_file <- function(con, path, params = list()) {
  DBI::dbGetQuery(con, read_sql_file(path, params))
}

table_exists <- function(con, schema, table) {
  n <- DBI::dbGetQuery(con, sprintf(
    "SELECT COUNT(*) AS n FROM information_schema.tables
     WHERE table_schema = '%s' AND table_name = '%s'", schema, table))$n
  n > 0
}

step <- function(label, expr) {
  t0 <- Sys.time()
  message(sprintf("[%s] %s ...", format(t0, "%H:%M:%S"), label))
  force(expr)
  message(sprintf("           done in %.1f s", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
}
