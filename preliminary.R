library(tidyverse)
working_dir <- "D:/Rob/SNL/Hellman"
setwd(working_dir)

qualtrics <- read.csv("Hellman_Qualtrics_12012020.csv")

sot_OCT <- read.csv("SOT-QC_Oct_28_2020.csv")
sot_NOV <- read.csv("SOT-QC_Nov_06_2020.csv")
sot_DEC <- read.csv("SOT-QC_Dec_17_32_03.csv")

oft_OCT <- read.csv("OFT-QC_Oct_28_2020.csv")
oft_NOV <- read.csv("OFT-QC_Nov_06_2020.csv")
oft_DEC <- read.csv("OFT-QC_Dec_17_32_03.csv")

OFT <- read.csv("OFT_participant_master.csv")

sot_QC <- rbind(sot_OCT, sot_NOV, sot_DEC)
oft_QC <- rbind(oft_OCT, oft_NOV, oft_DEC)

colnames(OFT)[1:2] <- c("worker_ID", "token_ID")
colnames(sot_QC)[2] <- "SOT_token_ID"
colnames(qualtrics)[19] <- "worker_ID"

OFT_merge <- merge(OFT, oft_QC, by = c("worker_ID", "token_ID"), all.x = TRUE, all.y = TRUE)

SOFT_merge <- merge(OFT_merge, sot_QC, by = "worker_ID", all.x = TRUE, all.y = TRUE)

QSOFT_merge <- merge(qualtrics, SOFT_merge, by = "worker_ID", all.x = TRUE, all.y = TRUE)

write.csv(QSOFT_merge, "Hellman_Master.csv", row.names = FALSE)

nums <- unlist(lapply(SOFT_merge, is.numeric))  
num_QSOFT <- SOFT_merge[ , nums]


subsetnums <- QSOFT_merge[, c(285:296, 306:314, 406:409)]
filtered_hellman <- subsetnums[complete.cases(subsetnums), ]
options(scipen=999)
colnames(filtered_hellman)[1:12] <- paste0("SC_", c("Demographics", "AES", "AQ-10", "AUDIT", "BIS-11", "EAT-26",
                                      "O-LIFE", "OCI-R", "SBSOD", "SDS", "STAI-TY2", "VideoGameQuestionnaire"))
hellman_corr <- rcorr(as.matrix(filtered_hellman), type = "pearson")



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
hellmat <- hellman_flatcorr[complete.cases(hellman_flatcorr), ]

hell_sig <- hellmat[hellmat$p < 0.10, ]
hs <- hell_sig[grepl('SC', hell_sig$row) | grepl('SC', hell_sig$column), ]

col <- colorRampPalette(c("#4477AA", "#77AADD", "#FFFFFF", "#EE9988", "#BB4444"))
corrplot(hellman_corr$r, method="color", col=col(200),  
         type="upper", order='alphabet', 
         addCoef.col = "black",# Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         p.mat = hellman_corr$P, sig.level = 0.10, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=FALSE, tl.cex = 1, number.cex = 0.8,
         title = "Hellman Correlations (p < 0.10)",
         
         
)


