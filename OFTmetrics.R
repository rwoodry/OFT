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
  part_master <- c()
  for (i in 1:length(participant_list)){
    print(i)
    sub_data <- participant_list[[i]][grepl("TestScene", participant_list[[i]]$trial_level), ]
    
    subj_id <- participant_list[[i]]$Subject_ID[1]
    
    oall_means <- colMeans(as.data.frame(sub_data)[,4:23])[c(6:8, 10:12, 15:20)]
    oall_sds <- colSds(as.matrix(as.data.frame(sub_data)[,4:23]))[c(6:8, 10:12, 15:20)]
    
    bytarget_data <- split(sub_data, sub_data$target_obj)
    
    chair_means <- colMeans(as.data.frame(bytarget_data$chFolding.A_LOD0)[,4:23])[c(6:8, 10:12, 15:20)]
    sball_means <- colMeans(as.data.frame(bytarget_data$'Soccer Ball')[,4:23])[c(6:8, 10:12, 15:20)]
    cone_means <- colMeans(as.data.frame(bytarget_data$cone_clean)[,4:23])[c(6:8, 10:12, 15:20)]
    bucket_means <- colMeans(as.data.frame(bytarget_data$Bucket_clean)[,4:23])[c(6:8, 10:12, 15:20)]
    
    chair_sds <- colSds(as.matrix(bytarget_data$chFolding.A_LOD0[,4:23]))[c(6:8, 10:12, 15:20)]
    sball_sds <- colSds(as.matrix(bytarget_data$'Soccer Ball'[,4:23]))[c(6:8, 10:12, 15:20)]
    cone_sds <- colSds(as.matrix(bytarget_data$cone_clean[,4:23]))[c(6:8, 10:12, 15:20)]
    bucket_sds <- colSds(as.matrix(bytarget_data$Bucket_clean[,4:23]))[c(6:8, 10:12, 15:20)]
    
    # Standard Deviation of the Ellipse metrics
    calc_sde(id = 1, points = cbind(bytarget_data$chFolding.A_LOD0$end_x, bytarget_data$chFolding.A_LOD0$end_z))
    sdeatt_chair <- sdeatt
    calc_sde(id = 2, points = cbind(bytarget_data$'Soccer Ball'$end_x, bytarget_data$'Soccer Ball'$end_z))
    sdeatt_sball <- sdeatt
    calc_sde(id = 3, points = cbind(bytarget_data$Bucket_clean$end_x, bytarget_data$Bucket_clean$end_z))
    sdeatt_bucket <- sdeatt
    calc_sde(id = 4, points = cbind(bytarget_data$cone_clean$end_x, bytarget_data$cone_clean$end_z))
    sdeatt_cone <- sdeatt
    
    # K- Means Cluster (clusters = 4)
    fit <- kmeans(sub_data[,7:8], 4)
    sub_data <- cbind(sub_data, fit$cluster)
    
    kmeans_ss_ratio <- fit$betweenss / fit$totss
    kc_1_endx <- fit$centers[1, 1]
    kc_1_endy <- fit$centers[1, 2]
    kc_2_endx <- fit$centers[2, 1]
    kc_2_endy <- fit$centers[2, 2]
    kc_3_endx <- fit$centers[3, 1]
    kc_3_endy <- fit$centers[3, 2]
    kc_4_endx <- fit$centers[4, 1]
    kc_4_endy <- fit$centers[4, 2]
    
    kc_1_size <- fit$size[1]
    kc_2_size <- fit$size[2]
    kc_3_size <- fit$size[3]
    kc_4_size <- fit$size[4]
    
    kc_1_wss <- fit$withinss[1]
    kc_2_wss <- fit$withinss[2]
    kc_3_wss <- fit$withinss[3]
    kc_4_wss <- fit$withinss[4]
    
    sbc<- split(sub_data, fit$cluster)
    
    kc_1_hg <- max(table(sbc$'1'$target_obj)) / nrow(sbc$'1')
    kc_2_hg <- max(table(sbc$'2'$target_obj)) / nrow(sbc$'2')
    kc_3_hg <- max(table(sbc$'3'$target_obj)) / nrow(sbc$'3')
    kc_4_hg <- max(table(sbc$'4'$target_obj)) / nrow(sbc$'4')
    
    # TODO: FIX THIS
    part_data <- c(subj_id, oall_means, oall_sds, 
                   chair_means, chair_sds, sball_means, sball_sds, 
                   bucket_means, bucket_sds, cone_means, cone_sds,
                   sdeatt_chair, sdeatt_sball, sdeatt_bucket, sdeatt_cone,
                   kmeans_ss_ratio, 
                   kc_1_endx, kc_1_endy, kc_1_size, kc_1_wss, kc_1_hg,
                   kc_2_endx, kc_2_endy, kc_2_size, kc_2_wss, kc_2_hg,
                   kc_3_endx, kc_3_endy, kc_3_size, kc_3_wss, kc_3_hg,
                   kc_4_endx, kc_4_endy, kc_4_size, kc_4_wss, kc_4_hg)
    print(part_data)
    part_master <- rbind(part_master, part_data)
  }
  
  return(part_data)
}
