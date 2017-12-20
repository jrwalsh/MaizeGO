#' Data describing manually curated GO annotations for Maize
#'
#' This is primarily from UniProt and only contains sources that
#' assigned GO annotations to maize B73 v4 identifiers (Zm #'s)
#'
#' @docType data
#' @usage data(MaizeGO)
#' @keywords datasets
#'
#' @format A data frame with 470 rows and 7 variables:
#' \describe{
#'   \item{geneID}{geneID}
#'   \item{goTerm}{goTerm}
#'   \item{publication}{publication}
#'   \item{evCode}{evCode}
#'   \item{curator}{curator}
#'   \item{source}{source}
#'   \item{type}{type}
#' }
"MaizeGO"

#' Data describing manually curated GO annotations for Maize
#'
#' This is data merged from several sources including student curators,
#' MaizeCyc, the MaizeGDB tables, and what we call the "Gold Set".  Only
#' contains sources which assign GO annotations to maize B73 v3 identifiers (GRMZM's),
#' including the old BAC-based ids (AC's)
#'
#' @docType data
#' @usage data(MaizeGO)
#' @keywords datasets
#'
#' @format A data frame with 77817 rows and 7 variables:
#' \describe{
#'   \item{geneID}{geneID}
#'   \item{goTerm}{goTerm}
#'   \item{publication}{publication}
#'   \item{evCode}{evCode}
#'   \item{curator}{curator}
#'   \item{source}{source}
#'   \item{type}{type}
#' }
"MaizeGO.v3"
