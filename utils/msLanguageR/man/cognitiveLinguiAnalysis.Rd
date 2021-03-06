% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/msLanguageR.R
\name{cognitiveLinguiAnalysis}
\alias{cognitiveLinguiAnalysis}
\title{Linguistic Analytics.}
\usage{
cognitiveLinguiAnalysis(text, apiKey)
}
\arguments{
\item{text}{Text to be analyzed. Is a string.}

\item{apiKey}{API key.}
}
\value{
Response from the API call.
}
\examples{
text <- "What did you say?!? I didn't hear about the director's "new proposal." It's important to Mr. and Mrs. Smith"

tokens <- cognitiveLinguiAnalysis(text, apiKey="a valid key")
tokens
}
\references{
See \url{https://dev.projectoxford.ai/docs/services/56ea598f778daf01942505ff/operations/56ea5a1cca73071fd4b102bb} for more information about the API.
}

