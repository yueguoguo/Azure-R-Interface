#' @title Sentiment analysis.
#' @references See \url{https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0} for more information about Text Analytics on Microsoft Cognitive Analysis.
#' @param text Text to be analyzed. Can be a dataframe or text vector. It is recommended to process multiple document in one call so as to save cost.
#' @param apiKey API key. Use apiInfo("function name") to get the information.
#' @return Response from sentiment analysis API, including score, text id, and/or error messages if there are.
#' @examples 
#' senti_score <- cognitiveSentiAnalysis("I love you", apiKey="a valid key string")
#' senti_score
#' 
#' text <- c("I love you", "I hate you", "This is love")
#' senti_scores <- cognitiveSentiAnalysis(text, apiKey="a valid key string")
#' senti_scores
#' @export
cognitiveSentiAnalysis <- function(text, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) {
    apiInfo()
    stop("Error: Please provide API key!")
  }
  
  json_txt <- 
    paste("{\"language\":\"en\", \"id\":\"", 1:length(text), "\", \"text\":\"", text, "\"}", sep="", collapse=",") %>%
    paste("{\"documents\": [", . , "]}", sep="") 
  
  response <-
    httr::POST(url="https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment", 
               add_headers(.headers=c("Ocp-Apim-Subscription-Key"=apiKey, "Content-Type"="application/json", "Accept"="application/json")), 
               body=json_txt) 
  
  if (status_code(response) != 200) {
    stopWithError(response)
  } else {
    return(outputFromResponse(response))
  }
}

#' @title Language detection.
#' @references See \url{https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0} for more information about Text Analytics on Microsoft Cognitive Analysis.
#' @param text Text to be analyzed. Can be a dataframe or text vector.
#' @param langNum number of languages to be detected.
#' @param apiKey API key.
#' @return Detected languages and/or error messages.
#' @examples 
#' lang1 <- cognitiveLangDetect("English", apiKey="a valid key string")
#' lang1
#' 
#' langs2 <- cognitiveLangDetect(c("English", "大数据"), langNum=2, apiKey="a valid key string")
#' langs2
#' @export
cognitiveLangDetect <- function(text, langNum=1, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) {
    apiInfo()
    stop("Error: Please provide API key!")
  }
  
  json_txt <- 
    paste("{\"language\":\"en\", \"id\":\"", 1:length(text), "\", \"text\":\"", text, "\"}", sep="", collapse=",") %>%
    paste("{\"documents\": [", . , "]}", sep="") 
  
  response <-
    httr::POST(url="https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/languages", 
               add_headers(.headers=c("Ocp-Apim-Subscription-Key"=apiKey, "Content-Type"="application/json", "Accept"="application/json")), 
               body=json_txt,
               numberOfLanguagesToDetect=langNum) 
  
  if (status_code(response) != 200) {
    stopWithError(response)
  } else {
    return(outputFromResponse(response))
  }
}

