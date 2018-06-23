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
##        go.student.miranda.raw
##
## Output:
##        go.maizecyc.clean
##        go.gold.clean
##        go.2011.clean
##        go.uniprot.clean
##        go.student.brittney.clean
##        go.student.miranda.clean
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

## Add alt_publication for consistency with other datasets
go.maize.clean$alt_publication <- NA

## Publication is uncommon, replace blanks with NA's, add PMID: to front of pubmed id
go.maize.clean$publication[go.maize.clean$publication == ""] <- NA
go.maize.clean$publication[!is.na(go.maize.clean$publication)] <- paste0("PMID:", go.maize.clean$publication[!is.na(go.maize.clean$publication)])

## Simplify evidence codes, assume missing is computationally derived.
go.maize.clean$evCodeType <- NA
go.maize.clean$evCode[go.maize.clean$evCode == ""] <- "COMP"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-EXP")] <- "EXP"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-EXP-IDA")] <- "IDA"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-EXP-TAS")] <- "TAS"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-EXP-IMP")] <- "IMP"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-EXP-IPI")] <- "IPI"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-COMP")] <- "COMP"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-COMP-HINF-SEQ-ORTHOLOGY")] <- "HINF-SEQ-ORTHOLOGY"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-COMP-AINF-SEQ-ORTHOLOGY")] <- "AINF-SEQ-ORTHOLOGY"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-COMP-IBA")] <- "IBA"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-AS")] <- "TAS"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-AS-TAS")] <- "TAS"
go.maize.clean$evCode[go.maize.clean$evCode %in% c("EV-IC")] <- "IC"

## Remove |'s from GO Terms
go.maize.clean$goTerm <- gsub(go.maize.clean$goTerm, pattern = "\\|", replacement = "")

## Remove duplicates and drop timestamp
go.maize.clean <-
  go.maize.clean %>%
  select(geneID, goTerm, publication, alt_publication, evCode, curator, evCodeType) %>%
  distinct(go.maize.clean)

## There was no qualifier or with columns for this dataset, but initiallize the empty anyway
go.maize.clean$qualifier <- NA
go.maize.clean$with <- NA

#==================================================================================================#
## go.gold.raw
#--------------------------------------------------------------------------------------------------#
go.gold.clean <- go.gold.raw

## Rename columns and select important columns
go.gold.clean <-
  go.gold.clean %>%
  rename(geneID = db_object_symbol, goTerm = term_accession, publication = db_reference, evCode = evidence_code, curator = assigned_by) %>%
  select(geneID, goTerm, publication, evCode, curator, qualifier, with)

## Clean up random characters, non data, comments, errors, and statements made with uncertain language
go.gold.clean$evCode <- gsub("IEF", NA, go.gold.clean$evCode)
go.gold.clean$evCode <- gsub("imp", "IMP", go.gold.clean$evCode)
go.gold.clean$geneID[go.gold.clean$geneID %in% c("PyrR")] <- "GRMZM2G090068" #assume PyrR = pyrr1
go.gold.clean <- subset(go.gold.clean, !grepl("ga-ms1", geneID)) #drop gams1, not associated with any gene model

## There are a couple v2 id's here that are not equivalent to a v3 id... manually fix them here
go.gold.clean$geneID[go.gold.clean$geneID %in% c("AC147602.5_FG004")] <- "GRMZM6G741210" # renamed gene model
go.gold.clean$geneID[go.gold.clean$geneID %in% c("GRMZM2G103315")] <- "GRMZM2G000964" # gene model merged into other gene model

## Simplify evidence codes, assume missing is computationally derived.
go.gold.clean$evCodeType <- NA
go.gold.clean$evCode[is.na(go.gold.clean$evCode)] <- "COMP"

## The MGDB publication should be kept, but in a separate column
go.gold.clean$alt_publication <- NA
go.gold.clean$alt_publication[go.gold.clean$publication %in% c("MGDB_REF:3133112|PMID:23198870")] <- "MGDB:3133112"
go.gold.clean$alt_publication[go.gold.clean$publication %in% c("MaizeGDB:123623")] <- "MGDB:123623"
go.gold.clean$alt_publication[go.gold.clean$publication %in% c("MaizeGDB:5888790")] <- "MGDB:5888790"

## Clean publication column
go.gold.clean$publication[go.gold.clean$publication %in% c("MGDB_REF:3133112|PMID:23198870")] <- "PMID:23198870"
go.gold.clean$publication[go.gold.clean$publication %in% c("MaizeGDB:123623")] <- ""
go.gold.clean$publication[go.gold.clean$publication %in% c("MaizeGDB:5888790")] <- ""

