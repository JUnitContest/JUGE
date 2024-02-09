# ------------------------------------------------------------------------------
# This script post-process the output of the parse-jacoco.py script and applies
# a couple filters.
#
# Usage:
# Rscript filter-out-classes.R
#   <input data file, e.g., byte-buddy.txt>
#   <output data file, e.g., byte-buddy-filtered-out.txt>
#
# ------------------------------------------------------------------------------

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop("USAGE: filter-out-classes.R <input data file> <output data file>")
}

INPUT_DATA_FILE  <- args[1]
OUTPUT_DATA_FILE <- args[2]

df <- read.csv(INPUT_DATA_FILE, sep=';') # class;method;num_branches;complexity;loc

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

cat('\n\n=== Before filtering out classes ===\n')
agg <- aggregate(cbind(num_branches, complexity, loc) ~ class, data=df, FUN=sum)
stats(agg)

# Filter out methods with less than 2 branches
df <- df[df$'num_branches' >= 2, ]

# Filter out methods with a cyclomatic complexity lower than five
df <- df[df$'complexity' >= 5, ]

cat('\n\n=== After filtering out classes ===\n')
agg <- aggregate(cbind(num_branches, complexity, loc) ~ class, data=df, FUN=sum)
stats(agg)

# Print out the 'class' column to the output file
write.table(agg, file=OUTPUT_DATA_FILE, append=FALSE, quote=FALSE, sep=',', row.names=FALSE)

# EOF
