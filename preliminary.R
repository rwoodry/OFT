library(tidyverse)
working_dir <- "D:/SampleData/Hellman/preliminary/"
setwd(working_dir)

qualtrics <- read.csv("Hellman_Preliminary.csv")
sot_OCT <- read.csv("SOT-QC_Oct_28_2020.csv")
sot_NOV <- read.csv("SOT-QC_Nov_06_2020.csv")
oft_OCT <- read.csv("OFT-QC_Oct_28_2020.csv")
oft_NOV <- read.csv("OFT-QC_Nov_06_2020.csv")
OFT <- read.csv("OFT_participant_master.csv")

sot_QC <- rbind(sot_OCT, sot_NOV)
oft_QC <- rbind(oft_OCT, oft_NOV)

colnames(OFT)[1:2] <- c("worker_ID", "token_ID")
colnames(sot_QC)[2] <- "SOT_token_ID"
colnames(qualtrics)[19] <- "worker_ID"

OFT_merge <- merge(OFT, oft_QC, by = c("worker_ID", "token_ID"), all.x = TRUE, all.y = TRUE)

SOFT_merge <- merge(OFT_merge, sot_QC, by = "worker_ID", all.x = TRUE, all.y = TRUE)

QSOFT_merge <- merge(qualtrics, SOFT_merge, by = "worker_ID", all.x = TRUE, all.y = TRUE)

write.csv(QSOFT_merge, "Hellman_Master.csv", row.names = FALSE)
  
nums <- unlist(lapply(SOFT_merge, is.numeric))  
num_QSOFT <- SOFT_merge[ , nums]

hellman_corr <- rcorr(as.matrix(num_QSOFT))

flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame(
    row = rownames(cormat)[row(cormat)[ut]],
    column = rownames(cormat)[col(cormat)[ut]],
    cor  =(cormat)[ut],
    p = pmat[ut]
  )
}

hellman_flatcorr <- flattenCorrMatrix(hellman_corr$r, hellman_corr$P)
hmat <- hellman_flatcorr[complete.cases(hellman_flatcorr), ]