## Remove duplicates
go.gold.clean <- distinct(go.gold.clean)

## Reorder columns
go.gold.clean <-
  go.gold.clean %>%
  select(geneID, goTerm, publication, alt_publication, evCode, curator, evCodeType, qualifier, with)

#==================================================================================================#
## go.2011.raw
#--------------------------------------------------------------------------------------------------#
go.2011.clean <- go.2011.raw

## Clean up errors and missing
go.2011.clean$X5[go.2011.clean$X4 %in% c("pebp8")] <- "GRMZM2G179264"
go.2011.clean$X5[go.2011.clean$X4 %in% c("id1")] <- "GRMZM2G011357"
go.2011.clean$X5[go.2011.clean$X4 %in% c("fl2")] <- "GRMZM2G397687"
go.2011.clean$X5[go.2011.clean$X4 %in% c("ao3")] <- "GRMZM2G019799"

## Add alt_publication for consistency with other datasets
go.2011.clean$alt_publication <- NA

## Rename columns and select important columns
go.2011.clean <-
  go.2011.clean %>%
  rename(geneID = X5, goTerm = X1, publication = X7, evCode = X9, curator = X8) %>%
  select(geneID, goTerm, publication, alt_publication, evCode, curator)

## Remove PO terms
go.2011.clean <-
  go.2011.clean %>%
  subset(!is.na(geneID) & !is.na(goTerm) & startsWith(goTerm, "GO:"))

## Add PMID: to front of pubmed id
go.2011.clean$publication[!is.na(go.2011.clean$publication)] <- paste0("PMID:", go.2011.clean$publication[!is.na(go.2011.clean$publication)])

## Simplify evidence codes, assume missing is computationally derived.
go.2011.clean$evCodeType <- NA

## Remove duplicates
go.2011.clean <- distinct(go.2011.clean)

## There was no qualifier or with columns for this dataset, but initiallize the empty anyway
go.2011.clean$qualifier <- NA
go.2011.clean$with <- NA

#==================================================================================================#
## go.uniprot.raw
#--------------------------------------------------------------------------------------------------#
go.uniprot.clean <- go.uniprot.raw

## Rename columns and select important columns, ignore GO terms with a "not" qualifier
go.uniprot.clean <-
  go.uniprot.clean %>%
  subset(!startsWith(QUALIFIER, "NOT")) %>%
  rename(geneID = `GENE PRODUCT ID`, goTerm = `GO TERM`, publication = REFERENCE, evCode = `GO EVIDENCE CODE`, curator = `ASSIGNED BY`, qualifier=`QUALIFIER`, with=`WITH/FROM`) %>%
  select(geneID, goTerm, publication, evCode, curator, qualifier, with)

## Clean non-standard publication data
go.uniprot.clean$alt_publication <- NA
go.uniprot.clean$alt_publication[grepl("DOI:", go.uniprot.clean$publication)] <- go.uniprot.clean$publication[grepl("DOI:", go.uniprot.clean$publication)]
go.uniprot.clean$alt_publication[grepl("GO_REF", go.uniprot.clean$publication)] <- go.uniprot.clean$publication[grepl("GO_REF", go.uniprot.clean$publication)]
go.uniprot.clean$publication[grepl("DOI:", go.uniprot.clean$publication)] <- NA
go.uniprot.clean$publication[startsWith(go.uniprot.clean$publication, "GO_REF")] <- NA

## Simplify evidence codes, assume missing is computationally derived and throw out "ND" (no data) statements
go.uniprot.clean$evCodeType <- NA

go.uniprot.clean$evCode[is.na(go.uniprot.clean$evCode)] <- "COMP"
go.uniprot.clean <- go.uniprot.clean[!go.uniprot.clean$evCode %in% c("ND"),] #no data found, so toss it out

## Remove duplicates
go.uniprot.clean <- distinct(go.uniprot.clean)

## Reorder columns
go.uniprot.clean <-
  go.uniprot.clean %>%
  select(geneID, goTerm, publication, alt_publication, evCode, curator, evCodeType, qualifier, with)

#==================================================================================================#
## go.student.brittney.raw
#--------------------------------------------------------------------------------------------------#
go.student.brittney.clean <- go.student.brittney.raw

## Rename columns and select important columns
go.student.brittney.clean <-
  go.student.brittney.clean %>%
  rename(geneID = `Gene Model`, gene = `Canonical Gene`, goTerm = `better GO`, publication = PMID, evCode = `e code`) %>%
  rename_at( 10, ~"qualifier" ) %>%
  rename_at( 11, ~"with" ) %>%
  select(geneID, gene, goTerm, publication, evCode, qualifier, with)

