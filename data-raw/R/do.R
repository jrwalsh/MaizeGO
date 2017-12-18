####################################################################################################
## Project:         maize.data.go
## Script purpose:  Run this script to convert raw data into clean data and load it into the /data directory
##
## Output:
##        MaizeGO
##
## Date: 2017-12-11
## Author: Jesse R. Walsh
####################################################################################################
source("./data-raw/R/loadData.R")
source("./data-raw/R/cleanData.R")
library(topGO)
library(tidyr)
library(dplyr)


## List of the go datasets to combine, tag them as source of info
go.maize.clean$source <- "MaizeCyc"
go.gold.clean$source <- "GoldSet"
go.2011.clean$source <- "2011Table"
go.uniprot.clean$source <- "UniProt"
go.student.brittney.clean$source <- "Student"
go.student.miranda.clean$source <- "Student"

## Merge the go files using v3 ids so the ids can be converted
go.maize.all <-
  bind_rows(go.gold.clean) %>%
  bind_rows(go.2011.clean) %>%
  bind_rows(go.student.brittney.clean) %>%
  bind_rows(go.student.miranda.clean)

## Convert to v4 ids
go.maize.all <-
  go.maize.all %>%
  rename(id = geneID) %>%
  inner_join(maize.genes.v3_to_v4_map.clean, by=c("id" = "v3_id")) %>%
  rename(geneID = v4_id) %>%
  select(geneID, goTerm, publication, evCode, curator, source)

## Convert Uniprot to v4 ids
go.uniprot.v4 <-
  go.uniprot.clean %>%
  rename(id = geneID) %>%
  inner_join(maize.genes.uniprot_to_v4_map.clean, by=c("id" = "UniProtID")) %>%
  rename(geneID = v4_id) %>%
  select(geneID, goTerm, publication, evCode, curator, source)

## Generate GO master datasete
MaizeGO <-
  go.maize.clean %>%
  bind_rows(go.uniprot.v4) %>%
  bind_rows(go.maize.all) %>%
  distinct()

## Simplify EV Codes based on uniprot definitions
MaizeGO$evCode[MaizeGO$evCode == "IDA"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "IPI"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "IMP"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "IGI"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "IEP"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "TAS"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "NAS"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "IC"] <- "EXP"
MaizeGO$evCode[MaizeGO$evCode == "ND"] <- "EXP"
MaizeGO$evCode[is.na(MaizeGO$evCode)] <- "COMP"
MaizeGO$evCode[MaizeGO$evCode == "ISS"] <- "COMP"
MaizeGO$evCode[MaizeGO$evCode == "ISM"] <- "COMP"
MaizeGO$evCode[MaizeGO$evCode == "RCA"] <- "COMP"

## Add type.  GO Terms are either CC, BP, or MF.  Terms without a type, type is set to NA
MaizeGO$type <- ""
MaizeGO$type[MaizeGO$goTerm %in% ls(GOMFTerm)] <- "MF"
MaizeGO$type[MaizeGO$goTerm %in% ls(GOBPTerm)] <- "BP"
MaizeGO$type[MaizeGO$goTerm %in% ls(GOCCTerm)] <- "CC"
MaizeGO$type[MaizeGO$type == ""] <- NA

## Save the output to /data
devtools::use_data(MaizeGO, overwrite = TRUE)

devtools::document(roclets=c('rd', 'collate', 'namespace'))

#--------------------------------------------------------------------------------------------------#
detach("package:tidyr", unload=TRUE)
detach("package:dplyr", unload=TRUE)
detach("package:topGO", unload=TRUE)
