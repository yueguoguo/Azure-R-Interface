# -------------------------------------------------------------------------
# Cognitive services wrap-up.
#
# Author:   Le Zhang, Data Scientist, Microsoft
# Date:     20161228
# -------------------------------------------------------------------------

#' @title Sentiment analysis.
#' 
#' @note See \url{https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0} for more information about Text Analytics on Microsoft Cognitive Analysis.
#' 
#' @param text Text to be analyzed. Can be a dataframe, list, or text vector.
#' @param apiKey API key.
#' 
#' @return Response from sentiment analysis API, including score, text id, and errors if there are.
#' @export
cognitiveSentiAnalysis <- function(text, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) stop("Error: no API Key provided!")
  
  json_txt <- 
    paste("{\"language\":\"en\", \"id\":\"", 1:length(text), "\", \"text\":\"", text, "\"}", sep = "", collapse = ",") %>%
    paste("{\"documents\": [", . , "]}", sep = "") 
  
  response <-
    httr::POST(url = "https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment", 
               add_headers(.headers = c("Ocp-Apim-Subscription-Key" = apiKey, "Content-Type" = "application/json", "Accept" = "application/json")), 
               body = json_txt) 
  
  response_df <-
    httr::content(response, "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() 
  
  # if return error code.
  if (status_code(response) != 200) {
    msg <- paste("Return code", status_code(response), "-", response_df$message, sep = " ")
    stop(msg, call. = FALSE)
  }
  
  return(response_df)
}

#' @title Spelling check.
#' 
#' @note See \url{https://dev.cognitive.microsoft.com/docs/services/56e73033cf5ff80c2008c679/operations/56e73036cf5ff81048ee6727} for more information about Spell Check API.
#' 
#' @param text Text to be analyzed. Can be a dataframe, list, or text vector.
#' @param mode spelling check mode. Deafult is proof.
#' @param mkt market location. Default is "en-us".
#' 
#' @return A data frame containing the detected token, its offset, type, and suggestions.
#' @export
cognitiveSpellingCheck <- function(text, apiKey,
                                   mode = "Proof",
                                   mkt = "en-us") {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) stop("Error: no API Key provided!")
  
  text <- paste("text=", paste(text, collapse = ","), sep = "")
  
  response <-
    httr::POST(url = "https://api.cognitive.microsoft.com/bing/v5.0/spellcheck",
               add_headers(.headers = c("Ocp-Apim-Subscription-Key" = apiKey, "Content-Type" = "application/x-www-form-urlencoded")), 
               body = text,
               mode = mode,
               mkt = "en-us") 
  
  response_df <-
    httr::content(response, "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() 
  
  # if return error code.
  if (status_code(response) != 200) {
    msg <- paste("Return code", status_code(response), "-", response_df$message, sep = " ")
    stop(msg, call. = FALSE)
  }
  
  return(response_df)
}

#' @title Translation.
#' 
#' @note See \url{http://docs.microsofttranslator.com/text-translate.html#!/default/post_TranslateArray} for more information about Translation API.
#' 
#' @param text text to be analyzed. 
#' @param lan_from source language.
#' @param lanTo target language.
#' @param apiKey API key
#' 
#' @return A data frame containing the translated text in the target language.

#' @export
cognitiveTranslation <- function(text, lanTo, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(lanTo)) stop("Error: no target language provided!")
  if (missing(apiKey)) stop("Error: no API Key provided!")
  
  # get the authentication token.
  
  token_response <- 
    httr::POST(url = "https://api.cognitive.microsoft.com/sts/v1.0/issueToken",
               add_headers(.headers = c("Ocp-Apim-Subscription-Key" = apiKey)))
  
  if (status_code(token_response) != 200) stopWithError(response)
  token <- paste("Bearer", httr::content(token_response, "text", encoding = "UTF-8"), sep = " ")
  
  response <-
    httr::GET(url = "https://api.microsofttranslator.com/v2/http.svc/Translate",
              add_headers(.headers = c("Accept" = "application/xml", "Authorization" = token)),
              query = list(text = text, to = lanTo))
  
  response_xml <- httr::content(response, "text", encoding = "UTF-8")
  response_list <- xmlToList(response_xml)
  
  if (status_code(response) != 200) stopWithError(response)
  
  return(response_list)
}

#' @title Linguistic Analytics.
#' 
#' @note See \url{https://dev.projectoxford.ai/docs/services/56ea598f778daf01942505ff/operations/56ea5a1cca73071fd4b102bb} for more information about the API.
#' 
#' @param text Text to be analyzed. Is a string.
#' @param apiKey API key.
#' 
#' @return Response from the API call.
#' @export
cognitiveLinguiAnalysis <- function(text, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) stop("Error: no API Key provided!")
  
  json_txt <- 
    paste("{\"language\":\"en\", \"analyzerIds\":", "[\"22a6b758-420f-4745-8a3c-46835a67c0d2\", \"4fa79af1-f22c-408d-98bb-b7d7aeef7f04\", \"08ea174b-bfdb-4e64-987e-602f85da7f72\"],", "\"text\":\"", text, "\"}", sep = "", collapse = ",") 
  
  response <-
    httr::POST(url = "https://api.projectoxford.ai/linguistics/v1.0/analyze", 
               add_headers(.headers = c("Ocp-Apim-Subscription-Key" = apiKey, "Content-Type" = "application/json")), 
               body = json_txt) 
  
  response_df <-
    httr::content(response, "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() 
  
  # if return error code.
  if (status_code(response) != 200) stopwithError(response)
  
  return(response_df)
}