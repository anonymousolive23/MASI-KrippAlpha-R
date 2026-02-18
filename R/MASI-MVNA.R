library(irrCAC)
library(stringr)

#setup
setwd("your working directory")
getOption("max.print")
options("max.print"=5000)

#setup to use reticulate and miniconda
reticulate::install_miniconda() #install miniconda. paste the directory output from R after installation is done in the line below for condaenv
reticulate::use_miniconda(condaenv = "your miniconda installation directory", required = TRUE) #force R to use miniconda
reticulate::py_config() #check that this went correctly - great!

library(reticulate) #import full list of reticulate functions. IMPORTANT: DO NOT DO THIS BEFORE LINES ABOVE OR R WILL USE THE DEFAULT PYTHON INSTALL ON YOUR BASE MACHINE; IF THERE IS NO DEFAULT PYTHON INSTALL THEN IT WILL FAIL

#setup for functions
pybuiltins = import_builtins() #import built-in functions from python
py_install("nltk") #download natural language processing toolkit (NLTK) module to miniconda
nltk = import("nltk") #import NLTK as an R module

#write a function to calculate MASI distance (see:https://www.cs.columbia.edu/nlp/papers/2006/passonneau_06.pdf)
MASI_dist = function(x, y, sep = " "){
  if(length(str_split(x, sep, simplify = F)[[1]]) == 1){ #if, after splitting the input using the separator specified, the vector = 1;
    x = str_split(x, sep, simplify = F)} #the input is set as x;
  else{x = unlist(str_split(x, sep, simplify = F)) #else, unlist the input and set as character 
  }
  
  if(length(str_split(y, sep, simplify = F)[[1]]) == 1){ #if, after splitting the input using the separator specified, the vector = 1;
    y = str_split(y, sep, simplify = F)} #the input is set as y;
  else{y = unlist(str_split(y, sep, simplify = F)) #else, unlist the input and set as character 
  }
  
  masi_distance = nltk$masi_distance(pybuiltins$set(x), pybuiltins$set(y)) #calculate MASI distance using nltk built-in functions
  masi_distance  #output MASI distance
}

##############################################################################################################################

df = read.csv("Combined Coding Matrix for MVAlpha.csv") #import ALL codes, preprocessed to contain coders by column and units by row

compute_weights = function(df, sep = "|") {
  all_codes = unique(unlist(merge)) #create a vector of all the unique labels (codes) in the dataset we imported
  alpha_mat = matrix( #create an empty matrix which:
    nrow = length(all_codes), #has nrow = the number of all the unique codes we extracted above
    ncol = length(all_codes), #has ncol = the number of all the unique codes we extracted above
    dimnames = list(all_codes, all_codes) #set the names of the rows*cols to be all the unique codes we extracted above
  )
  for (i in seq_len(nrow(alpha_mat))) { #iterate over every row of the matrix
    for (j in seq_len(ncol(alpha_mat))) { #iterate over every column of the matrix
      alpha_mat[i,j] = 1 - MASI_dist(all_codes[i], all_codes[j], sep) #for each ij combination in the matrix, the cell contents should be 1-the MASI distance calculated using the masi function above
    }
  }
  return(alpha_mat) #output the matrix
}

alpha_matrix = compute_weights(df)

mv_alpha = krippen.alpha.raw(df, weights = alpha_matrix, categ.labels = rownames(alpha_matrix)) #use the alpha matric as weights to calculate kripp's a for the full dataset
mv_alpha$est

##############################################################################################################################
save.image(file = "mvalpha.RData")
load(file = "mvalpha.RData")
