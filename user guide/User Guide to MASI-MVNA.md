# User Guide to Multi-Value Krippendorff's Alpha via MASI Distances
## Important Note: This is an updated guide for the most up-to-date versions of Data Processing.R and MASI-MVNA.R. The new version includes some significant quality of life improvements over the deprecated version, including by wrapping most of the code into functions that can be duplicated as many times as necessary. That also means the code structure has changed enough such that the old versions were deprecated.
## Quickstart guide

For those uninterested in details who simply want to know how to apply the code (although I would strongly suggest you read through the guide thoroughly before attempting to use the code), here is a quickstart guide:
1. Data should be formatted as follows:

|         Coder_1        |         Coder_2        |
|  --------------------- | ---------------------- |
|     code_a\|code_b     |         code_a         |
|     code_b\|code_c     | code_a\|code_b\|code_c |

Use \| as separators between codes and _ to join spaces in words. Cells where coders did not find an appropriate code (could not code) should have a single \| as its content. Cells where coders did not code specific data (missingness) should be left blank. See also [here](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/main/data/Data%20Format%20Example.csv).

2. If data needs to be transformed from a [binary coding matrix](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/main/data/Binary%20Coding%20Matrix%20Example.csv) to the format specified above, use [this](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/1783e95daf6795839389b6d259793014d0d00315/R/Data%20Processing.R). Dependencies are R packages `tidyr`, `dplyr`, `stats`, `psych`, and `janitor`.
4. If data is formatted appropriately and just needs to be analysed, use [this](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/1783e95daf6795839389b6d259793014d0d00315/R/MASI-MVNA.R). Dependencies are R packages `irrCAC`, `stringr`, and `reticulate`.
5. Change working directories in `setwd()` as appropriate to a directory which contains all your necessary data files.
6. Change miniconda directory in `reticulate::use_miniconda()` as appropriate to your miniconda installation.
7. Change filenames in `read.csv()`, `save.image()`, and `load()` as appropriate; the former to your existing data files and the latter to filename appropriate for your project.

## Introduction

This is a short guide for the use of the R code I wrote to calculate Krippendorff's Alpha via MASI distances. For technical details, see [here](https://www.cs.columbia.edu/nlp/papers/2006/passonneau_06.pdf).

