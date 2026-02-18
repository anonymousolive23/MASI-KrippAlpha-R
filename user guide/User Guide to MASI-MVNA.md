# User Guide to Multi-Value Krippendorff's Alpha via MASI Distances

## Quickstart guide

For those uninterested in details who simply want to know how to apply the code (although I would strongly suggest you read through the guide thoroughly before attempting to use the code), here is a quickstart guide:
1. Data should be formatted as follows:

|         Coder_1        |         Coder_2        |
|  --------------------- | ---------------------- |
|     code_a\|code_b     |         code_a         |
|     code_b\|code_c     | code_a\|code_b\|code_c |

Use \| as separators between codes and _ to join spaces in words. Cells where coders did not find an appropriate code (could not code) should have a single \| as its content. Cells where coders did not code specific data (missingness) should be left blank. See also [here](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/main/data/Data%20Format%20Example.csv).

2. If data needs to be transformed from a [binary coding matrix](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/main/data/Binary%20Coding%20Matrix%20Example.csv) to the format specified above, use [this](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/main/R/Data%20Processing%20for%20MASI%20Distance.R). Dependencies are R packages `tidyr`, `dplyr`, `stats`, `psych`, and `janitor`.
3. If data is formatted appropriately and just needs to be analysed, use [this](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/main/R/MASI%20Distance%20MVNA.R). Dependencies are R packages `irrCAC`, `stringr`, and `reticulate`.
4. Change working directories in `setwd()` as appropriate to a directory which contains all your necessary data files.
5. Change miniconda directory in `reticulate::use_miniconda()` as appropriate to your miniconda installation.
6. Change filenames in `read.csv()`, `save.image()`, and `load()` as appropriate; the former to your existing data files and the latter to filename appropriate for your project.

## Introduction

This is a short guide for the use of the R code I wrote to calculate Krippendorff's Alpha via MASI distances. For technical details, see [here](https://www.cs.columbia.edu/nlp/papers/2006/passonneau_06.pdf).

