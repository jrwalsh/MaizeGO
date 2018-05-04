####################################################################################################
## Project:         maize.data.go
## Script purpose:  Clean raw data relevant to this project
##
## Input:
##        go.maizecyc.raw
##        go.gold.raw
##        go.2011.raw
##        go.uniprot.raw
##        go.student.brittney.raw
##        go.student.miranda.raw.1
##        go.student.miranda.raw.2
##        go.student.miranda.raw.3
##        go.student.miranda.raw.4
##        go.student.miranda.raw.5
##        maize.genes.uniprot_to_v4_map.raw
##
## Output:
##        go.maizecyc.clean
##        go.gold.clean
##        go.2011.clean
##        go.uniprot.clean
##        go.student.brittney.clean
##        go.student.miranda.clean
##        maize.genes.uniprot_to_v4_map.clean
##
## Date: 2017-12-11
## Author: Jesse R. Walsh
####################################################################################################
library(tidyr)
library(dplyr)

#==================================================================================================#
## go.maize.raw
#--------------------------------------------------------------------------------------------------#
## Combine all three sheets
go.maizecyc.raw <-
  go.maizecyc.raw.1 %>%
  bind_rows(go.maizecyc.raw.2) %>%
  bind_rows(go.maizecyc.raw.3)

go.maize.clean <- go.maizecyc.raw

## Rename columns
go.maize.clean <-
  go.maize.clean %>%
  rename(geneID = `MaizeCyc2.2 Accession-1`) %>%
  rename(goTerm = `GO Term`)

## Parse out citation string and select important columns
go.maize.clean <-
  go.maize.clean %>%
  select(geneID, goTerm, Citation) %>%
  separate(Citation, c("publication", "evCode","timeStamp","curator"), sep=":", extra="drop")

## Publication is uncommon, replace blanks with NA's, add PMID: to front of pubmed id
go.maize.clean$publication[go.maize.clean$publication == ""] <- NA
go.maize.clean$publication[!is.na(go.maize.clean$publication)] <- paste0("PMID:", go.maize.clean$publication[!is.na(go.maize.clean$publication)])

## Simplify evidence codes, assume missing is computationally derived.
go.maize.clean$evCode[grepl("EV-EXP", go.maize.clean$evCode)] <- "EXP"
go.maize.clean$evCode[grepl("EV-AS", go.maize.clean$evCode)] <- "EXP" #trust author statements
go.maize.clean$evCode[grepl("EV-IC", go.maize.clean$evCode)] <- "EXP" #trust curator inferences
go.maize.clean$evCode[grepl("EV-COMP", go.maize.clean$evCode)] <- "COMP"
go.maize.clean$evCode[go.maize.clean$evCode == ""] <- "COMP"

## Remove |'s from GO Terms
go.maize.clean$goTerm <- gsub(go.maize.clean$goTerm, pattern = "\\|", replacement = "")

## Remove duplicates and drop timestamp
go.maize.clean <-
  go.maize.clean %>%
  select(geneID, goTerm, publication, evCode, curator) %>%
  distinct(go.maize.clean)

#==================================================================================================#
## go.gold.raw
#--------------------------------------------------------------------------------------------------#
go.gold.clean <- go.gold.raw

## Rename columns and select important columns
go.gold.clean <-
  go.gold.clean %>%
  rename(geneID = db_object_symbol, goTerm = term_accession, publication = db_reference, evCode = evidence_code, curator = assigned_by) %>%
  select(geneID, goTerm, publication, evCode, curator)

## Clean up random characters, non data, comments, errors, and statements made with uncertain language
go.gold.clean$evCode <- gsub("IEF", NA, go.gold.clean$evCode)
go.gold.clean$evCode <- gsub("imp", "IMP", go.gold.clean$evCode)
go.gold.clean <- subset(go.gold.clean, !grepl("PyrR", geneID) & !grepl("ga-ms1", geneID))

## Clean up publication column
go.gold.clean$publication <- gsub("MGDB_REF:3133112\\|","",go.gold.clean$publication)
go.gold.clean$publication[startsWith(go.gold.clean$publication, "Maize")] <- NA

## Remove duplicates
go.gold.clean <- distinct(go.gold.clean)

#==================================================================================================#
## go.2011.raw
#--------------------------------------------------------------------------------------------------#
go.2011.clean <- go.2011.raw

## Rename columns and select important columns
go.2011.clean <-
  go.2011.clean %>%
  rename(geneID = X5, goTerm = X1, publication = X7, evCode = X9, curator = X8) %>%
  select(geneID, goTerm, publication, evCode, curator)

## Remove PO terms
go.2011.clean <-
  go.2011.clean %>%
  subset(!is.na(geneID) & !is.na(goTerm) & startsWith(goTerm, "GO:"))

## Add PMID: to front of pubmed id
go.2011.clean$publication[!is.na(go.2011.clean$publication)] <- paste0("PMID:", go.2011.clean$publication[!is.na(go.2011.clean$publication)])

