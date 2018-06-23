####################################################################################################
## Project:         maize.data.go
## Script purpose:  Import datafiles relevant to this project
##
## Output:
##        go.maizecyc.raw
##        go.gold.raw
##        go.2011.raw
##        go.uniprot.raw
##        go.student.brittney.raw
##        go.student.miranda.raw
##        maize.genes.v3_to_v4_map.raw
##
## Date: 2017-12-11
## Author: Jesse R. Walsh
####################################################################################################
library(readr)
library(readxl)

## Read in GO Annotation data from MaizeCyc 2.2
go.maizecyc.raw.1 <- read_excel("./data-raw/preliminary GO terms to transfer to corncyc8.xlsx", sheet = "EV-EXP GO Annotations")
go.maizecyc.raw.2 <- read_excel("./data-raw/preliminary GO terms to transfer to corncyc8.xlsx", sheet = "EV-COMP GO Annotations")
go.maizecyc.raw.3 <- read_excel("./data-raw/preliminary GO terms to transfer to corncyc8.xlsx", sheet = "Not Exist in CornCyc8")

## Read in GO Annotation data from Gold Standard Set
go.gold.raw <- read_delim("./data-raw/maize_v3.gold.gaf", "\t", escape_double = FALSE, trim_ws = TRUE, skip = 1)

## Read in GO Annotation data from Ethy's Table
go.2011.raw <- read_csv("./data-raw/OBO_terms_since_2011.txt", col_names = FALSE, col_types = cols(X7 = col_character()))

## Read in GO Annotation data from QuickGO / UniProt
go.uniprot.raw <- read_delim("./data-raw/QuickGO-annotations-1508951884113-20171025.tsv", "\t", escape_double = FALSE, trim_ws = TRUE)

## Read in GO Annotation data from student curators
go.student.brittney.raw <- read_excel("./data-raw/Curation Spreadsheet - Brittney Dunfee_MS.xlsx", sheet = "Sheet1")
go.student.miranda.raw <- read_excel("./data-raw/Summary Table_JW.xlsx", sheet = "Sheet1")

#--------------------------------------------------------------------------------------------------#
detach("package:readr", unload=TRUE)
detach("package:readxl", unload=TRUE)