The main reason one would want to do this is to derive intercoder reliability/interannotater agreement/interrater agreement with qualitative coding which *DOES NOT ASSUME ORTHOGONALITY*. The reason you do not assume orthogonality can be multiple, but should be theoretically-driven. The outcome this technique yields can also be achieved using the r package [mvna](https://cran.r-project.org/package=mvna). The main difference being the code here bypasses computational limitations inherent to mvna, which calculates percentage disagreement through permutation computations. By contrast, my code delegates the computation to Python's [nltk](https://www.nltk.org/).

This guide consists of two sets of R code, [**Data Processing.R**](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/b593a788111d444789b2d38dbb354d53d8ffef36/R/Data%20Processing.R) and [**MASI-MVNA.R**](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/c02c92272c03a6cefcd81a588f79199099ef419a/R/MASI-MVNA.R). Both are important and useful but only the latter is strictly necessary. As the names indicate, the former is for processing data into the necessary format, and the latter is for the actual computation.

## Data Format

*This description is given for the sake of verification and completeness. If you need to convert data from a binary coding matrix to the format specified, use* [**Data Processing.R**](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/b593a788111d444789b2d38dbb354d53d8ffef36/R/Data%20Processing.R).

Your data should be in a Comma-Separated-Values (.csv) file. The data should consist of *i+1* rows - each *i* representing one piece of data, i.e., one participant response, paragraph, or whatever your data breakdown is - with *j* columns - each *j* representing one coder. The first row (*i*) of your file should be headers (i.e., ID labels for the coders).

In each cell (combination of *ij*), you should include all the codes applied to that piece of data *i* by each coder *j*. The codes should be separated with a vertical bar "\|"; DO NOT use a comma "," because of the file format. If the name of your code is more than one word (i.e., a phrase or compound noun), *ENSURE THERE ARE NO SPACES BETWEEN THE WORDS*. Use either an underscore "\_" or simply join the words together. **The preferred option is to use "\_" to join words**.

If in a cell *ij* the coder *j* did not find a suitable code to apply to data *i* (no code applicable), enter your separator "\|". If in a cell *ij* the coder *j* did not code the data *i* (missingness), leave cell blank.

*A visual example for the data format is given in file* [**Data Format Example.csv**](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/f5df2b3d22ce293599515effdd6a07354ed1c7d6/data/Data%20Format%20Example.csv).

## [Data Processing.R](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/b593a788111d444789b2d38dbb354d53d8ffef36/R/Data%20Processing.R)

*This R code is intended for converting a binary coding matrix to the format needed by* [**MASI-MVNA.R**](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/c02c92272c03a6cefcd81a588f79199099ef419a/R/MASI-MVNA.R). *If your data is formatted properly, you may skip this section*.

A binary coding matrix is when data consists of *i+1* rows - each *i* representing one piece of data - and *j+1* columns - each *j* representing one code that could be applied. The first row (*i*) of your file should be headers (i.e., names for codes that can be applied) and the first column (*j*) of your file should be data IDs (i.e., IDs for each piece of data). You will notice this does not mention multiple coders. That is by design. *Each n* coder should have *n* binary coding matrix.

In each cell (combination of *ij*) outside of the first row (*i*) and first column (*j*), you should have 1 of 3 cell entries: **1** = if the code (*j*) **WAS** coded in the data unit (*i*), **0** = if the code (*j*) **WAS NOT** coded in the data unit (*i*), and left **blank** if the data unit (*i*) **WAS NOT CODED BY THE CODER**. Thus, every cell = 0 in a row where coders could not apply any of the available codes, and every cell is blank in a row where the coder did not code the data unit. This distinction is important because statistically, we want to distinguish between instances where no code is applicable and where coding is missing.

*A visual example for the binary coding matrix is given in file* [**Binary Coding Matrix Example.csv**](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/f5df2b3d22ce293599515effdd6a07354ed1c7d6/data/Binary%20Coding%20Matrix%20Example.csv).

This code requires you to have installed R packages `tidyr`, `dplyr`, `stats`, `psych`, and `janitor` prior to starting. If you are missing any of the packages, use "install.packages(*"package"*)" for the relevant package, substituting *"package"* with the name of the package.

#### Things you should alter in this code for it to work **(Please read all before attempting changes):**

-   Line 8:

`setwd("your working directory")`

Change contents of `setwd()` to the working directory in which you have all your binary coding matrix files.

-   Lines 9-11:

`Coder_1 = read.csv("your binary coding matrix 1.csv")`
`Coder_2 = read.csv("your binary coding matrix 2.csv")`
`Coder_3 = read.csv("your binary coding matrix 3.csv")`

Change the contents of `read.csv()` to file names for the binary coding matrices. You do not need to have 3 coders, remove or add more lines using the same format as needed.

-   Lines 21-23:

`Coder_1 = clean_colnames(Coder_1)`
`Coder_2 = clean_colnames(Coder_2)`
`Coder_3 = clean_colnames(Coder_3)`

As above, you do not need to have 3 coders, remove or add more lines using the same format as needed. This section uses a function `clean_colnames` defined in lines 21-23, which substitutes any instances of . with _ and removes any instances that end in _. This is an optional function but one which I find useful, since when importing codes R substitutes spaces between characters with . and spaces at the end of characters with _. This function cleans that up

-   Lines 44-46:

`Coder_1 = condense_codes(Coder_1, "ResponseID")`
`Coder_2 = condense_codes(Coder_2, "ResponseID")`
`Coder_3 = condense_codes(Coder_3, "ResponseID")`

As above, you do not need to have 3 coders, remove or add more lines using the same format as needed. This section uses a function `condense_codes` defined in lines 26-42, which extracts all unique colnames in your binary coding matrix except for your id_col, which we specify here as `"ResponseID"`. It then checks across each row in your binary coding matrix: if cell contents = "1", the code is documented for that row (codes are separated by "\|") in a new column `"Codes"`; if all cells in a row = "0", "|\" is imputed in the column `"Codes"` to represent "no code applicable"; if all cells in a row are blank, the column `"Codes"` is left blank. This distinguishes between codes that are present, no codes being applicable for a specific data unit, or missingness (i.e., coder did not code a specific data unit). The function then removes all columns redundant for future analyses and retains id_col and `"Codes"`.

-   Lines 49-51:

`colnames(Coder_1) = c("ResponseID", "Coder_1")`
`colnames(Coder_2) = c("ResponseID", "Coder_2")`
`colnames(Coder_3) = c("ResponseID", "Coder_3")`

As above, you do not need to have 3 coders, remove or add more lines using the same format as needed. *In a future iteration these lines will be integrated into function* `condense_codes` *defined in lines 26-42. I have tried and failed a few times to implement the integration and have given up on that for now*.

-   Lines 53-54:

`newdf = merge(Coder_1, Coder_2, by = "ResponseID")`
`newdf = merge(newdf, Coder_3, by="ResponseID")`

If you have 2 coders, delete line 54. If you have more than 3 coders, duplicate line 54, substituting `Coder_3` with `Coder_n` each time.

## [MASI-MVNA.R](https://github.com/anonymousolive23/MASI-KrippAlpha-R/blob/c02c92272c03a6cefcd81a588f79199099ef419a/R/MASI-MVNA.R)

*This R code is what calculates MASI Distance, before then converting to MVNA. Please read the following carefully before attempting to use the code.*

This code is relatively complex because it is how you build an interface between R and Python, using the r package `reticulate`. This package is useful but might present challenges to newcomers, since `reticulate` is set to retrieve a native Python installation by default (i.e., CmdPrompt on Windows), which many people are not comfortable with doing technically but which also necessitates other pre-preparation steps.

This code resolves that by building an alternative miniconda directory ([see here for details](https://www.anaconda.com/docs/getting-started/miniconda/main)), forcing R to use that directory, and subsequently doing all the pre-preparation steps using R code. Parts of this code should only ever be run once, and then never run again. That is by design. That section of code will be highlighted below alongside the changes needed to use the code.

This code requires you to have installed R packages `irrCAC`, `stringr`, and `reticulate` prior to starting. If you are missing any of the packages, use "install.packages(*"package"*)" for the relevant package, substituting *"package"* with the name of the package.

You may note that while R package `reticulate` is needed for the code, we do not import the whole `reticulate` library until line 14, after a lot of setup. That is by design. You may be tempted to install the `reticulate` library before then. *DO NOT DO THIS*, because `reticulate` will attempt to retrieve a native Python installation.

#### Things you should alter in this code for it to work **(Please read all before attempting changes):**

-   Line 5:

`setwd("your working directory")`

Change contents of `setwd()` to the working directory in which you have your combined coding matrix files.

-   Line 10 **(VERY IMPORTANT):**

`reticulate::install_miniconda() #install miniconda. paste the directory output from R after installation is done in the line below for condaenv`

**THIS LINE SHOULD ONLY BE RUN ONCE, WHICH IS WHEN YOU FIRST USE THIS CODE**. This line installs miniconda and creates a miniconda directory. As the comments in the code suggest, the console output will print the directory where miniconda was installed. Copy the directory output and paste it in line 11 (addressed below). Once you have done this step once, you should comment out the code line (Ctrl + Shift + C in R) to avoid doing it again.

-   Lines 11-12:

`reticulate::use_miniconda(condaenv = "your miniconda installation directory", required = TRUE) #force R to use miniconda`
`reticulate::py_config() #check that this went correctly - great!`

As mentioned in the line above, change the contents of `reticulate::use_miniconda()` to `(condaenv = "your directory", required = TRUE)`. Line 11 forces `reticulate` to use your miniconda installation, and line 12 extracts the directories that `reticulate` has attached to. The output should look something like:

  python: C:/Users/username/AppData/Local/r-miniconda/python.exe

  libpython: C:/Users/username/AppData/Local/r-miniconda/python312.dll

  pythonhome: C:/Users/username/AppData/Local/r-miniconda

  version: 3.12.12 \| packaged by conda-forge \| (main, Oct 22 2025, 23:13:34) [MSC v.1944 64 bit (AMD64)]

  Architecture: 64bit

  numpy: [NOT FOUND]

  NOTE: Python version was forced by use_python() function

**CHECK THAT "pythonhome:" IS FOLLOWED BY THE DIRECTORY YOU SET IN LINE 11. If it is not, restart your R session (Ctrl + Shift + F10) and run the previous lines again.**

-   Line 39:

`df = read.csv("Combined Coding Matrix for MVAlpha.csv") #import ALL codes, preprocessed to contain coders by column and units by row`

If your data file has a different name, change contents of `read.csv()` to the appropriate file name.

-   Lines 62-63

`save.image(file = "mvalpha.RData")`
`load(file = "mvalpha.RData")`

Line 62 saves the output of your MVNA calculation to a .RData file. Change the filename "*mvalpha.RData*" as appropriate. Line 63 loads a saved MVNA calculation from a .Rdata file. Change the filename "*mvalpha.RData*" as appropriate.
