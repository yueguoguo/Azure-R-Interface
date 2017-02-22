#' languageR
#' 
#' The languageR package provides R functions to deploy Microsoft Cognitive Services for language-related analysis.
#' 
#' Currently supported Cognitive Service APIs include
#' 
#' \itemize{
#' \item Text Analytics API
#' \item Bing Spell Check API
#' \item Translator Text API
#' \item Linguistic API
#' }
#' 
#' @name languageR-package
#' @aliases languageR
#' @docType package
#' @keywords package
#' 
#' @importFrom jsonlite fromJSON
#' @importFrom httr add_headers headers content status_code http_status authenticate
#' @importFrom httr GET PUT DELETE POST
#' @importFrom XML htmlParse xpathApply xpathSApply xmlValue