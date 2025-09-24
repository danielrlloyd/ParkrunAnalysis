suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
  library(readr)
})

TARGET_DF_NAME <- NULL  
WRITE_OUTPUT   <- TRUE  
OUTPUT_PATH    <- "data/processed/clean_time.csv"

# Locate the combined data frame already in memory
pick_df_from_memory <- function(target = NULL){
  if (!is.null(target) && exists(target, inherits = TRUE) && is.data.frame(get(target, inherits = TRUE))) {
    name <- target; df <- get(target, inherits = TRUE)
    return(list(name = name, df = df))
  }
  objs <- mget(ls(), inherits = TRUE)
  dfs  <- objs[sapply(objs, is.data.frame)]
  stopifnot(length(dfs) > 0)
  nrs  <- vapply(dfs, nrow, integer(1))
  name <- names(dfs)[which.max(nrs)]
  list(name = name, df = dfs[[name]])
}

picked <- pick_df_from_memory(TARGET_DF_NAME)
df_name <- picked$name
df      <- picked$df
message("Using data frame: ", df_name, " (", nrow(df), " rows)")

# Identify the time column (case-insensitive; accepts 'time' or 'finish_time') 
nm <- names(df); lc <- tolower(nm)
idx <- which(lc %in% c("time","finish_time"))[1]
if (is.na(idx)) stop("No 'time' or 'finish_time' column found in the combined data frame.")
time_col <- nm[idx]

extract_finish_time <- function(x){
  x <- ifelse(is.na(x), "", as.character(x))
  m <- stringr::str_extract(x, "\\d{1,2}:\\d{2}(?::\\d{2})?")  # first mm:ss or hh:mm:ss
  dplyr::na_if(m, "")
}
time_to_seconds <- function(x){
  x0 <- trimws(as.character(x)); x0[is.na(x0)] <- ""
  out <- rep(NA_integer_, length(x0)); keep <- nzchar(x0)
  if (any(keep)) {
    sp <- strsplit(x0[keep], ":", fixed = TRUE)
    out[keep] <- vapply(sp, function(v){
      v <- suppressWarnings(as.integer(v))
      if (length(v) == 2) v[1]*60 + v[2]
      else if (length(v) == 3) v[1]*3600 + v[2]*60 + v[3]
      else NA_integer_
    }, integer(1))
  }
  out
}


df2 <- df |>
  mutate(
    time_clean   = extract_finish_time(.data[[time_col]]),
    time_seconds = time_to_seconds(time_clean)
  )

assign(df_name, df2, envir = .GlobalEnv)

if (WRITE_OUTPUT) {
  dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
  readr::write_csv(df2, OUTPUT_PATH)
  message("Added [time_clean, time_seconds] to ", df_name,
          " and wrote ", OUTPUT_PATH)
} else {
  message("Added [time_clean, time_seconds] to ", df_name, " (no file written).")
}
