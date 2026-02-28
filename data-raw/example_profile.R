# Script to generate inst/extdata/example_profile.rds
#
# Run this script from the package root directory to regenerate the example
# profvis data used by pv_example().

# Create a temporary R file with example code
tmp_dir <- tempdir()
example_file <- file.path(tmp_dir, "example_code.R")

example_code <- '
# Example functions for profiling demonstration

process_data <- function(n) {
  data <- generate_data(n)
  result <- transform_data(data)
  summarize_data(result)
}

generate_data <- function(n) {
  x <- numeric(n)
  for (i in seq_len(n)) {
    x[i] <- rnorm(1)
  }
  x
}

transform_data <- function(x) {
  result <- numeric(length(x))
  for (i in seq_along(x)) {
    result[i] <- sqrt(abs(x[i])) * 2
  }
  result
}

summarize_data <- function(x) {
  stats <- list(
    mean = mean(x),
    sd = sd(x),
    min = min(x),
    max = max(x)
  )
  format_output(stats)
}

format_output <- function(stats) {
  paste(
    sprintf("Mean: %.3f", stats$mean),
    sprintf("SD: %.3f", stats$sd),
    sep = ", "
  )
}
'

writeLines(example_code, example_file)

# Source with keep.source = TRUE to capture source references
source(example_file, local = TRUE, keep.source = TRUE)

# Profile the code - run multiple iterations to get enough samples
p <- profvis::profvis(
  {
    for (j in 1:10) {
      process_data(20000)
    }
  },
  interval = 0.005
)

# Normalize the paths to be portable
old_path <- example_file
new_path <- "example_code.R"

# Update prof data frame
p$x$message$prof$filename <- gsub(
  old_path,
  new_path,
  p$x$message$prof$filename,

  fixed = TRUE
)

# Update files list
for (i in seq_along(p$x$message$files)) {
  p$x$message$files[[i]]$filename <- gsub(
    old_path,
    new_path,
    p$x$message$files[[i]]$filename,
    fixed = TRUE
  )
  p$x$message$files[[i]]$normpath <- gsub(
    old_path,
    new_path,
    p$x$message$files[[i]]$normpath,
    fixed = TRUE
  )
}

# Save the profvis object
dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)
saveRDS(p, "inst/extdata/example_profile.rds")

# Print summary
cat("Saved example profile to inst/extdata/example_profile.rds\n\n")
prof <- p$x$message$prof
cat("Samples:", nrow(prof), "\n")
cat("Unique functions:", length(unique(prof$label)), "\n")
cat("Has source refs:", any(!is.na(prof$filename)), "\n")
cat("Files:", length(p$x$message$files), "\n")
