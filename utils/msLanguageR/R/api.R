#' @title List API information for each function.
#' @references See \url{https://azure.microsoft.com/en-us/services/cognitive-services/}.
#' @param funName Function name as a string. It's optional. If not provides, information of all the functions will be printed. 
#' @return Print the information of API keys for functions in the package.
#' @examples 
#' apiInfo()
#' @export
apiInfo <- function(funName) {
  df_info <- data.frame(
    FunctionName=c(
      "cognitiveSentiAnalysis",
      "cognitiveLangDetect",
      "cognitiveTopicDetect",
      "cognitiveKeyPhrases",
      "cognitiveSpellingCheck",
      "cognitiveTranslation",
      "cognitiveLinguiAnalysis"
    ),
    ServiceAPI=c(
      "Text Analytics API",
      "Text Analytics API",
      "Text Analytics API",
      "Text Analytics API",
      "Bing Spell Check API",
      "Translator API",
      "Linguistic API"
    ),
    Website=c(
      "https://www.microsoft.com/cognitive-services/en-us/text-analytics-api",
      "https://www.microsoft.com/cognitive-services/en-us/text-analytics-api",
      "https://www.microsoft.com/cognitive-services/en-us/text-analytics-api",
      "https://www.microsoft.com/cognitive-services/en-us/text-analytics-api",
      "https://azure.microsoft.com/en-us/services/cognitive-services/spell-check/",
      "https://azure.microsoft.com/en-us/services/cognitive-services/translator-text-api/",
      "https://www.microsoft.com/cognitive-services/en-us/linguistic-analysis-api"
    )
  )
  
  if (missing(funName)) {
    writeLines("Check out API information for each function:")
    print(df_info)
  } else {
    if (!(funName %in% as.character(df_info$FunctionName))) {
      stop("Error: Please provide a valid cognitive function name.")
    }
    
    writeLines(paste("API information for function", funName, sep=" "))
    print(dplyr::filter(df_info, as.character(FunctionName) == funName))
  }
}