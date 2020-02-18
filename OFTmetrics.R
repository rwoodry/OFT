library(tidyverse)
library(trajr)
library(matrixStats)


setwd("C:/Users/Spatial Neuroscience/Desktop/Unix-Desktop/OFTOutput")

oft_concatenate<- function(subj_ids){
  oft_data <- c()
  for(i in 1:length(subj_ids)){
    filename <- sprintf("%d_objdistance.csv", subj_ids[i])
    data <- read.csv(filename)
    data <- cbind(rep(subj_ids[i], nrow(data)), data)
    oft_data <- rbind(oft_data, data)
  }
  oft_data <- as.data.frame(oft_data)
  colnames(oft_data)[1] <- "Subject_ID"
  return(oft_data)
}

# Individual calculate functions for trial data

calc_dist_from_center <- function(end_x, end_z){
  dist <- sqrt((end_x - 98600)^2 + (end_z + 950)^2)
  return(dist)
}

calc_eucdisttrav <- function(start_x, start_z, end_x, end_z){
  euc_dist_trav <- dist <- sqrt((end_x - start_x)^2 + (end_z - start_z)^2)
  return(euc_dist_trav)
}

calc_tortuosity <- function(euc_dist_trav, tot_dist_trav){
  tortuosity <- euc_dist_trav / tot_dist_trav
  return(tortuosity)
}

calc_mean_dirchange <- function(subjid, trial_level){
  mean_dirchange <- c()
  for (i in 1:length(subjid)){
    posdata <- read.csv(sprintf("%d_position.csv", as.numeric(as.character(subjid[i]))))
    trackdata <- posdata[posdata$trial_level == trial_level[i], ]
    trackdata <- as.data.frame(cbind(trackdata$pos_x, trackdata$pos_z))
    
    trajdata <- TrajFromCoords(trackdata, fps = 10)
    mdc  <- mean(TrajDirectionalChange(trajdata))
    mean_dirchange <- c(mean_dirchange, mdc)
    print(paste(i, "mean"))
  }
  return(mean_dirchange)

}

calc_sd_dirchange <- function(subjid, trial_level){
  sd_dirchange <- c()
  for (i in 1:length(subjid)){
    posdata <- read.csv(sprintf("%d_position.csv", as.numeric(as.character(subjid[i]))))
    trackdata <- posdata[posdata$trial_level == trial_level[i], ]
    trackdata <- as.data.frame(cbind(trackdata$pos_x, trackdata$pos_z))
    
    trajdata <- TrajFromCoords(trackdata, fps = 10)
    sdc  <- sd(TrajDirectionalChange(trajdata))
    sd_dirchange <- c(sd_dirchange, sdc)
    print(paste(i, "sd"))
  }
  return(sd_dirchange)
  
}

# Calculate OFT trial metrics using above functions

oft_trialmetrics <- function(oft_conc_data){
  oft_conc_data <- oft_conc_data %>% mutate(
    dist_from_center = calc_dist_from_center(end_x, end_z),
    euc_dist_trav = calc_eucdisttrav(start_x, start_z, end_x, end_z),
    tortuosity = calc_tortuosity(euc_dist_trav, tot_dist),
    mean_dirchange = calc_mean_dirchange(Subject_ID, trial_level),
    sd_dirchange = calc_sd_dirchange(Subject_ID, trial_level)
  )
  return(oft_conc_data)
}

# Pipeline code
oft_data <- oft_concatenate(c(2,3,7,8,9,10))
oft_data <- oft_trialmetrics(oft_data)

# Compile participant data
participant_list <- split(oft_data, as.factor(oft_data$Subject_ID))



compile_participantmetrics <- function(participant_list){
  for (i in 1:length(participant_list)){
    sub_data <- participant_list[[i]][grepl("TestScene", participant_list[[i]]$trial_level), ]
    
    oall_means <- colMeans(as.data.frame(sub_data)[,4:23])[c(6:8, 10:12, 15:20)]
    oall_sds <- colSds(as.matrix(as.data.frame(sub_data)[,4:23]))[c(6:8, 10:12, 15:20)]
    
    bytarget_data <- split(sub_data, sub_data$target_obj)

    chair_means <- colMeans(as.data.frame(bytarget_data$chFolding.A_LOD0)[,4:23])[c(6:8, 10:12, 15:20)]
    sball_means <- colMeans(as.data.frame(bytarget_data$'Soccer Ball')[,4:23])[c(6:8, 10:12, 15:20)]
    cone_means <- colMeans(as.data.frame(bytarget_data$cone_clean)[,4:23])[c(6:8, 10:12, 15:20)]
    bucket_means <- colMeans(as.data.frame(bytarget_data$Bucket_clean)[,4:23])[c(6:8, 10:12, 15:20)]
    
    chair_sds <- colSds(as.data.frame(bytarget_data$chFolding.A_LOD0)[,4:23])[c(6:8, 10:12, 15:20)]
    sball_sds <- colSds(as.data.frame(bytarget_data$'Soccer Ball')[,4:23])[c(6:8, 10:12, 15:20)]
    cone_sds <- colSds(as.data.frame(bytarget_data$cone_clean)[,4:23])[c(6:8, 10:12, 15:20)]
    bucket_sds <- colSds(as.data.frame(bytarget_data$Bucket_clean)[,4:23])[c(6:8, 10:12, 15:20)]
  }
}

