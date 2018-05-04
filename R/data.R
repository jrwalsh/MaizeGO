#' Data describing manually curated GO annotations for Maize
#'
#' This only contains sources that assigned GO annotations to maize B73 v4 identifiers (Zm #'s),
#' which currently only includes 3 assignments made by Jesse and Mary based on student work.
#'
#' @docType data
#' @usage data(MaizeGO)
#' @keywords datasets
#'
#' @format A data frame with 3 rows and 7 variables:
#' \describe{
#'   \item{geneID}{geneID}
#'   \item{goTerm}{goTerm}
#'   \item{publication}{publication}
#'   \item{evCode}{evCode}
#'   \item{curator}{curator}
#'   \item{source}{source}
#'   \item{type}{type}
#' }
"MaizeGO.B73.v4"

#' Data describing manually curated GO annotations for Maize
#'
#' This is data merged from several sources including student curators,
#' MaizeCyc, the MaizeGDB tables, and what we call the "Gold Set".  Only
#' contains sources which assign GO annotations to maize B73 v3 identifiers (GRMZM's),
#' including the old BAC-based ids (AC's). Some GO type's are NA, possibly due to outdated terms.
#'
#' @docType data
#' @usage data(MaizeGO)
#' @keywords datasets
#'
#' @format A data frame with 77860 rows and 7 variables:
#' \describe{
#'   \item{geneID}{geneID}
#'   \item{goTerm}{goTerm}
#'   \item{publication}{publication}
#'   \item{evCode}{evCode}
#'   \item{curator}{curator}
#'   \item{source}{source}
#'   \item{type}{type}
#' }
"MaizeGO.B73.v3"

#' Data describing manually curated GO annotations for Maize
#'
#' This is data pulled from UniProt using: https://www.ebi.ac.uk/QuickGO/annotations?taxonId=4577&taxonUsage=descendants
#' Publication records may be DOI's instead of PMID's.  GeneID's are UniProt accessions.
#'
#' @docType data
#' @usage data(MaizeGO)
#' @keywords datasets
#'
#' @format A data frame with 985 rows and 7 variables:
#' \describe{
#'   \item{geneID}{geneID}
#'   \item{goTerm}{goTerm}
#'   \item{publication}{publication}
#'   \item{evCode}{evCode}
#'   \item{curator}{curator}
#'   \item{source}{source}
#'   \item{type}{type}
#' }
"MaizeGO.B73.Uniprot"