#' @title Topic detection.
#' @references See \url{https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0} for more information about Text Analytics on Microsoft Cognitive Analysis.
#' @note Note that one transaction is charged per text document submitted. For best performance, limit each document to a short, human written text paragraph such as review, conversation or user feedback.
#' @param text Text to be analyzed. Can be a dataframe, or a text vector.
#' @param stopWords Stop words to be excluded from the input documen text.
#' @param topicsToExclude Topics to be excluded from the detection.
#' @param apiKey API key.
#' @return Detected topics in the input documents and/or error messages.
#' @examples 
#' data(text_bbc)
#' 
#' topics_detected <- cognitiveTopicDetect(text_bbc, apiKey="a valid key")
#' topics_detected
#' @export
cognitiveTopicDetect <- function(text, apiKey,
                                 stopWords="",
                                 topicsToExclude="") {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) {
    apiInfo()
    stop("Error: Please provide API key!")
  }
  
  json_txt <- 
    paste("{\"id\":\"", 1:length(text), "\", \"text\":\"", text, "\"}", sep="", collapse=",") %>%
    paste("\"documents\": [", . , "]", sep="") %>%
    paste("{\"stopWords\": [\"", stopWords, "\"],", "\"topicsToExclude\": [\"", topicsToExclude, "\"],", ., "}", sep="")
  
  response <-
    httr::POST(url="https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/topics", 
               add_headers(.headers=c("Ocp-Apim-Subscription-Key"=apiKey, "Content-Type"="application/json", "Accept"="application/json")), 
               body=json_txt)
  
  if (status_code(response) != 202) stopWithError(response)
  
  repeat {
    op_location <- response$headers$`operation-location`
    job_response <- 
      httr::GET(url=op_location,
                add_headers(.headers=c(c("Ocp-Apim-Subscription-Key"=apiKey, "Content-Type"="application/json"))))
    
    if(content(job_response)$status == "Succeeded") {
      break
    } else if(content(job_response)$status == "Running") {
      print("The job is processing...")
    } else if(content(job_response)$status == "NotStarted") {
      print("The job has not been started.") 
    } else {
      stop(sprintf("The job failed - %s", content(job_response)$message))
    }
    
    Sys.sleep(5)
  }
  
  return(outputFromResponse(response))
}

#' @title Key phrases.
#' 
#' @references See \url{https://westus.dev.cognitive.microsoft.com/docs/services/TextAnalytics.V2.0} for more information about Text Analytics on Microsoft Cognitive Analysis.
#' @param text Text to be analyzed. Can be a dataframe or text vector.
#' @param apiKey API key.
#' @return Extracted key phrases and/or error messages.
#' @examples 
#' key_phrases <- cognitiveKeyPhrases("Artificial Intelligence is regarded as one of the disruptive technologies in the 21st century", apiKey="a valid key string")
#' key_phrases
#' @export
cognitiveKeyPhrases <- function(text, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) {
    apiInfo()
    stop("Error: Please provide API key!")
  }
  
  json_txt <- 
    paste("{\"language\":\"en\", \"id\":\"", 1:length(text), "\", \"text\":\"", text, "\"}", sep="", collapse=",") %>%
    paste("{\"documents\": [", . , "]}", sep="") 
  
  response <-
    httr::POST(url="https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/keyPhrases", 
               add_headers(.headers=c("Ocp-Apim-Subscription-Key"=apiKey, "Content-Type"="application/json", "Accept"="application/json")), 
               body=json_txt)
  
  if (status_code(response) != 200) {
    stopWithError(response)
  } else {
    return(outputFromResponse(response))
  }
}

#' @title Spelling check.
#' 
#' @references See \url{https://dev.cognitive.microsoft.com/docs/services/56e73033cf5ff80c2008c679/operations/56e73036cf5ff81048ee6727} for more information about Spell Check API.
#' @param text Text to be analyzed. Can be a dataframe or text vector.
#' @param mode Spelling check mode. Deafult is proof.
#' @param mkt Market location. Default is "en-us".
#' @return A data frame containing the detected token, its offset, type, and suggestions.
#' @examples 
#' text <- c("today is holliday", "hapyp new yaer")
#' 
#' text_detected <- cognitiveSpellingCheck(text, apiKey="a valid key")
#' text_detected
#' @export
cognitiveSpellingCheck <- function(text, apiKey,
                                   mode="Proof",
                                   mkt="en-us") {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) {
    apiInfo()
    stop("Error: Please provide API key!")
  }
  
  text <- paste("text=", paste(text, collapse=","), sep="")
  
  response <-
    httr::POST(url="https://api.cognitive.microsoft.com/bing/v5.0/spellcheck",
               add_headers(.headers=c("Ocp-Apim-Subscription-Key"=apiKey, "Content-Type"="application/x-www-form-urlencoded")), 
               body=text,
               mode=mode,
               mkt="en-us") 
  
  if (status_code(response) != 200) {
    stopWithError(response)
  } else {
    return(outputFromResponse(response))
  }
}

