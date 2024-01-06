# ------------------------------------------------------------------------------
# Install some package that might be required to run any analysis.
# ------------------------------------------------------------------------------

# R repository
repository <- 'http://cran.us.r-project.org'
# Install packages
install.packages('data.table', repos=repository)
install.packages('effsize', repos=repository)
install.packages('pracma', repos=repository)
install.packages('PMCMRplus', repos=repository)
# Load libraries (aka runtime sanity check)
library('data.table')
library('effsize')
library('pracma')
library('PMCMRplus')
# Exit
quit(save='no', status=0)
