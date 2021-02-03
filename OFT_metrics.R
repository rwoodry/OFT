library(tidyverse)
library(trajr)
library(matrixStats)
library(aspace)

working_dir <- "C:/Users/17868/Documents/R/Hellman/OFT/"
write_dir <- "C:/Users/17868/Documents/R/Hellman/"
setwd(working_dir)

oft_concatenate<- function(subj_ids){
  oft_data <- data.frame()
  
  for(i in 1:length(subj_ids)){
    filename <- subj_ids[i]
    subjid <- strsplit(filename, "_")[[1]][1]
    token <- strsplit(filename, "_")[[1]][2]
    data <- read.csv(filename, header = FALSE)
    names <- "target_obj, trial_level, start_x, start_z, start_rot_y, end_x, end_z, end_rot_y, delta_start, delta_target, run_time, completion_time, tot_dist, tot_rot_y, sl_dist, efficiency, avg_speed"
    colnames(data) <- strsplit(names, ", ")[[1]]
    data <- cbind(rep(subjid, nrow(data)), rep(token, nrow(data)), data)
    oft_data <- rbind(oft_data, data)
  }
  oft_data <- as.data.frame(oft_data)
  colnames(oft_data)[1:2] <- c("Subject_ID", "token")
  
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

calc_mean_dirchange <- function(subjid, token, trial_level){
  mean_dirchange <- c()
  print("Calculating Mean Directional Change: ")
  pb <- txtProgressBar(min = 0, max = length(subjid), style = 3)
  for (i in 1:length(subjid)){
    
    posdata <- read.csv(sprintf("%s_%s_position.csv", subjid[i], token[i]))
    names <- "pos_x, pos_z, rot_y, run_time, trial_time, target_obj, trial_level, delta_target, delta_start, speed, tot_dist, tot_rot_y, target_visible"
    colnames(posdata) <- strsplit(names, ", ")[[1]]
    trackdata <- posdata[posdata$trial_level == trial_level[i], ]
    trackdata <- as.data.frame(cbind(trackdata$pos_x, trackdata$pos_z))
    if (nrow(trackdata) != 0){
      trajdata <- TrajFromCoords(trackdata, fps = 10)
      
      mdc  <- mean(TrajDirectionalChange(trajdata))
      
    } else {
      mdc <- NA
    }
    
    mean_dirchange <- c(mean_dirchange, mdc)
    setTxtProgressBar(pb, i)
  }
  return(mean_dirchange)
  
}

calc_sd_dirchange <- function(subjid, token, trial_level){
  sd_dirchange <- c()
  print("Calculating Standard Deviation of Directional Change: ")
  pb <- txtProgressBar(min = 0, max = length(subjid), style = 3)
  for (i in 1:length(subjid)){
    posdata <- read.csv(sprintf("%s_%s_position.csv", subjid[i], token[i]))
    names <- "pos_x, pos_z, rot_y, run_time, trial_time, target_obj, trial_level, delta_target, delta_start, speed, tot_dist, tot_rot_y, target_visible"
    colnames(posdata) <- strsplit(names, ", ")[[1]]
    trackdata <- posdata[posdata$trial_level == trial_level[i], ]
    trackdata <- as.data.frame(cbind(trackdata$pos_x, trackdata$pos_z))
    if (nrow(trackdata) != 0){
      trajdata <- TrajFromCoords(trackdata, fps = 10)
      sdc  <- sd(TrajDirectionalChange(trajdata))
      
    } else {
      sdc <- NA
    }
    sd_dirchange <- c(sd_dirchange, sdc)
    setTxtProgressBar(pb, i)
    
  }
  return(sd_dirchange)
  
}

# Calculate OFT trial metrics using above functions

oft_trialmetrics <- function(oft_conc_data){
  oft_conc_data <- oft_conc_data %>% mutate(
    dist_from_center = calc_dist_from_center(end_x, end_z),
    euc_dist_trav = calc_eucdisttrav(start_x, start_z, end_x, end_z),
    tortuosity = calc_tortuosity(euc_dist_trav, tot_dist),
    mean_dirchange = calc_mean_dirchange(Subject_ID, token, trial_level),
    sd_dirchange = calc_sd_dirchange(Subject_ID, token, trial_level)
  )
  write.csv(oft_conc_data, paste0(write_dir, "OFT_trial_master.csv"), row.names = FALSE)
  return(oft_conc_data)
}


filenames <- list.files()[grepl("_objdistance.csv", list.files())]
print(filenames)
oft_data <- oft_concatenate(filenames)
print("oft conc done")
oft_data <- oft_trialmetrics(oft_data)
print("oft tm done")
# 

participant_list <- split(oft_data, as.factor(oft_data$Subject_ID))


compile_participantmetrics <- function(participant_list){
  part_master <- c()
  pb <- txtProgressBar(min = 0, max = length(participant_list), style = 3)
  print("Compiling Participant Metrics: ")
  
  for (i in 1:length(participant_list)){
    sub_data <- participant_list[[i]][grepl("TestScene", participant_list[[i]]$trial_level), ]
    
    subj_id <- participant_list[[i]]$Subject_ID[1]
    token <- participant_list[[i]]$token[1]
    
    oall_means <- colMeans(as.data.frame(sub_data)[,11:19], na.rm = TRUE)
    bytarget_data <- split(sub_data, sub_data$target_obj)
    
    if (nrow(sub_data) != 0 & length(names(bytarget_data)) >= 4){
      oall_sds <- colSds(as.matrix(as.data.frame(sub_data)[,11:19]))
      chair_sds <- colSds(as.matrix(bytarget_data$chFolding.A_LOD0[,11:19]))
      sball_sds <- colSds(as.matrix(bytarget_data$'Soccer Ball'[,11:19]))
      cone_sds <- colSds(as.matrix(bytarget_data$cone_clean[,11:19]))
      bucket_sds <- colSds(as.matrix(bytarget_data$Bucket_clean[,11:19]))
      
      chair_means <- colMeans(as.data.frame(bytarget_data$chFolding.A_LOD0)[,11:19])
      sball_means <- colMeans(as.data.frame(bytarget_data$'Soccer Ball')[,11:19])
      cone_means <- colMeans(as.data.frame(bytarget_data$cone_clean)[,11:19])
      bucket_means <- colMeans(as.data.frame(bytarget_data$Bucket_clean)[,11:19])
      
      # K- Means Cluster (clusters = 4)
      fit <- kmeans(sub_data[,8:9], 4)
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
      
      # Standard Deviation of the Ellipse metrics
      # calc_sde(id = 1, points = cbind(bytarget_data$chFolding.A_LOD0$end_x, bytarget_data$chFolding.A_LOD0$end_z))
      # sdeatt_chair <- sdeatt
      # calc_sde(id = 2, points = cbind(bytarget_data$'Soccer Ball'$end_x, bytarget_data$'Soccer Ball'$end_z))
      # sdeatt_sball <- sdeatt
      # calc_sde(id = 3, points = cbind(bytarget_data$Bucket_clean$end_x, bytarget_data$Bucket_clean$end_z))
      # sdeatt_bucket <- sdeatt
      # calc_sde(id = 4, points = cbind(bytarget_data$cone_clean$end_x, bytarget_data$cone_clean$end_z))
      # sdeatt_cone <- sdeatt
      
    } else {
      oall_sds <- rep(NA, 9)
      chair_sds <- rep(NA, 9)
      sball_sds <- rep(NA, 9)
      cone_sds <- rep(NA, 9)
      bucket_sds <- rep(NA, 9)
      
      
      chair_means <- rep(NA, 9)
      sball_means <- rep(NA, 9)
      cone_means <- rep(NA, 9)
      bucket_means <- rep(NA, 9)
      
      kmeans_ss_ratio <- NA
      kc_1_endx <- NA
      kc_1_endy <- NA
      kc_1_size <- NA
      kc_1_wss <- NA
      kc_1_hg <- NA
      kc_2_endx <- NA
      kc_2_endy <- NA
      kc_2_size <- NA
      kc_2_wss <- NA
      kc_2_hg <- NA
      kc_3_endx <- NA
      kc_3_endy <- NA
      kc_3_size <- NA
      kc_3_wss <- NA
      kc_3_hg <- NA
      kc_4_endx <- NA
      kc_4_endy <- NA
      kc_4_size <- NA
      kc_4_wss <- NA
      kc_4_hg <- NA
      
      # Standard Deviation of the Ellipse metrics
      
      # sdeatt_chair <- NA
      # 
      # sdeatt_sball <- NA
      # 
      # sdeatt_bucket <- NA
      # 
      # sdeatt_cone <- NA
    }
    
    # TODO: FIX COLNAMES OF PART MASTER TO HAVE CORRECT NAMES
    part_data <- c(subj_id, token, oall_means, oall_sds, 
                   chair_means, chair_sds, sball_means, sball_sds, 
                   bucket_means, bucket_sds, cone_means, cone_sds)
    
    # Get colnames
    metrics_names <- colnames(sub_data)[11:19]
    oall_names <- c(paste0("mean_", metrics_names), paste0("stddev_", metrics_names))
    object_names <- c(paste0("chair_", oall_names), paste0("sball_", oall_names),
                      paste0("bucket_", oall_names), paste0("cone_", oall_names))
    pm_names <- c("Subject_ID", "token", oall_names, object_names)
    part_master <- rbind(part_master, part_data)
    
    colnames(part_master) <- pm_names
    setTxtProgressBar(pb, i)
  }
  write.csv(part_master, paste0(write_dir, "OFT_participant_master.csv"), row.names = FALSE)
  return(part_master)
}

compile_participantmetrics(participant_list)
