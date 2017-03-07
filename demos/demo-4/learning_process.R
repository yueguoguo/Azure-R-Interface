# ---------------------------------------------------------------------------
# THIS IS A HEADER ADDED BY COMPUTE INTERFACE
# ---------------------------------------------------------------------------
CI_MACHINES <- c( "pofg001", "pofg002", "pofg003", "pofg004", "pofg005", "pofg006", "pofg007" )
CI_DNS <- c( "pofg001.southeastasia.cloudapp.azure.com", "pofg002.southeastasia.cloudapp.azure.com", "pofg003.southeastasia.cloudapp.azure.com", "pofg004.southeastasia.cloudapp.azure.com", "pofg005.southeastasia.cloudapp.azure.com", "pofg006.southeastasia.cloudapp.azure.com", "pofg007.southeastasia.cloudapp.azure.com" )
CI_VMUSER <- c( "zhle" )
CI_MASTER <- c( "pofg001.southeastasia.cloudapp.azure.com" )
CI_SLAVES <- c( "pofg002.southeastasia.cloudapp.azure.com", "pofg003.southeastasia.cloudapp.azure.com", "pofg004.southeastasia.cloudapp.azure.com", "pofg005.southeastasia.cloudapp.azure.com", "pofg006.southeastasia.cloudapp.azure.com", "pofg007.southeastasia.cloudapp.azure.com" )
CI_DATA <- ""
CI_CONTEXT <- "clusterParallel"

library(RevoScaleR)
# library(readr)
library(doParallel)
# --------- Set compute context
cl <- makePSOCKcluster(names=CI_SLAVES, master=CI_MASTER, user=CI_VMUSER)
registerDoParallel(cl)
rxSetComputeContext(RxForeachDoPar())
# --------- Load data.
# ciData <- ifelse(CI_DATA != '', read_csv(CI_DATA), data.frame(0))
# ---------------------------------------------------------------------------
# END OF THE HEADER ADDED BY COMPUTE INTERFACE
# ---------------------------------------------------------------------------
library(dplyr)
library(RevoScaleR)
library(readr)
# library(MicrosoftML)
library(caret)
library(magrittr)
library(rattle)
library(doParallel)

# function for generic feature engineering.

featureEngineering <- function(formula, data) {
  
  # NA action.
  
  data %<>% na.omit()
  
  # remove non-variants.
  
  data %<>% select(-one_of(names(data[, nearZeroVar(df)])))
  
  # feature selection - use caret rfe
  
  control <- trainControl(method="repeatedcv", number=3, repeats=1)
  
  label <- as.character(formula[[2]])
  
  data %<>%
    mutate_each(funs(as.factor), one_of(label)) %>%
    mutate_if(is.character, as.factor)
  
  model <- train(select(data, -one_of(label)),
                 unlist(select(data, one_of(label))),
                 data=data,
                 method="rf",
                 preProcess="scale",
                 trControl=control)
  
  imp <- varImp(model, scale=FALSE)
  
  imp_list <- rownames(imp$importance)[order(imp$importance$Overall, decreasing=TRUE)]
  
  top_var <-
    imp_list[1:(ncol(data) - 3)] %>%
    as.character()
  
  label <- all.vars(formula)[1]
  
  data %<>% 
    select(., one_of(c(top_var, as.character(label)))) %>%
    as.data.frame()
  
  # for convenience purpose, make label a binary factor type variable.
  
  levels(data[, c(as.character(label))]) <- c("0", "1")
  
  data
}

