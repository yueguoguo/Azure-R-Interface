#' @title Error handling.
#' 
#' @note adopted from the AzureSMR package.
#' 
#' @param r response returned from a http request.
stopWithError <- function(r) {
  msg <- paste0(as.character(sys.call(1))[1], "()") # Name of calling fucntion
  addToMsg <- function(x){
    if(is.null(x)) x else paste(msg, x, sep = "\n")
  }
  if(inherits(httr::content(r), "xml_document")){
    rr <- XML::xmlToList(XML::xmlParse(httr::content(r)))
    msg <- addToMsg(rr$Code)
    msg <- addToMsg(rr$Message)
  } else {
    rr <- httr::content(r)
    msg <- addToMsg(rr$error$code)
    msg <- addToMsg(rr$error$message)
  }
  msg <- addToMsg(paste0("Return code: ", status_code(r)))
  stop(msg, call. = FALSE)
}