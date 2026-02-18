library(tidyr)
library(dplyr)
library(stats)
library(psych)
library(janitor)

#setup
setwd("your working directory")
Coder_1 = read.csv("your binary coding matrix 1.csv")
Coder_2 = read.csv("your binary coding matrix 2.csv")
Coder_3 = read.csv("your binary coding matrix 3.csv")

#cleaning names
names(Coder_1) <- gsub("\\.", "_", names(Coder_1))
colnames(Coder_1) <- gsub("_$", "", colnames(Coder_1))

names(Coder_2) <- gsub("\\.", "_", names(Coder_2))
colnames(Coder_2) <- gsub("_$", "", colnames(Coder_2))

names(Coder_3) <- gsub("\\.", "_", names(Coder_3))
colnames(Coder_3) <- gsub("_$", "", colnames(Coder_3))

#vectorise names
all_cols = colnames(Coder_1) #extract the headers (codes) from the binary coding matrix

#Create the new column by applying a function to each row
Coder_1$Codes <- apply(Coder_1[, all_cols], 1, function(row) {
  codes <- all_cols[which(row == 1)]
  paste(codes, collapse = "|")
})

Coder_1 = Coder_1[c("ResponseID", "Codes")]

Coder_2$Codes <- apply(Coder_2[, all_cols], 1, function(row) {
  codes <- all_cols[which(row == 1)]
  paste(codes, collapse = "|")
})

Coder_2 = Coder_2[c("ResponseID", "Codes")]

Coder_3$Codes <- apply(Coder_3[, all_cols], 1, function(row) {
  codes <- all_cols[which(row == 1)]
  paste(codes, collapse = "|")
})

Coder_3 = Coder_3[c("ResponseID", "Codes")]

#processing
colnames(Coder_1) = c("ResponseID", "Coder_1")
colnames(Coder_2) = c("ResponseID", "Coder_2")
colnames(Coder_3) = c("ResponseID", "Coder_3")

newdf = merge(Coder_1, Coder_2, by = "ResponseID")
newdf = merge(newdf, Coder_3, by="ResponseID")

newdf = newdf[-1]
newdf = replace(newdf, newdf=="", "|")


write.csv(newdf, "Combined Coding Matrix for MVAlpha.csv", row.names = F)
