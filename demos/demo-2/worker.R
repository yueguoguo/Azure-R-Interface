# ---------------------------------------------------------------------------
# THIS IS A HEADER ADDED BY R INTERFACE
# ---------------------------------------------------------------------------
RI_MACHINES <- c( "virtual_machine_name" )
RI_DNS <- c( "virtual_machine_url" )
RI_VMUSER <- c( "zl" )
RI_MASTER <- c( "" )
RI_SLAVES <- c( "" )
RI_DATA <- "https://projectsdisks415.blob.core.windows.net/data/dataset3.csv"
RI_CONTEXT <- "localParallel"

library(RevoScaleR)
library(doParallel)
# --------- Set compute context
rxSetComputeContext(RxLocalParallel())
# --------- Load data.
download.file(url=RI_DATA, destfile='./data.csv')
riData <- read.csv('./data.csv', header=T, sep=',')
# ---------------------------------------------------------------------------
# END OF THE HEADER ADDED BY R INTERFACE
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Your worker script starts from here ... 
# ---------------------------------------------------------------------------

# libraries

library(dplyr)
library(magrittr)

time_start <- Sys.time()

# preconfiguration of used models.

model_config <-
  list(
    rxDForest = list(seed = 10,
                     cp = 0.01,
                     nTree = 100,
                     mTry = 3),
    rxBTrees = list(seed = 10,
                    learningRate = 0.2,
                    nTree = 100,
                    minSplit = 10,
                    minBucket = 10),
    rxNaiveBayes = NULL
  )

# functions used for model building and evaluating.

modelCreation <- function(formula, dataTrain, dataTest, modelName, modelConfig) {
  
  # load library for the function environment.
  
  library(dplyr)
  
  # function to evaluate the model performance.
  
  modelEvaluation <- function(observed, predicted) {
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
  
  model <- do.call(modelName, c(list(formula=formula, 
                                     data=dataTrain,
                                     verbose=2),
                                modelConfig))
  
  label <- all.vars(formula)[1]
  
  prediction <- 
    rxPredict(modelObject=model,
              data=dataTest,
              type="prob",
              overwrite=TRUE) 
  prediction <-
    ifelse(prediction[,1] > 0.5, "Yes", "No") %>%
    lapply(. , factor, c(levels=c("No", "Yes"))) %>%
    unlist()
  
  pred_metrics <- modelEvaluation(observed=unlist(select(dataTest, contains(label))),
                                  predicted=prediction)
  
  return(list(model=modelName, 
              parameters=modelConfig, 
              results=pred_metrics))
}

df <- riData

train_index <- sample(1:nrow(df), round(0.7 * nrow(df)))
df_train <- df[train_index, ]
df_test <- df[-train_index, ]

# execute the analytics with specified computing context for boosted performance.

names_train <- rxGetVarNames(data=select(df_train, -Attrition))
formula <- as.formula(paste("Attrition ~ ", paste(names_train, collapse="+")))

results <- 
  rxExec(modelCreation,
         formula=formula,
         dataTrain=df_train,
         dataTest=df_test,
         modelName=rxElemArg(names(model_config)),
         modelConfig=rxElemArg(model_config)) %T>%
  print()

time_end <- Sys.time()
print(time_end - time_start)