## Remove duplicates
go.2011.clean <- distinct(go.2011.clean)

#==================================================================================================#
## go.uniprot.raw
#--------------------------------------------------------------------------------------------------#
go.uniprot.clean <- go.uniprot.raw

## Rename columns and select important columns, ignore GO terms with a "not" qualifier
go.uniprot.clean <-
  go.uniprot.clean %>%
  subset(!startsWith(QUALIFIER, "NOT")) %>%
  rename(geneID = `GENE PRODUCT ID`, goTerm = `GO TERM`, publication = REFERENCE, evCode = `GO EVIDENCE CODE`, curator = `ASSIGNED BY`) %>%
  select(geneID, goTerm, publication, evCode, curator)

## Clean non-standard publication data
go.uniprot.clean$publication[startsWith(go.uniprot.clean$publication, "GO_REF")] <- NA

## Remove unusable lines (no GOterm = assume COMP later, no pub is OK)
go.uniprot.clean <-
  go.uniprot.clean %>%
  subset(!is.na(goTerm) &
         !is.na(geneID)) # no geneID/evCode = not usable

## Remove duplicates
go.uniprot.clean <- distinct(go.uniprot.clean)

#==================================================================================================#
## go.student.brittney.raw
## go.student.miranda.raw.1
## go.student.miranda.raw.2
## go.student.miranda.raw.3
## go.student.miranda.raw.4
## go.student.miranda.raw.5
#--------------------------------------------------------------------------------------------------#
go.student.brittney.clean <- go.student.brittney.raw

## Rename columns and select important columns
go.student.brittney.clean <-
  go.student.brittney.clean %>%
  rename(geneID = `Gene Model`, gene = `Canonical Gene`, goTerm = `better GO`, publication = PMID, evCode = `e code`) %>%
  rename_at( 11, ~"withGene" ) %>%
  select(geneID, gene, goTerm, publication, evCode, withGene)

## Clean non-standard "NA's" from data in geneID and other typos
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("None", "none", "noe")] <- NA
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GRMZM2G0050214")] <- "GRMZM2G005024"
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GRMZM2036340")] <- "GRMZM2G036340"
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GMZM5G870341")] <- "GRMZM2G032282"
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GMZM5G870340")] <- "GRMZM5G870342" # cpx1 is nec4
go.student.brittney.clean$evCode[go.student.brittney.clean$evCode %in% c("AF360356")] <- NA
go.student.brittney.clean$publication[go.student.brittney.clean$publication %in% c("MGDB: 514917")] <- "11708651"

## Hard-coded fix for missing geneID but present gene.  Manually resolve to a geneID
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("phyB1")] <- "GRMZM2G124532"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("phyB2")] <- "GRMZM2G092174"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("pet3")] <- "GRMZM2G177145"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("p")] <- "GRMZM2G084799" # presume this to mean gene p1
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("r1")] <- "GRMZM5G822829"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("ns2")] <- "Zm00001d052598" # review special issue with double naming (aka wox3B gene)
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("Abph2")] <- NA # no gene model associated with this gene

## Remove unusable lines, add a default curator (no GOterm = assume COMP later, no pub is OK)
go.student.brittney.clean <-
  go.student.brittney.clean %>%
  subset(!is.na(goTerm) &
           !is.na(geneID)) # no geneID/evCode = not usable

## Add curator column with default value
go.student.brittney.clean$curator <- NA

## Add PMID: to front of pubmed id
go.student.brittney.clean$publication[!is.na(go.student.brittney.clean$publication)] <-
  paste0("PMID:", go.student.brittney.clean$publication[!is.na(go.student.brittney.clean$publication)])

## Select columns and remove duplicates
go.student.brittney.clean <-
  go.student.brittney.clean %>%
  select(geneID, goTerm, publication, evCode, curator) %>%
  distinct() # no duplicates expected

#--#    #--#    #--#    #--#    #--#    #--#    #--#    #--#    #--#    #--#
go.student.miranda.raw <- go.student.miranda.raw.1

## This data is on 5 sheets that are not consistently formatted
go.student.miranda.raw <-
  go.student.miranda.raw.1 %>%
  rename(geneID = `Gene Model`, goTerm = `GO ID`, publication = PMID, evCode = `Experiment Code`) %>%
  select(geneID, goTerm, publication, evCode) %>%
  subset(!is.na(geneID) & !startsWith(geneID, "*none") & !startsWith(geneID, "no associated") & !is.na(goTerm))

go.student.miranda.clean <- go.student.miranda.raw

## Add Sheet 2
go.student.miranda.raw <-
  go.student.miranda.raw.2 %>%
  rename(geneID = `Gene Model`, goTerm = `GO ID`, publication = PMID, evCode = `Experiment Code`) %>%
  select(geneID, goTerm, publication, evCode) %>%
  subset(!is.na(geneID) & !startsWith(geneID, "*none") & !startsWith(geneID, "no associated") & !is.na(goTerm))

