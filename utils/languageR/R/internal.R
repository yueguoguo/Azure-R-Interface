#' @title Error handling.
#' 
#' @param r Response returned from a http request.
stopWithError <- function(response) {
  msg <- paste0(as.character(sys.call(1))[1], "()") # Name of calling fucntion
  
  addToMsg <- function(x){
    if(is.null(x)) x else paste(msg, x, sep="\n")
  }
  
  if(inherits(httr::content(response), "xml_document")){
    rr <- XML::xmlToList(XML::xmlParse(httr::content(response)))
    msg <- addToMsg(rr$Code)
    msg <- addToMsg(rr$Message)
  } else {
    rr <- httr::content(response)
    msg <- addToMsg(rr$innerError$code)
    msg <- addToMsg(rr$innerError$message)
  }
  
  msg <- addToMsg(paste0("Return code: ", status_code(response)))
  stop(msg, call.=FALSE)
}

#' @title Manipulate response to data frame.
#' 
#' @param r response returned from a http request.
#' @return response in a friendly format (e.g., data frame or list).
outputFromResponse <- function(response) {
  if (inherits(httr::content(response), "xml_document")) {
    response_xml <- httr::content(response, "text")
    
    output <- iconv(xmlToList(response_xml), from="UTF-8", to="UTF-8") # Encodings are one of 21st century's worse headaches - Dominic Comtois from StackOverflow.
  } else {
    output <- 
      httr::content(response, "text", encoding="UTF-8") %>%
      jsonlite::fromJSON() 
  }
}