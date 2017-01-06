# -------------------------------------------------------------------------
# Data exploration and feature engineering.
#
# Author:   Le Zhang
# Date:     20161227
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Initial setup
# -------------------------------------------------------------------------

# libraries used

# tools 

library(cognitiveR)

# data wrangling

library(dplyr)
library(magrittr)
library(stringr)

# natural language processing

library(tm)

# data visualization

library(ggplot2)
library(wordcloud)

# global variables

DATA <- "https://projectsdisks415.blob.core.windows.net/data/dataset.csv"

source("settings.R")

# -------------------------------------------------------------------------
# Data exploration on demographic data
# -------------------------------------------------------------------------

download.file(url = DATA,
              destfile = "./data.csv")

df <- 
  read.csv("./data.csv", header = TRUE) %>%
  mutate(Feedback = as.character(Feedback))

str(df)

# Count of terminated and active employees with different titles.

ggplot(df, aes(x=factor(Attrition), fill=factor(JobRole))) +
 geom_bar(width=0.5) +
  coord_flip() +
  xlab("Employment status") +
  ylab("Count") +
  scale_fill_discrete(guide=guide_legend(title="Job titles"))

# distribution of monthly income for job levels below 3 and service years between 2 and 5 years. 

ggplot(filter(df, YearsAtCompany >= 2 & YearsAtCompany <= 5 & JobLevel < 3),
       aes(x=factor(JobRole), y=MonthlyIncome, color=factor(Attrition))) +
  geom_boxplot() +
  xlab("Job title") +
  ylab("Monthly income") +
  scale_fill_discrete(guide=guide_legend(title="Job titles"))

# distribution of years-since-last-promotion for employees with different jobt titles and job levels.

ggplot(df, aes(x=YearsSinceLastPromotion, fill=factor(Attrition))) +
  geom_histogram(binwidth=0.5) +
  aes(y=..density..) +
  xlab("Years since last promotion.") +
  ylab("Density") +
  scale_fill_discrete(guide=guide_legend(title="Attrition")) +
  facet_grid(JobRole ~ JobLevel)

# -------------------------------------------------------------------------
# Data exploration on sentiment data
# -------------------------------------------------------------------------

# Job satisfaction score for employees with different status.

ggplot(df, aes(x=factor(JobSatisfaction), fill=factor(Attrition))) +
  geom_bar(width=0.5) +
  xlab("Score in Job Satisfaction.") +
  ylab("Count") +
  scale_fill_discrete(guide=guide_legend(title="Attrition")) 

# Sentiment score for employees with different status.

FeedbackSentiment=cognitiveSentiAnalysis(text=df$Feedback, apiKey=KEY_SENTI)

df %>%
  select(-Feedback) %>%
  cbind(., FeedbackSentiment=FeedbackSentiment$documents$score) ->
  df_exp_senti

ggplot(data=df_exp_senti, aes(x=JobRole, y=FeedbackSentiment, color=Attrition)) +
  geom_boxplot() +
  theme_bw() +
  xlab("Title") +
  ylab("Sentiment Score")

# Term frequency statistics for employees with different status.

corp_text <- 
  Corpus(VectorSource(df$Feedback)) %>%
  tm_map(removeNumbers) %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removeWords, stopwords("english")) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace) 

dtm_txt_raw <- 
  DocumentTermMatrix(corp_text, control=list(wordLengths=c(1, Inf), weighting=weightTf)) 

df_txt_wc <- 
  inspect(removeSparseTerms(dtm_txt_raw, 0.95)) %>%
  as.data.frame()

# plot word cloud.

wordcloud(words=names(df_txt_wc), 
          freq=colSums(df_txt_wc),
          random.order=FALSE)

# -------------------------------------------------------------
# Data preparation
# -------------------------------------------------------------

# data 1 - just demographic information.

df1 <- select(df,
              -EnvironmentSatisfaction,
              -JobSatisfaction,
              -RelationshipSatisfaction,
              -WorkLifeBalance,
              -JobInvolvement,
              -Feedback)

# data 2 - demographic with sentiment (term frequency)

dtm_txt <-
  removeSparseTerms(dtm_txt_raw, 0.9) %>%
  print()

df_txt <- 
  inspect(dtm_txt) %>%
  as.data.frame()

names(df_txt) <- paste("t", 1:ncol(df_txt), sep="")

df2 <- cbind(select(df, -Feedback), df_txt)

# data 3 - demographic with sentiment (sentiment score)

df3 <- df_exp_senti

# -------------------------------------------------------------
# Experimentation
# -------------------------------------------------------------

# upload the data sets onto blob and experimentally analyze it with Azure resources with help of R interface...