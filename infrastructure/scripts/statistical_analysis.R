#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

# author: Annibale Panichella (2017)
# edited by: [José Campos](https://jose.github.io/) (2024)

# load required library
library(data.table)
library(effsize)
library(pracma)
#library(xtable)
library(PMCMRplus)

# weights for the score
w_i <- 1
w_b <- 2
w_m <- 4
w_faults <- 4

# parse the input parameters
if (length(args)<2) {
  stop("At least two argument must be supplied: (i) input file, and (ii) output folder.", call.=FALSE)
} 

# read csv file
rawdata <- read.table(args[1], sep=",", header=TRUE)
rawdata$timeBudget <- as.factor(rawdata$timeBudget)
rawdata$benchmark  <- as.factor(rawdata$benchmark)
rawdata$class      <- as.factor(rawdata$class)
rawdata$tool       <- as.factor(rawdata$tool)

# create output directory
output_dir <- args[2]
if (file.exists(output_dir) == FALSE)
  dir.create(output_dir, showWarnings = TRUE)

# compute the score of each run
scores <- vector(mode = "list", length = nrow(rawdata))
for (index in 1:nrow(rawdata)) {
  point <- rawdata[index,]

  coverageScore <- 0
  coverageScore <- coverageScore + as.numeric(as.character(point$linesCoverageRatio))/100 * w_i 
  coverageScore <- coverageScore + as.numeric(as.character(point$conditionsCoverageRatio))/100 * w_b 
  coverageScore <- coverageScore + as.numeric(as.character(point$mutantsKillRatio))/100 * w_m 
  
  #if (as.numeric(as.character(point$failTests))>0)
  #  coverageScore <- coverageScore + w_faults
  
  # give a penalty when generationTime took too long
  if (as.numeric(as.character(point$generationTime)) == 0) {
    overtime_generation_penalty = 1.0
  } else {
    timeBudgetMillis = as.numeric(as.character(point$timeBudget)) * 1000
    generationTimeRatio = timeBudgetMillis / as.numeric(as.character(point$generationTime))
    overtime_generation_penalty = min(1, generationTimeRatio)
  }
  
  if (as.numeric(as.character(point$testcaseNumber)) == 0) {
    # no tests!
    coverageScore =  0.0
  } else {
    if (as.numeric(as.character(point$uncompilableNumber)) == as.numeric(as.character(point$totalTestClasses))) {
      uncompilableFlakyPenalty = 2.0
    } else {
      # assert testSuiteSize>0
      denominator <- as.numeric(as.character(point$testcaseNumber))
      denominator <- max(denominator, as.numeric(as.character(point$totalTestClasses)))
      flakyTestRatio = as.numeric(as.character(point$brokenTests))/denominator

      # assert totalNumberOfTestClasses !=0
      uncompilableTestClassesRatio = as.numeric(as.character(point$uncompilableNumber)) / as.numeric(as.character(point$totalTestClasses))
      uncompilableFlakyPenalty = flakyTestRatio + uncompilableTestClassesRatio
    }
    
    if (uncompilableFlakyPenalty>2.0)
      print("Error in the penalty function")
    
    coverageScore = (coverageScore * overtime_generation_penalty) - uncompilableFlakyPenalty
    if (coverageScore < 0)
       coverageScore = 0
  }

  scores[[index]] <- list(
    benchmark = point$benchmark,
    class = point$class, 
    run = as.numeric(as.character(point$run)),
    timeBudget = as.numeric(as.character(point$timeBudget)),
    config = paste(point$benchmark, "_", point$class, "_", as.numeric(as.character(point$timeBudget)), sep=""),
    tool = point$tool,
    score = coverageScore
  )
}
scores <- rbindlist(scores, fill = T)
write.csv(scores, file = paste(output_dir,"/detailed_score.csv", sep=""))

# aggregate multiple runs/seeds
average.scores <- scores
average.scores <- aggregate(score ~ config + timeBudget + benchmark + class + tool, data=average.scores, mean)
write.csv(average.scores, file = paste(output_dir,"/score_per_subject.csv", sep=""))

# apply the Friedman's test for statistical significance
res <- friedman.test(y = average.scores$score, groups = factor(average.scores$tool), blocks = factor(average.scores$config))
print(res)
res = as.data.frame(do.call(rbind, res))
write.table(res, file = paste(output_dir,"/friedman_test.txt", sep=""))

# apply the post-hoc Kruskal's predecure 
res <- kwAllPairsConoverTest(x = average.scores$score, g=as.factor(average.scores$tool))
print(res)
res = as.data.frame(res$p.value)
write.table(res, file = paste(output_dir,"/kruskal.txt", sep=""))

# compute final ranking
ranks <- data.frame(matrix(ncol=3,nrow=0, dimnames=list(NULL, c("config", "tool", "rank"))))
for (conf in unique(average.scores$'config')) {
  # print(conf)

  x <- average.scores[average.scores$'config' == conf, ]
  x$'rank' <- rank(-x$"score", ties.method=c('min'))
  # print(x)

  x <- subset(x, select=c('config', 'tool', 'rank'))
  ranks <- rbind(ranks, x)
}
print(head(ranks))
avg_ranks <- aggregate(rank ~ tool, data=ranks, mean)
avg_ranks <- avg_ranks[order(avg_ranks$"rank"), ]
print(avg_ranks)
write.csv(avg_ranks, file = paste(output_dir,"/final_ranking.txt", sep=""))

# compute average score of the tools for different time budgets
score.budget <- aggregate(score ~ timeBudget + tool, data=average.scores, sum)
print(score.budget)
write.csv(score.budget, file = paste(output_dir,"/average_score.csv", sep=""))

# compute the final scores
final.score <- aggregate(score ~ tool, data=score.budget, sum)
final.score <- final.score[order(-final.score$"score"), ]
print(final.score)
write.csv(final.score, file = paste(output_dir,"/final_score.csv", sep=""))

# EOF