mlProcess <- function(formula, data, modelName, modelPara) {
  
  library(dplyr)
  library(magrittr)
  library(caret)
  
  # functions used for model building and evaluating.
  
  modelCreation <- function(formula, data, modelName, modelPara) {
    
    if(missing(modelPara) ||
       is.null(modelPara) || 
       length(modelPara) == 0) {
      model <- do.call(modelName, list(data=data, formula=formula))
    } else {
      model <- do.call(modelName, c(list(data=data,
                                         formula=formula),
                                    modelPara))
    }
  }
  
  modelValidation <- function(formula, data, model) {
    
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
    
    prediction <-
      rxPredict(modelObject=model,
                data=data,
                # type="response",
                overwrite=TRUE)
    
    if("PredictedLabel" %in% names(prediction)) {
      prediction <- prediction$PredictedLabel
    }
    
    if(is.numeric(prediction[, 1])) {
      prediction <- ifelse(prediction[,1] > 0.5, "1", "0")
    }
      
    label <- all.vars(formula)[1]
    
    prediction <- lapply(prediction , factor, c(levels=c("0", "1")))
    prediction <- unlist(prediction)
    
    pred_metrics <- modelEvaluation(observed=unlist(data[, label]),
                                    predicted=prediction)
    
  }
  
  # update formula as after dropping non-variants some feature columns have been dropped..
  
  label <- all.vars(formula)[1]
  
  names <- rxGetVarNames(data=select(data, -one_of(as.character(label))))
  formula <- as.formula(paste(as.character(label), "~", paste(names, collapse="+")))
  
  # do partition here.
  
  train_index <- sample(1:nrow(data), round(0.7 * nrow(data)))
  dataTrain <- data[train_index, ]
  dataTest <- data[-train_index, ]
  
  model <- modelCreation(formula=formula,
                         data=dataTrain,
                         modelName=modelName,
                         modelPara=modelPara)
  
  result <- modelValidation(formula=formula,
                            data=dataTest,
                            model=model)
  
  list(model=model,
       result=result)
}

# -----------------------------------------------------------------------
# Let's do some test
# -----------------------------------------------------------------------

df <- read_csv("https://raw.githubusercontent.com/Microsoft/acceleratoRs/master/EmployeeAttritionPrediction/Data/DataSet1.csv")

# These are model configurations.

# TODO: MicrosoftML has much better ML algorithms but it is not available on Linux DSVM at the moment.

# model_config <- list(list(name="rxFastTrees",
#                           para=list(numTrees=100,
#                                     minSplit=10,
#                                     learningRate=0.2)),
#                      list(name="rxFastForest",
#                           para=list(numTrees=100,
#                                     minSplit=10)),
#                      list(name="rxLogisticRegression",
#                           para=list(l1Weight=2)),
#                      # fine tune net topology.
#                      list(name="rxNeuralNet",
#                           para=list(type="multiClass")))

# model configurations for RevoScaleR algorithms.

model_config <- list(name=c("rxLogit", "rxBTrees", "rxDForest", "rxNaiveBayes"), 
                     para=list(NULL,
                               NULL,
                               list(list(cp=0.01,
                                         nTree=50,
                                         mTry=3),
                                    list(cp=0.01,
                                         nTree=100,
                                         mTry=3),
                                    list(cp=0.01,
                                         nTree=200,
                                         mTry=3)),
                               NULL))

# since data set is the same so formula is the same as well.

label <- "Attrition"

names <- rxGetVarNames(data=select(df, -one_of(as.character(label))))
formula <- as.formula(paste(as.character(label), "~", paste(names, collapse="+")))

df %<>% featureEngineering(formula=formula)

# reconcile formula as data set has been changed after feature engineering.

names <- rxGetVarNames(data=select(df, -one_of(as.character(label))))
formula <- as.formula(paste(as.character(label), "~", paste(names, collapse="+")))

# just a test run on one algorithm - this is for debuging purpose.

# x <- mlProcess(formula=formula,
#                data=df,
#                modelName=model_config$name[3],
#                modelPara=x[[1]])

# let's try rx functions to parallelize the analysis:

# -----------------------------------------------------------------------
# Step1 - algorithm selection.
# -----------------------------------------------------------------------
# candidate algorithms with default parameters will be trained and validated with sample data sets. The outputs will be models and evaluation results for each algo.

results1 <- rxExec(mlProcess,
                   formula=formula,
                   data=df,
                   modelName=rxElemArg(model_config$name))

# -----------------------------------------------------------------------
# Step1 - algorithm selection.
# -----------------------------------------------------------------------
# after an algo is selected based on some criterion (let's say f-score, which is a balanced metric that considers both precision and recall.), another parallel execution on different sets of parameters are run - parameter tuning.

# select an algo with maximum f-score.

fscore <- numeric(0)
for (i in 1:length(results1)) {
  fscore[i] <- results1[[i]]$result["F-Score"]
}

algo <- model_config$name[which(fscore == max(fscore))]
para <- model_config$para[which(model_config$name == algo)]

# generate a list of model parameters according to config information.

results2 <- rxExec(mlProcess,
                   formula=formula,
                   data=df,
                   modelName=algo,
                   modelPara=rxElemArg(para))

results_all <- NULL
for (i in 1:length(results2)) {
  results_all[[length(results_all) + 1]] <- results2[[i]]$result
}

results_all
