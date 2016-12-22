# ----------------------------------------------------------------------
# Worker script for cluster parallel experiments to sweep parameters.
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le.
# CONTRIBUTORS:       Zhang Le.
# DATE OF CREATION:   20161028
# DEPARTMENT:         IMML & ADS
# COMPANY:            Microsoft
# ----------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Worker Script Starts Here ... 
# ---------------------------------------------------------------------------

time_start <- Sys.time()

# Libraries used.

library(dplyr)
library(magrittr)
library(ggplot2)

# Environment setup.

DATA_URL        <- RI_DATA
LOCAL_DATA_DIR  <- "."
LOCAL_DATA_NAME <- "<local-data-csv-file>"

# Feature engineering.

LIFE_WINDOW <- 10
LAG_WINDOW  <- 5
LAG_ALIGN   <- "right"

# ----------------------------------------------------------------------------
# Data Preparation
# ----------------------------------------------------------------------------

# Download and import data.

download.file(url=DATA_URL,
              destfile=file.path(LOCAL_DATA_DIR, LOCAL_DATA_NAME))

df <- read.csv(file.path(LOCAL_DATA_DIR, LOCAL_DATA_NAME),
               header=T, sep=",", stringsAsFactors=F)

analytics <- function(df, life_window, lag_align, lag_window)
{
  library(dplyr)
  library(magrittr)
  library(zoo)
  
  # Global variables used in the function.

  TRAIN_RATIO  <- 0.7
  TOP_FEATURES <- 35
  ALGO         <- "boosted tree"
  
  if (ALGO == "decision forest")
  {
    N_TREE <- 100
    TYPE   <- "class"
    M_TRY  <- 3
    CP     <- 0.01
    X_CV   <- 5
    
  } else if (ALGO == "boosted tree")
  {
    LEARN_RATE <- 0.2
    MIN_SPLIT  <- 10
    MIN_BUCKET <- 10
    N_TREE     <- 100
  } else {
    stop("Specify an algorithm to train the model.")
  }
  
  df_group <- 
    group_by(df, id) %>%
    summarise(count=n()) 
  if(life_window > min(df_group$count)) stop("life_window too large.")
  
  df_data <-
    select(df, -setting1, -setting2, -setting3) %>%
    group_by(id) %>%
    arrange(cycle) %>%
    mutate(label=ifelse(row_number() > round(n() / 2), 1, 0)) %>%
    filter(row_number() <= life_window | row_number() > n() - life_window)
  
  # Label the data and aggregate the features.
  
  fun_rollmean <- function(x) zoo::rollmean(x, lag_window, na.pad=TRUE, align=lag_align)
  fun_rollsd <- function(x) zoo::rollapply(x, lag_window, FUN=sd, align=lag_align, fill=NA)
  
  # Compute rolling mean and rolling standard deviation as new features.
  
  names_raw <- rxGetVarNames(df_data)[3:23]
  names_rollmean <- setNames(names_raw, paste0(names_raw, "_rollmean"))
  names_rollsd <- setNames(names_raw, paste0(names_raw, "_rollsd"))
  
  df_feature <-
    ungroup(df_data) %>%
    group_by(id, label) %>%
    mutate_each_(funs(fun_rollmean), names_rollmean) %>%
    mutate_each_(funs(fun_rollsd), names_rollsd) %>%
    select(-cycle)
  
  id.train <-
    sample(df_group$id, round(nrow(df_group) * TRAIN_RATIO)) 
  
  df_feature_train <-
    filter(df_feature, id %in% id.train) %>%
    ungroup() %>%
    select(-id)
  
  df_feature_test <-
    filter(df_feature, !id %in% id.train) %>%
    ungroup() %>%
    select(-id)
  
  # Find the top 35 relevant features.
  
  names_train <- rxGetVarNames(data=df_feature_train)
  formula_train <- as.formula(paste("~ ", paste(names_train, collapse="+")))
  correlation_train <- rxCor(formula=formula_train,
                             data=df_feature_train)
  correlation_train <- correlation_train[, "label"]
  correlation_abs <- abs(correlation_train)
  correlation_abs <- correlation_abs[order(correlation_abs, decreasing=TRUE)]
  correlation_abs <- correlation_abs[-1]
  correlation_abs <- correlation_abs[1:TOP_FEATURES]
  formula_train_top <-
    as.formula(paste(paste("label ~ "),
                     paste(names(correlation_abs), collapse="+")))
  
  # ----------------------------------------------------------------------------
  # Model Building
  # ----------------------------------------------------------------------------
  
  if (ALGO == "decision forest")
  {
    model <- rxDForest(formula=formula_train_top, 
                       seed=10,
                       data=df_feature_train, 
                       cp=CP, 
                       nTree=N_TREE, 
                       mTry=M_TRY,
                       verbose=2)
  } else if (ALGO == "boosted tree")
  {
    model <- rxBTrees(formula=formula_train_top, 
                      seed=10,
                      data=df_feature_train, 
                      learningRate=LEARN_RATE,
                      nTree=N_TREE, 
                      minSplit=MIN_SPLIT,
                      minBucket=MIN_BUCKET,
                      verbose=2)
  } else {
    stop("Please specify a valid algorithm for training the model.")
  }
  
  # ----------------------------------------------------------------------------
  # Evaluate Results
  # ----------------------------------------------------------------------------

  # Binary classification model evaluation metrics.
  
  evaluate_model <- function(observed, predicted)
  {
    confusion <- table(observed, predicted)
    print(confusion)
    tp <- confusion[1, 1]
    fn <- confusion[1, 2]
    fp <- confusion[2, 1]
    tn <- confusion[2, 2]
    accuracy <- (tp + tn) / (tp + fn + fp + tn)
    precision <- tp / (tp + fp)
    recall <- tp / (tp + fn)
    fscore <- 2 * (precision * recall) / (precision + recall)
    metrics <- c("Accuracy"=accuracy,
                 "Precision"=precision,
                 "Recall"=recall,
                 "F-Score"=fscore)
    print(data.frame(metrics))
    return(metrics)
  }
  
  df_test <- select(df_feature_test, select=-label)
  prediction <- rxPredict(modelObject=model,
                          data=df_feature_test,
                          type="prob",
                          overwrite=TRUE)
  
  threshold <- 0.5
  names(prediction) <- "pred.prob"
  prediction$pred.prob <- ifelse(prediction$pred.prob > threshold, 1, 0)
  prediction$pred.prob <- factor(prediction$pred.prob, levels=c(0, 1))
  
  print(sprintf("LIFE_WINDOW is %d and LAG_WINDOW is %d", life_window, lag_window))
  
  pred_metrics <- evaluate_model(observed=df_feature_test$label,
                                 predicted=prediction$pred.prob)
  
  c(pred_metrics, life_window, lag_window)
}

# Two experiments to sweep one parameter.
# (window=20, lag=3) and (window=50, lag=3)

sys1 <- system.time(rxExec(analytics,
                           df=df,
                           life_window=rxElemArg(c(40, 50)),
                           lag_align="left",
                           lag_window=rxElemArg(c(3, 3))) %T>% print())
print("Time cost of experiment on one parameter:") 
sprintf("%f minutes", sys1[3] / 60)

# Four experiments to sweep 2 parameters.
# (window=20, lag=3), (window=20, lag=5), (window=50, lag=3), and (window=50, lag=5)
sys2 <- system.time(rxExec(analytics,
                           df=df,
                           life_window=rxElemArg(list(40, 40, 50, 50)),
                           lag_align="left",
                           lag_window=rxElemArg(list(3, 5, 3, 5)),
                           timesToRun=4) %T>% print())
print("Time cost of experiment on one parameter:") 
sprintf("%f minutes", sys2[3] / 60)

time_end <- Sys.time()
print(time_end - time_start)

# ----------------------------------------------------------------------------
# Clean Up
# ----------------------------------------------------------------------------

file.remove(file.path(LOCAL_DATA_DIR, LOCAL_DATA_NAME))