## Clean non-standard "NA's" from data in geneID and other typos
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("None", "none", "noe")] <- NA
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GRMZM2G0050214")] <- "GRMZM2G005024"
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GRMZM2036340")] <- "GRMZM2G036340"
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GMZM5G870341")] <- "GRMZM2G032282"
go.student.brittney.clean$geneID[go.student.brittney.clean$geneID %in% c("GMZM5G870340")] <- "GRMZM5G870342" # cpx1 is nec4
go.student.brittney.clean$evCode[go.student.brittney.clean$evCode %in% c("AF360356")] <- NA

## The MGDB publication should be kept, but in a separate column
go.student.brittney.clean$alt_publication <- NA
go.student.brittney.clean$alt_publication[go.student.brittney.clean$publication %in% c("MGDB: 514917")] <- "MGDB:514917"
go.student.brittney.clean$publication[go.student.brittney.clean$publication %in% c("MGDB: 514917")] <- "11708651" # don't add "PMID" to id here, we add it to all of them a few lines below here

## Hard-coded fix for missing geneID but present gene.  Manually resolve to a geneID
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("phyB1")] <- "GRMZM2G124532"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("phyB2")] <- "GRMZM2G092174"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("pet3")] <- "GRMZM2G177145"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("p")] <- "GRMZM2G084799" # presume this to mean gene p1
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("r1")] <- "GRMZM5G822829"
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("ns2")] <- "Zm00001d052598" # review special issue with double naming (aka wox3B gene)
go.student.brittney.clean$geneID[go.student.brittney.clean$gene %in% c("Abph2")] <- NA # no gene model associated with this gene

## Remove unusable lines, add a default curator (no evCode = assume COMP later, no pub is OK)
go.student.brittney.clean <-
  go.student.brittney.clean %>%
  subset(!is.na(goTerm) &
           !is.na(geneID)) # no geneID/goTerm = not usable

## Add curator column with default value
go.student.brittney.clean$curator <- NA

## Add PMID: to front of pubmed id
go.student.brittney.clean$publication[!is.na(go.student.brittney.clean$publication)] <-
  paste0("PMID:", go.student.brittney.clean$publication[!is.na(go.student.brittney.clean$publication)])

## Simplify evidence codes, assume missing is computationally derived and throw out "ND" (no data) statements
go.student.brittney.clean$evCodeType <- NA
go.student.brittney.clean$evCode[is.na(go.student.brittney.clean$evCode)] <- "COMP"

## Select columns and remove duplicates
go.student.brittney.clean <-
  go.student.brittney.clean %>%
  select(geneID, goTerm, publication, alt_publication, evCode, curator, evCodeType, qualifier, with) %>%
  distinct() # no duplicates expected

#==================================================================================================#
## go.student.miranda.raw
#--------------------------------------------------------------------------------------------------#
go.student.miranda.clean <- go.student.miranda.raw

## Rename columns
go.student.miranda.clean <-
  go.student.miranda.clean %>%
  rename(geneID = `Gene Model`, goTerm = `GO ID`, publication = PMID, alt_publication = `MaizeGDB_Reference`, evCode = `Experiment Code`, qualifier = `Qualifier`, with = `With`) %>%
  select(geneID, goTerm, publication, alt_publication, evCode, qualifier, with) %>%
  subset(!is.na(geneID) & !is.na(goTerm))

## Clean up random characters, non data, comments, errors, and statements made with uncertain language
go.student.miranda.clean$curator <- NA

## Add PMID: to front of pubmed id
go.student.miranda.clean$publication[!is.na(go.student.miranda.clean$publication)] <-
  paste0("PMID:", go.student.miranda.clean$publication[!is.na(go.student.miranda.clean$publication)])

## Add MGDB: to front of alt_publication
go.student.miranda.clean$alt_publication[!is.na(go.student.miranda.clean$alt_publication)] <-
  paste0("MGDB:", go.student.miranda.clean$alt_publication[!is.na(go.student.miranda.clean$alt_publication)])

## Simplify evidence codes, assume missing is computationally derived and throw out "ND" (no data) statements
go.student.miranda.clean$evCodeType <- NA

## Reorder columns
go.student.miranda.clean <-
  go.student.miranda.clean %>%
  select(geneID, goTerm, publication, alt_publication, evCode, curator, evCodeType, qualifier, with)

#--------------------------------------------------------------------------------------------------#
detach("package:tidyr", unload=TRUE)
detach("package:dplyr", unload=TRUE)
