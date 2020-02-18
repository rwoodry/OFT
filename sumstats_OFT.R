library(tidyverse)

odlist <- list.files()[grepl("objdistance.csv", list.files())]

summarise_OFT <- function(filename){
  data <- read.csv(filename)
  subjid <- strsplit(filename, "_")[[1]][1]
  sumstats <- data[9:nrow(data), ] %>% group_by(target_obj) %>% 
    summarise(
      subject = sprintf("%03d", as.numeric(subjid)), count = n(), m_dtarget = mean(delta_target), s_dtarget = sd(delta_target),
      m_comptime = mean(completion_time))
  return(sumstats)
}

sumstats_OFT <- c()
for (i in 1:length(odlist)){
  print(odlist[i])
  sumData <- summarise_OFT(odlist[i])
  sumstats_OFT <- rbind(sumstats_OFT, sumData)
}
sumstats_OFT <- arrange(sumstats_OFT[, c(2, 1, 3:ncol(sumstats_OFT))], subject)



OFTclusterplot <- function(filename){
  cone <- geom_text(aes(x = 98425.07, y = -1010.915, label = "Co"), size = 3, color = "black")
  bucket <- geom_text(aes(x = 98685.8, y = -1060.1, label = "Bu"), size = 3, color = "black")
  chair <- geom_text(aes(x = 98541, y = -866, label = "Ch"), size = 3, color = "black")
  soccerball <- geom_text(aes(x = 98689.8, y = -832, label = "So"), size = 3, color = "black")
  
  subjid <- strsplit(filename, "_")[[1]][1] 
  obj3 <- read.csv(filename)
  
  objdata <- obj3[9:nrow(obj3), ]
  obj_clust <- kmeans(objdata[, 6:7], 4)
  obj_clust$cluster <- as.character(obj_clust$cluster)
  
  g <- ggplot() + geom_point(data=objdata, mapping=aes(end_x, end_z, color=target_obj)) + 
    geom_point(mapping = aes_string(x=obj_clust$centers[, "end_x"], 
                                    y = obj_clust$centers[,"end_z"]), color = "red", size = 4) +
    cone + bucket + chair + soccerball + coord_fixed(ratio = 1)
 
  ggsave(g, file=sprintf("OFTcluster_%03d.png", as.numeric(subjid)))
  
  
}

  