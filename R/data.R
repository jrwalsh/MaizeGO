#' Data describing manually curated GO annotations for Maize
#'
#' This is data merged from several sources including student curators,
#' MaizeCyc, the MaizeGDB tables, UniProt, and what we call the "Gold Set"
#'
#' @docType data
#' @usage data(MaizeGO)
#' @keywords datasets
#'
#' @format A data frame with 3209 rows and 6 variables:
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