#' @title Translation.
#' 
#' @references See \url{http://docs.microsofttranslator.com/text-translate.html#!/default/post_TranslateArray} for more information about Translation API. Get lists of languages (and codes) supported in the API at \url{https://msdn.microsoft.com/en-us/library/hh456380.aspx}.
#' @param text text to be analyzed. 
#' @param lanFrom Source language.
#' @param lanTo Target language.
#' @param apiKey API key.
#' @return A data frame containing the translated text in the target language.
#' @examples 
#' text <- "大数据"
#' 
#' translated_text1 <- cognitiveTranslation(text, lanFrom="zh-CHS", lanTo="en", apiKey="a valid key")
#' translated_text1
#' 
#' text <- "Big Data"
#' translated_text2 <- cognitiveTranslation(text, lanFrom="en", lanTo="zh-CHS", apiKey="a valid key")
#' translated_text2
#' 
#' translated_text3 <- cognitiveTranslation(text, lanFrom="en", lanTo="zh-CHT", apiKey="a valid key")
#' translated_text3
#' @export
cognitiveTranslation <- function(text, lanFrom, lanTo, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(lanFrom)) stop("Error: no source language provided!")
  if (missing(lanTo)) stop("Error: no target language provided!")
  if (missing(apiKey)) {
    apiInfo()
    stop("Error: Please provide API key!")
  }
  
  # get the authentication token.
  
  token_response <- 
    httr::POST(url="https://api.cognitive.microsoft.com/sts/v1.0/issueToken",
               add_headers(.headers=c("Ocp-Apim-Subscription-Key"=apiKey)))
  
  if (status_code(token_response) != 200) stopWithError(response)
  token <- paste("Bearer", httr::content(token_response, "text", encoding="UTF-8"), sep=" ")
  
  response <-
    httr::GET(url="https://api.microsofttranslator.com/v2/http.svc/Translate",
              add_headers(.headers=c("Accept"="application/xml", "Authorization"=token)),
              query=list(text=text, from=lanFrom, to=lanTo))
  
  if (status_code(response) != 200) {
    stopWithError(response)
  } else {
    return(outputFromResponse(response))
  }
}

#' @title Linguistic Analytics.
#' @references See \url{https://dev.projectoxford.ai/docs/services/56ea598f778daf01942505ff/operations/56ea5a1cca73071fd4b102bb} for more information about the API.
#' @param text Text to be analyzed. Is a string.
#' @param apiKey API key.
#' @return Response from the API call.
#' @examples 
#' text <- "What did you say?!? I didn't hear about the director's "new proposal." It's important to Mr. and Mrs. Smith"
#' 
#' tokens <- cognitiveLinguiAnalysis(text, apiKey="a valid key")
#' tokens
#' @export
cognitiveLinguiAnalysis <- function(text, apiKey) {
  if (missing(text) | !length(text) | (class(text) != "character")) stop("Error: no input provided or the input is not character type!")
  if (missing(apiKey)) {
    apiInfo()
    stop("Error: Please provide API key!")
  }
  
  json_txt <- 
    paste("{\"language\":\"en\", \"analyzerIds\":", "[\"22a6b758-420f-4745-8a3c-46835a67c0d2\", \"4fa79af1-f22c-408d-98bb-b7d7aeef7f04\", \"08ea174b-bfdb-4e64-987e-602f85da7f72\"],", "\"text\":\"", text, "\"}", sep="", collapse=",") 
  
  response <-
    httr::POST(url="https://api.projectoxford.ai/linguistics/v1.0/analyze", 
               add_headers(.headers=c("Ocp-Apim-Subscription-Key"=apiKey, "Content-Type"="application/json")), 
               body=json_txt) 
  
  if (status_code(response) != 200) {
    stopWithError(response)
  } else {
    return(outputFromResponse(response))
  }
}