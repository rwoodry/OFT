# Hellman Project R functions

# Load required packages
library(tidyverse)

# Set working directory
working_dir <- "~/R/Hellman"

# Quality Checks

# OFT

qcheck_OFT <- function(w_dir = working_dir){
  # Set working directory containing OFT output files
  setwd(w_dir)
  
  # List of filenames with trial data (objdistance.csv)
  filenames <- list.files()[grepl("objdistance.csv", list.files())]
  print("files obtained")
  
  worker_ID <- c()
  token_ID <- c()
  learn_complete <- c()
  practice_complete <- c()
  trials_complete <- c()
  pct_trials_complete <- c()
  avg_time_complete <- c()
  avg_dist_complete <- c()
  does_rob_approve <- c()
  comp_time <- c()
  
  
  # Iterate through each filename and return summary data 
  for (i in 1:length(filenames)){
    print(paste("started ", filenames[i]))
    # Split filename by "_" and assign the 6th element (worker ID) to vector
    worker_ID <- c(worker_ID, strsplit(filenames[i], "_")[[1]][1])
    
    # Split and assign the 7th element (token) to vector
    token_ID <- c(token_ID, strsplit(strsplit(filenames[i], "_")[[1]][2]))
    
    # Load ith objdistance file
    file <- read.csv(filenames[i], header = FALSE)
    
    # Check to see if Learn trials were completed
    learn_complete <- c(learn_complete, 
                        sum(grepl("Learn", unique(file[,2]))) == 4)
    
    # Check to see if practice trials were completed
    practice_complete <- c(practice_complete, 
                           sum(grepl("Practice", unique(file[,2]))) == 4)
    
    # Check to see i test trials were completed
    trials_complete <- c(trials_complete, 
                         sum(grepl("Test", unique(file[,2]))) == 24)
    
    # Output percent of test trials completed
    pct_trials_complete <- c(pct_trials_complete, 
                             sum(grepl("Test", unique(file[,2])))/24 * 100)
    
    # Average time of completion for test trials
    avg_time_complete <- c(avg_time_complete, 
                           mean(file[grepl("Test", file[,2]), 12]))
    
    comp_time <- c(comp_time, file[, 11][nrow(file)])
    
    # Average travel distance for test trials
    avg_dist_complete <- c(avg_dist_complete, 
                           mean(file[grepl("Test", file[,2]), 13]))
    
    # If else statement that creates a column of whether I recommend approval
    well_does_he <- ""
    
    if (learn_complete[i] && 
        practice_complete[i] && 
        pct_trials_complete[i] == 100 && 
        avg_time_complete[i] >= 10 && 
        avg_dist_complete[i] >= 100){
      well_does_he <- "YES"
    } else if (!learn_complete[i] | !practice_complete[i] | 
               pct_trials_complete[i] <= 50 | avg_time_complete[i] <= 5){
      well_does_he <- "NO"
    } else {
      well_does_he <- "MAYBE"
    }
    
    does_rob_approve <- c(does_rob_approve, well_does_he)
    
    print(paste("Completed ", filenames[i]))
  }
  

  
  QualityCheckTable <- cbind(worker_ID, token_ID, learn_complete, 
                             practice_complete, trials_complete, 
                             pct_trials_complete, avg_time_complete, 
                             avg_dist_complete, does_rob_approve, comp_time)
  date_string <- paste(strsplit(date(), " ")[[1]][c(2,3,5)], collapse = "_")
  
  file_output_name <- paste0("OFT-QC_", date_string, ".csv")
  
  write.csv(QualityCheckTable, file_output_name, row.names = FALSE)
  
  
}

qcheck_SOT <- function(working_dir){
  # Set working directory containing OFT output files
  
  # List of filenames with trial data (objdistance.csv)
  setwd(working_dir)
  filenames <- list.files()[grepl("SOT_", list.files())]
  
  worker_ID <- c()
  token_ID <- c()

  SOT_num_trialsComplete <- c()
  SOT_sd_responseAngle <- c()
  SOT_mean_angularError <- c()
  SOT_mean_reactionTime <- c()
  SOT_mean_responseTime <- c()
  SOT_total_runtime <- c()
  
  SOT_does_rob_approve <- c()
  
  for (i in 1:length(filenames)){
    print(paste("started ", filenames[i]))
    # Split filename by "_" and assign the 1st element (worker ID) to vector
    worker_ID <- c(worker_ID, strsplit(filenames[i], "_")[[1]][2])
    
    # Split and assign the 2nd element (token) to vector
    token_ID <- c(token_ID, strsplit(strsplit(filenames[i], "_")[[1]][3], ".csv")[[1]][1])
    
    # Load ith SOT file
    file <- read.csv(filenames[i])
    
    SOT_num_trialsComplete <- c(SOT_num_trialsComplete, nrow(file))
    SOT_sd_responseAngle <- c(SOT_sd_responseAngle, sd(file[which(file$trialType == ' Test'), 'responseAngle'], na.rm = TRUE))
    SOT_mean_angularError <- c(SOT_mean_angularError, mean(file[which(file$trialType == ' Test'), 'angularError'], na.rm = TRUE))
    SOT_mean_reactionTime <- c(SOT_mean_reactionTime, mean(file[which(file$trialType == ' Test'), 'reactionTime'], na.rm = TRUE))
    SOT_mean_responseTime <- c(SOT_mean_responseTime, mean(file[which(file$trialType == ' Test'), 'responseTime'], na.rm = TRUE))
    SOT_total_runtime <- c(SOT_total_runtime, file$endtime[length(file$endTime)])
    
    well_does_he <- ""
    
    if (nrow(file) <= 4 ){
      well_does_he <- 'NO'
    } else if (sd(file[which(file$trialType == ' Test'), 'responseAngle'], na.rm = TRUE) < 50 |
               mean(file[which(file$trialType == ' Test'),'angularError'], na.rm = TRUE) > 70 |
               mean(file[which(file$trialType == ' Test'),'responseTime'], na.rm = TRUE) < 7){
      well_does_he <- 'MAYBE'
    } else {
      well_does_he <- 'YES'
    }
    SOT_does_rob_approve <- c(SOT_does_rob_approve, well_does_he)
  }
  
  SOT_QualityCheckTable <- cbind(worker_ID, token_ID, SOT_num_trialsComplete, 
                                 SOT_sd_responseAngle, SOT_mean_angularError,
                                 SOT_mean_reactionTime, SOT_mean_responseTime,
                                 SOT_total_runtime, SOT_does_rob_approve)

  date_string <- paste(strsplit(date(), " ")[[1]][c(2,3,5)], collapse = "_")
  
  file_output_name <- paste0("SOT-QC_", date_string, ".csv")
  
  write.csv(SOT_QualityCheckTable, file_output_name, row.names = FALSE)
  
}
