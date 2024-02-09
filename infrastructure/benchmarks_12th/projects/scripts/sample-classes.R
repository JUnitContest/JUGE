# ------------------------------------------------------------------------------
# This script samples 10% of testable classes and prints out some stats.
#
# Usage:
# Rscript sample-classes.R
#   <input data file, e.g., byte-buddy-testable.txt>
#   <output data file, e.g., byte-buddy-sample.txt>
#
# ------------------------------------------------------------------------------

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop("USAGE: sample-classes.R <input data file, e.g., byte-buddy-testable.txt> <output data file, e.g., byte-buddy-sample.txt>")
}

PERCENTAGE=10#%

INPUT_DATA_FILE  <- args[1]
OUTPUT_DATA_FILE <- args[2]

df <- read.csv(INPUT_DATA_FILE, sep=',') # class,num_branches,complexity,loc,has_randoop_failed

stats <- function(df) {
  # Print out number of classes
  cat(paste0('Number of classes: ', length(unique(df$'class')), '\n'))
  # Print out min, max, and average number of branches
  cat(paste0('Number of branches (min): ', min(df$'num_branches'), '\n'))
  cat(paste0('Number of branches (max): ', max(df$'num_branches'), '\n'))
  cat(paste0('Number of branches (avg): ', mean(df$'num_branches'), '\n'))
  # Print out min, max, and average of complexity
  cat(paste0('Complexity (min): ', min(df$'complexity'), '\n'))
  cat(paste0('Complexity (max): ', max(df$'complexity'), '\n'))
  cat(paste0('Complexity (avg): ', mean(df$'complexity'), '\n'))
  # # Print out min, max, and average of loc
  # cat(paste0('LOC (min): ', min(df$'loc'), '\n'))
  # cat(paste0('LOC (max): ', max(df$'loc'), '\n'))
  # cat(paste0('LOC (avg): ', mean(df$'loc'), '\n'))
}

# Suffle row-wise
df <- df[sample(nrow(df)), ]
# Get first 10% of rows
df <- head(df, ceiling(nrow(df) * PERCENTAGE/100))

cat('\n\n=== Stats ===\n')
stats(df)

# Print out the 'class' column to the output file
write.table(df, file=OUTPUT_DATA_FILE, append=FALSE, quote=FALSE, sep=',', row.names=FALSE)

# EOF
