library(tidyverse)
working_dir <- "D:/SampleData/Hellman/preliminary/"
setwd(working_dir)

qualtrics <- read.csv("Hellman_Preliminary.csv")
sot_OCT <- read.csv("SOT-QC_Oct_28_2020.csv")
sot_NOV <- read.csv("SOT-QC_Nov_06_2020.csv")
