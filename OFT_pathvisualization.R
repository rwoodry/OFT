setwd("C:/Users/UCI - Robert Woodry/Desktop/Research/Tasks/OFT_Alpha_11-19-19")

library(tidyverse)

OFTpaths <- function(filename_string){
  posdata <- read.csv(filename_string)
  
  posdata <- posdata %>% mutate(trial_type = substr(trial_level, 1, 5))
  posdata$trial_type <- as.factor(posdata$trial_type)
  
  
  g <- ggplot(data = posdata, mapping = aes(x = pos_x, y = pos_z, group = trial_level, color = target_obj, linetype = trial_type))
  g <- g + geom_path(size = 1, arrow = arrow(angle = 20, length = unit(0.1, "inches"), type = "closed"))
  g <- g+ facet_wrap(vars(target_obj), nrow = 2)
  
  g <- g + scale_linetype_manual(values=c("solid", "longdash", "dotted"))
  
  cone <- geom_point(aes(x = 98425.07, y = -1010.915), size = 5, color = "blue")
  bucket <- geom_point(aes(x = 98685.8, y = -1060.1), size = 5, color = "red")
  chair <- geom_point(aes(x = 98541, y = -866), size = 5, color = "green")
  soccerball <- geom_point(aes(x = 98689.8, y = -832), size = 5, color = "purple")
  
  g <- g + soccerball + bucket + cone + chair
  g <- g + coord_fixed(ratio = 1)
  return(g)
}

OFTendlocs <-function(participant_nums){
  master_objdist <- c()
  for (i in 1:length(participant_nums)){
    file <- read.csv(sprintf("%d_objdistance.csv", participant_nums[i]))
    file <- cbind(rep(participant_nums[i], nrow(file)), file)
    master_objdist <- rbind(master_objdist, file)
  }
  
  colnames(master_objdist)[1] <- "Subject"
  
  g <- ggplot(data = master_objdist[grepl("TestScene", master_objdist$trial_level), ], mapping = aes(
    x = end_x, y = end_z, group = trial_level, color = as.factor(Subject)))
  
  g <- g + geom_point() + facet_wrap(vars(target_obj), nrow=2)
  
  cone <- geom_text(aes(x = 98425.07, y = -1010.915, label = "Co"), size = 3, color = "blue", alpha = 0.3)
  bucket <- geom_text(aes(x = 98685.8, y = -1060.1, label = "Bu"), size = 3, color = "red")
  chair <- geom_text(aes(x = 98541, y = -866, label = "Ch"), size = 3, color = "green")
  soccerball <- geom_text(aes(x = 98689.8, y = -832, label = "So"), size = 3, color = "purple")
  
  g <- g + soccerball + bucket + cone + chair
  g <- g + coord_fixed(ratio = 1)
  return(g)
}