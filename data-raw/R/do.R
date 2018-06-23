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
MaizeGO <-
  go.maize.clean %>%
  bind_rows(go.gold.clean) %>%
  bind_rows(go.2011.clean) %>%
  bind_rows(go.student.brittney.clean) %>%
  bind_rows(go.student.miranda.clean) %>%
  bind_rows(go.uniprot.clean)

## Simplify EV Codes into experimental or computational
MaizeGO$evCodeType[MaizeGO$evCode %in% c("EXP", "AS", "IDA", "IPI", "IMP", "IGI", "IEP", "TAS", "NAS", "IC", "ND")] <- "EXP" #trust author/curator statements
MaizeGO$evCodeType[is.na(MaizeGO$evCode)] <- "COMP"
MaizeGO$evCodeType[MaizeGO$evCode %in% c("", "COMP", "HINF-SEQ-ORTHOLOGY", "AINF-SEQ-ORTHOLOGY", "IBA", "ISS", "ISM", "RCA")] <- "COMP"

## Add type.  GO Terms are either CC, BP, or MF.  Terms without a type, type is set to NA
MaizeGO$type <- ""
MaizeGO$type[MaizeGO$goTerm %in% ls(GOMFTerm)] <- "MF"
MaizeGO$type[MaizeGO$goTerm %in% ls(GOBPTerm)] <- "BP"
MaizeGO$type[MaizeGO$goTerm %in% ls(GOCCTerm)] <- "CC"
MaizeGO$type[MaizeGO$type == ""] <- NA

## Split UniProt, v3 assigned, and v4 assigned GO annotations (we don't do ID mapping here, that is for end-user to do)
MaizeGO.B73.Uniprot <- subset(MaizeGO, source %in% "UniProt")
MaizeGO.B73.v3 <- subset(MaizeGO, !startsWith(geneID, "Zm") & !source %in% "UniProt")
MaizeGO.B73.v4 <- subset(MaizeGO, startsWith(geneID, "Zm"))

# ## There is a very likely possibility that one of the annotations assumed to be in v3 was actually from v1 or v2. No way to blanket
# ## fix this problem, but can at least get an idea if we have any problems by checking against a short list of gene models known
# ## to have changed between v2 and v3.  This is here as a check, but won't fix the problem if there is one.
# MaizeGO.B73.v3 %>%
#   subset(geneID %in% c(
#     "AC147602.5_FG004",
#     "AC190882.3_FG003",
#     "AC192244.3_FG001",
#     "AC194389.3_FG001",
#     "AC204604.3_FG008",
#     "AC210529.3_FG004",
#     "AC232289.2_FG005",
#     "AC233893.1_FG001",
#     "AC233910.1_FG005",
#     "AC235534.1_FG001",
#     "GRMZM2G103315",
#     "GRMZM2G452386",
#     "GRMZM2G518717",
#     "GRMZM2G020429",
#     "GRMZM2G439578",
#     "GRMZM2G117517",
#     "GRMZM5G864178",
#     "GRMZM2G143862",
#     "GRMZM5G823855"
#   ))

## Save the output to /data
devtools::use_data(MaizeGO.B73.v3, overwrite = TRUE)
devtools::use_data(MaizeGO.B73.v4, overwrite = TRUE)
devtools::use_data(MaizeGO.B73.Uniprot, overwrite = TRUE)

devtools::document(roclets=c('rd', 'collate', 'namespace'))

#--------------------------------------------------------------------------------------------------#
detach("package:tidyr", unload=TRUE)
detach("package:dplyr", unload=TRUE)
detach("package:topGO", unload=TRUE)
