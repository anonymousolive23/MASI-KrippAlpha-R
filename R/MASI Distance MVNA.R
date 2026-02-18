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

#write a function to calculate MASI distance (see:https://www.cs.columbia.edu/nlp/papers/2006/passonneau_06.pdf)
pybuiltins = import_builtins() #import built-in functions from python
py_install("nltk") #download natural language processing toolkit (NLTK) module to miniconda
nltk = import("nltk") #import NLTK as an R module
masi = function(x,y,split = " ") 
{
  if(length(str_split(x,split,simplify = F)[[1]]) == 1) 
  {
    x = str_split(x,split,simplify = F)
  }else
  {
    x = unlist(str_split(x,split,simplify = F)) 
  }
  
  if(length(str_split(y,split,simplify = F)[[1]]) == 1) 
  {
    y = str_split(y,split,simplify = F) 
  }else
  {
    y = unlist(str_split(y,split,simplify = F)) 
  }
  
  masiD =  nltk$masi_distance(pybuiltins$set(x),pybuiltins$set(y)) #calculate MASI distance using nltk built-in functions
  masiD  #output MASI distance
}

##############################################################################################################################

merge = read.csv("Combined Coding Matrix for MVAlpha.csv") #import ALL codes, preprocessed to contain coders by column and units by row

#calculating weight matrix for all observed combination of labels using MASI distance
labelsCombAll = unique(unlist(merge)) #create a vector of all the unique labels (codes) in the dataset we imported
distMasi = matrix(nrow = length(labelsCombAll),ncol = length(labelsCombAll), #create an empty matrix with all the combinations of codes present in the data for MASI distances
                   dimnames = list(labelsCombAll,labelsCombAll))

for(i in 1:nrow(distMasi)) #over all the permutations in the matrix, calculate MASI distances
  for(j in 1:ncol(distMasi))
  {
    distMasi[i,j] = 1-masi(labelsCombAll[i],labelsCombAll[j],"|")
  }

mv_alpha = krippen.alpha.raw(merge, weights = distMasi,categ.labels = rownames(distMasi)) #use the MASI distances as weights to calculate kripp's a for the full dataset
mv_alpha$est

##############################################################################################################################
save.image(file = "mvalpha.RData")

load(file = "mvalpha.RData")