go.student.miranda.clean <-
  go.student.miranda.clean %>%
  bind_rows(go.student.miranda.raw)

## Sheet 3
go.student.miranda.raw <-
  go.student.miranda.raw.3 %>%
  rename(geneID = `Gene Model`, goTerm = `GO ID`, publication = PMID, evCode = `Experiment Code`) %>%
  select(geneID, goTerm, publication, evCode) %>%
  subset(!is.na(geneID) & !startsWith(geneID, "*none") & !startsWith(geneID, "no associated") & !is.na(goTerm))

go.student.miranda.clean <-
  go.student.miranda.clean %>%
  bind_rows(go.student.miranda.raw)

## Sheet 4
go.student.miranda.raw <-
  go.student.miranda.raw.4 %>%
  rename(geneID = `Gene Model`, goTerm = `GO ID`, publication = PMID, evCode = `Experiment Code`) %>%
  select(geneID, goTerm, publication, evCode) %>%
  subset(!is.na(geneID) & !startsWith(geneID, "*none") & !startsWith(geneID, "no associated") & !is.na(goTerm))

go.student.miranda.clean <-
  go.student.miranda.clean %>%
  bind_rows(go.student.miranda.raw)

## Sheet 5
go.student.miranda.raw <-
  go.student.miranda.raw.5 %>%
  rename(geneID = `Gene Model`, goTerm = `GO ID`, publication = PMID, evCode = `Experiment Code`) %>%
  select(geneID, goTerm, publication, evCode) %>%
  subset(!is.na(geneID) & !startsWith(geneID, "*none") & !startsWith(geneID, "no associated") & !is.na(goTerm))

go.student.miranda.clean <-
  go.student.miranda.clean %>%
  bind_rows(go.student.miranda.raw)

## Clean up random characters, non data, comments, errors, and statements made with uncertain language
go.student.miranda.clean$curator <- NA
go.student.miranda.clean$geneID <- gsub("\\*", "", go.student.miranda.clean$geneID)
go.student.miranda.clean$evCode <- gsub("ida", "IDA", go.student.miranda.clean$evCode)
go.student.miranda.clean$evCode <- gsub("\"IMP\n\"", "IMP", go.student.miranda.clean$evCode)
go.student.miranda.clean <-
  go.student.miranda.clean %>%
  subset(startsWith(goTerm, "GO:")) %>%
  subset(!is.na(evCode)) %>%
  subset(startsWith(evCode, "IDA") |
           startsWith(evCode, "IMP") |
           startsWith(evCode, "IPI") |
           startsWith(evCode, "NAS") |
           startsWith(evCode, "TAS") |
           startsWith(evCode, "IEP") |
           startsWith(evCode, "IC") |
           startsWith(evCode, "IGI")) %>%
  subset(nchar(evCode) <= 3)
go.student.miranda.clean <-
  go.student.miranda.clean %>%
  subset(!grepl("\\(", geneID) &
           !grepl(":", geneID) &
           !grepl("_", geneID) &
           !grepl("could", geneID) &
           !grepl("none", geneID) &
           !grepl("not", geneID) &
           !grepl("NA", geneID) &
           !startsWith(geneID, "At"))
go.student.miranda.clean <-
  go.student.miranda.clean %>%
  subset(!grepl(" ", goTerm))
go.student.miranda.clean$publication[startsWith(go.student.miranda.clean$publication, "MGDB") | startsWith(go.student.miranda.clean$publication, "mgdb")] <- NA

## Add PMID: to front of pubmed id
go.student.miranda.clean$publication[!is.na(go.student.miranda.clean$publication)] <-
  paste0("PMID:", go.student.miranda.clean$publication[!is.na(go.student.miranda.clean$publication)])

# #==================================================================================================#
# ## maize.genes.uniprot_to_v4_map.raw
# #--------------------------------------------------------------------------------------------------#
# maize.genes.uniprot_to_v4_map.clean <- maize.genes.uniprot_to_v4_map.raw
#
# ## Remove unmapped lines and rename columns
# maize.genes.uniprot_to_v4_map.clean <-
#   maize.genes.uniprot_to_v4_map.clean %>%
#   subset(!is.na(`Cross-reference (Gramene)`)) %>%
#   rename(UniProtID = Entry, v4_id = `Cross-reference (Gramene)`)
#
# ## Extract the first ZM id from the list
# maize.genes.uniprot_to_v4_map.clean <-
#   maize.genes.uniprot_to_v4_map.clean %>%
#   mutate(v4_id = gsub("_.*", "", v4_id))
#
# ## Leave duplicates in, as this has a 1 to many mapping we want to preserve.

#--------------------------------------------------------------------------------------------------#
detach("package:tidyr", unload=TRUE)
detach("package:dplyr", unload=TRUE)