The main reason one would want to do this is to derive intercoder reliability/interannotater agreement/interrater agreement with qualitative coding which *DOES NOT ASSUME ORTHOGONALITY*. The reason you do not assume orthogonality can be multiple, but should be theoretically-driven. The outcome this technique yields can also be achieved using the r package [mvna](https://cran.r-project.org/package=mvna). The main difference being the code here bypasses computational limitations inherent to mvna, which calculates percentage disagreement through permutation computations. By contrast, my code delegates the computation to Python's [nltk](https://www.nltk.org/).

This guide consists of two sets of R code, **Data Processing for MASI Distance.R** and **MASI Distance MVNA.R**. Both are important and useful but only the latter is strictly necessary. As the names indicate, the former is for processing data into the necessary format, and the latter is for the actual computation.

## Data Format

*This description is given for the sake of verification and completeness. If you need to convert data from a binary coding matrix to the format specified, use* **Data Processing for MASI Distance.R**.

Your data should be in a Comma-Separated-Values (.csv) file. The data should consist of *i+1* rows - each *i* representing one piece of data, i.e., one participant response, paragraph, or whatever your data breakdown is - with *j* columns - each *j* representing one coder. The first row (*i*) of your file should be headers (i.e., ID labels for the coders).

In each cell (combination of *ij*), you should include all the codes applied to that piece of data *i* by each coder *j*. The codes should be separated with a vertical bar "\|"; DO NOT use a comma "," because of the file format. If the name of your code is more than one word (i.e., a phrase or compound noun), *ENSURE THERE ARE NO SPACES BETWEEN THE WORDS*. Use either an underscore "\_" or simply join the words together. **The preferred option is to use "\_" to join words**.

If in a cell *ij* the coder *j* did not find a suitable code to apply to data *i* (no code applicable), enter your separator "\|". If in a cell *ij* the coder *j* did not code the data *i* (missingness), leave cell blank.

*A visual example for the data format is given in file* **Data Format Example.csv**.

## Data Processing for MASI Distance.R

*This R code is intended for converting a binary coding matrix to the format needed by* **MASI Distance MVNA.R**. *If your data is formatted properly, you may skip this section*.

A binary coding matrix is when data consists of *i+1* rows - each *i* representing one piece of data - and *j+1* columns - each *j* representing one code that could be applied. The first row (*i*) of your file should be headers (i.e., names for codes that can be applied) and the first column (*j*) of your file should be data IDs (i.e., IDs for each piece of data). You will notice this does not mention multiple coders. That is by design. *Each n* coder should have *n* binary coding matrix.

*A visual example for the binary coding matrix is given in file* **Binary Coding Matrix Example.csv**.

This code requires you to have installed R packages `tidyr`, `dplyr`, `stats`, `psych`, and `janitor` prior to starting. If you are missing any of the packages, use "install.packages(*"package"*)" for the relevant package, substituting *"package"* with the name of the package.

#### Things you should alter in this code for it to work **(Please read all before attempting changes):**

-   Line 8:

`setwd("C:/Users/ghtan/Downloads/Research Internship/Open Secrets Data/Intercoder Reliability")`

Change contents of `setwd()` to the working directory in which you have all your binary coding matrix files.

-   Lines 9-11:

`Coder_1 = read.csv("Leo_Code-Document_Analysis(Final).csv")`

`Coder_2 = read.csv("MS_Random Coding Subset Combined(LeoModFinal).csv")`

`Coder_3 = read.csv("SV_Random Coding Subset Combined(LeoModFinal).csv")`

Change the contents of `read.csv()` to file names for the binary coding matrices. You do not need to have 3 coders, remove or add more lines using the same format as needed.

-   Lines 14-21:

`names(Coder_1) <- gsub("\\.", "_", names(Coder_1))`

`colnames(Coder_1) <- gsub("_$", "", colnames(Coder_1))`

`names(Coder_2) <- gsub("\\.", "_", names(Coder_2))`

`colnames(Coder_2) <- gsub("_$", "", colnames(Coder_2))`

`names(Coder_3) <- gsub("\\.", "_", names(Coder_3))`

`colnames(Coder_3) <- gsub("_$", "", colnames(Coder_3))`

As above, you do not need to have 3 coders, remove or add more lines using the same format as needed. This section presumes that amongst your codes, one or more code names have spaces; it substitutes the periods "." R automatically adds in between words with underscores "\_", and removes the undescores "\_" R automatically adds at the end of a code if a space is present. If your binary coding matrices are clean this step is not necessary.

-   Line 24:

`all_cols = colnames(Coder_1) #extract the headers (codes) from the binary coding matrix`

If you only want to extract a set number of codes from the dataset, add `[c(i:j)]` at the end of the code at line 24, with i and j being indices for the columns you want to extract the codes from.

-   Lines 27-46:

`Coder_1$Codes <- apply(Coder_1[, all_cols], 1, function(row) {`

`codes <- all_cols[which(row == 1)]`

`paste(codes, collapse = "|")`

`})`

`Coder_1 = Coder_1[c("ResponseID", "Codes")]`

`Coder_2$Codes <- apply(Coder_2[, all_cols], 1, function(row) {`

`codes <- all_cols[which(row == 1)]`

`paste(codes, collapse = "|")`

`})`

`Coder_2 = Coder_2[c("ResponseID", "Codes")]`

`Coder_3$Codes <- apply(Coder_3[, all_cols], 1, function(row) {`

`codes <- all_cols[which(row == 1)]`

`paste(codes, collapse = "|")`

`})`

`Coder_3 = Coder_3[c("ResponseID", "Codes")]`

These lines duplicate the code from lines 27-32 across the 3 coders. Only change if you have a different *n* number of coders by duplicating or reducing the code to fit.

-   Lines 49-51:

`colnames(Coder_1) = c("ResponseID", "Coder_1")`

`colnames(Coder_2) = c("ResponseID", "Coder_2")`

`colnames(Coder_3) = c("ResponseID", "Coder_3")`

These lines duplicate the code from line 49. Only change if you have a different *n* number of coders by duplicating or reducing the code to fit.

-   Lines 53-54:

`newdf = merge(Coder_1, Coder_2, by = "ResponseID")`

`newdf = merge(newdf, Coder_3, by="ResponseID")`

If you have 2 coders, delete line 54. If you have more than 3 coders, duplicate line 54, substituting `Coder_3` with `Coder_n` each time.

## MASI Distance MVNA.R

*This R code is what calculates MASI Distance, before then converting to MVNA. Please read the following carefully before attempting to use the code.*

This code is relatively complex because it is how you build an interface between R and Python, using the r package `reticulate`. This package is useful but might present challenges to newcomers, since `reticulate` is set to retrieve a native Python installation by default (i.e., CmdPrompt on Windows), which many people are not comfortable with doing technically but which also necessitates other pre-preparation steps.

This code resolves that by building an alternative miniconda directory ([see here for details](https://www.anaconda.com/docs/getting-started/miniconda/main)), forcing R to use that directory, and subsequently doing all the pre-preparation steps using R code. Parts of this code should only ever be run once, and then never run again. That is by design. That section of code will be highlighted below alongside the changes needed to use the code.

This code requires you to have installed R packages `irrCAC`, `stringr`, and `reticulate` prior to starting. If you are missing any of the packages, use "install.packages(*"package"*)" for the relevant package, substituting *"package"* with the name of the package.

You may note that while R package `reticulate` is needed for the code, we do not import the whole `reticulate` library until line 14, after a lot of setup. That is by design. You may be tempted to install the `reticulate` library before then. *DO NOT DO THIS*, because `reticulate` will attempt to retrieve a native Python installation.

#### Things you should alter in this code for it to work **(Please read all before attempting changes):**

-   Line 5:

`setwd("C:/Users/ghtan/Downloads/Research Internship/Open Secrets Data/Intercoder Reliability")`

Change contents of `setwd()` to the working directory in which you have all your binary coding matrix files.

-   Line 10 **(VERY IMPORTANT):**

`reticulate::install_miniconda() #install miniconda. paste the directory output from R after installation is done in the line below for condaenv`

**THIS LINE SHOULD ONLY BE RUN ONCE, WHICH IS WHEN YOU FIRST USE THIS CODE**. This line installs miniconda and creates a miniconda directory. As the comments in the code suggest, the console output will print the directory where miniconda was installed. Copy the directory output and paste it in line 11 (addressed below). Once you have done this step once, you should comment out the code line (Ctrl + Shift + C in R) to avoid doing it again.

-   Lines 11-12:

`reticulate::use_miniconda(condaenv = "C:/Users/ghtan/AppData/Local/r-miniconda", required = TRUE) #force R to use miniconda`

`reticulate::py_config() #check that this went correctly - great!`

As mentioned in the line above, change the contents of `reticulate::use_miniconda()` to `(condaenv = "your directory", required = TRUE)`. Line 11 forces `reticulate` to use your miniconda installation, and line 12 extracts the directories that `reticulate` has attached to. The output should look something like:

  python: C:/Users/ghtan/AppData/Local/r-miniconda/python.exe

  libpython: C:/Users/ghtan/AppData/Local/r-miniconda/python312.dll

  pythonhome: C:/Users/ghtan/AppData/Local/r-miniconda

  version: 3.12.12 \| packaged by conda-forge \| (main, Oct 22 2025, 23:13:34) [MSC v.1944 64 bit (AMD64)]

  Architecture: 64bit

  numpy: [NOT FOUND]

  NOTE: Python version was forced by use_python() function

**CHECK THAT "pythonhome:" IS FOLLOWED BY THE DIRECTORY YOU SET IN LINE 11. If it is not, restart your R session (Ctrl + Shift + F10) and run the previous lines again.**

-   Line 44:

`merge = read.csv("Combined Coding Matrix for MVAlpha.csv") #import ALL codes, preprocessed to contain coders by column and units by row`

If your data file has a different name, change contents of `read.csv()` to the appropriate file name.

-   Lines 61-62

`save.image(file = "mvalpha.RData")`

`load(file = "mvalpha.RData")`

Line 61 saves the output of your MVNA calculation to a .RData file. Change the filename "*mvalpha.RData*" as appropriate. Line 62 loads a saved MVNA calculation from a .Rdata file. Change the filename "*mvalpha.RData*" as appropriate.


