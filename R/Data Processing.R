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
clean_colnames = function(df) {
  new_names = gsub("\\.", "_", names(df)) #substitutes any instance of . with _
  new_names = gsub("_$", "", new_names) #substitutes instances ending in _ with blank space
  names(df) = new_names #applies the new, cleaned colnames
  df #output the cleaned dataframe
}

Coder_1 = clean_colnames(Coder_1)
Coder_2 = clean_colnames(Coder_2)
Coder_3 = clean_colnames(Coder_3)

#vectorise names and condense codes from wide format to single cell
condense_codes = function(df, id_column) {
  all_cols = setdiff(colnames(df), id_column) #extract all unique colnames in the dataframe except the id column
  
  df$Codes = apply(df[, all_cols, drop = FALSE], 1, function(row) { #create a new column Codes and check for all strings extracted above. handle by row with different conditions
    row[row == ""] = NA #if cells are empty, handle as NA
    if (all(is.na(row))) { #if all cells within a row are NA (empty), return as blank
      return("")
    }
    codes = all_cols[which(row == 1)] #if cell = 1, return the string extracted
    if (length(codes) == 0 && all(row %in% c(0, NA))) { #if all cells within a row are 0 (no code applicable),
      return("|") #return as |
    }
    paste(codes, collapse = "|") #paste the code(s) extracted with | as separator
  })
  df = df[, c(id_column, "Codes"), drop = FALSE] #drop all columns that are not the id column or the new Codes column
  return(df) #output the new dataframe
}

Coder_1 = condense_codes(Coder_1, "ResponseID")
Coder_2 = condense_codes(Coder_2, "ResponseID")
Coder_3 = condense_codes(Coder_3, "ResponseID")

#processing
colnames(Coder_1) = c("ResponseID", "Coder_1")
colnames(Coder_2) = c("ResponseID", "Coder_2")
colnames(Coder_3) = c("ResponseID", "Coder_3")

newdf = merge(Coder_1, Coder_2, by = "ResponseID")
newdf = merge(newdf, Coder_3, by="ResponseID")

newdf = newdf[-1]

write.csv(newdf, "Combined Coding Matrix for MVAlpha.csv", row.names = F)
