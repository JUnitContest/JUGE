# ------------------------------------------------------------------------------
# This script finds out which classes are testable and prints out some stats.
#
# Usage:
# Rscript testable-classes.R
#   <input data file, e.g., byte-buddy-filtered-out.txt>
#   <input data file, e.g., byte-buddy-gen-tests.txt>
#   <output data file, e.g., byte-buddy-testable.txt>
#
# ------------------------------------------------------------------------------

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  stop("USAGE: testable-classes.R <input data file, e.g., byte-buddy-filtered-out.txt> <input data file, e.g., byte-buddy-gen-tests.txt> <output data file, e.g., byte-buddy-testable.txt>")
}

CUTS_DATA_FILE   <- args[1]
GEN_DATA_FILE    <- args[2]
OUTPUT_DATA_FILE <- args[3]

df_cuts <- read.csv(CUTS_DATA_FILE, sep=',') # class,num_branches,complexity,loc
df_cuts <- aggregate(cbind(num_branches, complexity, loc) ~ class, data=df_cuts, FUN=sum)
df_gen  <- read.csv(GEN_DATA_FILE, sep=',') # class,has_randoop_failed
df      <- merge(df_cuts, df_gen, by='class') # class method num_branches complexity loc has_randoop_failed
df      <- df[df$'has_randoop_failed' == 0, ] # not failed

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

cat('\n\n=== Stats ===\n')
stats(df)

# Print out the 'class' column to the output file
write.table(df, file=OUTPUT_DATA_FILE, append=FALSE, quote=FALSE, sep=',', row.names=FALSE)

# EOF
