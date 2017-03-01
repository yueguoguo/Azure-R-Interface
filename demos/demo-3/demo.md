Employee Attrition Prediction with R Accelerator
========================================================
author: Le Zhang, Data Scientist at Microsoft
date: 2017-03-01
width: 1600
height: 1000

Agenda
========================================================



- Introduction.
- Employee attrition prediction with sentiment analysis.
- Walk-through of an R accelerator.

Introduction
========================================================

- Microsoft Algorithms and Data Science (ADS).
- ADS Asia Pacific. 
    - Scalable tools & algorithms for advanced analytics.
    - Data science accelerators to resolve real-world problems.

<img src="demo-figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

Data science and machine learning
========================================================

- Data science & Machine learning
- A review on iris.

![plot of chunk unnamed-chunk-3](demo-figure/unnamed-chunk-3-1.png)![plot of chunk unnamed-chunk-3](demo-figure/unnamed-chunk-3-2.png)

- Use cases: predictive maintenance, churn prediction, etc.

General work flow
========================================================

Microsoft Team Data Science Process

Use case - employee attrition prediction
========================================================

- Voluntary and involuntary.
- Consequences of employee attrition.
    - Loss of human resources.
    - Cost on new hires.
    - Potential loss of IP.
    
Use case - employee attrition prediction
========================================================

A general workflow

1. Problem formalization.
2. Data collection, exploration, and preparation.
3. Feature extraction.
4. Model creation and validation.

Problem formalization
========================================================

- Attrition rate.
- **Individual attrition** 
    - to identify employees with inclination of leaving with the available data.

Data collection, exploration, and preparation
========================================================

- historical records of each employee.
    - Time series.
    - Aggregated data.
- Labelled by employment status.

|Categories|Description|Factors|
|-----------|------------------------|------------------|
|Static|All sorts of demographic data, data that changes deterministically over time, etc.|Age, gender, years of service, etc.|
|Dynamic|Data that evolves over time, temporary data, etc.|Performance, salary, working hour, satifcation of job, social media posts, etc.|

Data collection, exploration, and preparation
========================================================

More understanding on data.

- Consult domain experts.
- Data exploration.
- Visualization.

Data collection, exploration, and preparation
========================================================

- Data source 
    - Employee attrition data: https://community.watsonanalytics.com/wp-content/uploads/2015/03/WA_Fn-UseC_-HR-Employee-Attrition.xlsx
    - Text data: http://www.glassdoor.com


```

  No  Yes 
1233  237 
```

- A glimpse at static data.


```
   Age Gender                   JobRole YearsAtCompany Attrition
1   49   Male        Research Scientist             10        No
2   33 Female        Research Scientist              8        No
3   27   Male     Laboratory Technician              2        No
4   32   Male     Laboratory Technician              7        No
5   59 Female     Laboratory Technician              1        No
6   30   Male     Laboratory Technician              1        No
7   38   Male    Manufacturing Director              9        No
8   36   Male Healthcare Representative              7        No
9   35   Male     Laboratory Technician              5        No
10  29 Female     Laboratory Technician              9        No
```

Data collection, exploration, and preparation
========================================================

<img src="demo-figure/unnamed-chunk-6-1.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" /><img src="demo-figure/unnamed-chunk-6-2.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" /><img src="demo-figure/unnamed-chunk-6-3.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

Data collection, exploration, and preparation
========================================================

Sentiment analysis

- Examples
    - Scoring
        - How do you feel about the job?
        - Do you have work-life balance?
        - How is the relationship with colleagues?
    - Posts on social media
        1. The work you have done is so cool!
        2. I do not think I am needed in the company...

Feature Extraction
========================================================

- Static data - ready for use.
- Dynamic data
    - Data aggregation.
        - Time series characteristics.
        - Statistical measures.
    - Natural language process.
    
Feature Extraction (Cont'd)
========================================================

- Statistical measures
    - max, min, standard deviation, etc.
- Time series characterization.
    - Trend analysis.
    - Peak detection.
    - Time series model (ARIMA, etc.)
- Feature selection.

Model creation and validation
========================================================

- Model selection
    - Logistic regression.
    - Support vector machine.
    - Decision tree.
- Ensemble methods
    - Bagging (bootstrap aggregating).
    - Boosting.
    - Stacking.
- Model training
    - Data partition.
    - Resampling.
    
Model creation and validation
========================================================

- Cross validation.
- Confusion matrix.
    - Precision.
    - Recall.
    - F Score.
    - ...

Employee attrition prediction - R accelerator
========================================================

- What-is
    - **Lightweight end-to-end solution templates that can be reused for accelerating process of prototyping, presenting, and documenting a data science solution of specific domain.**
    - Github repo https://github.com/Microsoft/acceleratoRs
- Why R

Step 1 Data exploration
========================================================

- Employee attrition data.


```r
dim(df1)
```

```
[1] 1470   33
```

- Review comments data.


```r
dim(df2)
```

```
[1] 500  34
```


```r
head(df2$Feedback, 3)
```

```
[1] "People are willing to share knowledge which is not the norm in this industry This is the first place I have worked where the people are great about that Also I get to work on cool projects that no one else in the world works on"
[2] "To repeat what I wrote before the people I work for and work with here are very smart and confident people"                                                                                                                         
[3] "The variety of different projects and the speed of completion I am truly very satisfied  pleased there is an endless list of pros"                                                                                                  
```

Step 2 Data preprocessing
========================================================


```r
# get predictors that has no variation.

pred_no_var <- names(df1[, nearZeroVar(df1)]) %T>% print()
```

```
[1] "EmployeeCount" "StandardHours"
```


```r
# remove the zero variation predictor columns.

df1 %<>% select(-one_of(pred_no_var))
```

Step 2 Data preprocessing (Cont'd)
========================================================


```r
# convert certain interger variable to factor variable.

int_2_ftr_vars <- c("Education", "EnvironmentSatisfaction", "JobInvolvement", "JobLevel", "JobSatisfaction", "NumCompaniesWorked", "PerformanceRating", "RelationshipSatisfaction", "StockOptionLevel")

df1[, int_2_ftr_vars] <- lapply((df1[, int_2_ftr_vars]), as.factor)
```


```r
# convert remaining integer variables to be numeric.

df1 %<>% mutate_if(is.integer, as.numeric)
```


```r
df1 %<>% mutate_if(is.character, as.factor)
```

Step 2 Feature extraction
========================================================

Select salient features with a pre-trained model.


```r
control <- trainControl(method="repeatedcv", number=3, repeats=1)

# train the model

model <- train(dplyr::select(df1, -Attrition), 
               df1$Attrition,
               data=df1, 
               method="rf", 
               preProcess="scale", 
               trControl=control)
```


```r
# estimate variable importance

imp <- varImp(model, scale=FALSE)
```

Step 2 Feature extraction (Cont'd)
========================================================


```r
# select the top-ranking variables.

imp_list <- rownames(imp$importance)[order(imp$importance$Overall, decreasing=TRUE)]

# drop the low ranking variables. Here the last 3 variables are dropped. 

top_var <- 
  imp_list[1:(ncol(df1) - 3)] %>%
  as.character() 

top_var
```

```
 [1] "MonthlyIncome"            "OverTime"                
 [3] "NumCompaniesWorked"       "Age"                     
 [5] "DailyRate"                "TotalWorkingYears"       
 [7] "JobRole"                  "DistanceFromHome"        
 [9] "MonthlyRate"              "HourlyRate"              
[11] "YearsAtCompany"           "PercentSalaryHike"       
[13] "EnvironmentSatisfaction"  "StockOptionLevel"        
[15] "EducationField"           "TrainingTimesLastYear"   
[17] "YearsWithCurrManager"     "JobSatisfaction"         
[19] "WorkLifeBalance"          "YearsSinceLastPromotion" 
[21] "JobLevel"                 "JobInvolvement"          
[23] "RelationshipSatisfaction" "Education"               
[25] "YearsInCurrentRole"       "MaritalStatus"           
[27] "BusinessTravel"           "Department"              
```

Step 3 Resampling
========================================================


```r
train_index <- 
  createDataPartition(df1$Attrition,
                      times=1,
                      p=.7) %>%
  unlist()

df1_train <- df1[train_index, ]
df1_test <- df1[-train_index, ]
```


```r
table(df1_train$Attrition)
```

```

 No Yes 
864 166 
```

Step 3 Resampling (Cont'd)
========================================================


```r
df1_train %<>% as.data.frame()

df1_train <- SMOTE(Attrition ~ .,
                  df1_train,
                  perc.over=300,
                  perc.under=150)
```


```r
table(df1_train$Attrition)
```

```

 No Yes 
747 664 
```

Step 4 Model building
========================================================


```r
# initialize training control. 
tc <- trainControl(method="boot", 
                   number=3, 
                   repeats=3, 
                   search="grid",
                   classProbs=TRUE,
                   savePredictions="final",
                   summaryFunction=twoClassSummary)
```

Step 4 Model building (Cont'd)
========================================================

Let's try several machine learning algorithms.


```r
# SVM model.

time_svm <- system.time(
  model_svm <- train(Attrition ~ .,
                     df1_train,
                     method="svmRadial",
                     trainControl=tc)
)

# random forest model

time_rf <- system.time(
  model_rf <- train(Attrition ~ .,
                     df1_train,
                     method="rf",
                     trainControl=tc)
)

# xgboost model.

time_xgb <- system.time(
  model_xgb <- train(Attrition ~ .,
                     df1_train,
                     method="xgbLinear",
                     trainControl=tc)
)
```

Step 4 Model building (Cont'd)
========================================================

An ensemble may be better?


```r
# ensemble of the three models.

time_ensemble <- system.time(
  model_list <- caretList(Attrition ~ ., 
                          data=df1_train,
                          trControl=tc,
                          methodList=c("svmRadial", "rf", "xgbLinear"))
)
```

```r
# stack of models. Use glm for meta model.

model_stack <- caretStack(
  model_list,
  metric="ROC",
  method="glm",
  trControl=tc
)
```

Step 5 Model evaluating
========================================================


```r
predictions <-lapply(models, 
                     predict, 
                     newdata=select(df1_test, -Attrition))
```


```r
# confusion matrix evaluation results.

cm_metrics <- lapply(predictions,
                     confusionMatrix, 
                     reference=df1_test$Attrition, 
                     positive="Yes")
```

Step 5 Model evaluating (Cont'd)
========================================================

Comparison of different models.




```r
algo_list <- c("SVM RBF", "Random Forest", "Xgboost", "Stacking")
time_consumption <- c(time_svm[3], time_rf[3], time_xgb[3], time_ensemble[3])

df_comp <- 
  data.frame(Models=algo_list, 
             Accuracy=acc_metrics, 
             Recall=rec_metrics, 
             Precision=pre_metrics,
             Elapsed=time_consumption) %T>%
             {head(.) %>% print()}
```

Step 6 Sentiment analysis - a glimpse
========================================================

```r
# getting the data.

head(df2$Feedback, 10)
```

```
 [1] "People are willing to share knowledge which is not the norm in this industry This is the first place I have worked where the people are great about that Also I get to work on cool projects that no one else in the world works on"                                                                                                                                                                
 [2] "To repeat what I wrote before the people I work for and work with here are very smart and confident people"                                                                                                                                                                                                                                                                                         
 [3] "The variety of different projects and the speed of completion I am truly very satisfied  pleased there is an endless list of pros"                                                                                                                                                                                                                                                                  
 [4] "As youve probably heard Google has great benefits insurance and flexible hours If you want to you can work from home"                                                                                                                                                                                                                                                                               
 [5] "Great insurance benefits free food equipment is available whenever you want it to be and there is always whatever you need monitor etc"                                                                                                                                                                                                                                                             
 [6] "Perks and incentives are a major plus I work with a lot of smart people and the people are the best part"                                                                                                                                                                                                                                                                                           
 [7] "We are at the forefront of new technology and so we are working with very high tech professionals every day"                                                                                                                                                                                                                                                                                        
 [8] "Great people to work with here as well as an enjoyable work environment I love to come to work every day"                                                                                                                                                                                                                                                                                           
 [9] "An amazing spirit of innovation open collaborative atmosphere great employee development and career advancement and exceptional senior management"                                                                                                                                                                                                                                                  
[10] "You work with the brightest people in the world who are also very modest and kind Very fun enjoyable flexible atmosphere where you can be yourself Every day I was there I found another reason to love it The campus is very well connected and collegial The food is obviously amazing They are also always inviting speakers and musicians and finding ways to keep you entertained and learning"
```

Step 7 Sentiment analysis - feature extraction
========================================================

```r
# create a corpus based upon the text data.

corp_text <- Corpus(VectorSource(df2$Feedback))
```


```r
# transformation on the corpus.

corp_text %<>%
  tm_map(removeNumbers) %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(removeWords, stopwords("english")) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace) 
```

Step 7 Sentiment analysis - feature extraction (Cont'd)
========================================================


```r
dtm_txt_tf <- 
  DocumentTermMatrix(corp_text, control=list(wordLengths=c(1, Inf), weighting=weightTf)) 
```


```r
# remove sparse terms.

dtm_txt <-
  removeSparseTerms(dtm_txt_tf, 0.99)
```


```r
df_txt <- 
  inspect(dtm_txt) %>%
  as.data.frame()
```

```
<<DocumentTermMatrix (documents: 500, terms: 352)>>
Non-/sparse entries: 6077/169923
Sparsity           : 97%
Maximal term length: 14
Weighting          : term frequency (tf)

     Terms
Docs  ability able access actually advance advancement almost also always
  1         0    0      0        0       0           0      0    1      0
  2         0    0      0        0       0           0      0    0      0
  3         0    0      0        0       0           0      0    0      0
  4         0    0      0        0       0           0      0    0      0
  5         0    0      0        0       0           0      0    0      1
  6         0    0      0        0       0           0      0    0      0
  7         0    0      0        0       0           0      0    0      0
  8         0    0      0        0       0           0      0    0      0
  9         0    0      0        0       0           1      0    0      0
  10        0    0      0        0       0           0      0    2      1
  11        0    0      0        0       0           0      0    0      0
  12        0    0      0        0       0           0      0    0      0
  13        0    0      0        0       0           0      0    1      0
  14        0    0      0        0       0           0      0    0      0
  15        0    0      0        0       0           0      0    0      0
  16        0    0      0        0       0           0      0    0      0
  17        0    0      0        0       0           0      0    0      0
  18        0    0      0        0       0           0      0    1      0
  19        0    0      0        0       0           0      0    0      0
  20        0    0      0        0       0           0      0    0      0
  21        0    0      0        0       0           0      0    0      0
  22        0    0      0        0       0           0      0    0      0
  23        0    0      0        0       0           0      0    0      0
  24        0    0      0        0       0           0      0    0      0
  25        0    0      0        0       0           0      0    0      0
  26        0    0      0        0       0           0      0    0      0
  27        0    0      0        0       0           0      0    0      0
  28        0    0      0        0       0           0      0    0      0
  29        0    0      0        0       0           0      0    0      0
  30        0    0      0        0       0           0      0    1      1
  31        0    0      1        0       0           0      0    0      0
  32        0    0      0        0       0           0      0    0      0
  33        0    0      0        0       0           0      0    0      0
  34        0    0      0        0       0           0      0    0      0
  35        0    0      0        0       0           0      0    0      1
  36        0    0      0        0       0           0      0    1      0
  37        0    0      0        0       0           0      0    0      0
  38        0    0      0        0       0           0      0    1      0
  39        0    0      0        0       0           0      0    0      0
  40        0    0      0        0       0           0      0    0      0
  41        0    0      0        0       0           0      0    0      0
  42        0    0      0        0       0           0      0    0      0
  43        0    0      0        0       0           0      1    0      0
  44        0    0      0        0       0           0      0    0      0
  45        0    0      0        0       0           0      0    0      0
  46        0    0      0        0       0           0      0    0      0
  47        0    0      0        0       0           0      0    0      0
  48        0    0      0        0       0           0      0    0      0
  49        0    0      0        0       0           0      0    0      0
  50        0    0      0        0       0           0      0    0      0
  51        0    0      0        0       0           0      0    0      0
  52        1    0      0        0       0           0      0    0      0
  53        0    0      0        0       0           0      0    2      0
  54        0    0      0        0       0           0      0    0      0
  55        0    0      0        0       0           0      0    0      0
  56        0    0      0        0       0           0      0    1      0
  57        0    0      0        0       0           0      0    0      0
  58        0    0      0        0       0           0      0    0      0
  59        0    0      0        0       0           0      0    0      0
  60        0    0      0        0       0           0      0    0      0
  61        1    0      0        0       0           0      0    0      0
  62        0    0      0        0       0           0      0    0      0
  63        0    0      0        0       0           0      0    1      0
  64        0    0      0        0       0           0      0    0      0
  65        0    0      0        0       0           0      0    0      0
  66        0    0      0        0       0           0      0    0      0
  67        0    0      0        0       0           0      0    0      0
  68        0    0      0        0       0           0      0    0      1
  69        0    0      0        0       0           0      0    0      0
  70        0    0      0        0       0           0      0    0      0
  71        1    0      0        0       0           0      0    0      0
  72        0    0      0        0       0           0      0    0      0
  73        0    0      0        0       0           0      0    0      0
  74        0    0      0        0       0           0      0    0      0
  75        0    0      0        0       0           0      0    0      0
  76        0    0      0        0       0           0      0    0      0
  77        0    0      0        0       0           0      0    0      0
  78        0    0      0        0       0           0      0    0      0
  79        0    0      0        0       0           0      0    0      0
  80        0    0      0        0       0           0      0    0      0
  81        0    0      0        0       0           0      0    0      0
  82        0    0      0        0       0           0      0    0      0
  83        0    0      0        0       0           0      0    0      0
  84        0    0      0        0       0           0      0    0      0
  85        0    0      0        0       0           0      0    0      0
  86        0    0      0        0       0           0      0    0      0
  87        0    0      0        0       0           0      0    0      0
  88        0    0      0        0       0           0      0    0      0
  89        0    0      0        0       0           0      0    0      0
  90        0    0      0        0       0           0      0    0      0
  91        0    0      0        0       0           0      0    0      0
  92        0    0      0        0       0           0      0    0      0
  93        0    0      0        0       0           0      0    0      0
  94        0    1      0        0       0           0      0    0      0
  95        0    0      0        0       0           0      0    0      0
  96        0    0      0        0       0           0      0    0      0
  97        0    0      0        0       0           0      0    0      0
  98        0    0      0        0       0           0      0    0      0
  99        0    0      0        0       0           0      0    0      0
  100       0    0      0        0       0           0      0    0      0
  101       0    0      0        0       1           0      0    0      0
  102       0    0      0        0       0           0      0    0      0
  103       0    0      0        0       0           0      0    0      0
  104       0    0      0        0       0           0      0    0      0
  105       0    0      0        0       0           0      0    0      0
  106       0    0      0        0       0           0      0    0      0
  107       0    0      0        0       0           0      0    0      0
  108       0    0      0        0       0           0      0    1      0
  109       0    0      0        0       0           0      0    0      0
  110       0    0      0        0       0           0      0    0      1
  111       0    0      0        0       0           0      0    0      0
  112       0    0      0        0       0           0      0    0      0
  113       0    1      0        0       0           0      0    0      0
  114       0    0      0        0       0           0      0    0      0
  115       0    0      0        0       0           0      0    0      0
  116       0    0      0        0       0           0      0    0      0
  117       0    0      0        0       0           0      0    0      0
  118       0    0      0        0       0           0      0    0      0
  119       0    0      0        0       0           0      0    0      0
  120       0    1      0        0       0           0      0    0      0
  121       0    0      0        0       0           0      0    0      0
  122       0    0      0        0       0           0      0    0      0
  123       0    0      0        0       1           0      0    0      0
  124       0    0      0        0       0           0      0    0      0
  125       0    0      0        0       0           0      0    0      0
  126       0    0      0        0       0           0      0    0      0
  127       0    1      0        0       1           0      0    0      0
  128       0    0      0        0       0           0      0    0      0
  129       0    0      1        0       0           0      0    0      0
  130       0    0      0        0       0           0      0    0      0
  131       0    0      0        0       0           0      0    0      0
  132       0    0      0        0       0           0      0    1      0
  133       0    0      0        0       0           0      0    0      0
  134       0    0      0        0       0           0      0    0      0
  135       0    0      1        0       0           0      1    0      0
  136       0    0      0        0       0           0      0    0      0
  137       0    0      0        0       0           0      0    0      0
  138       0    0      0        0       0           0      0    0      0
  139       0    0      0        0       0           0      0    0      1
  140       0    0      0        0       0           0      0    0      0
  141       0    0      0        0       0           0      0    0      0
  142       0    0      0        0       0           0      0    0      0
  143       0    0      0        0       0           0      0    0      0
  144       0    0      0        0       0           0      0    0      0
  145       0    0      0        0       0           0      0    0      0
  146       0    0      0        0       0           0      0    0      0
  147       0    0      0        0       0           0      0    0      1
  148       0    0      0        0       0           0      0    0      0
  149       0    0      0        0       0           0      0    0      0
  150       0    0      0        0       0           0      0    0      0
  151       0    0      0        0       0           0      0    0      0
  152       0    0      0        0       0           0      0    0      0
  153       0    0      0        0       0           0      0    0      0
  154       0    0      0        0       0           0      0    0      0
  155       0    0      0        0       0           0      0    0      0
  156       0    0      0        0       0           0      0    0      0
  157       0    0      0        0       0           0      0    0      0
  158       0    0      0        0       0           0      0    0      0
  159       0    0      0        0       0           0      0    1      0
  160       0    0      0        0       0           0      0    0      0
  161       0    0      0        0       0           0      0    0      0
  162       0    0      2        0       0           0      0    0      0
  163       0    0      0        0       0           0      0    0      0
  164       0    0      0        0       0           0      0    0      0
  165       0    0      0        0       0           0      0    0      0
  166       0    0      0        0       0           0      0    0      0
  167       0    0      0        0       0           0      0    0      0
  168       0    0      0        0       0           0      0    0      0
  169       0    0      0        0       0           0      0    0      0
  170       0    0      0        0       0           0      0    0      0
  171       0    0      0        0       0           0      0    0      0
  172       0    0      0        0       0           0      0    0      0
  173       0    0      0        0       0           0      0    0      0
  174       0    0      0        0       0           0      0    0      0
  175       0    0      0        0       0           0      0    0      0
  176       0    0      0        0       0           0      0    0      0
  177       0    0      0        0       0           0      0    0      0
  178       0    0      0        0       0           0      0    0      0
  179       0    0      0        0       0           0      0    0      0
  180       0    0      0        0       0           0      0    0      0
  181       0    0      0        0       0           0      0    0      0
  182       0    0      0        0       0           0      0    0      0
  183       0    0      0        0       0           0      0    0      0
  184       0    0      0        0       0           0      0    0      0
  185       0    0      0        0       0           0      0    0      0
  186       0    0      0        0       0           0      0    0      0
  187       0    0      0        0       0           0      0    0      0
  188       0    0      0        0       0           0      0    0      0
  189       0    0      0        0       0           0      0    0      0
  190       0    0      0        0       0           0      0    0      0
  191       0    0      0        0       0           0      0    0      0
  192       0    0      0        0       0           0      0    0      0
  193       0    0      0        0       0           0      1    0      0
  194       0    0      0        0       0           0      0    0      0
  195       0    0      0        0       0           0      0    0      1
  196       0    0      0        0       0           0      0    0      1
  197       0    0      0        0       0           1      0    0      0
  198       0    0      0        0       0           0      0    1      1
  199       0    0      0        0       0           0      0    0      0
  200       0    0      0        0       0           0      0    0      0
  201       0    0      0        0       0           0      0    0      0
  202       0    0      0        0       0           0      0    0      0
  203       0    0      0        0       0           0      0    0      0
  204       0    0      0        0       0           0      0    0      0
  205       0    0      1        0       0           0      0    0      0
  206       0    0      0        0       0           0      0    0      0
  207       0    0      0        0       0           0      0    0      0
  208       0    0      0        0       0           0      0    0      0
  209       0    0      0        0       0           0      0    0      0
  210       0    0      0        0       0           0      0    0      0
  211       1    0      0        0       0           0      0    0      0
  212       0    0      0        0       0           0      0    0      0
  213       0    0      0        0       0           0      0    0      0
  214       0    0      0        0       0           0      0    0      0
  215       0    0      0        0       0           0      0    0      1
  216       0    0      0        2       0           0      1    0      0
  217       0    0      0        0       0           0      0    0      0
  218       1    0      0        0       0           0      0    0      0
  219       0    0      0        0       0           0      0    0      0
  220       0    0      0        0       0           0      0    1      0
  221       0    0      0        0       0           0      0    0      0
  222       0    0      0        0       0           0      0    0      0
  223       0    0      0        0       0           0      0    0      0
  224       0    0      0        0       0           0      0    0      0
  225       0    0      0        0       0           0      0    0      0
  226       0    0      0        0       0           0      0    0      0
  227       0    0      0        1       0           0      0    0      0
  228       0    0      0        0       0           0      0    0      0
  229       0    0      0        0       0           0      0    0      0
  230       0    0      0        0       0           0      0    0      0
  231       0    0      0        0       0           0      0    0      0
  232       0    0      0        0       0           0      0    0      0
  233       0    0      0        0       0           0      0    1      0
  234       0    0      0        0       0           0      0    0      0
  235       0    0      0        0       0           0      0    0      0
  236       0    0      0        0       0           0      0    0      0
  237       0    0      0        0       0           0      0    0      0
  238       0    0      0        0       0           0      0    0      0
  239       0    0      0        0       0           0      0    0      0
  240       0    0      0        0       0           0      0    0      0
  241       0    0      0        0       0           0      0    0      0
  242       0    0      0        0       0           0      0    0      0
  243       0    0      0        0       0           0      0    0      0
  244       0    0      0        0       0           0      0    0      0
  245       0    0      0        0       0           0      0    0      0
  246       0    0      0        0       0           0      0    0      0
  247       0    0      0        0       0           0      0    0      0
  248       0    0      0        0       0           0      0    0      0
  249       0    0      0        0       0           0      0    0      1
  250       0    0      0        0       0           0      0    0      0
  251       0    0      0        0       0           0      0    0      0
  252       0    0      0        0       0           0      0    0      0
  253       0    0      0        0       0           0      0    0      0
  254       0    0      0        0       0           0      0    0      0
  255       0    0      0        0       0           0      0    0      0
  256       0    0      0        0       0           0      0    0      0
  257       0    0      0        0       0           0      0    0      0
  258       0    0      0        0       0           0      0    1      0
  259       0    0      0        0       0           1      0    0      0
  260       0    0      0        0       0           0      0    0      0
  261       0    0      0        0       0           0      0    0      0
  262       0    0      0        0       0           0      0    0      0
  263       0    0      0        0       0           0      0    0      0
  264       0    0      0        0       0           0      0    0      0
  265       0    0      0        0       0           0      0    0      0
  266       0    0      0        0       0           0      0    0      0
  267       0    0      0        0       0           1      0    0      0
  268       0    0      0        0       0           0      0    0      0
  269       0    0      0        0       0           0      0    0      0
  270       0    0      0        0       0           0      0    0      0
  271       0    0      0        0       0           0      0    0      0
  272       0    0      0        0       0           0      0    0      0
  273       0    0      0        0       0           0      0    0      0
  274       0    0      0        0       0           0      0    0      0
  275       0    0      0        0       0           0      0    0      0
  276       0    0      0        0       0           0      0    0      0
  277       0    0      0        0       0           0      0    0      0
  278       0    0      0        0       0           0      0    0      0
  279       0    0      0        0       0           0      0    0      0
  280       0    0      0        0       0           0      1    0      0
  281       0    0      0        0       0           0      0    0      0
  282       0    0      0        0       0           0      0    0      0
  283       0    0      0        0       0           0      0    0      0
  284       0    0      0        0       0           0      0    0      0
     Terms
Docs  amazing another anything areas around arrogant atmosphere autonomy
  1         0       0        0     0      0        0          0        0
  2         0       0        0     0      0        0          0        0
  3         0       0        0     0      0        0          0        0
  4         0       0        0     0      0        0          0        0
  5         0       0        0     0      0        0          0        0
  6         0       0        0     0      0        0          0        0
  7         0       0        0     0      0        0          0        0
  8         0       0        0     0      0        0          0        0
  9         1       0        0     0      0        0          1        0
  10        1       1        0     0      0        0          1        0
  11        0       0        0     0      0        0          0        0
  12        0       0        0     1      2        0          0        0
  13        0       0        0     0      1        0          0        0
  14        0       0        0     0      0        0          0        0
  15        0       0        0     0      0        0          0        0
  16        0       0        0     0      0        0          0        0
  17        0       0        0     0      0        0          0        0
  18        0       0        0     0      0        0          0        0
  19        0       0        0     0      0        0          0        0
  20        0       0        0     0      0        0          0        0
  21        0       0        0     0      0        0          0        0
  22        0       0        0     0      0        0          0        0
  23        0       0        0     0      0        0          0        0
  24        0       0        0     0      0        0          0        0
  25        0       0        0     0      0        0          0        0
  26        0       0        1     0      0        0          0        0
  27        0       0        0     0      0        0          0        0
  28        0       0        0     0      0        0          0        0
  29        0       0        0     0      0        0          0        0
  30        0       0        0     0      0        0          0        1
  31        0       0        0     0      0        0          0        0
  32        0       1        0     0      0        0          0        0
  33        0       0        0     0      0        0          0        0
  34        0       0        0     0      0        0          0        0
  35        0       0        0     0      0        0          0        0
  36        0       0        0     0      0        0          0        0
  37        0       0        0     0      0        0          0        0
  38        0       1        0     1      0        0          0        0
  39        0       0        0     0      0        0          0        0
  40        1       0        0     0      0        0          0        0
  41        0       0        0     0      0        0          0        0
  42        0       0        0     0      0        0          0        0
  43        0       0        0     0      0        0          0        0
  44        0       0        0     0      0        0          0        0
  45        0       0        0     0      1        0          0        0
  46        1       0        0     0      0        0          0        0
  47        0       0        0     0      0        0          0        0
  48        0       0        0     0      1        0          0        0
  49        0       0        0     0      0        0          0        0
  50        0       0        0     0      0        0          0        0
  51        0       0        0     0      0        0          0        0
  52        0       0        0     0      0        0          0        0
  53        4       0        0     0      0        0          0        0
  54        0       0        0     0      0        0          0        0
  55        0       0        0     0      0        0          0        0
  56        0       0        0     0      0        0          0        0
  57        0       0        0     0      0        0          2        0
  58        0       0        0     0      0        0          0        0
  59        0       0        0     0      0        0          0        0
  60        0       0        0     0      0        0          0        0
  61        0       0        0     0      0        0          1        0
  62        0       0        0     0      0        0          0        0
  63        0       0        0     0      1        0          0        0
  64        0       0        0     0      0        0          0        0
  65        0       0        0     0      0        0          0        0
  66        0       0        0     0      0        0          0        0
  67        0       0        0     0      0        0          0        0
  68        1       0        0     0      0        0          0        0
  69        0       0        0     0      0        0          0        0
  70        0       0        0     0      0        0          0        0
  71        0       0        0     0      0        0          0        0
  72        0       0        0     0      0        0          0        0
  73        0       0        0     0      0        0          0        0
  74        0       0        0     0      0        0          0        0
  75        0       0        0     0      0        0          0        0
  76        0       0        0     0      0        0          0        0
  77        0       0        0     0      0        0          0        0
  78        0       0        0     0      0        0          0        0
  79        0       0        0     0      0        0          1        0
  80        0       0        0     0      0        0          0        0
  81        0       0        0     0      0        0          0        0
  82        0       0        0     0      0        0          0        0
  83        0       0        0     0      0        0          0        0
  84        0       0        0     0      0        0          0        0
  85        0       0        0     0      0        0          0        0
  86        0       0        0     0      0        0          0        0
  87        0       0        0     0      0        0          0        0
  88        0       0        0     0      0        0          0        0
  89        0       0        0     0      0        0          1        0
  90        0       0        0     1      0        0          0        0
  91        0       0        0     0      0        0          0        0
  92        0       0        0     0      0        0          0        0
  93        0       0        0     0      0        0          0        0
  94        0       0        0     0      0        0          0        0
  95        0       0        0     0      0        0          0        0
  96        0       0        0     0      0        0          0        0
  97        1       0        0     0      0        0          0        0
  98        0       0        0     0      0        0          0        0
  99        0       0        0     0      0        0          0        0
  100       0       0        0     0      0        0          0        0
  101       0       0        0     0      0        0          0        0
  102       0       0        0     0      0        0          0        0
  103       0       0        0     0      0        0          0        0
  104       0       0        0     0      0        0          0        0
  105       0       0        0     0      0        0          0        0
  106       0       0        0     0      0        0          0        0
  107       0       0        0     0      0        0          0        0
  108       0       0        0     0      0        0          0        0
  109       0       0        0     0      0        0          0        0
  110       0       0        0     0      0        0          0        0
  111       0       0        0     0      0        0          0        0
  112       0       0        0     0      1        0          0        0
  113       0       0        0     0      0        0          0        0
  114       0       0        0     1      0        0          0        0
  115       0       0        0     0      0        0          0        0
  116       0       0        0     0      0        0          0        0
  117       3       0        0     0      0        0          0        0
  118       0       0        0     0      0        0          0        0
  119       0       0        1     0      0        0          0        0
  120       1       0        0     0      0        0          0        0
  121       1       0        0     0      0        0          0        0
  122       0       0        0     0      1        0          1        0
  123       0       0        0     0      0        0          0        0
  124       0       0        0     0      0        0          0        0
  125       0       0        0     0      0        0          0        0
  126       0       0        0     0      0        0          0        0
  127       0       0        0     0      0        0          0        0
  128       0       0        0     0      0        0          0        0
  129       1       0        0     0      0        0          0        0
  130       0       0        0     0      0        0          0        0
  131       0       0        0     0      0        0          0        0
  132       0       0        0     0      0        0          0        0
  133       1       0        0     0      0        0          0        0
  134       0       0        0     0      0        0          0        0
  135       0       0        0     0      0        0          0        0
  136       0       0        0     0      0        0          0        0
  137       0       0        0     0      0        0          0        0
  138       0       0        0     0      0        0          0        0
  139       0       0        0     0      0        0          0        0
  140       0       0        0     0      0        0          0        0
  141       0       0        0     0      0        0          0        0
  142       0       0        0     0      0        0          0        0
  143       0       0        0     0      0        0          0        0
  144       0       0        0     0      0        0          0        0
  145       0       0        0     0      0        0          0        0
  146       1       0        0     0      0        0          0        0
  147       0       0        0     0      0        0          0        0
  148       0       0        0     0      0        0          0        0
  149       0       0        0     0      0        0          0        0
  150       0       0        0     0      0        0          0        0
  151       0       0        0     0      1        0          0        0
  152       0       0        0     0      0        0          0        0
  153       0       0        0     0      0        0          0        1
  154       0       0        0     0      1        0          0        0
  155       0       0        0     0      0        0          0        0
  156       0       0        0     0      0        0          0        0
  157       0       0        0     0      0        0          0        0
  158       0       0        0     0      0        0          0        0
  159       0       0        0     0      0        0          1        0
  160       0       0        0     0      0        0          0        0
  161       1       0        0     0      0        0          0        0
  162       0       0        0     0      1        0          0        0
  163       0       0        0     0      0        0          0        1
  164       1       0        0     0      0        0          0        0
  165       1       0        0     0      0        0          0        0
  166       1       0        0     0      0        0          0        0
  167       0       0        0     0      0        0          0        0
  168       1       0        0     0      0        0          0        0
  169       0       0        0     0      0        0          0        0
  170       1       0        0     0      1        0          0        0
  171       0       0        0     0      0        0          0        0
  172       0       0        0     0      0        0          0        0
  173       0       0        0     0      0        0          0        0
  174       0       0        0     0      0        0          0        0
  175       0       0        0     0      0        0          0        0
  176       0       0        0     0      0        0          0        0
  177       0       0        0     0      0        0          0        0
  178       0       0        0     0      0        0          0        0
  179       0       0        0     1      0        0          0        0
  180       0       0        0     0      0        0          0        0
  181       0       0        0     0      0        0          0        0
  182       1       0        0     0      0        0          0        0
  183       0       0        0     0      0        0          0        0
  184       0       0        0     0      0        0          1        0
  185       0       0        0     0      0        0          1        0
  186       0       0        0     0      0        0          0        0
  187       0       0        0     0      0        0          0        1
  188       1       0        0     0      0        0          0        0
  189       0       0        0     0      0        0          0        0
  190       0       0        0     0      0        0          0        0
  191       0       0        0     0      1        0          0        0
  192       1       0        0     0      0        0          0        0
  193       1       0        0     0      0        0          0        0
  194       0       0        0     0      0        0          0        0
  195       0       0        0     0      0        0          0        0
  196       0       0        0     0      0        0          0        0
  197       0       0        0     0      0        0          0        0
  198       0       0        0     0      0        0          0        0
  199       0       0        0     0      0        0          0        0
  200       0       0        0     0      0        0          0        0
  201       0       0        0     0      0        0          0        0
  202       0       0        0     0      0        0          0        0
  203       0       0        0     0      0        0          0        0
  204       0       0        0     0      0        0          0        0
  205       0       0        0     0      0        0          0        0
  206       1       0        0     0      0        0          0        0
  207       0       0        0     0      0        0          0        0
  208       1       0        0     0      1        0          0        0
  209       0       0        0     0      0        0          0        0
  210       0       0        0     0      0        0          0        0
  211       0       0        0     0      0        0          0        0
  212       0       0        0     1      0        0          0        0
  213       0       0        0     0      0        0          0        0
  214       0       0        0     0      0        0          0        0
  215       0       0        0     0      0        0          0        0
  216       1       0        1     0      0        0          0        0
  217       0       0        0     0      0        0          0        0
  218       0       0        0     0      0        0          0        0
  219       1       0        0     0      0        0          0        0
  220       0       0        0     0      0        0          1        0
  221       0       0        0     0      0        0          0        0
  222       0       0        0     0      0        0          1        0
  223       0       0        0     0      0        0          0        0
  224       0       0        0     0      0        0          0        0
  225       0       0        0     0      1        0          0        0
  226       0       0        0     0      0        0          0        0
  227       1       0        0     0      0        0          0        0
  228       1       0        0     0      0        0          0        0
  229       0       0        0     0      0        0          0        0
  230       0       0        0     0      0        0          0        0
  231       0       0        0     0      0        0          0        0
  232       0       0        0     0      1        0          0        0
  233       0       0        0     0      1        0          0        0
  234       0       0        0     0      0        0          0        0
  235       2       0        0     0      0        0          0        0
  236       0       0        0     0      1        0          0        0
  237       0       0        0     0      0        0          0        0
  238       1       0        0     0      0        0          0        0
  239       0       0        0     0      0        0          0        0
  240       0       0        0     0      0        0          1        0
  241       0       0        0     0      0        0          0        0
  242       0       0        0     0      0        0          0        0
  243       0       0        0     0      0        0          0        0
  244       0       0        0     0      0        0          0        0
  245       0       0        0     0      0        0          1        0
  246       0       0        0     0      0        0          0        0
  247       0       0        0     0      0        0          0        0
  248       0       0        0     0      0        0          0        0
  249       0       0        0     1      0        0          0        0
  250       0       0        0     0      0        0          0        0
  251       0       0        0     0      0        0          0        0
  252       0       0        0     0      0        0          0        0
  253       0       0        0     0      0        0          0        0
  254       0       0        0     0      0        0          0        0
  255       0       0        0     0      0        0          0        0
  256       0       0        0     0      0        0          0        0
  257       0       0        0     0      0        0          0        0
  258       0       0        0     0      0        0          0        0
  259       0       0        0     0      0        0          0        0
  260       0       0        0     0      0        0          0        0
  261       0       0        0     0      0        0          0        0
  262       0       1        0     0      0        0          0        0
  263       0       0        0     0      0        0          0        0
  264       0       0        0     0      0        0          0        0
  265       0       0        1     0      0        0          0        0
  266       0       0        0     0      0        0          0        0
  267       0       0        0     0      0        0          0        1
  268       0       0        0     0      0        0          0        0
  269       0       0        0     0      0        0          0        0
  270       0       0        0     0      0        0          0        0
  271       0       0        0     0      0        0          0        0
  272       0       0        0     0      0        0          0        0
  273       0       0        0     0      0        0          0        0
  274       0       0        0     0      0        0          0        0
  275       0       0        0     0      0        0          0        0
  276       0       0        0     0      0        0          0        0
  277       0       0        0     0      0        0          0        0
  278       0       0        0     0      0        0          0        0
  279       0       0        0     0      0        0          0        0
  280       0       0        0     0      0        0          0        0
  281       0       0        0     0      0        0          0        0
  282       0       0        0     0      0        0          0        1
  283       0       0        0     0      0        0          0        0
  284       0       0        0     0      0        0          0        0
     Terms
Docs  available awesome back bad balance become becoming benefits best
  1           0       0    0   0       0      0        0        0    0
  2           0       0    0   0       0      0        0        0    0
  3           0       0    0   0       0      0        0        0    0
  4           0       0    0   0       0      0        0        1    0
  5           1       0    0   0       0      0        0        1    0
  6           0       0    0   0       0      0        0        0    1
  7           0       0    0   0       0      0        0        0    0
  8           0       0    0   0       0      0        0        0    0
  9           0       0    0   0       0      0        0        0    0
  10          0       0    0   0       0      0        0        0    0
  11          0       0    0   0       0      0        0        0    0
  12          0       0    0   0       0      0        0        1    2
  13          0       0    0   0       0      0        0        0    0
  14          0       0    0   0       0      0        0        0    0
  15          0       0    0   0       0      0        0        0    0
  16          0       0    0   0       0      0        0        0    0
  17          0       0    0   0       0      0        0        0    0
  18          0       0    0   0       0      0        0        0    0
  19          0       0    0   0       0      0        0        0    0
  20          0       0    0   0       0      0        0        0    0
  21          0       0    0   0       0      0        0        1    0
  22          0       0    0   0       0      0        0        0    0
  23          0       0    0   0       0      0        0        0    0
  24          0       1    0   0       0      0        0        0    0
  25          0       0    0   0       0      0        0        0    0
  26          0       0    0   0       0      0        0        0    0
  27          0       0    0   0       0      0        0        1    0
  28          0       0    0   0       0      0        0        0    0
  29          0       0    0   0       0      0        0        0    0
  30          0       0    0   0       0      0        0        1    1
  31          0       0    0   0       0      0        0        0    0
  32          0       0    0   0       0      0        0        0    0
  33          0       0    0   0       0      0        0        0    1
  34          0       0    0   0       0      0        0        0    0
  35          0       0    0   0       0      0        0        0    0
  36          0       0    0   0       0      0        0        1    0
  37          0       0    0   0       0      0        0        0    0
  38          0       0    0   0       0      0        0        0    0
  39          0       0    0   0       0      0        0        0    0
  40          0       0    0   0       1      0        0        0    0
  41          0       0    0   0       0      0        0        0    0
  42          0       0    0   0       0      0        0        0    1
  43          0       0    0   0       0      0        0        0    0
  44          0       0    0   0       0      0        0        1    1
  45          0       0    0   0       0      0        0        0    1
  46          0       0    0   0       0      0        0        0    0
  47          0       0    0   0       0      0        0        0    1
  48          0       0    0   0       0      0        0        1    0
  49          0       0    0   0       0      0        0        0    0
  50          0       0    0   0       0      0        0        0    0
  51          0       0    0   0       0      0        0        0    1
  52          0       0    0   0       0      0        0        0    0
  53          2       0    0   0       0      0        0        0    0
  54          0       0    0   0       0      0        0        0    0
  55          0       0    0   0       0      0        0        0    0
  56          0       0    0   0       0      0        0        1    0
  57          0       1    0   0       0      0        0        0    0
  58          0       0    0   0       0      0        0        0    0
  59          0       0    0   0       0      0        0        0    1
  60          0       0    0   0       0      0        0        0    0
  61          0       0    0   0       0      0        0        1    0
  62          0       0    0   0       0      0        0        1    0
  63          1       0    0   0       0      0        0        2    0
  64          0       0    0   0       0      0        0        0    0
  65          0       0    0   0       0      0        0        0    0
  66          0       0    0   0       0      0        0        0    1
  67          0       0    0   0       0      0        0        0    0
  68          0       0    0   0       0      0        0        0    1
  69          0       1    0   0       0      0        0        0    0
  70          0       0    0   0       0      0        0        0    0
  71          0       1    0   0       0      0        0        1    1
  72          0       0    0   0       0      0        0        0    0
  73          0       0    1   0       0      0        0        0    0
  74          0       0    0   0       0      0        0        0    1
  75          0       0    0   0       0      0        0        0    0
  76          0       0    0   0       0      0        0        0    0
  77          0       0    0   0       0      0        0        0    0
  78          0       0    0   0       0      0        0        1    0
  79          0       0    0   0       0      0        0        0    0
  80          0       0    0   0       0      0        0        0    0
  81          0       0    0   0       0      0        0        1    0
  82          0       0    0   0       0      0        0        0    0
  83          0       1    0   0       0      0        0        0    0
  84          0       0    0   0       0      0        0        0    0
  85          0       0    0   1       0      0        0        1    0
  86          0       0    0   0       0      0        0        0    0
  87          0       0    0   0       0      0        0        0    0
  88          0       0    0   0       0      0        0        0    1
  89          0       0    0   0       0      0        0        0    0
  90          0       0    0   0       0      0        0        1    1
  91          0       0    0   0       0      0        0        1    0
  92          0       0    0   0       0      0        0        0    0
  93          0       0    0   0       0      0        0        1    1
  94          1       0    0   0       0      0        0        0    0
  95          0       0    0   0       1      0        0        0    0
  96          0       0    0   0       0      0        0        0    0
  97          0       0    0   0       0      0        0        0    0
  98          0       0    0   0       0      0        0        1    0
  99          0       1    0   0       0      0        0        0    0
  100         0       0    0   0       0      0        0        0    1
  101         0       0    0   0       0      0        0        0    0
  102         0       0    0   0       0      0        0        0    0
  103         0       0    0   0       0      0        0        0    0
  104         0       0    0   0       1      0        0        0    1
  105         0       0    0   0       0      0        0        0    1
  106         0       0    0   0       0      0        0        1    0
  107         0       0    0   0       0      0        0        0    0
  108         0       0    0   0       0      0        0        0    0
  109         0       0    0   0       0      0        0        0    1
  110         0       0    0   0       0      0        0        0    0
  111         0       0    0   0       0      0        0        0    1
  112         0       0    0   0       0      0        0        0    0
  113         0       0    0   0       0      0        0        0    0
  114         0       0    0   0       0      0        0        0    0
  115         0       0    0   0       0      0        0        1    1
  116         0       0    0   0       0      0        0        0    0
  117         0       0    0   0       0      0        0        1    0
  118         0       0    0   0       0      0        0        0    0
  119         0       0    0   0       0      0        0        0    0
  120         0       1    0   0       0      0        0        0    0
  121         0       0    0   0       0      0        0        0    0
  122         0       0    0   0       0      0        0        0    0
  123         0       1    0   0       0      0        0        0    0
  124         1       0    0   0       0      0        0        0    0
  125         0       0    0   0       1      0        0        0    0
  126         0       0    0   0       0      0        0        0    0
  127         0       0    0   0       0      0        0        0    0
  128         0       1    0   0       0      0        0        0    0
  129         0       0    0   0       0      0        0        1    0
  130         0       0    0   0       0      0        0        1    0
  131         0       0    0   0       0      0        0        0    0
  132         0       0    0   0       0      0        0        0    1
  133         0       0    0   0       0      0        0        0    0
  134         0       0    0   0       0      0        0        1    1
  135         0       0    0   0       0      0        0        0    0
  136         0       0    0   0       0      0        0        0    1
  137         0       0    0   0       0      0        0        0    0
  138         1       0    0   0       0      0        0        0    0
  139         0       1    0   0       0      0        0        1    0
  140         0       0    0   0       0      0        0        0    0
  141         0       0    0   0       0      0        0        0    0
  142         0       0    0   0       0      0        0        0    1
  143         0       0    0   0       0      0        0        0    1
  144         0       0    0   0       0      0        0        0    0
  145         0       0    0   0       0      0        0        0    0
  146         0       0    0   0       0      0        0        0    0
  147         0       0    0   0       0      0        0        0    0
  148         0       0    0   0       1      0        0        0    0
  149         0       0    0   0       0      0        0        1    0
  150         0       0    0   0       0      0        0        0    0
  151         0       0    0   0       0      0        0        1    0
  152         0       0    0   0       0      0        0        0    0
  153         0       0    0   0       0      0        0        0    0
  154         0       0    0   0       0      0        0        0    0
  155         0       0    0   0       0      0        0        0    0
  156         0       0    0   0       0      0        0        1    0
  157         0       0    0   0       0      0        0        1    0
  158         0       0    0   0       0      0        0        0    0
  159         0       0    0   0       0      0        0        0    0
  160         0       0    0   0       0      0        0        1    0
  161         0       0    0   0       0      0        0        1    0
  162         0       0    0   0       0      0        0        0    0
  163         0       0    0   0       0      0        0        0    1
  164         0       0    0   0       0      0        0        1    0
  165         0       0    0   0       0      0        0        1    0
  166         0       0    0   0       1      0        0        0    0
  167         0       0    0   0       0      0        0        0    0
  168         0       0    0   0       0      0        0        0    0
  169         0       0    0   0       0      0        0        2    1
  170         0       0    0   0       0      0        0        0    0
  171         0       1    0   0       1      0        0        0    0
  172         0       1    0   0       0      0        0        1    0
  173         0       0    0   0       0      0        0        0    2
  174         0       0    0   0       1      0        0        0    0
  175         0       0    0   0       0      0        0        1    0
  176         0       0    0   0       0      0        0        0    0
  177         0       0    0   0       0      0        0        0    0
  178         0       0    0   0       0      0        0        0    0
  179         0       0    0   0       0      0        0        0    2
  180         0       0    0   0       0      0        0        1    0
  181         0       0    0   0       0      0        0        1    0
  182         0       0    0   0       0      0        0        0    0
  183         0       0    0   0       0      0        0        0    0
  184         0       0    1   0       0      0        0        0    0
  185         0       0    0   0       0      0        0        0    0
  186         0       1    0   0       1      0        0        0    0
  187         0       0    0   0       0      0        0        0    0
  188         0       0    0   0       0      0        0        0    0
  189         0       0    0   0       0      0        0        0    0
  190         0       0    0   0       0      0        0        0    0
  191         0       0    0   0       1      0        0        1    0
  192         0       0    0   0       0      0        0        0    0
  193         0       1    0   0       0      0        0        0    0
  194         0       0    0   0       0      0        0        0    1
  195         0       1    0   0       0      0        0        0    0
  196         0       0    0   0       0      0        0        1    0
  197         0       0    0   0       0      0        0        0    0
  198         0       0    0   0       0      0        0        0    0
  199         0       0    0   0       0      1        0        0    0
  200         0       0    0   0       0      0        0        1    0
  201         0       0    0   0       0      0        0        1    0
  202         0       1    0   0       0      0        0        0    0
  203         0       0    0   0       0      0        0        0    0
  204         0       0    0   0       0      0        0        0    1
  205         0       0    0   0       0      0        0        0    0
  206         0       0    0   0       0      0        0        0    0
  207         0       0    0   0       0      0        0        0    0
  208         0       0    0   0       0      0        0        0    1
  209         0       0    0   0       0      0        0        0    0
  210         0       0    0   0       0      0        0        0    0
  211         0       0    0   0       0      0        0        0    0
  212         0       0    0   0       0      0        0        1    0
  213         0       0    0   0       0      0        0        0    0
  214         0       0    0   0       0      0        0        0    0
  215         0       0    0   0       0      0        0        0    0
  216         0       0    0   0       0      0        0        0    0
  217         0       0    0   0       0      0        0        0    0
  218         0       1    0   0       0      0        0        0    0
  219         0       0    0   0       0      0        0        0    0
  220         0       0    0   0       0      0        0        0    0
  221         0       0    0   0       0      0        0        0    0
  222         0       0    0   0       0      0        0        0    0
  223         0       0    0   0       0      0        0        0    0
  224         0       0    0   0       0      0        0        1    0
  225         0       0    0   0       0      0        0        0    0
  226         0       0    0   0       0      0        0        0    0
  227         0       0    0   0       0      0        0        0    0
  228         0       0    0   0       0      0        0        0    0
  229         0       1    0   0       0      0        0        1    0
  230         0       0    0   0       0      0        0        0    0
  231         0       0    0   0       0      0        0        0    0
  232         0       0    0   0       0      0        0        0    0
  233         0       0    0   0       0      0        0        0    0
  234         0       0    0   0       0      0        0        0    0
  235         0       0    0   0       0      0        0        0    0
  236         0       0    0   0       0      0        0        0    0
  237         0       0    0   0       0      0        0        0    0
  238         0       0    0   0       0      0        0        0    1
  239         0       0    0   0       1      0        0        0    0
  240         0       0    0   0       0      0        0        0    1
  241         0       0    0   0       0      0        0        1    0
  242         0       0    0   0       0      0        0        0    0
  243         0       0    0   0       0      0        0        0    1
  244         0       0    0   0       0      0        0        0    0
  245         0       0    0   0       0      0        0        0    0
  246         1       1    0   0       0      0        0        0    0
  247         0       1    0   0       0      0        0        1    0
  248         0       0    0   0       0      0        0        0    0
  249         0       0    0   0       0      0        0        0    0
  250         0       0    0   0       0      0        0        0    0
  251         0       0    0   0       0      0        0        0    0
  252         0       0    0   0       0      0        0        0    0
  253         0       0    0   0       0      1        0        0    0
  254         0       0    0   0       0      0        0        0    0
  255         0       0    0   0       1      0        0        0    0
  256         0       0    0   0       0      0        0        0    0
  257         0       0    0   0       0      0        1        0    0
  258         0       1    0   0       0      0        0        0    0
  259         0       0    0   0       0      0        0        0    0
  260         0       0    0   0       0      0        0        0    0
  261         0       0    0   0       0      0        0        0    0
  262         0       0    0   0       0      0        0        0    0
  263         0       0    0   0       0      0        0        0    0
  264         0       0    0   0       0      0        0        0    0
  265         0       0    0   0       0      0        0        0    0
  266         0       0    0   0       0      0        0        0    0
  267         0       0    0   0       1      0        1        0    0
  268         0       0    0   0       0      0        0        0    0
  269         0       0    0   0       0      0        0        0    0
  270         0       0    0   0       0      0        0        0    0
  271         0       0    0   0       0      0        0        0    0
  272         0       0    0   0       0      0        0        0    0
  273         0       0    0   0       0      0        0        0    0
  274         0       0    0   0       0      0        0        0    0
  275         0       0    1   0       0      0        0        0    0
  276         0       0    0   0       0      0        0        0    0
  277         0       0    0   0       0      0        1        0    0
  278         0       0    0   0       0      0        0        0    0
  279         0       0    0   0       0      0        0        0    0
  280         0       0    0   1       0      0        0        0    0
  281         0       0    0   0       0      0        0        0    0
  282         0       0    0   0       1      0        0        0    0
  283         0       0    0   0       0      0        0        0    0
  284         0       0    0   0       0      0        0        0    0
     Terms
Docs  better big bonus bright brightest brilliant build bureaucracy
  1        0   0     0      0         0         0     0           0
  2        0   0     0      0         0         0     0           0
  3        0   0     0      0         0         0     0           0
  4        0   0     0      0         0         0     0           0
  5        0   0     0      0         0         0     0           0
  6        0   0     0      0         0         0     0           0
  7        0   0     0      0         0         0     0           0
  8        0   0     0      0         0         0     0           0
  9        0   0     0      0         0         0     0           0
  10       0   0     0      0         1         0     0           0
  11       0   0     0      0         0         0     0           0
  12       0   0     0      0         0         0     0           0
  13       1   0     0      0         0         0     0           0
  14       0   0     0      0         0         0     0           0
  15       1   0     1      0         0         0     0           0
  16       0   0     0      0         0         0     0           0
  17       0   1     0      0         0         0     0           0
  18       0   0     0      0         0         0     0           0
  19       0   0     0      0         0         0     0           0
  20       0   0     0      0         0         0     0           0
  21       0   0     1      0         0         0     0           0
  22       0   0     0      0         0         0     0           0
  23       0   0     0      0         0         0     0           0
  24       0   0     0      0         0         1     0           0
  25       0   0     0      0         0         0     0           0
  26       0   0     0      0         0         0     0           0
  27       0   0     0      0         0         1     0           0
  28       0   0     0      0         0         0     0           0
  29       0   1     0      0         1         0     0           0
  30       0   0     0      0         0         0     0           0
  31       0   0     0      0         0         0     0           0
  32       0   0     0      0         0         0     0           0
  33       0   0     0      0         0         0     0           0
  34       1   0     0      0         0         1     0           0
  35       1   0     0      0         0         0     0           0
  36       0   0     0      1         0         0     0           0
  37       0   0     1      0         0         0     0           0
  38       0   0     0      0         0         0     0           0
  39       0   0     0      0         0         0     0           0
  40       0   0     0      0         0         0     0           0
  41       1   0     0      0         0         0     0           0
  42       0   0     0      0         0         0     0           0
  43       0   0     0      0         0         0     0           0
  44       0   0     0      0         0         0     0           0
  45       0   0     0      0         0         0     0           0
  46       0   0     0      0         0         0     0           0
  47       0   0     0      0         1         0     0           0
  48       0   0     0      0         0         0     0           0
  49       0   0     0      0         0         0     0           0
  50       0   0     0      0         0         0     0           0
  51       0   1     0      0         0         0     0           0
  52       0   0     0      0         0         0     0           0
  53       0   0     0      0         0         0     0           0
  54       0   0     0      0         0         0     0           0
  55       0   1     0      0         0         0     1           0
  56       0   0     1      0         0         0     0           0
  57       0   0     0      0         0         0     0           0
  58       0   0     0      0         0         0     1           0
  59       0   0     0      0         0         0     0           0
  60       0   0     0      0         0         0     0           0
  61       0   0     0      0         0         0     0           0
  62       0   0     0      0         0         0     0           0
  63       0   0     0      0         0         0     0           0
  64       0   1     0      0         0         0     0           0
  65       1   0     0      1         0         0     0           0
  66       0   0     0      0         0         0     0           0
  67       0   0     0      0         0         0     0           0
  68       0   0     0      0         0         0     0           0
  69       0   0     0      0         0         0     0           0
  70       0   0     0      0         1         0     0           0
  71       0   0     0      0         0         0     0           0
  72       0   0     0      0         0         0     1           0
  73       1   0     0      0         0         0     0           0
  74       0   0     0      0         0         0     0           0
  75       0   0     0      1         0         0     0           0
  76       0   0     0      0         0         1     0           0
  77       0   0     0      0         0         0     0           0
  78       0   0     0      0         0         0     0           0
  79       0   0     0      0         1         0     0           0
  80       0   0     0      0         0         1     0           0
  81       0   0     0      0         0         0     0           0
  82       0   0     0      0         0         0     0           0
  83       0   0     0      0         0         0     0           0
  84       0   0     0      0         0         0     0           0
  85       0   0     0      0         0         0     0           0
  86       0   0     0      0         0         0     0           0
  87       0   1     0      0         0         0     0           0
  88       0   0     0      0         0         0     0           0
  89       0   0     0      0         0         0     0           0
  90       0   0     0      0         0         0     0           0
  91       0   0     0      0         0         0     0           0
  92       0   0     0      0         0         0     0           0
  93       0   0     0      0         0         0     0           0
  94       0   0     0      0         0         0     0           0
  95       0   0     0      0         0         0     0           0
  96       0   0     0      0         0         0     0           0
  97       0   0     0      0         0         0     0           0
  98       0   0     0      0         0         1     0           0
  99       0   0     0      0         0         0     0           0
  100      0   0     0      0         0         0     0           0
  101      0   0     0      0         0         0     0           0
  102      0   0     0      0         0         0     0           0
  103      0   0     0      0         0         0     0           0
  104      0   0     0      0         0         0     0           0
  105      0   0     0      0         0         0     0           0
  106      0   0     0      0         0         0     0           0
  107      0   0     0      0         0         0     0           0
  108      1   1     0      0         0         0     0           0
  109      0   0     0      0         0         0     0           0
  110      0   1     0      0         0         0     0           0
  111      0   0     0      0         0         0     0           0
  112      0   0     0      0         0         0     0           0
  113      0   0     0      0         0         0     0           0
  114      0   0     0      0         0         0     0           0
  115      0   0     0      0         0         0     0           0
  116      0   0     0      0         0         0     0           0
  117      0   0     0      0         0         0     0           0
  118      0   0     0      0         0         0     0           0
  119      0   1     0      0         0         0     0           0
  120      0   0     0      0         0         0     0           1
  121      0   0     0      0         0         0     0           0
  122      0   0     0      0         0         0     0           0
  123      0   0     0      0         0         0     0           0
  124      0   0     0      0         0         0     0           0
  125      0   0     0      0         0         0     0           0
  126      0   0     0      0         0         0     0           0
  127      1   0     0      0         0         0     0           0
  128      0   0     0      0         0         0     0           0
  129      0   0     0      0         0         0     0           0
  130      0   0     0      0         0         0     0           0
  131      0   0     1      0         0         0     0           0
  132      0   0     0      0         0         0     0           0
  133      0   0     0      0         0         0     0           0
  134      1   1     0      0         0         0     0           0
  135      0   0     0      0         0         0     0           0
  136      2   0     0      0         0         0     0           0
  137      0   0     0      0         0         0     0           0
  138      0   0     0      0         0         0     0           0
  139      0   0     0      0         0         0     0           0
  140      0   0     0      0         0         0     0           0
  141      0   0     0      0         0         0     0           0
  142      0   0     0      0         0         0     0           0
  143      0   0     0      1         1         0     0           0
  144      0   1     0      0         0         0     0           0
  145      0   0     0      0         0         0     0           0
  146      0   0     0      0         0         0     0           0
  147      0   0     0      0         0         0     0           0
  148      0   0     0      1         0         0     0           0
  149      0   0     0      0         0         0     0           0
  150      0   0     0      0         0         0     0           0
  151      0   0     0      0         0         0     0           0
  152      0   0     0      0         0         0     0           0
  153      0   0     0      0         0         0     0           0
  154      0   0     0      0         0         0     0           0
  155      0   0     0      0         0         0     0           0
  156      0   0     0      0         0         0     0           0
  157      0   0     0      0         0         0     0           0
  158      0   0     0      0         0         0     0           0
  159      0   0     0      0         0         0     0           0
  160      0   0     0      0         0         0     0           0
  161      0   0     0      0         0         0     0           0
  162      0   0     0      0         1         0     0           0
  163      0   0     0      0         0         0     0           0
  164      0   0     0      0         0         0     0           1
  165      0   0     0      0         0         0     0           0
  166      0   0     0      0         0         0     0           0
  167      0   0     0      0         0         0     0           0
  168      0   0     0      0         0         0     0           0
  169      0   0     0      0         0         0     0           0
  170      0   0     0      0         0         0     0           0
  171      0   0     0      0         0         0     0           0
  172      0   0     0      0         0         0     0           0
  173      0   0     0      0         0         0     0           0
  174      0   0     0      0         0         0     0           0
  175      0   0     0      0         0         0     0           0
  176      0   0     0      0         0         0     0           0
  177      0   0     0      0         0         0     0           0
  178      0   0     0      0         0         0     0           0
  179      0   0     0      0         0         0     0           0
  180      0   0     0      0         0         0     0           0
  181      0   0     0      0         0         0     0           0
  182      0   0     0      0         0         0     0           0
  183      0   0     0      0         0         0     0           0
  184      0   0     0      0         0         0     0           0
  185      0   0     0      0         0         0     0           0
  186      0   0     0      0         0         0     0           0
  187      0   0     0      0         0         0     1           0
  188      0   1     0      0         0         0     0           0
  189      0   0     0      0         0         0     0           0
  190      0   0     0      0         0         0     0           0
  191      0   0     0      0         0         0     0           0
  192      0   0     0      0         0         0     0           0
  193      0   0     0      0         0         0     0           0
  194      0   0     0      0         0         0     0           0
  195      0   0     0      0         0         0     0           0
  196      0   0     0      0         0         0     0           0
  197      0   0     0      0         0         0     0           0
  198      0   2     0      0         0         0     0           0
  199      0   0     0      0         0         0     0           0
  200      0   0     0      0         0         0     0           0
  201      0   0     0      0         0         0     0           0
  202      0   0     0      0         0         0     0           0
  203      0   0     0      0         0         0     0           0
  204      0   0     0      0         0         0     0           0
  205      0   0     0      0         0         0     0           0
  206      0   0     0      0         0         0     0           0
  207      0   0     0      0         0         0     0           0
  208      0   0     0      0         0         0     0           0
  209      0   0     0      0         0         0     0           0
  210      0   0     0      0         0         0     0           0
  211      0   0     0      0         0         0     0           0
  212      0   0     0      0         0         0     0           0
  213      0   0     0      0         0         1     0           0
  214      0   0     0      0         0         0     0           0
  215      0   0     0      0         0         0     0           0
  216      0   0     0      0         0         0     0           0
  217      0   0     0      0         0         0     0           0
  218      0   0     0      0         0         0     0           0
  219      0   0     0      0         0         0     0           0
  220      0   0     0      0         0         0     0           0
  221      0   1     0      0         0         0     0           0
  222      0   0     0      0         0         0     0           0
  223      0   0     0      0         0         0     0           0
  224      0   0     0      0         0         0     0           0
  225      0   0     0      0         0         0     0           0
  226      0   0     0      0         0         0     0           0
  227      0   0     0      0         0         0     0           0
  228      0   0     0      0         0         0     0           0
  229      0   0     0      0         0         0     0           0
  230      0   0     0      0         0         0     0           0
  231      0   0     0      0         0         0     0           0
  232      0   0     0      0         0         0     0           0
  233      0   0     0      0         0         0     0           0
  234      0   1     0      0         0         0     0           0
  235      0   0     0      0         0         0     0           0
  236      0   0     0      0         0         0     0           0
  237      0   0     0      0         0         0     0           0
  238      0   0     0      0         1         0     0           0
  239      0   0     0      0         0         0     0           0
  240      0   0     0      0         1         0     0           0
  241      0   0     0      0         0         0     0           0
  242      0   0     0      0         0         0     0           0
  243      0   0     0      0         0         0     0           0
  244      0   0     0      0         0         0     0           0
  245      0   0     0      0         0         0     0           0
  246      0   0     0      0         0         0     0           0
  247      0   0     0      0         0         0     0           0
  248      0   0     0      0         0         0     0           0
  249      0   0     0      0         0         0     0           0
  250      0   0     0      0         0         0     0           0
  251      0   0     0      0         0         0     0           0
  252      0   0     0      0         0         0     0           0
  253      0   0     0      0         0         0     0           0
  254      0   0     0      0         0         0     0           0
  255      0   0     0      0         0         0     0           0
  256      0   0     0      0         0         0     0           0
  257      0   0     0      0         0         0     0           0
  258      0   0     0      0         0         0     0           0
  259      0   0     0      0         0         0     0           0
  260      0   0     0      0         0         0     0           0
  261      0   0     0      0         0         0     0           0
  262      0   0     0      0         0         0     0           0
  263      0   0     0      0         0         0     0           0
  264      0   0     0      0         0         0     0           0
  265      0   0     0      0         0         0     0           0
  266      0   0     0      0         0         0     0           0
  267      0   0     0      0         0         0     0           0
  268      0   0     0      0         0         0     0           0
  269      0   1     0      0         0         0     0           0
  270      0   1     0      0         0         0     0           0
  271      0   0     0      0         0         0     0           0
  272      0   0     0      0         0         0     0           0
  273      0   0     0      0         0         0     0           0
  274      0   0     0      0         0         0     0           0
  275      0   0     0      0         0         0     0           0
  276      0   0     0      0         0         0     0           0
  277      0   0     0      0         0         0     0           0
  278      0   0     0      0         0         0     0           0
  279      1   0     0      0         0         0     0           0
  280      0   0     0      0         0         0     0           0
  281      1   0     0      0         0         0     0           0
  282      0   0     0      0         0         0     0           0
  283      0   0     0      0         0         0     0           0
  284      0   0     0      0         0         0     0           0
     Terms
Docs  business campus can cant care career challenges challenging chance
  1          0      0   0    0    0      0          0           0      0
  2          0      0   0    0    0      0          0           0      0
  3          0      0   0    0    0      0          0           0      0
  4          0      0   1    0    0      0          0           0      0
  5          0      0   0    0    0      0          0           0      0
  6          0      0   0    0    0      0          0           0      0
  7          0      0   0    0    0      0          0           0      0
  8          0      0   0    0    0      0          0           0      0
  9          0      0   0    0    0      1          0           0      0
  10         0      1   1    0    0      0          0           0      0
  11         0      0   1    0    0      0          0           0      0
  12         0      0   1    0    0      0          0           0      0
  13         0      0   1    0    0      0          0           0      0
  14         0      0   0    0    0      0          0           0      0
  15         0      0   0    0    0      0          0           0      0
  16         0      0   0    0    0      0          0           0      0
  17         0      0   0    0    0      0          0           0      1
  18         0      0   0    0    0      0          0           0      0
  19         0      0   0    0    0      0          0           0      0
  20         0      0   0    0    0      0          0           0      0
  21         0      0   0    0    0      0          0           0      0
  22         0      0   0    0    0      0          0           0      0
  23         0      0   0    0    0      0          0           0      0
  24         0      0   0    0    0      0          0           0      0
  25         0      0   0    0    0      0          0           0      0
  26         0      0   0    0    0      0          0           0      0
  27         0      0   0    0    0      0          0           0      0
  28         0      0   0    0    0      0          0           0      1
  29         0      0   1    0    0      0          0           1      0
  30         0      0   0    0    0      0          0           0      0
  31         0      0   0    0    1      0          0           0      0
  32         0      0   0    0    0      0          0           0      0
  33         0      0   0    0    0      0          0           0      0
  34         0      0   0    0    1      0          0           0      0
  35         0      0   0    0    0      0          0           0      0
  36         0      0   0    0    0      0          0           0      0
  37         0      0   0    0    0      0          0           0      0
  38         0      0   0    0    0      0          0           1      0
  39         0      0   2    0    0      0          0           0      0
  40         0      0   0    0    0      0          0           0      0
  41         1      0   0    0    0      0          0           0      0
  42         0      0   0    0    0      0          0           0      0
  43         0      0   1    0    0      0          0           1      0
  44         0      0   2    0    0      0          0           0      0
  45         0      0   0    0    0      0          0           0      0
  46         0      0   1    0    0      0          0           0      0
  47         0      0   0    0    0      0          0           0      0
  48         0      0   0    0    0      0          0           0      0
  49         0      0   0    0    0      0          0           0      0
  50         1      0   0    0    0      0          0           1      0
  51         0      0   1    0    0      0          0           0      0
  52         0      0   1    0    0      0          0           0      0
  53         0      1   0    0    0      0          0           0      0
  54         0      0   0    0    0      0          0           0      0
  55         0      0   0    0    0      0          0           1      0
  56         0      0   1    0    0      0          0           0      0
  57         0      0   0    0    0      0          0           0      0
  58         0      0   0    0    0      0          0           0      0
  59         0      0   0    0    0      0          0           0      0
  60         0      0   0    0    0      0          0           0      0
  61         0      0   0    0    0      0          0           0      0
  62         0      0   0    0    0      0          0           0      0
  63         0      0   0    0    0      0          0           0      0
  64         0      0   0    0    0      0          0           0      0
  65         0      0   0    0    0      0          0           0      0
  66         0      0   1    0    0      0          0           0      0
  67         0      0   1    0    0      0          0           0      0
  68         0      0   0    0    0      0          1           0      0
  69         0      1   0    0    0      0          0           0      0
  70         0      0   0    0    0      1          0           0      0
  71         0      0   1    0    0      0          0           0      0
  72         0      0   2    0    0      0          0           0      0
  73         0      0   1    0    0      0          0           0      0
  74         0      0   0    0    0      0          0           0      0
  75         0      0   0    0    0      0          0           0      0
  76         0      0   1    1    0      0          0           0      0
  77         0      0   0    0    0      0          0           0      0
  78         0      0   0    0    0      0          0           0      0
  79         0      0   0    0    0      0          0           0      0
  80         0      0   0    0    0      0          0           1      0
  81         0      0   0    0    0      0          0           0      0
  82         0      0   1    0    0      0          0           0      0
  83         0      0   0    0    0      0          0           0      0
  84         0      0   1    0    0      0          0           0      0
  85         0      0   0    0    0      0          0           0      0
  86         0      0   0    0    0      0          0           0      0
  87         0      0   0    0    0      0          0           0      0
  88         0      0   0    0    1      0          0           0      0
  89         0      0   0    0    0      0          0           0      0
  90         0      0   0    0    0      0          0           0      0
  91         0      0   0    0    0      0          0           0      0
  92         0      0   0    0    0      0          0           0      0
  93         0      0   0    0    0      0          0           0      0
  94         1      0   0    0    0      0          1           0      0
  95         0      0   1    0    0      1          0           0      0
  96         0      0   0    0    0      0          0           1      0
  97         0      0   0    0    0      0          0           0      0
  98         0      0   0    0    0      0          0           0      0
  99         0      0   0    0    0      0          0           0      1
  100        0      0   0    0    0      0          0           0      0
  101        0      0   0    0    0      0          0           0      0
  102        0      0   0    0    0      0          0           0      0
  103        0      0   0    0    0      0          0           0      0
  104        0      0   0    0    0      0          0           0      0
  105        0      0   0    0    0      0          0           0      0
  106        0      0   0    0    0      0          0           0      0
  107        0      0   2    0    0      0          0           0      0
  108        0      0   0    0    1      0          0           0      0
  109        0      0   0    0    0      0          0           0      0
  110        0      0   0    0    0      0          0           0      0
  111        0      0   0    0    0      0          0           0      0
  112        0      0   0    0    0      0          0           0      0
  113        0      0   0    0    0      0          0           0      0
  114        0      0   0    0    0      0          0           0      0
  115        0      0   0    0    0      0          0           0      0
  116        0      0   0    0    0      0          0           0      0
  117        0      0   0    0    0      0          0           0      0
  118        0      0   0    0    0      1          0           0      0
  119        0      0   1    0    0      0          0           0      0
  120        0      0   0    0    0      0          0           1      0
  121        0      0   1    0    0      0          0           0      0
  122        0      0   0    0    0      0          0           0      0
  123        0      0   1    0    0      0          0           0      0
  124        0      0   0    0    0      0          0           0      0
  125        0      0   0    0    0      0          0           0      0
  126        0      0   0    0    0      0          0           0      0
  127        0      0   0    0    0      0          0           0      0
  128        0      0   0    0    0      0          0           0      0
  129        0      0   0    0    0      0          0           0      0
  130        1      0   0    0    0      0          0           0      0
  131        0      0   0    0    0      0          0           0      0
  132        0      0   1    0    0      0          0           0      0
  133        0      0   1    0    0      1          0           0      0
  134        0      0   0    0    0      0          0           0      0
  135        0      0   0    0    0      0          0           0      0
  136        0      0   0    0    0      0          0           0      0
  137        0      0   0    0    0      0          0           0      0
  138        0      0   0    0    0      0          0           0      0
  139        0      0   0    0    0      0          0           0      0
  140        0      0   0    0    0      0          0           0      0
  141        0      0   0    0    0      0          0           0      0
  142        0      0   0    0    0      0          0           0      0
  143        0      0   0    0    0      0          1           0      1
  144        0      0   0    0    0      0          0           0      0
  145        0      0   0    0    0      0          0           0      0
  146        0      0   0    0    0      0          0           0      0
  147        0      0   0    0    0      0          0           0      0
  148        0      1   1    0    0      0          0           0      0
  149        0      0   0    0    0      0          0           0      0
  150        0      0   0    0    0      0          0           0      0
  151        0      0   0    0    0      0          0           1      0
  152        0      0   0    0    0      0          0           0      0
  153        0      0   0    0    0      0          0           0      0
  154        0      0   2    0    0      0          0           0      0
  155        0      0   0    0    0      0          0           0      0
  156        0      0   0    0    0      0          0           0      0
  157        0      0   0    0    0      0          0           1      0
  158        0      0   0    0    0      0          0           0      0
  159        0      0   0    0    0      0          0           0      0
  160        0      0   0    0    0      0          0           0      0
  161        0      0   0    0    0      0          0           0      0
  162        0      0   0    0    0      0          0           0      1
  163        0      0   0    0    0      0          0           0      0
  164        0      0   0    0    0      0          0           0      0
  165        0      0   0    0    0      0          0           0      0
  166        0      0   0    0    0      0          0           0      0
  167        0      0   0    0    0      0          0           0      0
  168        0      0   0    0    0      0          0           0      0
  169        0      0   0    0    0      0          0           0      0
  170        0      0   0    0    0      0          0           0      0
  171        0      0   0    0    0      0          0           0      0
  172        0      0   0    0    0      0          0           0      0
  173        0      0   0    0    0      0          0           0      0
  174        0      0   0    0    0      1          0           0      0
  175        0      0   0    0    0      0          0           0      0
  176        0      0   0    0    0      0          0           0      0
  177        0      0   0    0    0      0          0           0      0
  178        0      0   0    0    0      1          0           0      0
  179        0      0   0    0    0      0          0           0      0
  180        0      0   0    0    0      0          0           0      0
  181        0      0   0    0    0      0          0           0      0
  182        1      0   0    0    0      0          0           0      0
  183        0      0   0    0    0      0          0           0      0
  184        0      0   0    0    0      0          0           0      0
  185        0      0   0    0    0      0          0           0      0
  186        0      0   0    0    0      0          0           0      0
  187        0      0   0    0    0      1          0           0      0
  188        0      0   0    0    0      0          0           0      1
  189        0      0   0    0    0      0          0           0      0
  190        0      0   0    0    0      0          0           0      0
  191        0      0   0    0    0      0          0           0      0
  192        0      0   0    0    1      0          0           0      0
  193        0      0   1    0    0      0          0           0      0
  194        0      0   1    0    0      0          0           0      0
  195        0      0   1    0    0      0          0           0      0
  196        0      0   0    0    0      0          0           0      0
  197        0      0   0    0    0      0          0           0      0
  198        0      0   0    0    0      0          0           0      0
  199        0      0   0    0    0      0          1           0      0
  200        0      0   0    0    0      0          0           0      0
  201        0      0   0    0    0      0          0           1      0
  202        0      0   0    0    0      0          0           0      0
  203        0      0   0    0    0      0          0           0      0
  204        0      0   1    1    0      0          0           0      0
  205        0      0   0    0    0      0          0           0      0
  206        0      0   0    0    0      0          0           0      0
  207        0      0   0    0    0      0          0           1      0
  208        0      0   0    0    0      0          0           0      0
  209        0      0   1    0    0      0          0           0      0
  210        0      0   0    0    0      0          0           0      0
  211        0      0   0    0    0      0          0           0      0
  212        0      0   0    0    0      0          0           0      0
  213        0      0   0    0    0      0          1           0      0
  214        0      0   0    0    0      0          0           0      0
  215        0      0   1    0    0      1          0           0      0
  216        0      0   0    0    0      0          0           0      0
  217        0      0   0    0    0      0          0           0      0
  218        0      0   0    0    0      0          0           0      0
  219        0      0   0    1    0      1          0           0      0
  220        1      0   0    0    0      0          0           0      0
  221        0      0   1    0    0      0          0           0      0
  222        0      0   1    0    0      0          0           0      0
  223        0      0   0    0    0      0          0           0      0
  224        0      0   0    0    0      0          0           0      0
  225        0      0   0    0    0      0          0           1      0
  226        0      0   0    0    0      0          0           0      0
  227        0      0   0    0    0      0          0           0      0
  228        0      0   0    0    0      0          0           0      0
  229        0      1   0    0    0      0          0           0      0
  230        0      0   0    0    0      0          0           0      0
  231        0      0   0    0    0      0          0           0      0
  232        0      0   0    0    0      0          0           0      0
  233        0      0   0    0    0      0          0           0      0
  234        0      0   0    0    0      0          0           0      0
  235        0      0   0    0    0      0          0           0      0
  236        0      0   0    0    0      0          0           0      0
  237        0      0   0    0    1      0          0           0      0
  238        0      0   0    0    0      0          0           0      0
  239        0      0   0    0    0      0          0           0      0
  240        0      0   0    0    0      0          0           0      0
  241        0      0   1    0    0      0          0           0      0
  242        0      0   0    0    0      0          0           0      0
  243        0      1   0    0    0      0          0           0      0
  244        0      0   0    0    0      0          0           0      0
  245        1      0   0    0    0      0          0           0      0
  246        0      0   0    0    0      0          0           0      0
  247        0      0   0    0    0      0          1           0      0
  248        0      0   1    0    0      0          0           0      0
  249        0      0   0    0    0      0          0           0      0
  250        1      0   0    0    0      0          0           0      0
  251        0      0   0    0    0      0          0           0      0
  252        0      0   0    0    0      0          0           0      0
  253        0      0   0    0    0      0          0           0      0
  254        0      0   1    0    0      0          0           0      0
  255        0      0   0    0    0      0          0           0      0
  256        0      0   0    0    0      0          0           0      0
  257        0      0   0    0    0      1          0           0      0
  258        0      0   0    0    0      0          0           0      0
  259        0      0   1    0    0      1          0           0      0
  260        0      0   0    0    0      0          0           0      0
  261        0      0   0    0    0      0          0           0      0
  262        0      0   1    0    0      0          0           0      0
  263        0      0   0    0    0      0          0           0      0
  264        0      0   0    0    0      0          0           0      0
  265        0      0   0    1    0      0          0           0      0
  266        0      0   0    0    0      0          0           0      0
  267        0      0   0    0    0      1          0           0      0
  268        0      0   0    0    0      0          0           0      0
  269        0      0   0    0    0      0          0           0      0
  270        0      0   0    0    0      0          0           0      0
  271        0      0   0    0    0      1          0           0      0
  272        0      0   1    0    0      0          0           0      0
  273        0      0   0    0    0      0          0           0      0
  274        0      0   0    0    0      0          0           0      0
  275        0      0   0    0    0      0          0           0      0
  276        0      0   2    0    0      0          0           0      0
  277        0      0   0    0    0      0          0           0      0
  278        0      0   0    0    0      0          0           0      0
  279        0      0   0    0    0      0          0           0      0
  280        0      0   0    0    0      0          0           0      0
  281        0      0   0    0    0      0          0           0      0
  282        0      0   0    0    0      0          0           0      0
  283        0      0   0    0    0      0          0           0      0
  284        0      0   0    0    0      0          0           0      0
     Terms
Docs  change changing class code colleagues college come coming
  1        0        0     0    0          0       0    0      0
  2        0        0     0    0          0       0    0      0
  3        0        0     0    0          0       0    0      0
  4        0        0     0    0          0       0    0      0
  5        0        0     0    0          0       0    0      0
  6        0        0     0    0          0       0    0      0
  7        0        0     0    0          0       0    0      0
  8        0        0     0    0          0       0    1      0
  9        0        0     0    0          0       0    0      0
  10       0        0     0    0          0       0    0      0
  11       1        0     0    0          0       0    0      0
  12       0        0     0    0          0       0    0      0
  13       0        0     0    0          0       0    0      0
  14       0        0     0    0          0       0    0      0
  15       0        0     0    0          0       0    0      0
  16       0        0     0    0          0       0    0      0
  17       0        0     0    0          0       0    0      0
  18       0        0     0    0          0       0    0      0
  19       0        0     0    0          0       0    0      0
  20       0        0     0    0          0       0    0      0
  21       0        0     0    0          0       0    0      0
  22       0        0     0    0          0       0    0      0
  23       0        0     0    0          0       0    0      0
  24       0        0     0    0          0       0    0      0
  25       0        0     0    0          0       0    0      0
  26       0        0     0    0          0       0    0      0
  27       1        0     0    0          1       0    0      0
  28       0        0     0    0          0       0    0      0
  29       0        0     0    0          0       0    0      0
  30       0        0     0    0          0       0    0      0
  31       0        0     0    0          0       0    0      0
  32       0        0     0    0          0       1    0      0
  33       0        0     0    0          0       0    0      0
  34       0        0     0    0          0       0    0      0
  35       0        0     0    0          0       0    0      0
  36       0        0     0    0          0       0    0      0
  37       0        0     0    0          0       0    0      0
  38       0        0     0    0          0       0    0      0
  39       0        0     0    0          0       0    0      0
  40       0        0     0    0          0       0    0      0
  41       0        0     0    0          0       0    0      0
  42       0        0     0    0          0       0    0      0
  43       0        0     0    0          0       0    0      0
  44       0        0     0    0          0       0    0      0
  45       0        0     0    0          0       0    0      0
  46       0        0     0    0          0       0    0      0
  47       1        0     0    0          0       0    0      0
  48       0        0     0    0          0       0    0      0
  49       0        0     0    0          0       0    1      0
  50       0        0     0    0          0       0    0      0
  51       0        0     0    0          0       0    0      0
  52       2        0     0    0          0       0    0      0
  53       0        0     0    0          0       0    0      0
  54       0        0     0    0          0       0    0      0
  55       0        0     0    0          0       0    0      0
  56       1        0     0    0          0       0    0      0
  57       0        0     0    0          0       0    0      0
  58       0        0     0    0          0       0    0      0
  59       0        0     0    0          0       0    0      0
  60       0        0     0    0          0       0    0      0
  61       0        0     0    0          0       0    0      0
  62       0        0     0    0          0       0    0      0
  63       0        0     0    0          0       0    0      0
  64       0        0     0    0          0       0    0      0
  65       0        0     0    0          0       0    0      1
  66       0        0     0    0          0       0    0      0
  67       0        0     0    0          0       0    0      0
  68       0        0     0    0          0       0    0      0
  69       0        0     0    0          0       0    0      0
  70       0        0     0    0          0       0    0      0
  71       0        0     0    0          0       0    0      0
  72       0        0     0    0          0       0    0      0
  73       0        0     0    0          0       0    0      0
  74       0        0     0    0          0       0    0      0
  75       0        0     0    0          0       0    0      0
  76       0        0     0    0          0       0    0      0
  77       0        0     0    0          0       0    0      0
  78       0        0     0    0          0       0    0      0
  79       0        0     0    0          0       0    0      0
  80       0        0     0    0          1       0    0      0
  81       0        0     0    0          0       0    0      0
  82       0        0     0    0          0       0    0      0
  83       0        0     0    0          0       0    0      0
  84       0        0     0    0          0       0    0      0
  85       0        0     0    0          0       0    0      0
  86       0        0     0    0          0       0    0      0
  87       0        0     0    0          0       0    0      0
  88       0        0     0    0          0       0    0      0
  89       0        0     0    0          0       0    0      0
  90       0        0     0    0          0       0    0      0
  91       0        0     0    0          0       0    0      0
  92       0        0     1    0          0       0    0      0
  93       0        0     0    0          0       0    0      0
  94       0        0     0    0          0       0    0      0
  95       0        0     0    0          0       0    0      0
  96       0        0     0    0          1       0    0      0
  97       0        0     0    0          0       0    0      0
  98       0        0     0    0          0       0    0      0
  99       0        0     0    0          0       0    0      0
  100      0        0     0    0          0       0    0      0
  101      0        0     0    0          0       1    0      1
  102      0        0     0    0          1       0    0      0
  103      0        0     0    0          0       0    0      0
  104      0        0     0    0          0       0    0      0
  105      0        0     0    0          0       0    0      0
  106      0        0     0    0          0       0    0      0
  107      0        0     0    0          0       0    0      0
  108      0        1     0    0          0       0    0      0
  109      0        0     0    0          0       0    0      0
  110      0        0     0    0          0       0    0      0
  111      0        0     0    0          0       0    0      0
  112      0        0     0    0          0       0    0      0
  113      0        0     0    0          0       0    0      0
  114      0        0     0    0          0       0    0      0
  115      0        0     0    0          0       0    0      0
  116      0        0     0    0          0       0    0      0
  117      0        0     0    0          0       0    0      0
  118      0        0     0    0          0       0    0      0
  119      0        0     0    0          0       0    0      0
  120      0        0     0    0          0       0    0      0
  121      0        0     0    0          0       0    0      0
  122      0        0     0    0          0       0    0      0
  123      0        0     0    0          0       0    0      0
  124      0        0     0    0          0       0    0      0
  125      0        0     0    0          0       0    0      0
  126      0        0     0    0          0       0    0      0
  127      0        0     0    0          0       0    0      0
  128      0        0     0    0          0       0    0      0
  129      0        0     0    0          0       0    0      0
  130      0        0     0    0          0       0    0      0
  131      1        0     0    0          0       0    0      0
  132      0        0     0    0          0       0    0      0
  133      0        0     0    0          0       0    0      0
  134      0        0     0    0          0       0    0      0
  135      0        0     0    0          0       0    0      0
  136      0        0     0    0          0       0    0      0
  137      0        0     0    0          0       0    0      0
  138      0        0     0    0          0       0    0      0
  139      0        0     0    0          0       0    0      0
  140      0        0     0    0          0       0    0      0
  141      0        0     0    0          0       0    0      0
  142      0        0     0    0          0       0    0      0
  143      1        0     0    0          0       0    0      0
  144      0        0     0    0          0       0    0      0
  145      1        0     0    0          0       0    0      0
  146      0        0     0    0          1       0    0      0
  147      0        0     0    0          0       0    0      0
  148      0        0     0    0          0       0    0      0
  149      0        0     0    0          0       0    0      0
  150      0        0     0    0          1       0    0      0
  151      0        0     0    0          0       0    0      0
  152      0        0     0    0          1       0    0      0
  153      0        0     0    0          0       0    0      0
  154      0        0     0    0          0       0    0      0
  155      0        0     0    0          0       0    0      0
  156      0        0     0    0          1       0    0      0
  157      0        0     0    0          0       0    0      0
  158      0        0     0    0          0       0    0      0
  159      0        0     0    0          0       0    0      0
  160      0        0     0    0          0       0    0      0
  161      0        0     0    0          0       0    0      0
  162      0        0     0    1          0       0    0      0
  163      0        0     0    0          0       0    0      0
  164      0        0     0    0          0       0    0      0
  165      0        0     0    0          1       0    0      0
  166      0        0     0    0          0       0    0      0
  167      0        0     0    0          0       0    0      0
  168      0        0     0    0          0       0    0      0
  169      0        0     0    0          0       0    0      0
  170      0        0     0    0          0       0    0      0
  171      0        0     0    0          0       0    0      0
  172      0        0     0    0          0       0    0      0
  173      0        0     0    0          0       0    0      0
  174      0        0     0    0          1       0    0      0
  175      1        0     0    0          0       0    0      0
  176      0        0     0    0          0       0    0      1
  177      0        0     0    0          0       0    0      0
  178      0        1     0    0          1       0    0      0
  179      0        0     0    0          0       0    0      0
  180      0        0     0    0          0       0    0      0
  181      0        0     0    0          0       0    0      0
  182      0        0     0    0          0       0    0      0
  183      0        0     0    0          1       0    0      0
  184      0        0     0    0          0       0    0      0
  185      0        0     0    0          0       0    0      0
  186      0        0     0    0          0       0    0      0
  187      0        0     0    0          0       0    0      0
  188      0        0     0    0          0       0    0      0
  189      0        0     0    0          0       0    0      0
  190      0        0     0    0          0       0    0      0
  191      0        0     0    0          0       0    0      0
  192      0        1     0    0          0       0    0      0
  193      0        0     0    0          0       0    0      0
  194      0        0     0    0          0       0    0      0
  195      0        0     0    0          0       0    0      0
  196      0        0     0    0          0       0    0      0
  197      0        0     0    0          0       0    0      0
  198      0        0     0    0          0       0    0      0
  199      0        0     0    0          0       0    0      0
  200      0        0     0    0          0       0    0      0
  201      0        0     0    0          0       0    0      0
  202      0        0     0    0          0       0    0      0
  203      0        0     0    0          0       0    0      0
  204      0        0     0    0          0       0    0      0
  205      0        0     0    0          0       0    0      0
  206      0        0     0    0          0       0    0      0
  207      0        0     0    0          0       0    0      0
  208      0        0     0    0          0       0    0      0
  209      0        1     0    0          0       0    0      0
  210      0        1     0    0          0       0    0      0
  211      0        0     0    0          0       0    0      0
  212      0        0     0    0          0       0    0      0
  213      0        0     0    0          0       0    0      0
  214      0        0     0    0          0       0    0      0
  215      0        0     0    0          0       0    0      0
  216      0        0     0    0          0       0    0      0
  217      0        0     0    0          0       0    0      0
  218      0        0     0    0          0       0    0      0
  219      0        0     0    0          0       0    0      0
  220      0        0     0    0          0       0    0      0
  221      0        0     0    0          0       0    1      0
  222      0        0     0    0          0       0    0      0
  223      0        0     0    0          0       0    0      0
  224      0        0     0    0          0       0    0      0
  225      0        0     0    0          0       0    0      0
  226      0        0     0    0          0       0    0      1
  227      0        0     0    0          0       0    1      0
  228      0        0     0    0          0       0    0      0
  229      0        0     0    0          0       0    0      0
  230      0        0     0    0          0       0    0      0
  231      0        0     0    0          0       0    0      0
  232      0        0     0    0          0       0    0      0
  233      0        0     0    0          0       0    0      0
  234      0        0     0    0          0       0    0      0
  235      0        0     0    0          0       0    0      0
  236      0        0     0    0          0       0    0      0
  237      0        0     0    0          0       0    0      0
  238      0        0     0    0          0       0    0      0
  239      0        0     0    0          0       0    0      0
  240      1        0     0    0          0       0    0      0
  241      0        1     0    0          0       0    0      0
  242      0        0     0    0          0       0    0      0
  243      0        0     0    0          0       0    0      0
  244      0        1     0    0          0       0    0      0
  245      0        0     0    0          1       0    0      0
  246      0        0     0    0          0       0    0      0
  247      0        0     0    0          0       0    0      0
  248      0        0     0    0          0       0    0      0
  249      0        1     0    0          0       0    0      0
  250      0        0     0    0          0       0    0      0
  251      0        0     0    0          0       0    0      0
  252      0        0     0    0          0       0    0      0
  253      0        0     0    0          0       0    0      0
  254      1        0     0    0          0       0    0      0
  255      0        0     0    0          0       0    0      0
  256      0        0     0    0          0       0    0      0
  257      0        0     0    0          0       0    0      0
  258      0        0     0    0          0       0    0      0
  259      0        0     0    0          0       0    0      0
  260      0        0     0    0          0       0    0      0
  261      0        0     0    0          0       0    0      0
  262      0        0     0    0          0       0    0      0
  263      0        0     0    0          0       0    0      0
  264      0        0     0    0          0       0    0      0
  265      1        0     0    0          0       0    0      0
  266      0        0     0    0          0       0    0      0
  267      0        0     0    0          0       0    0      0
  268      0        0     0    0          0       0    0      0
  269      0        0     0    0          0       0    0      0
  270      0        0     0    0          0       0    0      0
  271      0        0     0    0          0       0    0      0
  272      0        0     0    0          0       0    0      0
  273      0        0     0    0          0       0    0      0
  274      0        0     0    0          0       0    0      0
  275      0        0     0    0          0       0    0      0
  276      0        0     0    0          0       0    0      0
  277      0        0     0    0          0       0    0      0
  278      0        0     0    0          0       0    0      0
  279      0        0     0    0          0       0    0      0
  280      0        0     0    0          0       0    0      0
  281      0        0     0    0          0       0    0      0
  282      0        0     0    0          0       0    0      0
  283      0        0     0    0          0       0    0      0
  284      0        0     0    0          0       0    0      0
     Terms
Docs  communication companies company compensation competent competitive
  1               0         0       0            0         0           0
  2               0         0       0            0         0           0
  3               0         0       0            0         0           0
  4               0         0       0            0         0           0
  5               0         0       0            0         0           0
  6               0         0       0            0         0           0
  7               0         0       0            0         0           0
  8               0         0       0            0         0           0
  9               0         0       0            0         0           0
  10              0         0       0            0         0           0
  11              0         0       0            0         0           0
  12              0         0       0            0         0           0
  13              0         0       0            0         0           0
  14              0         0       0            0         0           0
  15              0         0       0            0         0           0
  16              0         0       0            0         0           0
  17              0         0       0            0         0           0
  18              0         0       1            0         0           0
  19              0         0       0            0         0           0
  20              0         1       0            0         0           0
  21              0         0       2            1         0           0
  22              0         0       0            0         0           0
  23              0         0       0            0         0           0
  24              0         0       0            0         0           0
  25              0         0       0            0         0           0
  26              0         0       0            0         0           0
  27              1         0       0            1         0           0
  28              0         0       1            0         0           0
  29              0         0       0            0         0           0
  30              0         0       0            0         0           0
  31              0         0       3            0         0           0
  32              0         0       0            0         0           0
  33              0         0       0            0         0           0
  34              0         0       0            0         0           0
  35              0         0       0            0         0           0
  36              0         0       0            1         0           1
  37              0         0       0            0         1           0
  38              0         0       0            0         0           0
  39              0         1       0            0         0           0
  40              0         0       0            0         0           0
  41              0         0       2            0         1           0
  42              0         0       1            0         0           0
  43              0         0       0            0         0           0
  44              0         0       2            0         0           0
  45              0         0       0            0         0           0
  46              0         0       1            0         0           0
  47              0         0       0            0         0           0
  48              0         0       0            0         0           0
  49              0         0       0            0         0           0
  50              0         0       0            0         0           0
  51              0         0       1            0         0           0
  52              0         0       0            0         0           0
  53              0         0       0            0         0           0
  54              0         0       2            0         0           0
  55              0         0       0            0         0           0
  56              0         0       0            0         0           0
  57              0         0       0            0         0           0
  58              0         0       1            0         0           0
  59              0         0       0            0         0           0
  60              0         0       0            0         0           0
  61              0         0       0            0         0           0
  62              0         0       1            0         0           0
  63              0         0       0            0         0           0
  64              0         0       1            0         1           0
  65              0         0       0            0         0           0
  66              0         0       0            0         0           0
  67              0         0       2            0         0           0
  68              0         0       0            0         0           0
  69              0         0       1            0         0           0
  70              0         0       1            0         0           0
  71              0         1       0            0         0           0
  72              0         0       0            1         0           0
  73              0         0       0            0         0           0
  74              0         0       0            0         0           0
  75              0         0       0            0         0           0
  76              0         1       0            0         0           0
  77              0         0       0            0         0           0
  78              0         0       0            0         0           0
  79              0         0       0            0         0           0
  80              0         0       0            0         0           0
  81              0         0       0            0         0           0
  82              0         0       0            0         0           0
  83              0         0       0            0         0           0
  84              0         0       0            1         0           1
  85              0         0       1            0         0           0
  86              0         0       0            0         0           0
  87              0         0       2            0         0           0
  88              0         0       0            0         0           0
  89              0         0       0            0         0           0
  90              0         0       0            0         1           0
  91              0         0       0            0         0           0
  92              0         0       0            0         0           0
  93              0         0       0            1         0           0
  94              0         0       1            0         0           0
  95              0         0       0            0         0           0
  96              0         0       1            0         0           0
  97              0         0       0            0         0           0
  98              0         0       0            1         0           0
  99              0         0       2            0         0           0
  100             0         1       0            0         0           0
  101             0         0       0            0         0           0
  102             0         0       0            0         0           0
  103             0         0       0            0         0           0
  104             0         0       1            0         0           0
  105             0         0       1            0         0           0
  106             0         0       0            0         0           0
  107             0         0       0            0         0           0
  108             0         1       0            0         0           0
  109             0         0       0            0         0           0
  110             0         0       1            0         0           0
  111             0         0       0            0         0           0
  112             0         0       0            0         0           0
  113             0         0       0            0         0           0
  114             0         0       1            0         0           0
  115             0         0       0            0         0           0
  116             0         0       0            0         0           0
  117             0         0       0            0         0           0
  118             0         0       0            0         0           0
  119             0         0       0            0         0           0
  120             0         0       0            0         0           0
  121             0         0       1            0         0           0
  122             0         0       0            0         0           0
  123             0         1       0            0         0           0
  124             1         0       0            0         0           1
  125             0         0       0            0         0           0
  126             1         0       0            0         0           0
  127             0         0       1            0         0           0
  128             0         0       1            0         0           0
  129             0         0       0            0         0           0
  130             0         1       0            0         0           0
  131             0         0       0            1         0           0
  132             0         0       0            0         0           0
  133             0         0       0            0         0           0
  134             0         0       1            0         0           0
  135             0         0       0            0         0           0
  136             0         0       0            0         0           0
  137             0         0       1            0         0           0
  138             1         0       0            0         0           0
  139             0         0       1            0         0           0
  140             0         0       0            0         0           0
  141             0         0       0            0         0           0
  142             0         0       0            0         0           0
  143             0         0       0            0         1           0
  144             0         0       0            0         0           0
  145             0         0       0            0         0           0
  146             0         0       0            0         0           0
  147             0         0       0            0         0           0
  148             0         0       1            0         0           0
  149             0         0       0            0         0           0
  150             0         0       0            0         0           0
  151             0         0       0            1         0           0
  152             0         0       0            0         0           0
  153             0         0       0            0         0           0
  154             0         0       1            0         0           0
  155             0         0       0            0         0           0
  156             0         0       0            0         0           0
  157             0         0       0            0         0           0
  158             0         0       1            0         0           0
  159             0         0       1            0         0           0
  160             0         0       0            0         0           0
  161             0         0       0            0         0           0
  162             0         0       0            0         0           0
  163             0         0       0            0         0           0
  164             0         0       1            0         0           0
  165             0         0       0            0         0           0
  166             0         0       0            0         0           0
  167             0         0       0            0         0           0
  168             0         0       0            0         0           0
  169             0         0       2            0         0           0
  170             0         0       0            0         0           0
  171             0         0       0            0         0           0
  172             0         0       0            0         0           0
  173             0         0       0            0         0           0
  174             0         0       0            0         0           0
  175             0         0       0            0         0           0
  176             0         0       0            0         0           0
  177             0         0       1            0         0           0
  178             0         0       0            0         0           0
  179             0         0       0            0         0           0
  180             0         1       2            0         0           0
  181             0         0       0            0         0           1
  182             0         0       0            0         0           0
  183             0         0       0            0         0           0
  184             0         0       0            0         0           0
  185             0         0       1            0         0           1
  186             0         0       0            0         0           0
  187             0         0       0            0         0           0
  188             0         0       0            0         0           0
  189             0         0       2            0         0           0
  190             0         0       0            0         0           0
  191             0         0       1            0         0           0
  192             0         0       0            0         0           0
  193             0         0       2            0         0           0
  194             0         0       0            0         0           0
  195             0         1       0            0         0           0
  196             0         0       0            0         0           0
  197             0         0       0            0         0           0
  198             0         0       0            0         0           0
  199             0         0       0            0         0           0
  200             0         0       0            0         0           0
  201             0         0       0            1         0           0
  202             0         0       0            0         0           0
  203             0         0       0            0         1           0
  204             0         0       1            0         0           0
  205             0         0       0            0         0           0
  206             0         0       0            0         0           0
  207             0         0       0            0         0           0
  208             0         0       1            0         0           0
  209             0         0       1            0         0           0
  210             0         0       0            0         0           0
  211             0         0       0            0         0           0
  212             0         0       2            1         0           0
  213             0         0       0            0         0           0
  214             0         0       1            0         0           0
  215             0         0       0            0         0           0
  216             0         1       2            1         0           0
  217             0         0       0            0         0           0
  218             0         0       0            0         0           0
  219             0         0       0            0         0           0
  220             0         0       0            0         0           0
  221             0         0       0            0         0           0
  222             0         0       0            0         0           0
  223             0         0       0            0         0           0
  224             0         0       0            0         0           0
  225             0         0       0            0         0           0
  226             0         0       0            0         0           0
  227             0         0       0            0         0           0
  228             0         0       3            0         0           0
  229             0         0       0            0         0           0
  230             0         0       1            0         0           0
  231             0         0       0            0         0           0
  232             0         0       2            0         0           0
  233             0         0       0            0         0           0
  234             0         0       1            0         0           0
  235             0         0       0            0         0           0
  236             0         0       0            0         0           0
  237             0         0       0            0         0           0
  238             0         0       0            0         0           0
  239             0         0       0            0         0           0
  240             0         0       0            0         0           0
  241             0         0       0            0         0           0
  242             0         0       0            0         0           0
  243             0         1       0            0         0           0
  244             0         0       0            0         0           0
  245             0         0       0            0         0           0
  246             0         0       0            0         0           0
  247             0         0       0            0         0           0
  248             0         0       1            0         0           0
  249             0         0       1            0         0           0
  250             0         0       0            0         0           0
  251             0         0       0            0         0           0
  252             0         0       0            0         0           0
  253             0         0       0            0         0           0
  254             0         0       1            0         0           0
  255             0         0       0            0         0           0
  256             0         0       1            0         0           0
  257             0         0       0            0         0           0
  258             0         0       1            0         0           0
  259             0         0       0            0         0           0
  260             0         0       0            0         0           0
  261             0         0       0            0         0           0
  262             0         0       1            0         0           0
  263             0         0       0            0         0           0
  264             0         0       0            0         0           0
  265             0         0       1            0         0           0
  266             0         0       0            0         0           0
  267             0         0       0            0         0           0
  268             0         0       0            0         0           0
  269             0         0       2            0         0           0
  270             0         1       0            0         0           0
  271             0         0       0            0         0           0
  272             0         0       0            0         0           0
  273             0         0       0            0         1           0
  274             0         0       0            0         0           0
  275             0         0       0            0         0           0
  276             0         0       0            0         0           0
  277             0         0       0            0         0           0
  278             0         0       0            0         0           0
  279             0         0       0            0         0           0
  280             0         0       0            0         0           0
  281             0         0       0            0         0           0
  282             0         0       0            0         0           0
  283             0         0       0            0         0           0
  284             0         0       0            0         0           0
     Terms
Docs  completely cons constant contractors contribute cool corporate
  1            0    0        0           0          0    1         0
  2            0    0        0           0          0    0         0
  3            0    0        0           0          0    0         0
  4            0    0        0           0          0    0         0
  5            0    0        0           0          0    0         0
  6            0    0        0           0          0    0         0
  7            0    0        0           0          0    0         0
  8            0    0        0           0          0    0         0
  9            0    0        0           0          0    0         0
  10           0    0        0           0          0    0         0
  11           0    0        0           0          0    0         0
  12           0    0        0           0          0    0         0
  13           0    0        0           0          0    0         0
  14           0    0        0           0          0    0         0
  15           0    0        0           0          0    0         0
  16           0    0        0           0          0    0         0
  17           0    0        0           0          0    0         0
  18           0    0        0           0          0    0         0
  19           0    0        0           0          0    0         0
  20           0    0        0           0          0    0         0
  21           0    0        0           0          0    0         0
  22           0    0        0           0          0    0         0
  23           0    0        0           0          0    0         0
  24           0    0        0           0          0    0         0
  25           0    0        0           0          0    0         0
  26           0    0        0           0          0    0         0
  27           0    0        0           0          0    0         0
  28           0    0        0           0          0    0         0
  29           0    0        0           0          0    0         0
  30           0    0        0           0          0    0         0
  31           0    0        0           0          0    1         0
  32           0    0        0           0          0    0         0
  33           0    0        0           0          0    0         0
  34           0    0        0           0          0    0         0
  35           0    0        0           0          0    0         0
  36           0    0        0           0          0    0         0
  37           0    0        0           0          0    0         0
  38           0    0        0           0          0    0         0
  39           0    0        0           0          0    0         0
  40           0    0        0           0          0    1         0
  41           0    0        0           0          0    0         0
  42           0    0        0           0          0    0         0
  43           0    0        0           0          0    0         0
  44           0    0        0           0          0    0         0
  45           0    0        0           0          0    0         0
  46           0    0        0           0          0    0         0
  47           0    0        0           0          0    0         0
  48           0    0        0           0          0    0         0
  49           0    0        0           0          0    0         0
  50           0    0        0           0          0    0         0
  51           0    0        0           0          0    0         0
  52           0    0        1           0          0    0         0
  53           0    0        0           0          0    0         0
  54           0    0        0           0          0    1         0
  55           0    0        0           0          0    0         0
  56           0    0        0           0          0    0         0
  57           0    0        0           0          0    0         0
  58           0    0        0           0          0    0         0
  59           0    0        0           0          0    0         0
  60           0    0        0           0          0    0         0
  61           0    0        0           0          1    0         0
  62           0    0        0           0          0    0         0
  63           0    0        0           0          0    0         0
  64           0    0        0           0          0    0         0
  65           0    0        0           0          0    0         0
  66           0    0        0           0          0    0         0
  67           1    0        0           0          0    0         0
  68           0    0        0           0          0    0         0
  69           0    0        0           0          0    0         0
  70           0    0        0           0          0    0         0
  71           0    0        0           0          0    0         0
  72           0    0        0           0          0    0         0
  73           0    0        0           0          0    0         0
  74           0    0        0           0          0    0         0
  75           0    0        0           0          0    0         0
  76           0    0        0           0          0    0         0
  77           0    0        0           0          0    0         0
  78           0    0        0           0          0    0         0
  79           0    0        0           0          0    0         0
  80           0    0        0           0          0    0         0
  81           0    0        0           0          0    0         0
  82           0    0        0           0          0    0         0
  83           0    0        0           0          0    0         0
  84           0    0        0           0          0    0         0
  85           1    0        0           0          0    0         0
  86           0    0        0           0          0    0         0
  87           0    0        0           0          0    0         0
  88           0    0        0           0          0    0         0
  89           0    0        0           0          0    0         0
  90           0    0        0           0          0    0         0
  91           0    0        0           0          0    0         0
  92           0    0        0           0          0    0         0
  93           0    0        0           0          0    0         0
  94           0    0        0           0          0    0         0
  95           0    0        0           0          0    0         0
  96           0    0        0           0          0    0         0
  97           0    0        0           0          0    0         0
  98           0    0        0           0          0    0         0
  99           0    0        0           0          0    0         0
  100          0    0        0           0          0    0         0
  101          0    0        0           0          0    0         0
  102          0    0        0           0          0    0         0
  103          0    0        0           0          0    0         0
  104          0    0        0           0          0    0         0
  105          0    0        0           0          0    0         0
  106          0    0        0           0          0    0         0
  107          0    0        0           0          0    0         0
  108          0    0        0           0          0    0         0
  109          0    0        0           0          0    0         0
  110          0    0        0           0          0    0         0
  111          0    0        0           0          0    0         0
  112          0    0        0           0          0    0         0
  113          0    0        0           0          0    0         0
  114          0    0        0           0          0    0         0
  115          0    0        0           0          0    0         0
  116          0    0        0           0          0    0         0
  117          0    0        0           0          0    0         0
  118          0    0        1           0          0    0         0
  119          0    0        0           0          0    0         0
  120          0    0        0           0          0    0         0
  121          0    0        0           0          0    0         0
  122          0    0        0           0          0    0         0
  123          0    0        0           0          0    0         0
  124          0    0        0           0          0    0         0
  125          0    0        0           0          0    0         0
  126          0    0        0           0          0    0         0
  127          0    0        0           0          0    0         0
  128          0    0        0           0          0    0         0
  129          0    0        0           0          0    0         0
  130          0    0        0           0          0    0         0
  131          0    0        0           0          0    0         0
  132          0    0        0           0          0    0         0
  133          0    0        0           0          0    0         0
  134          0    0        0           0          0    0         0
  135          0    0        0           0          0    0         0
  136          0    0        0           0          0    0         0
  137          0    0        0           0          0    0         0
  138          0    0        0           0          0    0         0
  139          0    0        0           0          0    0         0
  140          0    0        0           0          0    0         0
  141          0    0        0           0          0    0         0
  142          0    0        0           0          0    0         0
  143          0    0        0           0          0    0         0
  144          0    0        0           0          0    0         0
  145          0    0        0           0          0    0         0
  146          0    0        0           0          0    0         0
  147          0    0        0           0          0    0         0
  148          0    0        0           0          0    0         0
  149          0    0        0           0          0    0         0
  150          0    0        0           0          0    0         0
  151          0    0        0           0          0    0         0
  152          0    0        0           0          0    0         0
  153          0    0        0           0          0    0         0
  154          0    0        0           0          0    0         0
  155          0    0        0           0          0    0         0
  156          0    0        0           0          0    0         0
  157          0    0        0           0          0    0         0
  158          0    0        0           0          0    0         0
  159          0    0        0           0          0    0         0
  160          0    0        0           0          0    0         0
  161          0    0        0           0          0    0         0
  162          0    0        0           0          0    0         0
  163          0    0        0           0          0    0         0
  164          0    0        0           0          0    0         0
  165          0    0        0           0          0    0         1
  166          0    0        0           0          0    0         0
  167          0    0        0           0          0    0         0
  168          0    0        0           0          0    0         0
  169          0    0        0           0          0    0         0
  170          0    0        0           0          0    0         0
  171          0    0        0           0          0    0         0
  172          0    0        0           0          0    0         0
  173          0    0        0           0          0    0         0
  174          0    0        0           0          0    0         0
  175          0    0        0           0          0    0         0
  176          0    0        1           0          0    0         0
  177          0    0        0           0          0    0         0
  178          0    0        0           0          0    0         0
  179          0    0        0           0          0    0         0
  180          0    0        0           0          0    0         0
  181          0    0        0           0          0    0         0
  182          0    0        0           0          0    0         0
  183          0    0        0           0          0    0         0
  184          0    0        0           0          0    0         0
  185          0    0        0           0          0    0         0
  186          0    0        0           0          0    0         0
  187          0    0        0           0          0    0         0
  188          0    0        0           0          0    0         0
  189          0    0        0           0          0    0         0
  190          0    0        0           0          0    0         0
  191          0    0        0           0          0    0         0
  192          0    0        0           0          0    0         0
  193          0    0        0           0          0    0         0
  194          0    0        0           0          0    0         0
  195          0    0        0           0          0    0         0
  196          0    0        0           0          0    0         0
  197          0    0        0           0          0    0         0
  198          0    0        0           0          0    0         0
  199          0    0        0           0          0    0         0
  200          0    0        0           0          0    0         0
  201          0    0        0           0          0    0         0
  202          0    0        0           0          0    0         0
  203          0    0        0           0          0    0         0
  204          0    0        0           0          0    0         0
  205          0    0        0           0          0    0         0
  206          0    0        0           0          0    0         0
  207          0    0        0           0          0    0         0
  208          0    0        0           0          0    0         0
  209          0    0        0           0          0    1         0
  210          0    0        0           0          0    0         0
  211          0    0        0           0          0    0         0
  212          0    0        0           0          0    0         0
  213          0    0        0           0          0    0         0
  214          0    0        0           0          0    0         0
  215          0    0        0           0          0    0         0
  216          0    0        0           0          0    0         0
  217          0    0        0           0          0    0         0
  218          0    0        0           0          0    0         0
  219          0    0        0           0          0    0         0
  220          0    0        0           1          0    0         0
  221          0    0        0           0          0    0         0
  222          0    0        0           0          0    0         0
  223          0    0        0           0          0    0         0
  224          0    0        0           0          0    0         0
  225          0    0        0           0          0    0         0
  226          0    0        0           0          0    1         0
  227          0    0        0           0          0    0         0
  228          0    0        0           0          0    0         0
  229          0    0        0           0          0    0         0
  230          0    0        0           0          0    0         0
  231          0    0        0           0          0    0         0
  232          0    0        0           0          0    1         0
  233          0    0        0           0          0    0         0
  234          0    0        0           0          0    0         0
  235          0    0        0           0          0    0         0
  236          0    0        0           0          0    0         0
  237          0    0        0           0          0    0         0
  238          0    0        0           0          0    0         0
  239          0    0        0           0          0    0         0
  240          0    0        0           0          0    0         0
  241          0    0        0           0          0    0         0
  242          0    0        0           0          0    0         0
  243          0    0        0           0          0    0         0
  244          0    0        0           0          0    0         0
  245          0    0        0           0          0    0         0
  246          0    0        0           0          0    0         0
  247          0    0        0           0          0    0         0
  248          0    0        0           0          0    0         0
  249          0    0        0           0          0    0         0
  250          0    0        0           0          0    0         0
  251          0    0        0           0          0    0         0
  252          0    0        0           0          0    0         0
  253          0    0        0           0          0    0         0
  254          0    0        0           0          0    0         0
  255          0    0        0           0          0    0         0
  256          0    0        0           0          0    0         0
  257          0    0        0           0          0    0         0
  258          0    0        0           1          0    0         0
  259          0    0        0           0          0    0         0
  260          0    0        0           0          0    0         0
  261          1    0        0           0          0    0         0
  262          0    0        0           0          0    0         0
  263          0    1        0           0          0    0         0
  264          0    0        0           0          0    0         0
  265          0    0        0           0          0    0         0
  266          0    0        0           0          0    0         0
  267          0    0        0           0          0    0         0
  268          0    0        0           0          0    0         0
  269          0    0        0           2          0    0         0
  270          0    0        0           0          0    0         0
  271          0    0        0           0          0    0         0
  272          0    0        0           0          0    0         0
  273          0    0        0           0          0    0         0
  274          0    0        0           0          0    0         0
  275          0    0        0           0          0    0         0
  276          0    0        0           0          0    0         0
  277          0    0        0           0          0    0         0
  278          0    0        0           0          0    0         0
  279          0    0        0           0          0    0         0
  280          0    0        0           0          0    0         0
  281          0    0        0           0          0    0         0
  282          0    0        0           0          0    0         0
  283          0    0        0           0          0    0         0
  284          0    0        0           0          0    0         0
     Terms
Docs  coworkers creative culture day days decisions department development
  1           0        0       0   0    0         0          0           0
  2           0        0       0   0    0         0          0           0
  3           0        0       0   0    0         0          0           0
  4           0        0       0   0    0         0          0           0
  5           0        0       0   0    0         0          0           0
  6           0        0       0   0    0         0          0           0
  7           0        0       0   1    0         0          0           0
  8           0        0       0   1    0         0          0           0
  9           0        0       0   0    0         0          0           1
  10          0        0       0   1    0         0          0           0
  11          0        0       0   0    0         0          0           0
  12          0        0       0   1    0         0          0           0
  13          0        1       0   0    0         0          0           0
  14          0        0       0   0    0         0          0           0
  15          0        0       0   0    0         0          0           0
  16          0        0       0   0    0         0          0           0
  17          0        0       0   0    0         0          0           0
  18          0        0       0   0    0         0          0           0
  19          0        0       0   0    0         0          0           0
  20          0        0       0   0    0         0          0           0
  21          0        0       0   0    0         0          0           1
  22          0        0       0   0    0         0          0           0
  23          0        0       0   0    0         0          0           0
  24          0        0       0   0    0         0          0           0
  25          0        0       0   0    0         0          0           0
  26          0        0       0   0    0         1          0           0
  27          0        0       0   0    0         0          0           0
  28          0        0       0   0    0         0          0           0
  29          0        0       0   1    0         0          0           0
  30          0        0       0   1    0         0          0           0
  31          0        0       0   0    0         0          0           0
  32          1        0       0   0    0         0          0           0
  33          0        0       0   1    0         0          0           0
  34          0        0       0   0    0         0          1           0
  35          0        0       0   0    0         0          0           0
  36          1        0       0   0    0         0          0           0
  37          0        0       0   0    0         0          0           0
  38          0        0       0   0    0         0          0           0
  39          0        0       0   1    0         0          0           0
  40          0        0       0   0    0         0          0           0
  41          0        0       0   2    0         0          0           0
  42          0        0       0   0    0         0          0           0
  43          0        0       0   0    0         0          0           0
  44          0        0       0   0    0         0          0           0
  45          0        0       0   0    0         0          0           1
  46          0        0       0   0    0         0          0           0
  47          0        1       0   0    0         0          0           0
  48          0        0       0   0    0         0          0           0
  49          0        0       0   0    0         0          0           0
  50          0        0       0   0    0         0          0           0
  51          0        0       0   0    0         2          0           0
  52          0        0       1   0    0         0          0           0
  53          0        0       0   0    0         0          0           0
  54          0        0       0   0    0         0          0           0
  55          0        0       1   0    0         0          0           0
  56          1        0       0   0    0         0          0           0
  57          0        0       0   0    0         0          0           0
  58          0        0       0   0    0         0          0           0
  59          0        0       0   0    0         0          0           0
  60          1        0       0   0    0         0          0           0
  61          0        0       0   0    0         0          0           0
  62          0        0       0   0    0         0          0           0
  63          0        0       0   0    0         0          0           0
  64          0        0       0   0    0         0          0           0
  65          0        0       0   0    0         0          0           0
  66          0        0       2   0    0         0          0           0
  67          0        0       0   0    0         0          0           0
  68          0        0       0   0    0         0          0           0
  69          0        0       0   0    0         0          0           0
  70          0        0       0   0    0         0          0           0
  71          0        0       1   0    0         0          0           0
  72          1        0       0   0    0         0          0           0
  73          0        0       0   0    0         0          0           0
  74          0        0       0   0    0         0          0           0
  75          0        0       0   0    0         0          0           0
  76          0        0       1   0    0         0          0           0
  77          0        0       0   0    0         0          0           0
  78          1        0       0   0    0         0          0           0
  79          1        0       0   0    0         0          0           0
  80          0        0       1   0    0         0          0           0
  81          0        0       0   0    0         0          0           0
  82          2        0       0   0    0         0          0           0
  83          1        0       0   0    0         0          0           0
  84          0        0       0   0    0         0          0           0
  85          0        0       0   0    0         0          0           0
  86          0        0       0   0    0         0          0           0
  87          0        0       0   0    0         0          0           0
  88          0        0       0   0    0         0          0           0
  89          0        0       0   0    0         0          0           0
  90          0        0       0   0    0         0          0           0
  91          0        0       1   0    0         0          0           0
  92          0        0       0   0    0         0          0           0
  93          0        0       0   0    0         0          0           0
  94          0        0       0   1    0         0          0           0
  95          1        0       0   0    0         0          0           0
  96          0        0       1   0    0         0          0           0
  97          0        0       0   0    0         0          0           0
  98          1        0       0   0    0         0          0           0
  99          0        0       0   0    0         0          0           0
  100         0        0       0   0    0         0          0           0
  101         0        0       0   0    0         0          0           0
  102         0        0       0   0    0         0          0           0
  103         0        0       1   0    0         0          0           0
  104         0        0       0   1    0         0          0           0
  105         0        0       0   0    0         0          0           0
  106         0        0       0   0    0         0          0           0
  107         0        0       0   0    0         0          0           0
  108         0        0       0   0    0         0          0           0
  109         0        0       0   1    0         0          0           0
  110         0        0       0   0    0         0          0           0
  111         0        0       1   0    0         0          0           0
  112         0        0       0   0    0         0          0           0
  113         0        0       0   0    0         0          0           0
  114         0        0       0   0    0         0          0           0
  115         0        0       1   0    0         0          0           0
  116         0        0       0   0    0         0          0           0
  117         0        0       0   0    0         0          0           0
  118         0        0       0   0    0         0          0           0
  119         0        0       0   0    0         0          0           0
  120         0        0       0   1    0         0          0           0
  121         0        0       0   0    0         0          0           0
  122         0        0       0   0    0         0          0           0
  123         1        0       0   0    0         0          0           0
  124         0        0       0   0    0         0          0           0
  125         2        0       1   0    0         0          0           0
  126         0        1       0   0    0         0          0           1
  127         0        0       0   0    0         0          0           0
  128         0        0       0   0    0         0          0           0
  129         0        0       0   0    0         0          0           0
  130         0        0       0   0    0         0          0           0
  131         0        0       0   0    0         0          0           0
  132         0        0       0   0    0         0          0           0
  133         0        0       0   0    0         0          0           0
  134         0        0       0   0    0         0          0           0
  135         0        0       0   0    0         0          0           0
  136         0        0       0   0    0         0          0           0
  137         0        0       1   0    0         0          0           1
  138         0        0       0   0    0         0          0           0
  139         0        0       0   0    0         0          0           0
  140         0        0       0   0    0         0          0           0
  141         1        0       0   0    0         0          0           0
  142         0        0       0   0    0         0          0           0
  143         0        0       1   0    0         0          0           0
  144         0        0       0   0    0         0          0           0
  145         0        0       0   0    0         0          0           0
  146         0        0       0   0    0         0          0           0
  147         1        0       0   0    0         0          0           0
  148         0        0       0   0    0         0          0           0
  149         1        0       0   0    0         0          0           0
  150         0        0       0   0    0         0          0           0
  151         1        0       0   0    0         0          0           0
  152         0        0       0   0    0         0          0           0
  153         0        0       1   0    0         0          0           0
  154         0        0       0   0    0         0          0           0
  155         0        0       0   0    0         0          0           0
  156         0        0       0   0    0         0          0           0
  157         0        0       0   0    0         0          0           0
  158         0        0       0   0    0         0          0           0
  159         1        0       0   0    0         0          0           0
  160         0        0       0   0    0         0          0           1
  161         0        0       0   0    0         0          0           0
  162         0        0       0   0    0         0          0           0
  163         0        0       0   0    0         0          0           0
  164         0        0       0   0    0         0          0           0
  165         0        0       1   0    0         0          0           0
  166         0        0       0   0    0         0          0           0
  167         0        0       0   0    0         0          0           0
  168         0        0       0   0    0         0          0           0
  169         0        0       0   0    0         0          0           0
  170         0        0       0   0    0         0          0           0
  171         0        0       0   0    0         0          0           0
  172         0        0       0   0    0         0          0           0
  173         0        0       0   0    0         0          0           0
  174         0        0       0   0    0         0          0           0
  175         0        0       0   0    0         0          0           0
  176         0        0       1   0    0         0          0           0
  177         1        0       0   0    0         0          0           0
  178         0        0       0   0    0         0          0           0
  179         0        0       0   0    0         0          0           0
  180         1        0       0   0    0         0          0           0
  181         0        0       0   0    0         0          0           0
  182         0        0       0   0    0         0          0           0
  183         0        0       0   0    0         0          0           0
  184         0        0       0   0    0         0          0           0
  185         0        0       0   0    0         0          0           0
  186         0        0       1   0    0         0          0           0
  187         0        0       1   0    0         0          0           0
  188         0        0       0   0    0         0          0           0
  189         0        0       0   0    0         0          0           0
  190         0        0       0   0    0         0          0           0
  191         0        0       0   0    0         0          0           0
  192         1        0       0   0    0         0          0           0
  193         0        0       1   0    0         0          0           0
  194         0        0       0   0    0         0          0           0
  195         0        0       0   0    0         0          0           0
  196         1        0       0   0    0         0          0           0
  197         1        0       1   0    0         0          0           0
  198         0        0       0   0    0         0          0           0
  199         0        0       1   0    0         0          0           0
  200         0        0       0   0    0         0          0           0
  201         0        0       0   0    0         0          0           0
  202         0        0       0   0    0         0          0           0
  203         1        0       0   0    0         0          0           0
  204         0        0       0   0    0         0          0           0
  205         0        0       0   0    0         0          0           0
  206         0        0       0   0    0         0          0           0
  207         1        0       0   0    0         0          0           0
  208         0        0       0   0    0         0          0           0
  209         0        0       0   0    0         0          0           0
  210         0        0       0   0    0         0          0           0
  211         0        1       0   0    0         0          0           0
  212         0        0       0   0    0         0          0           0
  213         0        1       0   0    0         0          0           0
  214         0        0       0   0    0         0          0           0
  215         0        0       0   0    0         0          0           1
  216         1        0       0   0    0         0          0           0
  217         0        0       0   0    0         0          0           0
  218         0        0       1   0    0         0          0           0
  219         0        0       0   0    0         0          0           0
  220         0        0       1   0    0         0          0           0
  221         0        0       0   0    0         0          0           0
  222         0        0       0   0    0         0          0           0
  223         0        0       0   0    0         0          0           0
  224         0        0       0   0    0         0          0           0
  225         0        0       0   0    0         0          0           0
  226         1        0       0   1    0         0          0           0
  227         0        0       0   0    0         0          0           0
  228         0        0       1   0    0         0          0           0
  229         0        0       0   0    0         0          0           0
  230         0        0       1   0    0         0          0           0
  231         0        1       1   0    0         0          0           0
  232         0        0       0   0    0         0          0           0
  233         0        0       0   0    0         0          0           0
  234         0        0       0   0    0         0          0           0
  235         0        0       1   0    0         0          0           0
  236         0        0       0   0    0         0          0           0
  237         0        0       0   0    0         0          0           0
  238         0        0       0   0    0         0          0           0
  239         0        0       0   0    0         0          0           0
  240         0        0       0   0    0         0          0           0
  241         0        0       0   0    0         0          0           0
  242         0        0       0   0    0         0          0           1
  243         0        0       1   0    0         0          0           0
  244         0        0       0   0    0         0          0           0
  245         0        0       0   0    0         0          0           0
  246         0        0       0   0    0         0          0           0
  247         0        0       0   0    0         0          0           0
  248         0        0       0   0    0         0          0           0
  249         0        0       0   0    0         0          0           0
  250         0        0       0   0    0         1          0           0
  251         0        0       0   0    0         0          0           0
  252         0        0       0   0    0         0          0           0
  253         0        0       0   0    0         0          0           0
  254         0        0       0   0    0         0          0           0
  255         0        0       0   0    0         0          0           0
  256         0        0       0   0    0         1          0           0
  257         0        0       0   0    0         0          0           0
  258         0        0       0   0    0         0          0           0
  259         0        0       0   0    0         0          0           0
  260         0        0       0   2    0         0          0           0
  261         0        0       0   0    0         0          0           0
  262         0        0       0   0    0         0          0           0
  263         0        0       0   0    0         0          0           0
  264         0        0       0   0    0         0          0           0
  265         0        0       0   0    0         0          0           0
  266         0        0       0   0    0         0          0           0
  267         0        0       0   0    0         1          1           0
  268         0        0       0   0    0         0          0           0
  269         0        0       0   0    0         0          0           0
  270         0        0       0   0    0         0          0           0
  271         0        0       0   0    0         0          0           0
  272         0        0       0   0    0         0          0           0
  273         0        0       0   0    0         0          0           0
  274         0        0       0   0    0         0          0           0
  275         0        0       0   0    0         0          0           0
  276         0        0       0   0    0         0          0           0
  277         0        0       0   0    0         0          0           0
  278         0        0       0   0    0         0          0           0
  279         0        0       0   0    0         0          0           0
  280         0        0       0   0    0         0          0           0
  281         0        0       0   0    0         0          0           0
  282         0        0       1   0    0         0          0           0
  283         0        0       0   0    0         0          0           0
  284         0        0       0   0    0         0          0           0
     Terms
Docs  different difficult doesnt done dont driven easy else employee
  1           0         0      0    0    0      0    0    1        0
  2           0         0      0    0    0      0    0    0        0
  3           1         0      0    0    0      0    0    0        0
  4           0         0      0    0    0      0    0    0        0
  5           0         0      0    0    0      0    0    0        0
  6           0         0      0    0    0      0    0    0        0
  7           0         0      0    0    0      0    0    0        0
  8           0         0      0    0    0      0    0    0        0
  9           0         0      0    0    0      0    0    0        1
  10          0         0      0    0    0      0    0    0        0
  11          0         0      0    0    0      0    0    0        0
  12          0         0      0    0    0      0    0    0        1
  13          0         0      0    0    0      0    0    0        0
  14          0         0      0    0    0      0    0    0        0
  15          0         0      0    0    0      0    0    0        0
  16          0         0      0    0    0      0    0    0        0
  17          0         0      0    0    0      0    0    0        0
  18          0         0      0    1    0      0    0    0        0
  19          0         0      0    2    0      0    0    0        0
  20          0         0      0    1    1      0    0    0        0
  21          0         0      0    0    0      0    0    0        0
  22          0         0      0    0    0      0    0    0        0
  23          0         0      0    0    0      0    0    0        0
  24          0         0      0    0    0      0    1    0        0
  25          0         0      0    0    0      0    0    0        0
  26          0         0      0    0    0      0    0    0        0
  27          0         0      0    0    0      0    0    0        1
  28          0         0      0    0    0      0    0    0        1
  29          0         0      0    0    0      0    0    0        0
  30          0         0      0    0    0      0    0    0        0
  31          0         0      0    0    0      0    0    0        0
  32          0         0      0    0    0      1    0    0        0
  33          0         0      0    0    0      0    0    0        0
  34          0         0      0    0    0      0    0    0        0
  35          0         0      0    0    0      0    0    0        0
  36          0         0      0    0    0      0    0    0        0
  37          0         0      0    0    2      0    0    0        0
  38          1         0      0    0    0      0    1    2        0
  39          0         0      0    0    0      1    0    0        0
  40          0         0      0    0    0      0    0    0        0
  41          0         0      0    0    0      0    0    0        0
  42          0         0      0    0    0      0    0    0        0
  43          0         0      0    0    0      0    0    1        0
  44          0         0      0    0    0      0    0    0        0
  45          0         0      1    0    0      0    0    0        0
  46          0         0      0    0    0      0    1    0        0
  47          1         0      0    0    0      0    0    0        0
  48          0         0      0    0    0      0    0    0        0
  49          0         0      0    0    0      0    0    0        0
  50          0         0      0    0    0      0    0    0        0
  51          0         0      0    1    1      0    0    0        0
  52          0         0      0    1    0      0    0    0        0
  53          0         0      0    0    0      0    0    0        0
  54          0         0      0    0    0      0    0    0        0
  55          0         0      0    0    0      0    0    0        0
  56          0         0      0    0    0      0    1    0        0
  57          0         0      0    0    0      0    0    1        0
  58          0         0      0    0    0      0    0    0        0
  59          0         0      0    0    0      0    0    0        0
  60          0         0      0    0    0      0    0    0        0
  61          0         0      0    0    0      0    0    0        0
  62          0         0      0    0    0      0    0    0        0
  63          0         0      0    0    0      0    0    0        0
  64          0         0      0    0    0      0    0    0        0
  65          0         0      0    0    0      0    0    0        0
  66          0         0      0    0    0      0    0    0        0
  67          0         0      0    0    0      0    0    0        0
  68          0         0      0    0    0      0    0    0        0
  69          0         0      0    0    0      0    0    0        0
  70          0         0      0    0    0      0    0    0        0
  71          0         0      0    0    0      0    0    0        0
  72          0         0      0    0    0      0    0    0        0
  73          0         0      0    0    1      0    0    0        0
  74          0         0      0    0    0      0    0    0        0
  75          0         0      0    0    0      0    0    0        0
  76          0         0      0    0    0      0    0    0        0
  77          0         0      0    0    0      0    0    0        0
  78          0         0      0    0    0      0    0    0        0
  79          0         0      0    0    0      1    0    0        0
  80          0         0      0    0    0      0    0    0        0
  81          0         0      0    0    0      0    0    0        0
  82          0         0      0    0    0      0    0    0        0
  83          0         0      0    0    0      0    0    0        0
  84          0         0      0    0    0      0    0    0        0
  85          0         0      0    0    0      0    0    0        0
  86          0         0      0    0    1      0    0    0        0
  87          0         0      0    0    0      0    0    0        0
  88          0         0      0    0    0      0    0    0        0
  89          0         0      0    0    0      0    0    0        0
  90          0         0      0    0    0      0    0    0        0
  91          0         0      0    0    0      0    0    0        0
  92          0         0      0    0    0      0    0    0        0
  93          0         0      0    0    0      0    0    0        0
  94          0         0      0    0    0      0    0    0        0
  95          0         0      0    0    0      0    0    0        0
  96          0         0      0    0    0      0    0    0        0
  97          0         0      0    0    0      0    0    0        0
  98          0         0      0    0    0      0    0    0        0
  99          0         0      0    0    0      0    0    0        0
  100         0         0      0    0    0      0    0    0        0
  101         0         0      0    0    0      0    0    0        0
  102         0         0      0    0    0      0    0    0        0
  103         0         0      0    0    0      1    0    0        0
  104         0         0      0    0    0      0    0    0        0
  105         0         0      0    0    0      0    0    1        0
  106         0         0      0    0    0      0    0    0        0
  107         0         0      0    0    0      0    0    0        0
  108         0         0      0    0    0      0    0    0        0
  109         0         0      0    0    0      0    0    0        0
  110         0         0      0    0    0      0    0    0        0
  111         0         0      0    0    0      0    0    0        0
  112         0         0      0    0    0      0    0    0        0
  113         0         0      0    0    0      0    0    0        0
  114         0         0      0    0    0      0    0    0        0
  115         0         0      0    0    0      0    0    0        0
  116         0         0      0    0    0      0    0    0        0
  117         0         0      0    0    0      0    0    0        0
  118         0         0      0    0    0      0    0    0        0
  119         0         0      0    0    0      0    0    0        0
  120         0         0      0    0    0      0    0    0        0
  121         0         0      0    0    0      0    0    0        0
  122         0         0      0    1    0      0    0    0        0
  123         0         0      0    0    0      0    0    0        0
  124         0         0      0    0    0      0    0    0        0
  125         0         0      0    0    0      0    0    0        0
  126         0         0      0    0    0      0    0    0        0
  127         0         0      0    0    0      0    0    0        0
  128         0         0      0    0    0      0    0    0        0
  129         0         0      0    0    0      0    0    0        0
  130         0         0      0    0    0      0    0    0        0
  131         0         0      0    1    0      0    1    0        0
  132         0         0      0    0    0      0    0    0        0
  133         2         0      0    0    1      0    0    0        0
  134         0         0      0    0    0      0    0    0        0
  135         0         0      0    0    0      0    0    0        0
  136         1         0      1    0    0      0    0    0        0
  137         0         0      0    0    0      0    0    0        0
  138         0         0      0    0    0      0    0    0        0
  139         0         0      0    0    0      0    0    0        0
  140         0         0      0    0    0      0    0    0        1
  141         0         0      0    0    0      0    0    0        0
  142         0         0      0    0    1      0    0    0        0
  143         0         0      0    0    0      0    0    0        0
  144         0         0      0    0    0      0    1    0        0
  145         0         0      0    0    0      0    0    0        0
  146         0         0      0    0    0      0    0    0        0
  147         0         0      0    0    0      0    0    0        0
  148         0         0      0    0    0      0    0    0        1
  149         0         0      0    0    0      0    0    0        0
  150         0         0      0    0    0      1    0    0        0
  151         0         0      0    2    0      1    0    0        0
  152         0         0      0    0    0      0    0    0        0
  153         0         0      0    0    0      0    0    0        0
  154         0         0      0    0    0      0    0    0        0
  155         0         0      0    0    0      0    0    0        0
  156         0         0      0    0    0      0    0    0        0
  157         0         0      0    0    0      0    0    0        0
  158         0         0      0    0    0      0    0    0        0
  159         0         0      0    0    0      0    0    0        0
  160         0         0      0    0    0      0    0    0        0
  161         0         0      0    0    0      0    0    0        0
  162         0         0      0    0    0      0    0    0        0
  163         0         0      0    0    0      0    0    0        0
  164         0         0      0    0    0      0    0    0        0
  165         0         0      0    0    0      0    0    0        0
  166         0         0      0    0    0      0    0    0        0
  167         1         0      0    0    0      0    0    0        0
  168         0         0      0    0    0      0    0    0        0
  169         0         0      0    0    0      0    0    0        0
  170         0         0      0    0    0      0    0    0        0
  171         0         0      0    0    0      0    0    0        0
  172         0         0      0    0    0      0    0    0        0
  173         0         0      0    0    0      0    0    0        0
  174         0         0      0    0    0      1    0    0        0
  175         0         0      0    0    0      0    2    0        0
  176         0         0      0    0    0      0    0    0        0
  177         0         0      0    0    0      0    0    0        0
  178         0         0      0    0    0      0    0    0        0
  179         0         0      0    0    0      0    0    0        0
  180         0         0      0    0    1      0    0    0        0
  181         0         0      0    0    0      0    0    0        0
  182         0         0      0    0    0      0    0    0        0
  183         0         0      0    0    0      0    0    0        0
  184         0         0      0    0    1      0    0    0        0
  185         0         0      0    0    0      0    0    0        0
  186         0         0      0    0    0      0    0    0        0
  187         0         0      0    0    0      0    0    0        0
  188         0         0      0    0    0      0    0    0        0
  189         0         0      0    0    0      0    0    0        1
  190         0         0      0    0    1      0    0    0        0
  191         0         0      0    0    0      0    0    0        0
  192         0         0      0    0    0      0    0    0        0
  193         0         0      0    0    0      0    0    0        0
  194         0         0      0    0    0      0    0    0        0
  195         0         0      0    0    0      0    0    0        0
  196         0         0      0    0    0      0    1    0        0
  197         0         0      0    0    0      0    0    0        0
  198         0         1      0    0    0      0    0    0        0
  199         0         0      0    0    0      0    0    0        0
  200         0         0      0    0    0      0    0    0        0
  201         0         0      0    0    0      0    0    0        0
  202         0         0      0    0    0      0    0    0        0
  203         0         0      0    0    0      0    0    0        0
  204         0         0      0    0    0      0    0    0        0
  205         0         0      0    0    0      0    0    0        0
  206         0         0      0    0    0      0    0    0        0
  207         0         0      0    0    0      0    0    0        0
  208         0         0      0    0    0      0    0    0        0
  209         0         0      0    0    0      0    0    0        0
  210         0         0      0    0    0      0    0    0        0
  211         0         0      0    0    0      0    0    0        0
  212         2         0      0    0    1      0    0    0        0
  213         0         0      0    0    0      0    0    0        0
  214         0         0      0    0    0      0    0    0        0
  215         0         0      0    0    0      0    0    0        0
  216         0         0      0    0    0      0    0    0        0
  217         0         0      0    0    0      0    0    0        0
  218         0         0      0    0    0      0    0    0        0
  219         0         0      0    0    0      0    0    0        0
  220         0         0      0    0    0      0    0    0        0
  221         1         0      0    0    0      0    0    0        0
  222         0         0      0    0    0      0    0    0        0
  223         0         0      0    0    0      0    0    0        0
  224         0         0      0    0    0      0    0    0        0
  225         0         0      0    0    0      1    0    0        0
  226         0         0      0    0    0      0    0    0        0
  227         0         0      0    0    0      0    0    0        1
  228         0         0      0    0    0      0    0    0        0
  229         0         0      0    0    0      0    0    0        0
  230         0         0      0    0    0      1    0    0        0
  231         0         0      0    0    0      0    0    0        0
  232         0         0      0    0    0      0    0    0        0
  233         1         0      0    0    0      0    2    0        0
  234         0         0      0    0    0      0    0    0        0
  235         0         0      0    1    0      0    0    0        0
  236         0         0      0    0    0      0    0    0        0
  237         0         0      0    0    0      0    1    0        0
  238         0         0      0    1    0      0    0    0        0
  239         0         0      0    0    0      0    0    0        0
  240         0         0      0    0    0      0    1    0        0
  241         0         0      0    0    0      0    0    0        0
  242         0         0      0    0    0      0    0    0        0
  243         0         0      0    0    0      0    0    0        0
  244         0         0      0    0    0      0    0    0        0
  245         0         0      0    0    0      0    0    0        0
  246         0         0      0    0    0      0    0    0        0
  247         0         0      0    0    0      0    0    0        0
  248         0         0      0    0    0      0    0    0        0
  249         0         0      0    0    0      0    0    0        0
  250         0         0      0    0    1      0    0    0        0
  251         0         0      0    0    0      0    0    0        0
  252         0         0      0    0    0      0    0    0        0
  253         0         0      0    0    0      0    0    0        0
  254         0         0      0    0    0      0    1    0        0
  255         0         1      0    0    0      0    0    0        0
  256         0         0      0    0    0      0    0    0        0
  257         0         0      0    0    0      0    0    0        0
  258         0         0      0    0    0      0    0    0        0
  259         0         0      0    0    0      0    0    0        0
  260         0         0      0    0    0      0    0    0        0
  261         0         0      0    0    0      0    0    0        0
  262         0         0      0    0    0      0    0    0        0
  263         0         0      0    0    0      0    0    0        0
  264         0         0      0    0    0      0    0    0        0
  265         0         1      0    1    0      0    0    0        0
  266         0         0      0    0    0      0    0    0        0
  267         0         0      0    0    0      0    0    0        0
  268         0         0      0    0    0      0    0    0        0
  269         0         0      0    0    0      0    0    0        0
  270         0         0      0    0    0      0    0    0        0
  271         0         0      0    0    0      0    0    0        0
  272         0         0      0    0    0      0    0    0        0
  273         0         1      0    0    0      0    0    0        0
  274         0         0      0    0    0      0    0    0        0
  275         0         1      0    0    0      0    0    0        0
  276         0         0      0    0    1      0    0    0        0
  277         0         0      0    0    0      0    0    0        0
  278         0         0      0    0    0      0    0    0        0
  279         0         0      0    0    0      0    0    0        0
  280         0         0      0    0    0      0    0    0        0
  281         0         0      0    0    0      0    0    0        0
  282         0         0      0    0    0      0    0    0        0
  283         0         0      0    0    0      0    0    0        0
  284         0         0      0    0    0      0    0    0        0
     Terms
Docs  employees end engineer engineering engineers enjoy enough
  1           0   0        0           0         0     0      0
  2           0   0        0           0         0     0      0
  3           0   0        0           0         0     0      0
  4           0   0        0           0         0     0      0
  5           0   0        0           0         0     0      0
  6           0   0        0           0         0     0      0
  7           0   0        0           0         0     0      0
  8           0   0        0           0         0     0      0
  9           0   0        0           0         0     0      0
  10          0   0        0           0         0     0      0
  11          0   0        0           0         0     0      0
  12          0   0        0           0         0     0      0
  13          0   0        0           0         0     0      0
  14          0   0        0           0         0     0      0
  15          0   0        0           0         0     0      0
  16          2   0        0           0         0     0      0
  17          0   0        0           0         0     0      0
  18          1   0        0           0         0     0      0
  19          1   0        0           0         0     0      0
  20          0   0        2           0         0     0      0
  21          0   0        0           0         0     0      0
  22          0   0        0           0         0     0      0
  23          0   0        0           0         2     0      0
  24          0   0        0           0         0     0      0
  25          0   0        0           0         0     0      0
  26          0   0        0           0         0     0      0
  27          0   0        0           0         0     0      0
  28          0   0        0           0         0     0      0
  29          0   0        0           1         0     0      0
  30          0   0        0           0         1     1      0
  31          0   0        0           0         0     0      0
  32          0   0        0           1         1     0      1
  33          0   1        0           0         0     0      0
  34          1   0        0           0         0     0      0
  35          0   0        0           0         0     0      0
  36          0   0        0           0         0     0      0
  37          0   0        0           0         0     0      0
  38          0   0        0           0         0     0      0
  39          0   0        0           0         0     0      0
  40          0   0        0           0         0     0      0
  41          0   0        0           0         0     0      0
  42          0   0        0           0         0     0      0
  43          0   0        0           0         2     0      0
  44          0   0        0           0         0     0      0
  45          0   0        0           0         1     0      0
  46          1   0        0           0         0     0      0
  47          0   0        0           0         1     0      0
  48          0   0        0           0         0     0      0
  49          0   0        0           0         0     0      0
  50          0   0        0           0         0     0      0
  51          0   0        0           0         3     0      0
  52          0   0        0           0         0     0      0
  53          0   0        0           0         0     0      0
  54          0   0        0           1         0     0      0
  55          0   0        0           0         2     0      0
  56          0   0        0           0         0     0      0
  57          0   0        0           0         0     0      0
  58          1   0        0           0         0     0      0
  59          0   0        0           0         0     0      0
  60          0   0        0           0         0     0      0
  61          0   0        0           0         0     0      0
  62          0   0        0           1         0     0      0
  63          1   0        0           0         0     0      0
  64          0   0        1           0         0     0      0
  65          2   0        0           0         0     1      0
  66          2   0        0           0         0     0      0
  67          0   0        0           0         0     0      0
  68          0   0        0           0         0     0      0
  69          0   0        0           0         0     0      0
  70          0   0        0           0         0     0      0
  71          0   0        0           0         0     0      0
  72          0   1        0           0         0     0      0
  73          0   0        0           0         0     0      0
  74          0   0        0           0         0     0      0
  75          0   0        0           0         0     0      0
  76          0   0        0           0         0     0      0
  77          0   0        0           0         0     0      0
  78          0   0        0           0         0     0      0
  79          0   0        0           0         0     0      0
  80          0   0        0           0         0     0      0
  81          0   0        0           0         1     0      0
  82          0   0        0           0         0     0      0
  83          0   0        0           0         0     0      0
  84          0   0        0           0         0     0      0
  85          0   0        0           0         0     0      0
  86          0   0        0           0         0     0      0
  87          0   0        0           0         1     0      0
  88          0   0        0           0         0     0      0
  89          0   0        0           0         0     0      0
  90          1   0        0           0         0     0      0
  91          0   0        0           0         0     0      0
  92          0   0        0           0         0     0      0
  93          0   0        0           0         0     0      0
  94          1   0        0           0         0     0      0
  95          0   0        0           0         0     0      0
  96          0   0        0           0         0     0      0
  97          0   0        0           0         0     0      0
  98          0   0        0           0         0     0      0
  99          0   0        1           0         1     0      0
  100         0   0        0           0         0     0      0
  101         0   0        0           0         0     0      0
  102         0   0        0           0         0     0      0
  103         0   0        0           0         0     0      0
  104         0   0        0           0         0     0      0
  105         0   0        0           0         0     0      0
  106         0   0        0           0         0     0      0
  107         0   0        0           1         0     0      0
  108         0   0        0           0         0     0      0
  109         0   0        0           0         0     0      0
  110         0   0        0           0         0     0      0
  111         0   0        0           0         0     0      0
  112         0   0        0           0         0     0      0
  113         0   0        0           0         0     0      0
  114         0   0        0           0         1     0      0
  115         0   0        0           1         0     0      0
  116         0   0        0           0         0     0      0
  117         0   0        0           0         0     0      0
  118         0   0        0           0         0     0      0
  119         0   0        0           0         0     0      0
  120         0   0        0           0         0     0      0
  121         0   0        0           1         0     0      0
  122         0   0        0           0         0     0      0
  123         0   0        0           0         0     0      0
  124         0   0        0           0         0     0      0
  125         0   0        0           0         0     0      0
  126         1   0        0           0         0     0      0
  127         0   0        0           0         0     0      0
  128         0   0        0           0         0     0      0
  129         0   0        0           0         0     0      0
  130         0   0        0           0         0     0      0
  131         1   0        0           0         0     0      0
  132         0   0        0           0         1     0      0
  133         0   0        1           0         0     0      0
  134         0   0        0           0         0     0      0
  135         1   0        1           0         0     0      0
  136         1   0        0           0         0     0      0
  137         0   0        0           1         0     0      0
  138         0   0        0           0         0     0      0
  139         1   0        0           0         0     0      0
  140         0   0        0           0         0     0      0
  141         0   0        0           0         0     0      0
  142         0   0        0           0         0     0      0
  143         0   0        0           0         0     0      0
  144         0   0        0           0         0     0      0
  145         1   0        0           0         0     0      0
  146         0   0        0           0         0     0      0
  147         0   0        0           0         0     0      0
  148         0   0        0           0         0     0      0
  149         0   0        0           0         0     0      0
  150         1   0        0           0         0     0      0
  151         0   0        0           0         0     0      0
  152         0   0        0           0         0     0      0
  153         0   0        0           0         0     0      0
  154         0   0        0           0         0     0      0
  155         0   0        0           0         0     0      0
  156         0   0        0           0         0     0      0
  157         0   0        0           0         0     0      0
  158         0   0        0           0         0     0      0
  159         0   0        0           0         0     0      0
  160         0   0        0           1         0     0      0
  161         0   0        0           1         0     0      0
  162         0   0        0           0         0     0      0
  163         0   0        0           0         0     0      0
  164         1   0        0           0         0     0      0
  165         0   0        0           0         0     0      0
  166         1   0        0           0         0     0      0
  167         0   0        0           0         0     0      0
  168         0   0        0           0         0     0      0
  169         0   0        0           0         0     0      0
  170         0   0        0           0         0     0      0
  171         0   0        0           0         0     0      0
  172         0   0        0           0         0     0      0
  173         0   0        0           0         0     0      0
  174         0   0        0           0         0     0      0
  175         0   0        0           1         0     0      0
  176         0   0        0           0         0     0      0
  177         0   0        0           0         0     0      0
  178         0   0        0           0         0     0      0
  179         0   0        0           0         0     0      0
  180         0   0        0           0         0     0      0
  181         0   0        0           0         0     0      0
  182         0   0        0           0         0     0      0
  183         0   0        0           0         0     0      0
  184         0   0        0           0         0     0      0
  185         0   0        0           0         0     0      0
  186         0   0        0           0         0     0      0
  187         0   0        0           0         0     0      0
  188         2   0        0           0         0     0      0
  189         2   0        0           0         0     0      0
  190         0   0        2           0         0     0      0
  191         0   0        0           0         0     0      0
  192         0   0        0           0         0     0      0
  193         1   0        0           0         0     0      0
  194         0   0        0           0         0     0      0
  195         0   0        0           0         0     0      0
  196         0   0        0           0         0     0      0
  197         0   0        0           0         0     0      0
  198         0   0        0           0         0     0      2
  199         0   0        0           0         0     0      0
  200         0   0        0           0         0     0      0
  201         0   0        0           0         0     0      0
  202         0   0        0           0         0     0      0
  203         0   0        0           0         0     0      0
  204         0   0        0           0         0     0      0
  205         0   0        0           0         0     0      0
  206         0   0        0           0         0     0      0
  207         0   0        0           0         0     0      0
  208         0   0        0           0         0     0      0
  209         0   0        0           0         0     0      0
  210         0   0        0           0         0     0      0
  211         1   0        0           0         0     0      0
  212         0   0        0           0         0     0      0
  213         0   0        0           0         0     0      0
  214         0   0        0           0         0     0      0
  215         0   0        0           0         0     0      0
  216         0   0        0           0         0     0      0
  217         0   0        0           0         0     0      0
  218         0   0        0           0         0     0      0
  219         0   0        0           1         0     0      0
  220         1   0        0           0         0     0      0
  221         0   0        0           0         0     0      0
  222         0   0        0           0         0     0      0
  223         0   0        0           0         0     0      0
  224         0   0        0           0         0     0      0
  225         0   0        0           0         0     0      0
  226         1   0        0           0         0     1      0
  227         1   0        0           0         0     0      0
  228         0   0        0           0         0     0      0
  229         0   0        0           0         0     0      0
  230         0   0        0           0         0     0      0
  231         0   0        0           0         0     0      0
  232         1   0        0           0         0     0      0
  233         0   0        0           0         0     0      0
  234         0   0        0           0         0     0      1
  235         1   0        0           0         0     0      0
  236         0   0        0           0         0     0      0
  237         0   0        0           0         0     0      0
  238         0   0        0           0         0     0      0
  239         0   0        0           0         0     0      0
  240         0   0        0           0         1     0      0
  241         0   1        0           0         0     0      0
  242         0   0        0           0         0     0      0
  243         1   0        0           0         0     0      0
  244         0   0        0           0         0     0      0
  245         0   0        0           0         0     0      0
  246         1   0        0           0         0     0      0
  247         0   0        0           0         0     0      0
  248         0   0        0           0         0     0      0
  249         0   0        0           0         0     0      0
  250         0   0        0           0         0     0      0
  251         0   0        0           0         0     0      0
  252         0   0        0           0         0     0      0
  253         0   0        0           0         0     0      0
  254         0   0        0           0         0     0      0
  255         0   0        0           0         0     0      0
  256         0   0        0           0         0     0      0
  257         0   0        1           0         0     0      0
  258         0   0        0           0         1     0      0
  259         0   0        0           0         0     0      0
  260         0   0        0           0         0     0      0
  261         0   0        0           0         0     0      0
  262         0   0        0           0         1     0      0
  263         0   0        1           0         0     0      0
  264         0   0        0           0         0     0      0
  265         0   0        0           0         0     0      0
  266         0   0        0           0         0     0      0
  267         0   0        0           0         0     0      0
  268         0   0        0           0         0     0      0
  269         1   0        0           0         0     0      0
  270         1   1        0           0         0     0      0
  271         0   0        0           0         0     0      0
  272         0   0        0           0         0     0      0
  273         0   0        0           0         0     0      0
  274         0   0        0           0         0     0      0
  275         0   0        0           0         0     0      0
  276         0   0        0           0         0     0      1
  277         1   0        0           0         0     0      1
  278         1   0        0           0         0     0      0
  279         0   0        0           0         0     0      0
  280         1   0        0           0         0     0      1
  281         0   0        0           0         0     0      0
  282         0   0        0           0         0     0      0
  283         0   0        0           0         0     0      0
  284         0   0        0           0         0     0      0
     Terms
Docs  environment etc even ever every everyone everything excellent
  1             0   0    0    0     0        0          0         0
  2             0   0    0    0     0        0          0         0
  3             0   0    0    0     0        0          0         0
  4             0   0    0    0     0        0          0         0
  5             0   1    0    0     0        0          0         0
  6             0   0    0    0     0        0          0         0
  7             0   0    0    0     1        0          0         0
  8             1   0    0    0     1        0          0         0
  9             0   0    0    0     0        0          0         0
  10            0   0    0    0     1        0          0         0
  11            0   0    0    0     1        0          0         0
  12            0   1    0    0     0        0          0         1
  13            1   0    1    0     0        2          0         0
  14            0   0    0    0     0        0          0         0
  15            0   0    1    0     0        0          0         0
  16            0   0    0    0     0        0          0         0
  17            1   0    0    0     0        0          0         0
  18            0   0    0    1     0        0          0         0
  19            1   0    0    0     0        0          0         0
  20            0   0    0    0     0        0          0         0
  21            0   0    0    0     1        0          0         1
  22            0   0    0    0     0        0          0         0
  23            0   0    0    0     0        0          0         0
  24            0   0    0    0     0        0          0         0
  25            0   0    0    0     0        0          0         0
  26            0   0    0    0     0        0          0         0
  27            0   0    0    0     1        0          0         1
  28            0   0    0    0     0        1          0         0
  29            0   0    0    1     1        0          0         0
  30            0   0    0    0     0        0          0         0
  31            0   0    0    1     0        1          1         0
  32            0   0    0    0     0        0          0         0
  33            1   0    0    0     0        0          0         0
  34            0   0    0    0     0        0          0         0
  35            0   0    0    0     0        0          0         0
  36            0   0    0    0     0        0          0         0
  37            0   0    0    0     0        0          0         0
  38            0   0    0    0     0        0          0         0
  39            0   0    0    0     1        0          0         1
  40            0   0    0    0     0        0          0         0
  41            0   0    0    0     0        1          1         0
  42            0   0    0    0     0        0          0         0
  43            0   0    0    0     0        0          0         0
  44            0   0    0    0     0        0          0         0
  45            0   0    0    1     0        0          0         0
  46            0   0    0    0     0        0          0         0
  47            0   1    0    1     0        0          0         0
  48            0   0    0    0     0        1          0         0
  49            0   0    0    0     0        0          0         0
  50            0   0    0    0     0        0          0         0
  51            0   0    0    0     0        0          0         0
  52            0   0    0    0     0        0          0         0
  53            0   0    0    0     0        0          0         0
  54            0   0    0    0     0        0          1         0
  55            0   0    0    0     0        0          0         0
  56            0   0    0    0     0        0          0         0
  57            0   0    0    0     0        0          0         0
  58            0   0    0    0     0        0          0         0
  59            0   0    0    0     0        0          0         0
  60            0   0    0    0     0        0          0         0
  61            0   0    2    0     0        0          0         0
  62            0   0    0    0     0        0          0         0
  63            1   0    1    0     0        0          0         0
  64            0   0    0    0     0        0          0         0
  65            0   0    0    0     0        0          0         0
  66            0   0    0    0     0        0          0         0
  67            0   0    0    0     0        0          0         0
  68            0   0    0    0     0        0          0         0
  69            1   1    0    0     0        0          0         0
  70            1   0    0    0     0        0          0         0
  71            0   0    0    1     0        0          0         0
  72            0   0    0    0     0        0          0         0
  73            0   0    1    0     0        0          0         0
  74            0   0    0    0     0        0          0         0
  75            0   0    0    0     0        0          0         0
  76            3   0    0    0     0        1          0         0
  77            0   0    0    0     0        0          0         0
  78            0   0    0    0     0        0          0         0
  79            1   0    0    1     0        0          0         0
  80            2   0    0    0     0        0          0         0
  81            0   0    0    0     0        0          0         0
  82            0   0    0    0     0        0          0         0
  83            1   0    0    0     0        0          0         0
  84            0   0    0    0     0        0          0         0
  85            0   0    0    0     0        0          0         0
  86            1   0    0    0     0        0          0         0
  87            0   0    0    0     0        0          0         0
  88            0   0    0    1     0        0          0         0
  89            0   0    0    0     0        0          0         0
  90            0   0    0    0     0        0          0         0
  91            0   0    0    0     0        0          0         0
  92            0   0    0    0     0        0          0         0
  93            0   0    0    0     0        0          0         0
  94            0   0    0    0     1        0          0         0
  95            0   0    0    0     0        0          0         0
  96            0   0    0    0     0        0          0         0
  97            0   0    0    0     0        0          0         0
  98            0   0    0    0     0        0          0         0
  99            0   0    0    0     0        0          0         0
  100           0   0    0    1     0        0          0         0
  101           0   0    0    0     0        0          0         0
  102           0   0    0    0     0        0          0         1
  103           0   0    0    0     0        0          0         0
  104           0   0    0    0     1        0          0         0
  105           0   0    0    1     0        0          0         0
  106           0   0    0    0     0        0          0         0
  107           0   0    0    0     0        0          0         0
  108           1   1    0    0     0        0          0         0
  109           0   0    0    0     2        0          0         1
  110           0   0    0    0     0        0          0         0
  111           0   0    0    0     0        0          0         0
  112           0   0    0    0     0        0          0         0
  113           1   0    0    0     0        0          0         0
  114           0   0    0    0     0        0          0         0
  115           0   0    0    1     0        0          0         0
  116           0   0    0    0     0        0          0         0
  117           0   0    0    0     0        0          0         0
  118           0   0    0    0     0        0          0         0
  119           0   0    0    0     0        0          0         0
  120           1   0    0    0     1        0          0         0
  121           0   0    0    0     0        0          0         0
  122           0   0    0    0     0        0          0         0
  123           0   0    0    0     0        0          0         0
  124           0   0    0    0     0        0          0         0
  125           0   0    0    0     0        0          0         0
  126           0   0    0    0     0        0          0         0
  127           0   0    0    0     0        0          0         0
  128           0   0    0    0     0        0          0         0
  129           0   0    0    0     0        0          0         0
  130           0   0    0    0     0        0          0         0
  131           0   0    0    0     0        0          0         0
  132           0   0    0    0     0        0          0         0
  133           0   0    1    0     0        0          0         0
  134           1   0    0    1     0        3          0         0
  135           0   0    0    0     0        0          0         0
  136           0   0    0    0     0        0          0         0
  137           0   0    0    0     0        1          0         0
  138           0   0    0    0     0        0          0         0
  139           0   0    0    0     0        0          0         0
  140           1   0    0    0     0        0          0         0
  141           0   0    0    0     0        0          0         0
  142           0   0    0    0     0        1          0         0
  143           0   0    1    0     0        0          0         0
  144           0   0    0    0     0        0          0         0
  145           0   0    0    0     0        0          0         0
  146           0   0    0    0     0        0          0         0
  147           0   0    0    0     0        0          0         0
  148           0   0    1    0     0        0          0         0
  149           0   0    0    0     0        0          0         0
  150           0   0    0    0     0        0          0         0
  151           0   0    0    0     0        0          0         0
  152           0   0    0    0     0        0          0         0
  153           0   0    0    0     0        1          0         0
  154           0   0    0    0     0        0          0         0
  155           0   0    0    0     0        0          0         0
  156           0   0    0    0     0        0          0         0
  157           0   0    0    0     0        0          0         1
  158           0   0    0    0     0        0          0         0
  159           1   0    0    0     0        1          1         1
  160           0   0    0    0     0        0          0         0
  161           0   0    0    0     0        1          0         1
  162           0   0    0    0     0        0          0         0
  163           0   0    0    0     0        0          0         0
  164           0   0    0    0     0        0          0         0
  165           0   0    0    0     0        0          0         0
  166           0   0    0    0     0        0          0         0
  167           1   0    0    0     0        0          0         0
  168           0   1    0    0     0        0          0         0
  169           0   2    0    0     0        0          0         0
  170           1   0    0    0     0        0          0         0
  171           0   0    0    0     0        0          0         0
  172           0   0    0    0     0        0          0         0
  173           0   0    0    0     0        0          0         0
  174           1   0    0    0     0        0          0         1
  175           0   0    0    0     0        0          0         0
  176           0   0    0    0     0        0          0         0
  177           1   0    0    0     0        0          0         0
  178           0   0    0    0     0        0          0         0
  179           0   0    0    1     0        0          0         0
  180           0   0    0    0     0        0          0         0
  181           0   0    0    0     0        0          0         1
  182           0   0    0    0     0        0          0         0
  183           0   0    0    0     0        0          0         0
  184           0   0    0    0     0        0          0         0
  185           0   0    0    0     0        0          0         0
  186           0   0    0    0     0        0          0         0
  187           0   0    0    0     0        0          0         0
  188           0   0    0    0     0        0          0         0
  189           0   0    0    0     0        0          0         0
  190           0   0    1    0     0        0          0         0
  191           0   0    0    0     0        0          0         0
  192           0   0    0    0     0        0          0         0
  193           0   0    0    0     0        0          0         0
  194           0   0    0    0     0        0          0         1
  195           0   0    0    0     0        0          0         0
  196           0   0    0    0     0        0          0         0
  197           1   0    0    0     0        0          0         0
  198           0   0    0    1     0        0          0         0
  199           0   0    1    0     0        0          0         0
  200           0   0    0    0     0        0          0         1
  201           0   0    0    0     0        0          0         0
  202           0   0    0    0     0        0          0         0
  203           0   0    0    0     0        0          0         0
  204           0   0    0    0     0        2          0         0
  205           0   0    0    0     0        0          0         0
  206           0   0    0    0     0        0          0         0
  207           0   0    0    0     0        0          0         1
  208           0   1    0    0     0        1          0         0
  209           1   0    0    0     0        0          0         1
  210           0   0    0    0     0        0          0         0
  211           1   0    0    0     0        0          0         0
  212           0   0    0    0     0        0          0         0
  213           0   0    0    0     0        0          0         1
  214           0   0    0    0     0        1          0         0
  215           0   0    0    0     0        0          0         0
  216           0   0    0    1     0        0          0         0
  217           2   0    0    0     0        0          0         0
  218           0   0    0    0     0        0          0         0
  219           0   0    0    0     0        0          0         0
  220           0   0    0    0     0        0          0         0
  221           0   0    0    0     0        1          0         0
  222           0   0    0    0     0        0          0         0
  223           1   0    0    0     0        1          0         0
  224           0   0    0    0     0        0          0         0
  225           0   0    0    0     0        0          0         0
  226           0   0    0    0     1        0          0         0
  227           0   0    0    0     0        0          0         0
  228           1   0    0    0     0        0          0         0
  229           0   0    0    0     0        0          0         1
  230           0   0    0    0     0        0          0         0
  231           0   0    0    0     0        0          0         0
  232           0   0    0    0     0        0          0         0
  233           0   0    0    0     0        0          0         0
  234           0   0    0    0     0        0          0         0
  235           0   0    0    0     1        0          0         0
  236           1   0    0    0     0        0          0         0
  237           1   1    1    0     0        0          0         0
  238           1   0    0    0     0        0          0         0
  239           1   0    0    0     0        0          0         0
  240           0   0    0    1     0        0          0         0
  241           0   0    0    0     1        0          0         0
  242           0   0    0    0     0        0          0         0
  243           0   0    0    0     0        0          0         0
  244           0   0    0    0     0        0          0         0
  245           0   0    0    0     0        0          0         0
  246           0   0    0    0     0        0          0         0
  247           1   0    0    0     0        0          0         0
  248           0   0    0    0     0        0          0         0
  249           0   0    0    0     0        0          0         0
  250           0   0    0    0     0        0          0         0
  251           1   0    0    0     0        0          0         0
  252           0   0    0    0     0        0          0         0
  253           0   0    0    0     0        0          0         0
  254           0   0    0    0     0        0          0         0
  255           0   0    0    0     0        0          0         0
  256           0   0    0    0     0        0          0         0
  257           0   0    0    0     0        0          0         0
  258           0   0    1    0     0        0          0         0
  259           0   0    0    0     0        0          0         0
  260           0   0    0    0     0        0          0         0
  261           0   0    0    0     0        0          0         0
  262           0   0    0    0     0        0          0         0
  263           0   0    0    0     0        0          0         0
  264           0   0    0    0     0        0          0         0
  265           0   0    0    0     0        0          0         0
  266           0   0    0    0     0        0          0         0
  267           0   0    1    0     0        0          0         0
  268           0   0    0    0     0        0          0         0
  269           0   0    0    0     0        0          0         0
  270           0   0    0    0     0        0          0         0
  271           0   0    0    0     0        0          0         0
  272           0   0    0    0     0        1          0         0
  273           0   0    0    0     0        0          0         0
  274           0   0    0    0     0        0          0         0
  275           1   0    0    0     0        1          0         0
  276           0   0    0    0     0        0          0         0
  277           0   0    1    0     0        0          0         0
  278           0   0    0    0     0        0          0         0
  279           0   0    0    0     0        0          0         0
  280           0   0    0    0     0        0          0         0
  281           0   0    0    0     0        0          0         0
  282           0   0    0    0     0        0          0         0
  283           0   0    0    0     0        0          0         0
  284           0   0    0    0     0        0          0         0
     Terms
Docs  exciting expect expected experience extremely fast feedback feel
  1          0      0        0          0         0    0        0    0
  2          0      0        0          0         0    0        0    0
  3          0      0        0          0         0    0        0    0
  4          0      0        0          0         0    0        0    0
  5          0      0        0          0         0    0        0    0
  6          0      0        0          0         0    0        0    0
  7          0      0        0          0         0    0        0    0
  8          0      0        0          0         0    0        0    0
  9          0      0        0          0         0    0        0    0
  10         0      0        0          0         0    0        0    0
  11         0      0        0          0         0    0        0    0
  12         0      0        0          0         0    0        0    0
  13         0      0        0          0         0    0        0    1
  14         0      0        0          0         0    0        0    0
  15         0      0        0          0         0    0        0    0
  16         0      0        0          1         0    0        0    0
  17         0      0        0          0         0    0        0    0
  18         0      0        0          0         0    0        0    0
  19         0      0        0          0         0    1        0    0
  20         0      0        0          0         0    0        0    0
  21         0      0        0          0         0    0        0    1
  22         0      0        0          0         0    0        0    0
  23         0      0        0          0         0    0        0    0
  24         0      0        0          0         0    0        0    0
  25         0      0        0          0         0    0        0    0
  26         0      0        0          0         0    0        0    0
  27         0      0        0          0         0    0        0    0
  28         0      0        0          0         0    0        0    0
  29         0      0        0          0         0    0        0    0
  30         0      0        0          0         0    0        0    0
  31         0      0        0          0         0    0        0    0
  32         0      0        0          0         0    0        0    0
  33         0      0        0          0         0    1        0    0
  34         0      0        0          0         0    0        0    0
  35         0      0        0          0         0    0        0    0
  36         0      0        0          0         0    0        0    0
  37         0      0        0          0         0    0        0    2
  38         0      0        0          0         0    0        0    0
  39         0      0        0          1         0    0        0    3
  40         0      0        0          0         0    0        0    0
  41         0      0        0          1         0    0        0    0
  42         0      0        0          0         0    0        0    0
  43         0      0        0          0         1    0        0    0
  44         0      0        0          0         0    0        0    0
  45         0      0        0          0         1    0        0    0
  46         0      0        0          0         0    0        0    0
  47         1      0        0          0         0    0        0    0
  48         0      0        0          0         0    0        0    0
  49         0      0        0          0         0    0        0    0
  50         0      0        0          0         0    0        0    0
  51         0      0        0          0         1    0        0    0
  52         0      0        0          0         0    0        0    0
  53         0      0        0          0         0    0        0    0
  54         0      0        0          0         0    0        0    0
  55         0      0        0          0         0    0        0    0
  56         0      0        0          0         0    0        0    0
  57         0      0        0          0         1    0        0    0
  58         0      0        0          0         0    0        0    0
  59         0      0        0          0         0    0        0    0
  60         0      0        0          0         0    0        0    0
  61         0      0        0          0         0    0        0    0
  62         0      0        0          0         0    0        0    0
  63         0      0        0          0         0    0        0    0
  64         0      0        0          0         0    0        0    0
  65         0      0        0          0         0    0        0    1
  66         0      0        0          0         0    0        0    0
  67         0      0        0          0         1    0        0    0
  68         0      0        0          0         0    0        0    0
  69         1      0        0          0         0    0        0    0
  70         0      0        0          0         0    0        0    0
  71         0      0        0          0         0    0        0    0
  72         0      0        0          0         0    0        0    0
  73         0      0        0          0         0    0        0    0
  74         0      0        0          0         0    0        0    0
  75         0      0        0          0         0    0        0    0
  76         0      0        0          0         0    0        0    0
  77         0      0        0          0         0    0        1    0
  78         0      0        0          0         0    0        0    0
  79         0      0        0          0         0    0        0    0
  80         0      0        0          0         0    0        0    0
  81         0      0        0          0         0    0        0    0
  82         0      0        0          1         0    0        0    0
  83         0      0        0          0         0    0        0    0
  84         0      0        0          0         0    0        0    0
  85         0      0        0          0         0    0        0    0
  86         0      0        0          0         0    0        0    0
  87         0      0        0          0         0    0        0    0
  88         0      0        0          0         0    0        0    1
  89         0      0        0          0         0    0        0    0
  90         0      0        0          0         0    1        0    0
  91         0      0        0          0         0    0        0    0
  92         0      0        0          0         0    0        0    0
  93         0      0        0          0         0    0        0    0
  94         0      0        0          0         0    0        0    1
  95         0      0        0          0         0    0        0    0
  96         0      0        0          0         0    0        0    0
  97         0      0        0          0         0    0        0    0
  98         0      0        0          0         0    0        0    0
  99         0      0        0          0         0    0        0    0
  100        0      0        0          0         0    0        0    0
  101        0      0        0          0         0    0        0    0
  102        0      0        0          0         0    0        0    0
  103        0      0        0          0         0    1        0    0
  104        0      0        0          0         0    0        1    0
  105        0      0        0          1         0    0        0    0
  106        0      0        0          0         0    0        0    0
  107        0      0        0          0         0    0        0    0
  108        0      0        0          0         0    0        0    0
  109        0      0        0          0         0    0        1    0
  110        0      0        0          0         1    0        0    0
  111        0      0        0          0         0    0        0    0
  112        0      0        0          0         0    0        0    0
  113        0      0        0          0         0    0        0    0
  114        0      0        0          0         0    0        0    0
  115        0      0        0          0         0    1        0    0
  116        0      0        0          0         0    0        0    0
  117        0      0        0          0         0    0        0    1
  118        0      0        0          0         0    0        0    0
  119        0      0        0          1         0    0        0    0
  120        0      0        0          0         0    0        0    0
  121        0      0        0          0         0    0        0    2
  122        0      0        0          0         0    0        0    0
  123        0      0        0          0         0    0        0    0
  124        0      0        0          0         0    0        0    0
  125        0      0        0          0         0    0        0    0
  126        0      0        0          0         0    0        0    0
  127        0      0        0          0         0    0        0    0
  128        0      0        0          0         0    0        0    0
  129        0      0        0          0         0    0        0    0
  130        0      0        0          0         0    0        0    0
  131        0      0        0          0         0    0        0    0
  132        0      0        0          0         0    0        0    0
  133        0      0        0          0         0    0        0    0
  134        0      0        0          0         0    0        0    0
  135        0      0        0          0         0    0        0    0
  136        0      0        0          0         0    0        0    0
  137        0      0        0          0         0    0        0    0
  138        0      0        0          0         0    0        0    0
  139        0      0        0          0         0    0        0    0
  140        0      0        0          0         0    1        0    0
  141        0      0        0          1         0    0        0    0
  142        0      0        0          0         0    0        0    0
  143        0      0        0          0         0    0        0    0
  144        0      0        0          0         0    0        0    0
  145        0      0        0          0         0    0        0    0
  146        0      0        0          0         0    0        0    0
  147        0      0        0          0         0    0        0    0
  148        0      0        0          0         0    0        0    0
  149        0      0        0          0         0    0        0    0
  150        0      0        0          0         0    0        0    0
  151        0      0        0          0         0    0        0    0
  152        0      0        0          0         0    0        0    0
  153        0      0        0          0         0    0        0    0
  154        0      0        0          0         0    0        0    0
  155        0      0        0          0         0    0        0    0
  156        0      0        0          0         0    0        0    0
  157        0      0        0          0         0    0        0    0
  158        1      0        0          0         0    0        0    0
  159        0      0        0          0         0    0        0    0
  160        0      0        0          0         0    0        0    0
  161        0      0        0          0         0    0        0    1
  162        0      0        0          0         0    0        0    0
  163        0      0        0          0         0    0        0    0
  164        0      0        0          0         0    0        0    0
  165        0      0        0          0         0    0        0    0
  166        0      0        0          0         0    0        0    0
  167        0      0        0          0         0    0        0    0
  168        0      0        0          0         0    0        0    0
  169        0      0        0          0         0    0        0    0
  170        0      0        0          0         0    1        0    0
  171        0      0        0          0         0    0        0    0
  172        0      0        0          0         0    0        0    0
  173        0      0        0          1         0    0        0    0
  174        0      0        0          0         0    0        0    0
  175        0      0        0          0         0    0        0    0
  176        0      0        0          0         0    0        0    0
  177        0      0        0          0         0    0        0    0
  178        0      0        0          0         0    0        0    1
  179        0      0        0          1         0    0        0    0
  180        0      0        0          0         0    0        0    0
  181        0      0        0          0         0    0        0    0
  182        0      0        0          0         0    0        0    0
  183        0      0        0          0         0    0        0    0
  184        0      0        0          0         0    0        0    1
  185        0      0        0          0         0    0        0    0
  186        0      0        0          0         0    0        0    0
  187        0      0        0          0         0    0        0    0
  188        0      0        0          0         0    0        0    0
  189        0      0        0          0         0    0        0    1
  190        0      0        0          0         0    0        0    0
  191        0      0        0          0         0    0        0    0
  192        1      0        0          0         0    0        0    0
  193        0      0        0          0         0    0        0    0
  194        0      0        0          0         0    0        0    0
  195        0      0        0          0         0    0        0    0
  196        0      0        0          0         0    0        0    0
  197        0      0        0          0         0    0        0    0
  198        0      0        0          0         0    0        0    0
  199        0      0        0          0         0    0        0    0
  200        0      0        0          0         0    0        0    0
  201        0      0        0          0         0    0        0    0
  202        0      0        0          0         0    0        0    0
  203        0      0        0          0         0    0        0    0
  204        0      0        0          0         0    0        0    0
  205        0      0        0          0         0    0        0    0
  206        0      0        0          0         0    0        0    0
  207        0      0        0          0         0    0        0    0
  208        0      0        0          0         0    0        0    0
  209        1      0        0          0         0    0        0    0
  210        0      0        0          0         0    0        0    0
  211        0      0        0          0         0    0        0    0
  212        0      0        0          0         0    0        0    0
  213        0      0        0          0         1    1        0    0
  214        0      0        0          0         0    0        0    0
  215        0      0        0          0         0    0        0    0
  216        0      0        0          0         0    0        0    0
  217        0      0        0          0         0    0        0    0
  218        0      0        0          0         0    0        0    0
  219        0      0        0          0         0    0        0    0
  220        0      0        0          0         0    0        0    0
  221        0      0        0          0         1    0        0    0
  222        0      0        0          0         0    0        0    0
  223        0      0        0          0         0    0        0    0
  224        0      0        0          0         0    0        0    0
  225        0      0        0          0         0    0        0    0
  226        0      0        0          0         0    0        0    0
  227        0      0        0          0         0    0        1    0
  228        0      0        0          0         0    0        0    0
  229        0      0        0          0         0    0        0    0
  230        0      0        0          0         0    0        0    0
  231        1      1        0          0         0    0        0    0
  232        0      0        0          0         0    0        0    0
  233        0      0        0          0         0    0        0    0
  234        0      0        0          0         0    0        0    0
  235        0      0        0          0         0    0        0    0
  236        0      0        0          0         0    0        0    0
  237        0      0        0          0         0    0        0    0
  238        0      0        0          0         0    0        0    0
  239        0      0        0          0         0    0        0    0
  240        0      0        0          0         0    0        0    0
  241        0      0        0          0         0    0        0    0
  242        0      0        0          0         0    0        0    0
  243        0      0        0          2         0    0        0    0
  244        0      0        0          0         0    0        0    0
  245        0      0        0          0         0    0        0    0
  246        0      0        0          0         0    0        0    0
  247        0      0        0          0         0    0        0    0
  248        0      0        0          0         0    0        0    0
  249        0      0        0          0         0    0        0    0
  250        0      0        0          0         0    0        0    0
  251        0      0        0          0         0    0        0    0
  252        0      0        0          0         0    0        0    0
  253        0      0        0          0         0    0        0    0
  254        0      0        0          0         0    0        0    1
  255        0      0        1          0         0    0        0    0
  256        0      0        0          0         0    0        0    0
  257        0      0        0          0         0    0        0    0
  258        0      0        0          1         0    0        0    0
  259        0      0        0          0         0    0        0    0
  260        0      0        0          0         0    0        0    0
  261        0      0        0          1         0    0        0    0
  262        0      0        0          0         1    0        0    0
  263        0      0        0          0         0    0        0    0
  264        0      0        0          0         0    0        0    0
  265        0      0        0          0         0    0        0    0
  266        0      0        0          0         0    0        0    0
  267        0      0        0          0         0    0        0    0
  268        0      0        0          0         0    0        0    0
  269        0      0        0          0         0    0        0    0
  270        0      0        0          0         0    0        0    0
  271        0      0        0          0         0    0        0    0
  272        0      0        0          0         0    0        0    0
  273        0      0        0          0         0    0        0    1
  274        0      0        0          0         0    0        0    0
  275        0      0        0          0         0    0        0    0
  276        0      0        0          0         0    0        0    0
  277        0      0        1          0         1    0        0    0
  278        0      0        0          0         0    0        0    0
  279        0      0        0          0         0    0        0    0
  280        0      0        0          1         0    0        0    0
  281        0      0        0          1         0    0        0    0
  282        0      0        0          0         0    0        0    0
  283        0      0        0          0         0    0        0    0
  284        0      0        0          0         0    0        0    0
     Terms
Docs  find first flat flexibility flexible focus food free freedom fresh
  1      0     1    0           0        0     0    0    0       0     0
  2      0     0    0           0        0     0    0    0       0     0
  3      0     0    0           0        0     0    0    0       0     0
  4      0     0    0           0        1     0    0    0       0     0
  5      0     0    0           0        0     0    1    1       0     0
  6      0     0    0           0        0     0    0    0       0     0
  7      0     0    0           0        0     0    0    0       0     0
  8      0     0    0           0        0     0    0    0       0     0
  9      0     0    0           0        0     0    0    0       0     0
  10     0     0    0           0        1     0    1    0       0     0
  11     0     0    0           0        0     0    1    1       0     0
  12     0     0    0           0        0     0    1    1       0     0
  13     0     1    0           0        0     0    0    0       0     0
  14     0     0    0           0        0     0    0    0       0     0
  15     0     0    0           0        0     0    0    1       0     0
  16     0     0    0           0        0     0    0    0       0     0
  17     0     0    0           0        0     0    0    0       0     0
  18     0     0    0           0        0     0    0    0       0     0
  19     0     0    0           0        0     0    0    0       0     0
  20     0     0    0           0        0     0    0    0       0     0
  21     0     0    0           0        0     0    0    0       0     0
  22     0     0    0           0        0     0    0    0       0     0
  23     0     0    0           1        0     1    0    0       0     0
  24     0     0    0           0        0     0    0    0       0     0
  25     0     0    0           0        0     0    0    0       0     0
  26     0     0    0           0        0     0    0    0       0     0
  27     0     0    0           0        0     0    0    0       0     0
  28     0     0    0           0        0     0    0    0       0     0
  29     0     0    0           0        0     0    0    0       0     0
  30     0     1    0           0        0     0    0    0       0     0
  31     0     0    0           0        0     0    1    0       0     0
  32     0     0    0           0        0     0    0    0       1     0
  33     0     1    0           0        0     0    0    1       0     0
  34     0     0    0           0        0     0    0    0       0     0
  35     0     0    0           0        0     0    0    0       0     0
  36     0     0    0           0        0     0    0    1       0     0
  37     0     0    0           0        0     0    1    2       0     0
  38     1     0    0           0        0     0    0    0       0     0
  39     0     0    0           0        0     0    0    0       0     0
  40     0     0    0           0        0     0    0    0       1     0
  41     0     0    0           0        0     0    0    0       0     0
  42     0     0    0           0        0     0    0    0       0     0
  43     0     0    0           0        0     0    0    0       1     0
  44     0     0    0           0        0     0    2    1       0     0
  45     0     0    0           0        0     0    1    1       0     0
  46     0     0    0           0        0     0    1    1       0     0
  47     0     0    0           0        0     0    0    0       0     0
  48     0     0    0           0        0     0    1    0       0     0
  49     0     0    0           0        0     0    0    0       0     0
  50     0     0    0           0        0     0    0    0       0     0
  51     0     0    0           0        0     0    0    0       0     0
  52     0     0    0           0        0     0    0    0       0     0
  53     0     0    0           0        0     0    1    1       0     0
  54     0     0    0           0        0     0    0    0       0     0
  55     0     0    0           1        0     0    0    0       0     0
  56     0     0    0           0        0     0    0    0       0     0
  57     0     0    0           0        0     0    2    0       0     0
  58     0     0    0           0        0     0    0    0       0     0
  59     0     0    0           0        0     0    0    0       0     0
  60     0     0    0           0        0     0    1    0       0     0
  61     0     0    0           0        0     0    0    0       0     0
  62     0     0    0           0        0     0    0    0       0     0
  63     0     0    0           0        0     0    1    4       0     0
  64     0     0    0           0        0     0    0    0       0     0
  65     0     0    0           0        0     0    0    0       0     0
  66     0     0    0           0        0     0    0    0       0     0
  67     0     0    0           0        1     0    1    0       0     0
  68     0     0    0           0        0     0    0    0       0     0
  69     0     0    0           0        0     0    1    1       0     0
  70     0     0    0           0        0     0    0    0       0     0
  71     0     0    0           0        0     0    0    0       0     0
  72     1     0    0           0        0     0    0    0       0     0
  73     1     0    0           0        0     0    0    0       0     0
  74     0     0    0           0        0     0    0    0       0     0
  75     0     0    0           0        0     0    0    0       0     0
  76     0     0    0           0        0     0    0    0       0     0
  77     0     0    0           0        0     0    0    0       0     0
  78     0     0    0           0        0     0    1    0       0     0
  79     0     0    0           0        0     0    0    0       0     0
  80     0     0    0           0        0     0    0    0       0     0
  81     0     0    0           0        0     0    1    1       0     0
  82     0     0    0           0        0     0    0    0       0     0
  83     0     0    0           0        0     0    1    0       0     0
  84     0     0    0           0        0     0    0    0       0     0
  85     0     0    0           0        0     0    1    1       0     0
  86     0     0    0           0        0     0    0    0       0     0
  87     0     0    0           0        0     0    0    0       0     0
  88     0     0    0           0        0     0    1    0       0     0
  89     0     0    0           0        0     0    0    0       0     0
  90     0     0    0           0        0     0    0    0       0     0
  91     0     0    0           0        0     0    1    1       0     0
  92     0     0    0           0        0     0    0    0       0     0
  93     0     0    0           0        0     0    0    0       0     0
  94     0     0    0           0        0     0    0    0       0     1
  95     0     0    0           0        0     0    0    1       0     0
  96     0     0    0           0        0     0    0    0       0     0
  97     0     0    0           0        0     0    0    0       0     0
  98     0     0    0           0        0     0    0    0       0     0
  99     0     0    0           0        0     0    0    0       0     0
  100    0     0    0           0        0     0    0    0       0     0
  101    0     0    0           0        0     0    0    0       0     0
  102    0     0    0           0        0     0    1    0       0     0
  103    0     0    0           0        0     0    0    0       0     0
  104    0     0    0           0        0     0    0    0       0     0
  105    0     0    0           0        0     0    0    0       0     0
  106    0     0    0           0        0     0    0    0       0     0
  107    0     0    0           0        0     0    0    0       0     0
  108    0     0    0           0        0     0    0    0       0     0
  109    0     0    0           0        0     0    1    1       0     0
  110    0     0    0           0        0     0    0    0       0     0
  111    0     0    0           0        0     0    0    1       0     0
  112    0     0    0           0        0     0    0    0       0     0
  113    0     0    0           0        0     0    0    1       1     0
  114    0     0    0           0        0     0    0    0       1     0
  115    0     0    0           0        0     0    0    0       0     0
  116    0     0    0           0        0     0    1    0       0     0
  117    0     0    0           0        0     0    0    0       0     0
  118    0     0    0           0        0     0    0    0       0     0
  119    0     0    0           0        0     0    0    0       0     0
  120    0     0    0           0        0     0    1    0       0     0
  121    0     0    0           0        0     0    0    0       0     0
  122    0     0    0           0        0     0    0    0       0     0
  123    0     0    0           0        0     0    1    0       0     0
  124    0     0    0           0        0     0    1    0       0     0
  125    0     0    0           0        0     0    0    0       0     0
  126    0     0    0           0        0     0    0    0       0     0
  127    0     0    0           0        0     0    0    0       0     0
  128    0     0    0           0        0     0    0    0       0     0
  129    0     0    0           0        0     0    0    0       0     0
  130    0     0    0           0        0     0    0    1       0     0
  131    0     0    0           0        0     0    0    0       0     0
  132    0     0    0           0        0     0    0    1       0     0
  133    0     0    0           0        0     0    1    1       0     0
  134    0     0    0           0        0     0    0    0       0     0
  135    0     0    0           0        0     0    0    0       0     0
  136    0     0    0           0        0     0    0    0       0     0
  137    0     0    0           0        0     0    0    0       0     0
  138    0     0    0           0        0     0    0    0       0     0
  139    0     0    0           0        0     0    0    0       0     0
  140    0     0    1           0        0     0    1    1       0     0
  141    0     0    0           0        0     0    0    0       0     0
  142    0     0    0           0        0     0    0    0       0     0
  143    0     0    0           0        0     0    0    0       0     0
  144    0     0    0           0        0     0    0    0       0     0
  145    0     0    0           0        0     0    0    0       0     0
  146    0     0    0           0        0     0    1    0       0     0
  147    0     0    0           0        0     0    0    0       0     0
  148    1     0    0           0        0     0    0    0       0     0
  149    0     0    0           0        0     0    0    0       0     0
  150    0     0    0           0        0     0    0    0       0     0
  151    0     0    0           0        0     0    0    0       0     0
  152    0     0    0           0        0     0    0    0       0     0
  153    0     0    0           0        0     2    0    0       0     0
  154    0     0    0           0        0     0    0    0       0     0
  155    0     0    0           0        0     0    0    2       0     0
  156    0     0    0           0        0     0    0    0       0     0
  157    0     0    0           0        0     0    0    0       0     0
  158    0     0    0           0        0     0    0    0       0     0
  159    0     0    0           0        0     0    0    0       0     0
  160    0     0    0           0        0     1    0    0       0     0
  161    0     0    0           0        0     0    0    0       0     0
  162    0     0    0           0        0     0    1    1       0     0
  163    0     0    0           0        0     0    0    0       0     0
  164    0     0    0           0        0     0    0    0       0     0
  165    0     0    0           0        0     0    1    0       1     0
  166    0     0    0           0        0     0    0    0       0     0
  167    0     0    0           0        0     0    0    0       0     0
  168    0     0    0           0        0     0    1    1       0     0
  169    0     0    0           0        0     0    1    0       0     0
  170    0     0    0           0        0     0    0    0       0     0
  171    0     0    0           1        0     0    0    0       0     0
  172    0     0    0           0        0     0    1    1       0     0
  173    0     0    0           0        0     0    0    0       0     0
  174    0     0    0           0        0     0    0    0       0     0
  175    1     0    0           0        0     0    0    0       0     0
  176    0     0    0           0        0     0    0    0       0     0
  177    0     0    0           0        0     0    0    0       0     0
  178    0     0    0           0        0     0    0    1       0     0
  179    0     0    0           0        0     0    0    0       0     0
  180    0     0    0           0        0     0    0    0       0     0
  181    0     0    0           0        0     0    0    0       0     0
  182    0     0    0           0        0     0    0    0       0     0
  183    0     0    0           0        0     0    1    1       0     0
  184    0     0    0           0        0     0    1    1       0     0
  185    0     0    0           0        0     0    1    0       0     0
  186    0     0    0           0        0     0    0    0       0     0
  187    0     0    0           0        0     0    0    0       0     0
  188    0     0    0           0        0     0    0    0       0     0
  189    0     0    0           0        0     0    0    0       0     0
  190    0     0    0           0        0     0    0    0       0     0
  191    0     0    0           0        0     0    0    0       0     0
  192    0     0    0           0        0     0    0    0       0     0
  193    0     0    0           0        0     0    0    0       0     0
  194    0     0    0           0        0     0    0    0       0     0
  195    0     0    0           0        0     0    0    0       0     0
  196    0     0    0           0        0     0    0    0       0     0
  197    0     0    0           1        0     0    0    1       0     0
  198    0     0    0           0        0     0    0    0       0     0
  199    0     1    0           0        0     0    0    0       0     0
  200    0     0    0           0        0     0    0    0       0     0
  201    0     0    0           0        0     0    0    0       0     0
  202    0     0    0           0        0     0    0    0       0     0
  203    0     0    0           0        0     0    1    1       1     0
  204    0     0    0           0        0     0    2    1       0     0
  205    0     0    0           0        0     0    0    0       0     0
  206    0     0    0           0        0     0    0    0       0     0
  207    0     0    0           0        0     0    0    0       0     0
  208    0     0    0           0        0     0    1    0       0     0
  209    0     0    0           0        0     0    0    0       0     0
  210    0     0    0           0        0     0    0    0       0     0
  211    0     0    0           0        0     0    0    0       0     1
  212    0     0    0           0        0     0    0    0       0     0
  213    0     0    0           0        1     0    1    1       0     0
  214    0     0    0           0        0     0    0    0       0     0
  215    0     0    0           0        0     0    0    0       0     0
  216    0     0    0           0        0     0    0    0       0     0
  217    0     0    0           0        0     0    0    0       0     0
  218    0     0    0           0        0     0    0    0       0     0
  219    0     0    0           0        0     0    0    0       0     0
  220    0     0    0           1        0     0    0    0       0     0
  221    1     0    0           0        0     0    0    0       0     0
  222    0     0    0           0        0     0    1    1       0     0
  223    0     0    0           0        0     0    0    0       0     0
  224    0     0    0           0        0     0    0    0       0     0
  225    0     0    0           0        0     0    0    0       0     0
  226    0     0    0           0        0     0    0    0       0     0
  227    0     0    0           0        0     0    0    0       1     0
  228    0     0    0           1        0     0    0    0       0     0
  229    0     0    0           0        0     0    1    1       0     0
  230    0     0    0           0        0     0    0    0       0     0
  231    0     0    0           0        0     0    0    0       0     0
  232    0     0    0           0        0     0    0    2       0     0
  233    0     0    0           0        0     0    0    0       0     0
  234    0     0    0           0        0     0    0    0       0     0
  235    0     0    0           0        0     0    0    0       0     0
  236    0     0    0           0        0     0    1    1       0     0
  237    0     0    0           0        0     1    0    0       0     0
  238    0     0    0           0        0     0    0    0       0     0
  239    0     0    0           0        0     0    0    0       0     0
  240    0     0    0           0        0     0    0    0       0     0
  241    0     0    0           0        0     0    1    0       0     0
  242    0     0    0           0        0     0    0    0       0     0
  243    0     0    0           0        0     0    0    1       0     0
  244    0     0    0           0        0     0    1    1       0     0
  245    0     0    0           0        0     0    0    0       0     0
  246    0     0    0           0        0     0    0    0       0     0
  247    0     0    0           0        0     0    0    0       0     0
  248    0     0    0           0        0     0    0    0       0     0
  249    0     0    0           0        0     0    0    0       0     0
  250    0     0    0           0        0     0    0    0       0     0
  251    0     0    0           0        0     0    0    0       0     0
  252    0     0    0           0        0     0    0    0       0     0
  253    0     0    0           0        0     0    0    0       0     0
  254    1     0    0           0        0     0    0    0       0     0
  255    0     0    0           0        0     0    0    0       0     0
  256    0     0    0           0        0     0    0    0       0     0
  257    0     0    0           0        0     0    0    0       0     0
  258    0     0    0           0        0     0    0    0       0     0
  259    0     0    0           0        0     0    0    0       0     0
  260    0     0    0           0        0     0    0    0       0     0
  261    0     0    0           0        0     0    0    0       0     0
  262    0     0    0           0        0     0    0    0       0     0
  263    0     0    0           1        0     0    0    0       0     0
  264    0     0    0           0        0     1    0    0       0     0
  265    0     0    0           0        0     0    0    0       0     0
  266    0     0    0           0        0     0    0    0       0     0
  267    0     0    0           0        0     0    0    0       0     0
  268    0     0    0           0        0     0    0    0       0     0
  269    0     0    0           0        0     0    0    0       0     0
  270    0     0    0           0        0     0    0    0       0     0
  271    0     0    0           0        0     0    0    0       0     0
  272    0     0    0           0        0     0    0    0       0     0
  273    0     0    0           0        0     0    0    0       0     0
  274    0     0    0           0        0     1    0    0       0     0
  275    0     0    0           0        0     0    0    0       0     0
  276    1     0    0           0        0     0    0    0       0     0
  277    0     0    0           0        0     0    0    0       0     1
  278    0     0    0           0        0     0    0    0       0     0
  279    0     0    0           0        0     0    0    0       0     0
  280    0     0    0           0        0     0    0    0       0     0
  281    0     0    0           0        0     0    0    0       0     1
  282    0     0    0           0        0     0    0    0       0     0
  283    0     0    0           0        0     0    0    0       0     0
  284    0     0    0           0        0     0    0    0       0     0
     Terms
Docs  friendly full fun game general generally get getting give given go
  1          0    0   0    0       0         0   1       0    0     0  0
  2          0    0   0    0       0         0   0       0    0     0  0
  3          0    0   0    0       0         0   0       0    0     0  0
  4          0    0   0    0       0         0   0       0    0     0  0
  5          0    0   0    0       0         0   0       0    0     0  0
  6          0    0   0    0       0         0   0       0    0     0  0
  7          0    0   0    0       0         0   0       0    0     0  0
  8          0    0   0    0       0         0   0       0    0     0  0
  9          0    0   0    0       0         0   0       0    0     0  0
  10         0    0   1    0       0         0   0       0    0     0  0
  11         0    0   0    0       0         0   0       0    0     0  0
  12         0    0   0    1       0         0   0       0    0     0  0
  13         0    0   0    0       0         0   0       0    0     0  1
  14         0    0   0    0       0         0   0       0    0     0  0
  15         0    0   0    0       0         0   0       0    0     0  0
  16         0    0   0    0       0         0   0       0    0     0  0
  17         0    0   0    0       0         0   0       0    0     0  0
  18         0    0   0    0       0         0   0       0    0     0  0
  19         0    0   0    0       0         0   2       0    0     0  0
  20         0    0   0    0       0         0   1       0    0     0  0
  21         0    0   0    0       0         0   0       0    0     0  0
  22         0    0   0    0       0         0   0       0    0     0  0
  23         0    0   0    0       0         0   0       0    0     0  0
  24         0    0   0    0       0         0   0       0    0     0  0
  25         0    0   0    0       0         0   0       0    0     0  0
  26         0    0   0    0       0         0   0       0    0     0  0
  27         0    0   0    0       0         0   0       0    0     0  0
  28         0    0   0    0       0         0   0       1    0     0  0
  29         0    0   0    0       0         0   0       0    0     0  0
  30         0    0   2    0       0         0   0       0    0     0  0
  31         0    0   0    0       0         0   0       0    1     0  0
  32         0    0   0    0       0         1   0       0    0     1  0
  33         0    0   0    0       0         0   0       0    0     0  0
  34         0    0   0    0       0         0   0       0    0     0  0
  35         0    0   0    0       0         1   1       0    0     0  0
  36         0    0   0    0       0         0   0       0    0     0  0
  37         0    0   1    0       0         0   1       0    0     0  1
  38         0    0   0    0       0         0   0       0    0     0  0
  39         0    0   0    0       0         0   1       0    0     0  0
  40         0    0   0    0       0         0   0       0    0     0  0
  41         0    0   0    0       0         0   0       0    0     0  0
  42         0    0   1    0       0         0   1       0    0     0  0
  43         0    0   0    0       0         0   1       0    0     0  0
  44         0    0   0    0       1         0   0       0    0     0  0
  45         0    0   0    0       0         0   2       0    0     0  0
  46         0    0   1    0       0         0   0       0    0     0  1
  47         0    0   0    1       0         0   1       0    0     0  0
  48         0    0   0    0       0         0   0       0    0     0  0
  49         0    0   0    0       0         0   0       0    0     0  0
  50         0    0   1    0       0         0   0       0    0     0  0
  51         0    0   0    0       0         0   1       1    1     0  0
  52         0    0   0    0       0         0   0       0    0     0  0
  53         0    0   0    0       0         0   0       0    0     0  1
  54         0    0   0    0       0         0   0       0    0     0  0
  55         0    0   0    0       0         0   0       0    0     0  0
  56         0    0   0    0       0         0   0       0    0     0  0
  57         0    0   0    0       0         0   0       0    0     0  0
  58         0    1   0    0       0         0   0       0    0     0  0
  59         0    0   0    0       0         0   0       0    0     0  0
  60         0    0   0    0       0         0   0       0    0     0  0
  61         0    0   0    0       1         0   0       0    0     0  0
  62         0    0   0    0       0         0   0       0    0     0  0
  63         0    0   0    0       0         0   0       0    0     0  0
  64         0    0   0    0       1         0   0       0    0     0  0
  65         0    0   0    0       1         0   1       0    0     0  0
  66         0    0   0    0       0         0   0       0    0     0  0
  67         0    0   0    0       0         0   0       0    0     0  0
  68         0    0   0    0       0         0   0       0    0     0  0
  69         0    0   0    0       0         0   0       0    0     0  0
  70         0    0   0    0       0         0   0       0    0     0  0
  71         0    0   0    0       0         0   0       0    0     0  0
  72         0    0   0    0       0         0   0       0    0     0  0
  73         0    0   0    0       0         0   1       0    0     0  0
  74         0    0   0    0       0         0   0       0    0     0  0
  75         0    0   0    0       0         0   0       0    0     0  0
  76         0    0   0    0       0         0   0       0    0     0  0
  77         0    0   0    0       0         0   0       0    0     0  0
  78         0    0   0    0       0         0   0       0    0     0  0
  79         0    0   0    0       0         0   0       0    0     0  0
  80         0    0   1    0       0         1   0       0    0     0  0
  81         0    0   0    0       0         0   0       0    0     0  0
  82         0    0   0    0       0         0   0       1    0     0  0
  83         0    0   0    0       0         0   0       0    0     0  0
  84         0    0   1    0       0         0   0       0    0     0  0
  85         0    0   0    0       0         0   0       0    0     0  0
  86         0    0   0    0       0         0   0       0    0     0  0
  87         0    0   0    0       0         0   0       1    0     0  0
  88         0    0   0    0       0         0   0       0    0     0  0
  89         0    0   0    0       0         0   0       0    0     0  0
  90         0    0   0    0       0         0   0       0    0     0  0
  91         0    0   0    0       0         0   0       0    0     0  0
  92         0    0   0    0       0         0   0       0    0     0  0
  93         0    0   0    0       0         0   0       0    0     0  0
  94         0    0   0    0       0         0   0       0    0     0  0
  95         0    0   0    0       0         0   0       0    0     0  0
  96         0    0   0    0       0         0   0       0    0     0  0
  97         0    0   0    0       0         0   0       0    0     0  0
  98         0    0   0    0       0         0   0       0    0     0  0
  99         0    0   0    0       0         0   0       0    0     0  1
  100        0    0   0    0       0         0   0       0    0     0  0
  101        0    0   0    0       0         0   0       0    0     1  0
  102        0    0   0    0       0         0   0       0    0     0  0
  103        1    0   0    0       0         0   0       0    0     0  0
  104        0    0   0    0       0         0   0       0    0     0  0
  105        1    0   0    0       0         0   0       0    0     0  0
  106        0    0   0    0       0         0   0       0    0     0  0
  107        0    0   0    0       0         0   0       0    0     0  0
  108        0    0   0    0       0         0   0       0    0     0  0
  109        0    0   0    0       0         0   0       0    0     0  0
  110        0    0   0    0       0         0   0       0    0     0  0
  111        0    0   0    0       0         0   0       0    0     1  0
  112        0    0   0    0       0         0   0       0    0     0  0
  113        0    0   0    0       0         0   0       0    1     0  0
  114        0    0   0    0       0         0   0       0    0     0  0
  115        0    0   0    0       0         0   0       0    0     0  0
  116        0    0   0    0       0         0   0       0    0     0  0
  117        0    0   0    0       0         0   0       0    0     0  0
  118        0    0   0    0       0         0   0       0    0     0  0
  119        0    0   1    0       0         0   0       0    0     0  0
  120        0    0   0    0       0         0   1       0    0     0  0
  121        1    0   0    0       0         0   0       0    0     0  0
  122        0    0   0    0       0         0   1       0    0     0  0
  123        0    0   0    0       0         0   0       0    0     0  0
  124        0    0   0    0       0         0   0       0    0     0  0
  125        2    0   0    0       0         0   0       0    0     0  0
  126        0    0   0    0       0         0   0       0    0     0  0
  127        0    0   0    0       0         0   0       0    0     0  0
  128        0    1   1    0       0         0   0       0    1     0  0
  129        0    0   0    0       0         0   0       1    0     0  0
  130        0    0   0    0       0         0   0       0    0     0  0
  131        0    1   0    0       0         0   0       0    0     0  0
  132        0    0   0    0       0         0   0       0    0     0  0
  133        0    0   0    0       0         0   0       0    0     0  0
  134        0    0   1    0       0         1   0       0    0     0  0
  135        0    0   0    0       0         0   0       0    0     0  0
  136        0    0   1    0       0         0   0       0    0     0  0
  137        0    0   0    0       0         0   0       0    0     0  0
  138        0    0   1    0       0         0   0       0    0     0  0
  139        0    0   0    0       0         0   0       0    0     0  0
  140        0    0   0    0       0         0   0       0    0     0  0
  141        1    0   0    0       0         0   0       0    0     0  0
  142        0    0   0    0       0         0   0       0    0     0  0
  143        0    0   0    0       0         0   0       0    0     0  0
  144        0    0   1    0       0         0   0       0    0     0  0
  145        0    0   0    0       0         0   0       0    0     0  0
  146        0    0   1    0       0         0   0       0    0     0  0
  147        0    0   0    0       0         0   0       0    0     0  0
  148        0    0   0    0       0         0   0       0    0     0  0
  149        0    0   0    0       0         0   0       0    0     0  0
  150        0    0   0    0       0         0   0       0    0     0  0
  151        0    0   0    0       0         0   0       1    0     0  0
  152        0    0   0    0       0         0   0       0    0     0  0
  153        0    0   0    0       0         0   0       0    0     0  0
  154        0    0   0    0       0         0   0       0    0     0  0
  155        0    0   0    1       0         0   0       0    0     0  0
  156        0    0   0    0       0         0   0       0    0     0  0
  157        0    0   0    0       0         0   0       0    0     0  0
  158        0    0   0    0       0         0   0       0    0     0  0
  159        0    0   0    0       0         0   0       0    0     0  0
  160        0    0   0    0       0         0   0       0    0     0  0
  161        0    0   0    0       0         0   0       0    0     0  0
  162        0    0   0    0       0         0   0       0    0     0  0
  163        0    0   0    0       0         0   0       0    0     1  0
  164        0    0   1    0       0         0   0       0    0     0  0
  165        0    0   0    1       0         0   0       0    0     0  0
  166        0    0   0    0       0         0   0       0    0     0  0
  167        0    0   1    0       0         0   0       0    0     0  0
  168        0    0   0    0       0         0   0       0    0     0  0
  169        0    0   0    0       0         0   0       0    0     0  0
  170        0    0   0    0       0         0   0       0    0     0  0
  171        0    0   0    0       0         0   0       0    0     0  0
  172        0    0   0    0       0         0   0       0    0     0  0
  173        0    0   0    0       0         0   0       0    0     0  0
  174        0    0   0    0       0         0   0       0    0     0  0
  175        0    0   0    0       0         0   1       0    0     0  0
  176        0    0   1    0       0         0   0       0    0     0  0
  177        0    0   2    0       0         0   0       0    0     0  0
  178        0    0   0    0       0         0   0       0    0     0  0
  179        0    0   0    0       0         0   0       0    0     0  0
  180        0    0   0    0       0         0   1       0    0     0  0
  181        0    0   0    0       0         0   0       0    0     0  0
  182        0    0   0    0       0         0   1       0    0     0  0
  183        1    0   0    0       0         0   0       0    0     0  0
  184        0    0   0    0       0         0   0       0    0     0  0
  185        0    0   0    0       0         0   0       0    0     0  0
  186        0    0   0    0       0         0   0       0    0     0  0
  187        0    0   0    0       0         0   0       0    0     0  0
  188        0    0   0    0       0         0   0       0    0     0  0
  189        0    0   0    0       0         0   0       0    0     0  0
  190        0    0   0    0       0         0   1       0    0     0  1
  191        0    0   0    0       0         0   0       0    0     0  0
  192        0    0   0    0       0         0   0       0    0     0  0
  193        0    0   0    0       0         0   0       1    0     0  0
  194        0    0   0    0       0         0   0       0    0     0  0
  195        0    0   0    0       0         0   0       0    0     0  0
  196        0    0   0    0       0         0   0       0    0     0  0
  197        0    0   1    0       0         0   0       0    0     0  0
  198        0    0   0    0       0         0   2       0    0     0  0
  199        0    0   0    0       0         0   0       0    0     0  0
  200        0    0   0    0       0         0   0       0    0     0  0
  201        0    0   0    0       0         0   1       0    0     0  0
  202        0    0   1    0       0         0   1       0    0     0  0
  203        0    0   0    0       0         0   0       0    0     0  0
  204        0    0   0    0       0         0   0       0    0     0  0
  205        0    0   0    0       0         0   0       0    0     0  0
  206        0    0   0    0       0         0   0       0    0     0  0
  207        0    0   0    0       0         0   0       0    0     0  0
  208        0    0   0    1       0         0   0       0    0     0  0
  209        0    0   0    0       0         0   1       0    0     0  0
  210        0    0   0    0       0         0   0       0    0     0  0
  211        0    0   0    0       0         0   0       0    0     1  0
  212        0    0   0    0       0         0   0       0    0     0  0
  213        0    0   0    0       0         0   0       0    0     0  0
  214        1    0   0    0       0         0   0       0    0     0  0
  215        0    0   0    0       0         0   0       0    0     0  0
  216        0    0   0    0       0         0   0       0    0     0  0
  217        0    0   1    0       0         0   0       0    0     0  0
  218        0    0   0    0       0         0   0       0    0     0  0
  219        0    0   0    0       0         0   0       0    0     0  0
  220        1    0   0    0       0         0   0       0    0     0  0
  221        0    0   0    0       0         0   0       0    0     0  0
  222        0    0   0    0       0         0   0       0    0     0  0
  223        0    0   0    0       0         0   0       0    0     0  0
  224        0    0   0    0       0         0   0       0    0     0  0
  225        0    0   0    0       0         0   0       0    0     0  0
  226        0    0   1    0       0         0   0       0    0     0  0
  227        0    0   0    0       0         0   0       0    0     0  0
  228        0    0   0    0       0         0   0       0    0     0  0
  229        0    0   1    0       0         0   0       0    0     0  0
  230        0    0   0    0       0         0   0       0    0     0  0
  231        0    0   0    0       0         0   0       0    0     0  0
  232        0    0   0    0       0         0   0       0    0     0  0
  233        1    0   0    0       0         1   0       0    0     0  0
  234        1    0   1    0       0         1   0       0    0     0  0
  235        0    0   0    0       0         0   0       0    0     0  0
  236        0    0   0    0       0         0   0       0    0     0  0
  237        0    0   0    0       0         0   0       0    0     0  0
  238        0    0   0    0       0         0   1       0    0     0  0
  239        0    0   0    0       0         0   0       0    0     0  0
  240        0    0   0    0       0         0   0       0    0     0  0
  241        0    0   0    1       0         1   0       0    0     0  0
  242        0    0   0    0       0         0   0       0    0     0  0
  243        0    0   0    0       0         0   0       0    0     0  0
  244        0    0   0    0       0         0   0       0    0     0  0
  245        0    0   1    0       0         0   0       0    0     0  0
  246        0    0   0    0       0         0   0       0    0     0  0
  247        0    0   0    0       0         0   0       0    0     0  0
  248        0    0   0    0       0         0   1       0    0     0  0
  249        0    0   0    0       0         0   1       0    0     0  0
  250        0    0   0    0       0         0   1       0    0     0  0
  251        1    0   0    0       0         0   0       0    0     0  0
  252        0    0   0    0       0         0   0       0    0     0  0
  253        0    0   0    0       0         0   0       0    0     0  0
  254        0    0   0    0       0         0   0       0    0     0  0
  255        0    0   0    0       0         0   0       0    0     0  0
  256        0    0   0    0       0         0   0       0    0     0  0
  257        0    0   0    0       0         0   0       0    0     0  0
  258        0    1   0    0       0         0   0       0    0     1  0
  259        0    0   0    0       0         0   1       0    0     0  0
  260        0    0   0    0       0         0   0       0    0     0  0
  261        0    0   0    0       0         0   0       0    0     0  0
  262        0    0   0    0       0         0   0       0    0     0  0
  263        0    0   0    0       0         0   0       0    0     0  0
  264        0    0   0    0       0         0   0       0    0     0  0
  265        0    0   0    0       0         0   1       0    0     0  0
  266        0    0   0    0       0         0   0       0    0     0  0
  267        0    0   0    0       0         0   0       0    0     0  0
  268        0    0   0    0       0         0   0       0    0     0  0
  269        0    0   0    0       0         0   0       0    0     0  0
  270        0    0   0    0       0         0   0       0    0     0  0
  271        0    0   0    0       0         0   0       0    0     0  0
  272        0    0   0    0       0         0   0       0    0     0  0
  273        0    0   0    0       0         0   0       0    0     0  0
  274        0    0   0    0       0         0   0       0    0     0  0
  275        0    0   0    0       0         0   0       0    0     0  0
  276        0    0   0    0       0         0   0       0    0     0  0
  277        0    0   0    0       0         0   0       0    0     0  0
  278        0    0   0    0       0         0   0       1    0     0  0
  279        0    0   0    0       0         0   0       0    0     0  0
  280        0    0   0    0       0         0   0       0    0     0  0
  281        0    0   0    0       0         0   0       0    0     0  0
  282        0    0   0    0       0         0   0       0    0     0  0
  283        0    0   0    0       0         0   0       0    0     0  0
  284        0    0   0    0       0         0   0       0    0     0  0
     Terms
Docs  going good google got gourmet great group groups growth hard help
  1       0    0      0   0       0     1     0      0      0    0    0
  2       0    0      0   0       0     0     0      0      0    0    0
  3       0    0      0   0       0     0     0      0      0    0    0
  4       0    0      1   0       0     1     0      0      0    0    0
  5       0    0      0   0       0     1     0      0      0    0    0
  6       0    0      0   0       0     0     0      0      0    0    0
  7       0    0      0   0       0     0     0      0      0    0    0
  8       0    0      0   0       0     1     0      0      0    0    0
  9       0    0      0   0       0     1     0      0      0    0    0
  10      0    0      0   0       0     0     0      0      0    0    0
  11      0    0      4   0       0     0     1      1      0    0    0
  12      0    0      1   0       0     1     0      0      0    0    0
  13      0    1      1   0       0     0     0      0      0    0    0
  14      0    0      0   0       0     2     0      0      0    0    0
  15      0    1      2   0       0     0     0      0      0    0    0
  16      0    0      2   0       0     0     0      0      0    0    0
  17      0    1      0   0       0     0     0      0      0    0    0
  18      0    0      1   0       0     0     0      0      0    0    0
  19      0    0      0   0       0     0     0      0      0    0    0
  20      0    0      1   0       0     0     0      0      0    0    0
  21      0    1      1   0       0     0     0      0      0    0    0
  22      0    0      0   0       0     3     0      0      0    0    0
  23      0    0      1   0       0     2     0      0      0    0    0
  24      0    0      0   0       0     0     0      0      0    0    0
  25      0    0      0   0       0     0     0      0      0    0    0
  26      0    1      0   0       0     0     0      0      0    0    0
  27      0    0      0   0       0     0     0      0      0    0    0
  28      0    0      0   0       0     0     0      0      0    0    0
  29      0    0      1   0       0     0     0      0      0    0    0
  30      1    0      2   0       0     0     0      0      0    0    0
  31      1    0      0   0       0     2     0      0      0    0    0
  32      0    0      2   0       0     1     0      0      0    0    0
  33      0    0      1   0       1     1     0      0      0    0    0
  34      0    0      0   0       0     0     0      0      0    0    0
  35      0    0      0   0       0     0     0      0      0    1    0
  36      0    0      0   0       0     0     0      0      0    0    0
  37      0    2      0   0       0     0     0      0      0    0    0
  38      1    0      1   0       0     0     0      0      0    0    0
  39      0    0      0   0       0     1     0      0      0    0    0
  40      0    1      0   0       0     0     0      0      0    0    0
  41      0    0      0   0       0     1     0      0      0    0    0
  42      0    0      2   0       0     0     0      0      0    0    0
  43      0    0      2   0       0     0     0      0      0    0    0
  44      0    0      0   0       1     2     0      0      0    0    0
  45      0    0      2   0       0     1     0      0      0    0    0
  46      0    0      0   0       0     2     0      0      0    0    0
  47      0    0      0   1       0     0     0      0      0    0    0
  48      0    0      0   0       0     1     0      0      0    0    0
  49      0    0      1   0       0     0     0      0      0    0    0
  50      0    0      0   0       0     1     0      0      0    0    0
  51      0    0      0   0       0     0     0      0      0    0    0
  52      0    0      0   0       0     0     0      0      0    0    0
  53      0    0      0   0       0     0     1      0      0    0    0
  54      0    0      0   0       0     0     0      0      0    0    0
  55      0    0      2   0       0     0     0      0      0    0    0
  56      0    1      0   0       0     1     0      0      0    0    0
  57      0    0      0   0       0     0     0      0      0    0    0
  58      0    0      2   0       0     4     0      0      0    0    0
  59      0    0      1   0       0     1     0      0      0    0    0
  60      0    0      0   0       0     1     0      0      0    0    0
  61      0    1      0   0       0     0     0      0      0    0    0
  62      0    0      0   0       0     2     0      0      0    0    0
  63      0    0      2   0       0     0     0      0      0    0    0
  64      0    0      1   0       0     1     0      0      0    0    0
  65      0    0      1   0       0     0     0      0      0    0    0
  66      0    0      2   0       0     0     0      0      0    0    0
  67      0    0      1   0       0     2     0      0      0    0    0
  68      0    0      1   0       0     0     0      0      0    0    0
  69      1    0      1   0       0     0     0      0      0    0    0
  70      0    0      2   0       0     0     0      0      1    0    0
  71      0    0      0   0       0     1     0      1      0    0    0
  72      0    0      1   0       0     0     0      0      0    0    0
  73      0    0      0   0       0     0     0      0      0    0    0
  74      0    0      0   0       0     1     0      0      0    0    0
  75      0    0      1   0       0     1     0      0      0    0    0
  76      0    0      1   0       0     1     0      0      0    0    0
  77      0    0      0   0       0     0     0      0      0    0    0
  78      0    1      0   0       0     1     0      0      0    0    0
  79      0    0      1   0       0     2     0      0      0    1    0
  80      0    0      1   0       0     0     0      0      0    0    0
  81      0    0      2   0       0     2     0      0      0    0    0
  82      0    0      0   0       0     3     0      0      0    0    0
  83      0    0      0   0       0     1     0      0      0    0    0
  84      0    0      2   0       0     1     0      0      0    0    0
  85      0    0      1   0       0     0     0      0      0    0    0
  86      0    0      0   0       0     1     0      0      0    0    0
  87      1    0      0   0       0     1     1      1      0    0    0
  88      0    0      0   0       0     0     1      0      0    0    0
  89      0    2      0   0       0     0     0      0      0    0    0
  90      0    0      0   0       0     1     0      0      0    0    0
  91      0    0      0   0       0     1     0      0      0    0    0
  92      0    0      0   0       0     1     0      0      0    0    0
  93      0    0      0   0       0     0     0      0      0    0    0
  94      0    0      1   0       0     0     0      0      0    0    0
  95      0    1      0   0       1     1     0      0      0    0    0
  96      0    1      0   0       0     0     0      0      0    0    0
  97      0    0      0   0       0     0     0      0      0    0    0
  98      0    0      0   0       0     0     0      0      0    0    0
  99      0    0      1   0       0     1     0      0      0    0    0
  100     0    0      0   0       0     0     0      0      0    0    0
  101     0    0      1   0       0     0     0      0      0    0    0
  102     0    1      0   0       0     0     0      0      1    0    0
  103     0    0      0   0       0     0     0      0      1    0    0
  104     0    0      0   0       0     0     0      0      0    0    1
  105     0    0      1   0       0     0     0      0      0    0    0
  106     0    0      0   0       0     0     0      0      1    0    0
  107     0    0      0   0       0     0     0      0      0    0    0
  108     0    0      0   0       0     0     0      0      0    0    0
  109     0    0      1   0       1     0     0      0      1    0    0
  110     0    0      1   0       0     0     0      0      0    0    0
  111     0    0      0   0       0     0     0      0      0    0    0
  112     0    0      0   0       0     0     0      0      0    0    0
  113     0    0      0   0       0     0     0      0      0    0    0
  114     0    0      0   0       0     1     0      0      0    0    0
  115     0    0      0   0       0     0     0      0      0    0    0
  116     0    0      0   0       0     2     0      0      0    0    0
  117     0    0      0   0       0     0     0      0      0    0    0
  118     0    0      1   0       0     1     0      0      0    0    0
  119     0    0      0   0       0     0     0      0      0    0    0
  120     0    0      0   0       0     0     0      0      0    0    1
  121     0    0      0   0       0     2     0      0      0    0    0
  122     0    1      0   0       0     1     0      0      0    0    0
  123     0    0      0   0       0     1     0      0      0    0    0
  124     0    1      0   0       0     0     0      0      0    0    0
  125     0    0      0   0       0     2     0      0      0    0    0
  126     0    0      0   0       0     0     0      0      0    0    0
  127     0    0      0   0       0     0     0      1      1    0    0
  128     0    0      1   0       0     1     0      0      0    0    0
  129     0    0      0   0       0     1     0      0      0    0    0
  130     0    0      0   0       0     0     0      0      0    0    0
  131     0    1      0   0       0     2     0      0      0    0    0
  132     0    0      0   0       0     0     0      0      0    0    0
  133     0    0      2   0       1     0     0      0      1    0    0
  134     0    0      0   0       0     0     0      0      0    0    0
  135     0    0      1   0       0     0     0      0      0    0    0
  136     0    0      1   0       0     1     0      0      0    0    0
  137     0    0      1   0       0     0     0      0      0    0    0
  138     1    0      0   0       0     1     0      0      0    0    0
  139     0    0      1   0       0     0     0      0      0    0    0
  140     0    1      0   0       0     0     0      0      0    0    0
  141     0    0      1   0       0     1     0      0      0    0    0
  142     0    0      0   0       0     0     0      0      0    0    0
  143     0    0      0   0       0     1     0      0      0    0    0
  144     0    0      0   0       0     0     0      0      0    0    0
  145     0    0      0   0       0     1     0      0      0    0    0
  146     0    0      0   0       0     1     0      0      0    0    0
  147     0    0      0   0       0     0     0      0      0    0    0
  148     0    0      1   3       0     0     0      0      0    0    0
  149     0    0      0   0       0     2     0      0      0    0    0
  150     0    1      0   0       0     0     0      0      0    0    0
  151     0    1      0   0       0     0     0      0      0    0    0
  152     0    0      0   0       0     1     0      0      0    0    0
  153     1    0      0   0       0     0     0      0      0    0    0
  154     0    0      0   0       0     0     0      0      0    0    0
  155     0    0      0   0       0     0     0      0      0    0    0
  156     0    0      1   0       0     2     0      0      0    0    0
  157     0    0      0   0       0     0     0      0      0    0    0
  158     0    0      0   0       0     0     1      0      0    0    0
  159     1    0      0   0       0     1     0      0      0    0    0
  160     0    0      0   0       0     0     0      0      0    0    0
  161     0    0      0   0       0     0     0      0      0    0    0
  162     0    0      0   0       0     0     0      0      0    0    0
  163     0    0      1   0       0     0     0      0      0    0    0
  164     0    0      0   0       0     1     0      0      0    0    0
  165     0    0      0   0       0     0     0      0      0    0    0
  166     0    0      1   0       0     3     0      0      0    0    0
  167     0    0      0   0       0     1     0      0      0    0    0
  168     0    0      0   0       0     0     0      0      0    0    0
  169     0    0      1   0       0     1     0      0      0    0    0
  170     0    0      3   0       0     0     0      0      0    0    0
  171     0    0      0   0       0     1     0      0      0    0    0
  172     0    0      0   0       0     1     0      0      0    0    0
  173     0    0      0   0       0     0     0      0      0    0    0
  174     0    0      0   0       0     0     0      0      1    0    0
  175     0    0      0   0       0     1     0      1      0    0    0
  176     0    0      0   0       0     0     0      0      0    0    0
  177     0    0      0   0       0     0     0      0      0    0    0
  178     0    1      0   0       0     0     0      0      0    0    0
  179     0    0      0   0       0     2     0      0      0    0    0
  180     0    0      1   0       0     1     0      0      0    0    0
  181     0    1      0   0       0     1     0      0      0    0    0
  182     0    0      0   0       0     1     0      0      0    0    0
  183     0    0      0   0       0     0     0      0      0    0    0
  184     0    0      0   0       0     0     0      0      0    0    0
  185     0    3      0   0       0     0     0      0      0    0    0
  186     0    0      0   0       0     1     0      0      0    0    0
  187     0    0      0   0       0     1     0      0      0    0    0
  188     0    0      0   0       0     1     0      0      0    0    0
  189     0    0      1   0       0     0     0      0      0    0    0
  190     0    0      0   0       0     0     0      0      0    0    0
  191     0    0      0   0       0     2     0      0      0    0    0
  192     0    0      0   0       0     0     0      0      0    0    0
  193     0    1      0   0       0     0     1      0      0    0    1
  194     0    0      1   0       0     0     0      0      0    0    0
  195     0    0      1   0       0     1     0      0      0    0    0
  196     0    0      0   0       0     2     0      0      0    0    0
  197     0    1      0   0       0     1     0      0      0    0    0
  198     0    0      1   0       0     1     0      0      0    0    0
  199     0    0      1   0       0     1     0      0      0    0    0
  200     0    0      0   0       0     0     0      0      0    0    0
  201     0    1      0   0       0     0     0      0      0    0    0
  202     0    0      0   0       0     0     0      0      0    0    0
  203     0    0      0   0       0     0     0      0      0    0    0
  204     0    0      0   0       0     2     0      0      0    0    0
  205     0    0      0   0       0     0     0      0      0    0    0
  206     0    0      0   0       0     0     0      0      0    0    0
  207     0    0      0   0       0     0     0      0      0    0    0
  208     0    0      1   0       0     0     0      0      0    1    1
  209     0    0      0   0       0     2     0      0      0    0    0
  210     0    0      0   0       0     0     0      0      0    0    0
  211     0    0      0   0       0     0     0      0      0    0    0
  212     0    1      0   0       0     1     0      0      0    1    0
  213     0    0      0   0       0     0     0      0      0    0    0
  214     0    0      0   0       0     0     0      0      0    0    0
  215     0    0      1   0       0     0     0      0      0    0    0
  216     0    0      1   0       0     1     0      0      0    0    0
  217     0    0      0   0       0     1     0      0      0    0    0
  218     0    0      0   0       0     1     0      0      0    0    0
  219     0    0      0   0       0     0     0      0      0    0    0
  220     0    0      0   0       0     0     0      0      1    0    0
  221     0    0      1   0       0     0     0      0      0    0    0
  222     0    0      0   0       0     0     0      0      0    0    1
  223     0    0      0   0       0     0     0      0      0    0    0
  224     0    1      0   0       0     0     0      0      0    0    0
  225     0    0      0   0       0     1     0      0      0    0    0
  226     0    0      1   0       0     0     0      0      0    0    0
  227     0    0      0   0       0     0     0      0      0    0    0
  228     0    1      0   0       0     0     0      0      0    0    0
  229     0    0      0   0       0     2     0      0      0    0    0
  230     0    0      0   0       0     1     0      0      0    0    0
  231     0    0      1   0       0     0     0      0      0    0    0
  232     0    0      1   0       0     1     0      0      0    0    0
  233     0    0      2   0       0     0     0      0      0    0    0
  234     0    0      0   0       0     0     0      0      0    0    0
  235     0    0      1   0       0     0     0      0      0    2    0
  236     0    0      0   0       0     2     0      0      0    0    0
  237     0    0      1   0       0     0     0      0      0    0    0
  238     0    0      1   0       0     1     0      0      0    0    0
  239     0    0      0   0       0     0     0      0      0    0    0
  240     0    0      0   0       0     0     0      0      0    0    0
  241     0    0      0   0       0     1     0      0      0    0    0
  242     0    0      0   0       0     0     0      0      0    0    0
  243     0    0      1   0       0     1     0      0      0    0    0
  244     0    0      0   0       0     1     0      0      0    0    0
  245     0    1      0   0       0     1     0      0      0    0    0
  246     0    0      1   0       0     1     0      0      0    0    0
  247     0    0      0   0       0     2     0      0      0    0    0
  248     0    0      0   0       0     0     0      0      0    0    0
  249     1    0      0   0       0     0     0      0      0    0    0
  250     0    0      0   0       0     0     0      0      0    0    0
  251     0    0      0   0       0     0     0      0      0    0    0
  252     0    0      0   0       0     0     0      0      0    0    0
  253     0    0      0   0       0     0     0      0      0    0    0
  254     0    0      0   0       0     0     0      0      0    0    0
  255     0    0      0   0       0     0     0      0      0    0    0
  256     0    0      0   0       0     0     0      0      0    0    0
  257     0    0      0   0       0     0     0      0      0    0    0
  258     0    0      0   0       0     0     0      0      0    0    0
  259     0    0      0   0       0     0     0      0      0    0    0
  260     0    0      0   0       0     0     1      0      0    0    0
  261     0    0      1   0       0     0     0      0      0    0    0
  262     0    0      0   0       0     0     0      0      0    0    0
  263     0    0      1   0       0     0     0      0      0    0    0
  264     0    0      0   0       0     0     0      0      0    0    0
  265     0    0      0   0       0     0     0      0      0    0    0
  266     0    0      0   0       0     1     0      0      0    0    0
  267     0    0      0   0       0     0     0      0      0    0    0
  268     0    0      1   0       0     0     0      0      0    0    0
  269     0    0      0   0       0     0     0      0      0    0    0
  270     0    0      0   0       0     0     0      0      0    0    0
  271     0    0      0   0       0     0     0      0      1    0    0
  272     0    0      0   0       0     0     0      0      0    0    0
  273     0    0      0   0       0     0     0      1      0    0    0
  274     0    0      0   0       0     0     0      0      0    0    0
  275     0    0      0   0       0     0     0      0      0    0    0
  276     0    0      0   0       0     0     0      0      0    1    0
  277     0    2      0   0       0     0     0      0      0    0    0
  278     0    0      0   0       0     0     0      0      0    0    0
  279     0    0      0   0       0     0     0      0      1    0    0
  280     0    0      0   0       0     0     0      0      0    0    0
  281     0    0      0   0       0     0     0      0      0    0    0
  282     0    0      0   0       0     0     0      0      0    0    0
  283     0    0      0   0       0     0     0      0      0    0    0
  284     0    0      0   0       0     0     0      0      0    0    0
     Terms
Docs  high highly hire hired horrible hours hr huge ideas impact
  1      0      0    0     0        0     0  0    0     0      0
  2      0      0    0     0        0     0  0    0     0      0
  3      0      0    0     0        0     0  0    0     0      0
  4      0      0    0     0        0     1  0    0     0      0
  5      0      0    0     0        0     0  0    0     0      0
  6      0      0    0     0        0     0  0    0     0      0
  7      1      0    0     0        0     0  0    0     0      0
  8      0      0    0     0        0     0  0    0     0      0
  9      0      0    0     0        0     0  0    0     0      0
  10     0      0    0     0        0     0  0    0     0      0
  11     0      0    0     0        0     0  0    0     0      1
  12     0      0    0     0        0     0  0    0     0      0
  13     0      0    0     0        0     0  0    0     0      0
  14     0      0    0     0        0     0  0    0     0      1
  15     1      0    0     0        0     0  0    0     0      0
  16     1      0    0     0        0     0  0    0     0      0
  17     0      0    0     0        0     0  0    0     0      0
  18     0      0    0     0        0     0  0    0     1      0
  19     0      0    0     0        0     0  0    0     0      0
  20     0      0    0     0        0     0  0    0     0      0
  21     0      0    0     0        0     0  0    0     0      0
  22     0      0    0     0        0     0  0    0     0      0
  23     0      0    0     0        0     0  0    0     0      0
  24     0      0    0     0        0     0  0    1     1      0
  25     0      0    0     0        0     0  0    0     0      0
  26     0      0    0     0        0     0  0    0     0      0
  27     2      0    0     0        0     0  0    0     0      0
  28     0      0    0     0        0     0  0    0     0      0
  29     0      0    0     0        0     0  0    0     0      0
  30     0      0    0     0        0     0  0    0     0      0
  31     0      0    0     0        0     0  0    0     0      0
  32     0      0    0     0        0     0  0    0     1      0
  33     0      0    0     0        0     0  0    0     0      0
  34     0      0    0     0        0     0  0    0     0      0
  35     0      0    0     0        0     0  0    0     0      0
  36     0      0    0     0        0     0  0    0     0      0
  37     0      0    0     0        0     0  0    0     0      0
  38     0      0    0     0        0     0  0    0     0      0
  39     0      0    0     0        0     0  0    0     0      0
  40     0      0    0     0        0     0  0    0     0      0
  41     0      0    0     0        0     0  0    0     0      0
  42     0      0    0     0        0     0  0    0     0      0
  43     0      0    0     0        0     0  0    0     0      0
  44     0      0    0     0        0     0  0    0     0      0
  45     0      0    0     0        0     0  0    0     0      0
  46     0      0    0     0        0     0  0    0     0      0
  47     0      0    0     0        0     0  0    0     0      0
  48     0      0    0     0        0     1  0    0     0      0
  49     0      0    0     0        0     0  0    0     0      0
  50     0      0    0     0        0     0  0    0     0      0
  51     1      0    0     0        0     0  0    0     0      1
  52     0      0    0     0        0     0  0    1     0      1
  53     0      0    0     0        0     0  0    0     0      0
  54     0      0    0     0        0     0  0    0     0      0
  55     0      0    0     0        0     0  0    0     0      0
  56     0      0    0     0        0     0  0    0     0      0
  57     0      0    0     0        0     0  0    0     0      0
  58     0      0    0     0        0     0  0    0     0      0
  59     0      0    0     0        0     0  0    0     0      0
  60     0      0    0     0        0     0  0    0     0      0
  61     0      0    0     0        0     0  0    0     0      1
  62     0      0    0     0        0     0  0    0     0      0
  63     0      0    0     0        0     0  0    0     0      0
  64     0      0    0     0        0     0  0    0     0      1
  65     0      0    0     0        0     0  0    0     0      0
  66     1      0    0     0        0     0  0    0     0      0
  67     0      0    0     0        0     1  0    0     0      0
  68     0      0    0     0        0     0  0    0     0      0
  69     0      0    0     0        0     0  0    0     0      0
  70     0      0    0     0        0     0  0    0     0      0
  71     0      0    0     0        0     0  0    0     0      0
  72     1      0    0     0        0     0  0    0     0      1
  73     0      0    0     0        0     0  0    0     0      0
  74     0      0    0     0        0     0  0    0     0      0
  75     0      0    0     0        0     0  0    0     0      0
  76     0      0    0     0        0     0  0    0     0      0
  77     0      0    0     0        0     0  0    0     0      0
  78     1      0    0     0        0     0  0    0     0      0
  79     0      0    0     0        0     0  0    0     0      0
  80     0      0    0     0        0     0  0    0     0      0
  81     0      0    0     0        0     0  0    1     0      0
  82     0      0    0     0        0     0  0    0     0      0
  83     0      0    0     0        0     0  0    0     0      0
  84     0      0    0     0        0     0  0    0     0      0
  85     0      0    0     0        0     0  0    0     0      0
  86     0      0    0     0        0     0  0    0     0      0
  87     0      0    0     0        0     0  0    0     0      0
  88     0      0    0     0        0     0  0    0     0      0
  89     0      0    0     0        0     1  0    0     0      0
  90     0      0    0     0        0     1  0    0     0      0
  91     0      0    0     0        0     0  0    0     0      0
  92     0      0    0     0        0     0  0    0     0      0
  93     0      0    0     0        0     0  0    0     0      0
  94     0      0    0     0        0     0  0    0     0      0
  95     0      0    0     0        0     0  0    0     0      0
  96     0      0    0     0        0     0  0    0     0      0
  97     0      0    0     0        0     0  0    0     0      0
  98     1      0    0     0        0     0  0    0     0      1
  99     0      0    0     0        0     0  0    0     1      1
  100    0      0    0     0        0     0  0    0     0      0
  101    0      0    0     0        0     0  0    1     0      0
  102    0      0    0     0        0     0  0    0     0      0
  103    1      2    0     0        0     0  0    0     0      0
  104    0      0    0     0        0     0  0    0     0      0
  105    0      0    0     0        0     0  0    0     0      0
  106    0      0    0     0        0     0  0    0     0      0
  107    0      0    0     0        0     0  0    0     0      0
  108    0      0    0     0        0     0  0    0     0      0
  109    0      0    0     0        0     0  0    0     0      0
  110    0      0    0     0        0     0  0    1     0      0
  111    0      0    0     0        0     0  0    0     0      0
  112    0      0    0     0        0     0  0    0     0      1
  113    0      0    0     0        0     0  0    0     0      0
  114    0      1    0     0        0     0  0    0     0      0
  115    0      0    0     0        0     0  0    0     0      0
  116    0      0    0     0        0     0  0    0     0      0
  117    0      0    0     0        0     0  0    0     0      1
  118    0      0    0     0        0     0  0    0     0      0
  119    0      0    0     0        0     0  0    0     0      1
  120    1      0    0     0        0     0  0    1     0      1
  121    0      0    0     0        0     0  0    0     0      0
  122    0      0    0     0        0     0  0    0     0      0
  123    0      0    0     0        0     0  0    0     0      0
  124    0      0    0     0        0     0  0    0     0      0
  125    0      0    0     0        0     0  0    0     0      0
  126    0      0    0     0        0     0  0    0     0      0
  127    0      0    0     0        0     0  0    0     0      0
  128    0      0    0     0        0     0  0    0     0      0
  129    0      0    0     0        0     0  0    0     0      0
  130    0      0    0     0        0     0  0    0     0      0
  131    1      0    0     0        0     0  0    0     0      0
  132    0      0    0     0        0     0  0    0     0      0
  133    0      0    0     0        0     0  0    0     0      0
  134    0      0    0     0        0     0  0    0     0      0
  135    0      0    0     0        0     0  0    0     0      0
  136    0      0    0     0        0     0  0    0     0      0
  137    0      0    0     0        0     0  0    0     0      0
  138    0      0    0     0        0     0  0    0     0      0
  139    0      0    0     0        0     0  0    0     0      0
  140    0      0    0     0        0     0  0    0     0      0
  141    0      0    0     0        0     0  0    0     0      0
  142    0      0    0     0        0     0  0    0     0      0
  143    0      1    0     0        0     0  0    0     0      0
  144    0      0    0     0        0     0  0    0     0      1
  145    0      0    0     0        0     0  0    0     0      0
  146    0      0    0     0        0     0  0    0     0      0
  147    1      0    0     0        0     0  0    0     0      0
  148    1      0    0     0        0     0  0    0     0      0
  149    0      0    0     0        0     0  0    0     0      0
  150    0      0    0     0        0     0  0    0     0      0
  151    0      0    0     0        0     0  0    0     0      0
  152    0      0    0     0        0     0  0    0     0      0
  153    0      0    0     0        0     0  0    0     0      0
  154    0      0    0     0        0     0  0    0     0      0
  155    0      0    0     0        0     0  0    0     0      0
  156    0      0    0     0        0     0  0    0     0      1
  157    0      0    0     0        0     0  0    0     0      0
  158    0      0    0     0        0     0  0    0     1      0
  159    0      0    0     0        0     0  0    0     0      0
  160    0      0    0     0        0     0  0    0     0      0
  161    0      0    0     0        0     0  0    0     0      0
  162    0      0    0     0        0     0  0    0     0      0
  163    0      0    0     0        0     0  0    1     0      0
  164    0      0    0     0        0     0  0    0     0      0
  165    0      0    0     0        0     0  0    0     0      0
  166    0      0    0     0        0     0  0    0     0      0
  167    0      0    0     0        0     0  0    0     0      0
  168    0      0    0     0        0     0  0    0     0      0
  169    0      0    0     1        0     0  0    0     0      0
  170    0      0    0     0        0     0  0    0     0      1
  171    0      0    0     0        0     0  0    0     1      0
  172    0      0    0     0        0     0  0    0     0      0
  173    0      0    0     0        0     0  0    0     0      0
  174    0      0    0     0        0     0  0    0     0      0
  175    0      0    0     0        0     0  0    0     0      0
  176    0      0    0     0        0     0  0    0     0      0
  177    0      0    0     0        0     0  0    0     0      0
  178    0      0    0     0        0     0  0    0     0      0
  179    0      0    0     0        0     0  0    0     0      0
  180    0      0    0     0        0     0  0    0     0      0
  181    0      0    0     0        0     0  0    0     0      0
  182    0      0    0     0        0     0  0    0     1      0
  183    0      0    0     0        0     0  0    0     0      0
  184    0      0    0     0        0     0  0    0     0      0
  185    0      0    0     0        0     0  0    0     0      0
  186    0      0    0     0        0     0  0    0     0      0
  187    0      0    0     0        0     0  0    0     0      0
  188    0      0    0     0        0     0  0    0     0      1
  189    1      0    0     0        0     0  0    0     0      1
  190    0      0    0     0        0     0  0    0     0      0
  191    0      0    0     0        0     0  0    0     0      0
  192    0      0    0     0        0     0  0    0     0      1
  193    0      0    0     0        0     0  0    0     0      0
  194    0      0    0     0        0     0  0    0     0      0
  195    0      0    0     0        0     0  0    0     0      0
  196    0      0    0     0        0     0  0    0     0      0
  197    0      0    0     0        0     0  0    0     0      0
  198    0      0    0     0        0     0  0    0     1      0
  199    0      0    0     0        0     0  0    0     0      0
  200    0      0    0     0        0     0  0    0     0      0
  201    0      0    0     0        0     0  0    0     0      0
  202    0      0    0     0        0     0  0    0     0      0
  203    0      0    0     0        0     0  0    0     0      0
  204    0      0    0     0        0     0  0    0     0      0
  205    0      0    0     0        0     0  0    0     0      0
  206    0      0    0     0        0     0  0    0     0      0
  207    0      0    0     0        0     0  0    0     0      0
  208    0      0    0     0        0     0  0    0     0      0
  209    0      0    0     0        0     0  0    0     0      0
  210    0      0    0     0        0     0  0    0     0      0
  211    0      0    0     0        0     0  0    0     1      0
  212    0      0    0     0        0     0  0    0     0      0
  213    0      0    0     0        0     0  0    0     0      0
  214    0      0    0     0        0     0  0    0     0      0
  215    0      0    0     0        0     0  0    0     0      0
  216    0      0    0     0        0     0  0    0     0      0
  217    0      0    0     0        0     0  0    0     0      0
  218    0      0    0     0        0     0  0    0     0      0
  219    0      0    0     0        0     0  0    0     0      0
  220    0      0    0     0        0     0  0    0     0      0
  221    0      0    0     0        0     0  0    0     0      1
  222    0      0    0     0        0     1  0    0     0      0
  223    0      0    0     0        0     0  0    0     0      0
  224    0      0    0     0        0     0  0    0     0      0
  225    0      0    0     0        0     0  0    0     0      0
  226    0      0    0     0        0     0  0    0     0      0
  227    0      0    0     0        0     0  0    0     0      0
  228    0      0    0     0        0     0  0    0     0      0
  229    0      0    0     0        0     0  0    0     0      0
  230    0      0    0     0        0     0  0    1     0      1
  231    0      0    0     0        0     0  0    0     0      0
  232    1      0    0     0        0     0  0    0     0      0
  233    0      0    0     0        0     0  0    0     0      0
  234    0      0    0     0        0     0  0    0     0      0
  235    0      0    0     0        0     0  0    0     0      0
  236    0      0    0     0        0     0  0    0     0      0
  237    0      0    0     0        0     0  0    0     0      0
  238    0      0    0     0        0     0  0    0     0      0
  239    0      0    0     0        0     0  0    0     0      0
  240    0      0    0     0        0     0  0    0     0      0
  241    0      0    0     0        0     0  0    0     0      0
  242    0      0    0     0        0     0  0    0     0      0
  243    0      0    0     0        0     0  0    0     0      0
  244    0      0    0     0        0     0  0    0     0      0
  245    0      0    0     0        0     0  0    0     0      0
  246    0      0    0     0        0     0  0    0     0      0
  247    0      0    0     0        0     0  0    0     0      0
  248    0      0    0     0        0     0  0    0     0      0
  249    0      0    0     0        0     0  0    0     0      0
  250    0      0    0     0        0     0  0    0     0      0
  251    0      0    0     0        0     0  1    0     0      0
  252    0      0    0     0        0     1  0    0     0      0
  253    0      0    0     0        0     0  0    0     0      0
  254    0      0    1     0        0     0  0    0     0      0
  255    1      0    0     0        0     0  0    0     0      0
  256    0      0    0     0        0     0  0    0     0      0
  257    0      0    0     0        0     0  0    0     0      0
  258    0      0    0     0        0     0  0    0     0      0
  259    0      0    0     0        0     0  0    0     0      0
  260    0      0    0     0        0     0  0    0     0      0
  261    0      0    0     0        0     0  0    0     0      0
  262    0      0    0     0        0     0  0    0     0      0
  263    0      0    0     0        0     0  0    0     0      0
  264    0      0    0     0        0     0  0    0     0      0
  265    0      0    0     0        0     0  0    1     0      0
  266    0      0    0     0        0     1  0    0     0      0
  267    0      0    0     0        0     0  0    0     0      0
  268    0      0    0     0        0     0  0    0     0      0
  269    0      0    0     0        0     0  0    0     0      0
  270    0      0    0     0        0     0  0    0     0      0
  271    0      0    0     0        0     0  0    0     0      0
  272    0      0    0     0        0     0  0    0     0      0
  273    0      0    0     0        0     0  0    0     0      0
  274    0      0    0     0        0     0  0    0     0      0
  275    0      0    0     0        0     0  0    0     0      0
  276    0      0    0     0        0     0  0    0     0      0
  277    0      0    0     0        0     0  0    0     0      0
  278    0      0    0     0        0     0  0    0     0      0
  279    0      0    0     0        0     0  0    0     0      0
  280    1      0    0     0        0     0  1    0     0      0
  281    0      0    0     0        0     0  0    0     1      0
  282    0      0    0     0        0     0  0    0     0      0
  283    0      0    0     0        0     0  0    0     0      0
  284    0      0    0     0        0     0  0    0     0      0
     Terms
Docs  incredible incredibly individual industry information infrastructure
  1            0          0          0        1           0              0
  2            0          0          0        0           0              0
  3            0          0          0        0           0              0
  4            0          0          0        0           0              0
  5            0          0          0        0           0              0
  6            0          0          0        0           0              0
  7            0          0          0        0           0              0
  8            0          0          0        0           0              0
  9            0          0          0        0           0              0
  10           0          0          0        0           0              0
  11           0          0          0        0           0              0
  12           0          0          0        0           0              0
  13           0          0          0        0           0              0
  14           0          0          0        0           0              0
  15           0          0          0        0           0              0
  16           0          0          0        0           0              0
  17           0          0          0        0           0              0
  18           0          0          0        0           0              0
  19           0          0          0        0           0              0
  20           0          0          0        0           0              0
  21           0          0          0        0           0              0
  22           0          0          0        0           0              0
  23           0          0          0        0           0              0
  24           0          0          0        0           0              0
  25           0          0          0        0           0              0
  26           0          0          0        0           0              0
  27           0          0          0        0           0              0
  28           0          0          0        0           0              0
  29           0          0          0        0           0              0
  30           0          0          0        0           0              0
  31           0          0          0        0           0              0
  32           0          0          0        0           0              0
  33           0          0          0        0           0              0
  34           0          0          0        0           0              0
  35           0          0          0        0           0              0
  36           1          1          0        0           0              0
  37           0          0          0        0           0              0
  38           0          0          0        1           0              0
  39           0          0          0        0           0              0
  40           0          0          0        0           0              0
  41           1          1          0        0           0              0
  42           0          0          0        0           0              0
  43           0          0          0        1           0              0
  44           0          0          0        0           0              0
  45           0          0          0        0           0              0
  46           0          0          0        0           0              0
  47           0          0          0        0           0              0
  48           0          1          0        0           0              0
  49           0          0          0        1           0              0
  50           0          0          0        0           0              0
  51           0          0          0        0           2              0
  52           0          0          0        2           0              0
  53           0          0          0        0           0              0
  54           0          0          0        0           0              0
  55           0          0          0        0           0              1
  56           0          0          0        0           0              0
  57           0          0          0        0           0              0
  58           0          0          0        0           0              0
  59           0          0          0        0           0              0
  60           0          0          0        0           0              0
  61           1          0          0        0           0              0
  62           0          0          0        0           0              0
  63           0          0          0        0           0              0
  64           0          0          0        0           0              1
  65           0          0          0        0           0              0
  66           0          0          0        0           0              0
  67           0          0          0        0           0              0
  68           0          0          0        0           0              0
  69           0          0          0        0           0              0
  70           0          0          0        0           0              0
  71           0          0          0        0           0              1
  72           0          0          0        0           0              0
  73           0          2          0        0           0              0
  74           0          0          0        0           0              0
  75           0          0          0        0           0              0
  76           0          0          0        0           0              0
  77           0          0          0        0           0              0
  78           0          0          0        0           0              0
  79           0          0          0        0           0              0
  80           0          1          0        0           0              0
  81           0          0          0        0           0              0
  82           0          0          0        0           0              0
  83           0          0          0        0           0              0
  84           0          0          0        0           0              0
  85           0          0          0        0           0              0
  86           0          0          0        0           0              0
  87           0          0          1        0           0              0
  88           0          0          0        0           0              0
  89           0          0          0        0           0              0
  90           0          0          0        0           0              0
  91           0          0          0        0           0              0
  92           0          0          0        0           0              1
  93           0          0          0        0           0              0
  94           0          0          0        0           0              0
  95           1          0          0        0           0              0
  96           0          0          0        0           0              0
  97           0          0          0        0           0              0
  98           0          0          0        0           0              0
  99           0          0          2        0           0              0
  100          0          0          0        0           0              0
  101          0          0          0        0           0              0
  102          0          0          0        0           0              0
  103          0          0          0        0           0              0
  104          1          0          0        0           1              0
  105          0          0          0        0           0              0
  106          0          0          0        0           0              0
  107          0          0          0        0           0              1
  108          0          0          0        0           0              0
  109          0          0          0        0           0              0
  110          0          0          0        0           0              0
  111          0          0          0        0           0              0
  112          0          0          0        0           0              0
  113          0          0          0        0           0              0
  114          0          0          0        0           0              1
  115          1          0          0        0           0              0
  116          0          0          0        0           0              0
  117          0          0          0        0           0              0
  118          0          0          0        0           0              0
  119          0          0          0        0           0              0
  120          0          0          0        0           0              0
  121          0          0          0        0           0              0
  122          0          0          0        0           0              0
  123          0          0          0        0           0              0
  124          0          0          0        0           0              0
  125          0          0          0        0           0              0
  126          0          0          0        0           0              0
  127          0          0          0        0           0              0
  128          0          0          0        0           1              0
  129          0          0          0        0           0              0
  130          0          0          1        0           0              0
  131          0          0          0        0           0              0
  132          0          0          0        0           0              0
  133          0          0          0        0           0              0
  134          0          0          0        1           1              0
  135          0          0          0        0           0              0
  136          0          0          1        0           0              0
  137          1          0          0        0           0              0
  138          0          0          0        0           0              0
  139          0          0          0        0           0              0
  140          2          0          0        0           0              0
  141          0          0          0        0           0              0
  142          0          0          0        0           0              0
  143          0          0          0        0           0              0
  144          0          0          0        0           0              0
  145          0          0          0        0           0              0
  146          0          0          0        0           0              0
  147          0          0          0        0           0              0
  148          0          0          0        0           0              0
  149          0          0          0        0           0              0
  150          0          0          0        0           0              0
  151          0          0          0        0           0              0
  152          0          0          0        0           0              0
  153          0          0          0        0           0              0
  154          0          0          0        0           0              0
  155          0          0          0        0           0              0
  156          0          0          0        0           0              0
  157          0          0          0        0           0              0
  158          0          0          0        0           0              0
  159          0          0          0        0           0              0
  160          0          1          0        0           0              0
  161          0          0          0        0           0              1
  162          0          0          0        1           0              0
  163          0          0          0        0           0              0
  164          0          0          0        0           0              1
  165          0          0          0        0           0              0
  166          0          0          0        0           0              0
  167          0          0          0        0           0              0
  168          0          1          0        0           0              0
  169          0          0          0        0           0              0
  170          0          0          0        0           0              0
  171          0          0          0        0           0              0
  172          0          0          0        0           0              0
  173          0          0          0        0           0              0
  174          0          0          0        0           0              0
  175          0          0          0        0           0              0
  176          0          0          0        0           0              0
  177          0          0          0        0           0              0
  178          0          0          0        0           0              0
  179          0          0          0        0           0              0
  180          0          0          0        0           0              0
  181          0          0          0        0           0              0
  182          0          0          0        0           0              0
  183          0          0          0        0           0              0
  184          0          0          0        0           0              0
  185          0          0          0        0           0              0
  186          0          0          0        0           0              0
  187          0          0          0        0           0              0
  188          0          0          0        0           0              0
  189          0          0          0        0           0              0
  190          0          0          0        0           0              0
  191          0          0          0        0           0              0
  192          0          0          0        0           0              0
  193          0          0          0        0           0              1
  194          0          0          0        0           0              0
  195          0          0          0        0           0              0
  196          0          0          0        0           0              0
  197          0          0          0        0           0              0
  198          0          0          0        0           0              0
  199          0          0          0        0           0              0
  200          0          0          0        0           0              0
  201          0          0          0        0           0              0
  202          0          0          0        0           0              0
  203          0          0          0        0           0              0
  204          0          0          0        0           0              0
  205          0          0          0        0           1              0
  206          0          0          0        0           0              0
  207          0          0          0        0           0              0
  208          0          0          0        0           0              0
  209          0          0          0        0           0              0
  210          0          0          0        0           0              0
  211          0          0          0        0           0              0
  212          0          0          0        0           0              0
  213          0          0          0        0           0              0
  214          0          0          0        0           0              0
  215          0          0          0        0           0              0
  216          0          1          0        0           0              0
  217          0          0          0        0           0              0
  218          0          0          0        0           0              0
  219          0          0          0        0           0              0
  220          0          0          0        0           0              0
  221          0          0          0        0           0              0
  222          0          0          0        0           0              0
  223          0          0          0        0           0              0
  224          0          0          0        0           0              0
  225          0          0          0        0           0              0
  226          0          0          0        0           0              0
  227          0          0          0        0           0              0
  228          0          0          0        0           0              0
  229          0          0          0        0           0              0
  230          0          0          0        0           0              0
  231          0          0          0        0           0              0
  232          0          0          0        0           0              0
  233          0          0          0        0           0              0
  234          0          0          0        0           1              0
  235          0          0          0        0           0              0
  236          0          0          0        0           0              0
  237          0          0          0        0           0              0
  238          0          0          0        0           0              0
  239          0          0          0        0           0              0
  240          0          0          0        0           0              0
  241          0          0          0        0           0              0
  242          0          0          0        0           0              0
  243          0          0          0        0           0              0
  244          0          0          0        0           0              0
  245          0          0          0        0           0              0
  246          0          0          0        0           0              0
  247          0          0          0        0           0              0
  248          0          0          0        0           0              0
  249          0          0          0        0           0              0
  250          0          0          0        0           0              0
  251          0          0          0        0           0              0
  252          0          0          0        0           0              0
  253          0          0          0        0           0              0
  254          0          0          0        0           0              0
  255          0          0          0        0           0              0
  256          0          0          0        0           0              0
  257          0          0          0        0           0              0
  258          0          0          0        0           0              0
  259          0          0          0        0           0              0
  260          0          0          0        0           0              0
  261          0          0          0        0           0              0
  262          0          0          0        0           0              0
  263          0          0          0        0           0              0
  264          0          0          0        0           0              0
  265          0          0          0        0           0              0
  266          0          0          0        0           0              0
  267          0          0          1        0           0              0
  268          0          0          0        0           0              1
  269          0          0          0        0           0              0
  270          0          0          0        0           0              0
  271          0          0          0        0           0              0
  272          0          0          0        0           0              0
  273          0          0          0        0           0              0
  274          0          0          0        0           0              0
  275          0          0          0        0           0              0
  276          0          0          0        0           0              0
  277          0          0          0        0           0              0
  278          0          0          0        0           0              0
  279          0          0          0        0           0              0
  280          0          0          0        0           0              0
  281          0          0          0        0           0              0
  282          0          0          0        0           0              0
  283          0          0          0        0           0              0
  284          0          0          0        0           0              0
     Terms
Docs  innovation innovative instead intelligent interest interesting
  1            0          0       0           0        0           0
  2            0          0       0           0        0           0
  3            0          0       0           0        0           0
  4            0          0       0           0        0           0
  5            0          0       0           0        0           0
  6            0          0       0           0        0           0
  7            0          0       0           0        0           0
  8            0          0       0           0        0           0
  9            1          0       0           0        0           0
  10           0          0       0           0        0           0
  11           0          0       0           0        0           0
  12           0          0       0           0        0           0
  13           0          0       0           0        0           0
  14           0          0       0           0        0           0
  15           0          0       0           0        0           0
  16           0          0       0           0        0           1
  17           0          0       0           0        0           0
  18           0          0       0           0        0           0
  19           0          0       0           0        0           0
  20           0          0       0           0        0           0
  21           0          0       0           0        0           0
  22           0          0       0           0        0           0
  23           0          0       0           0        0           0
  24           0          0       0           0        0           0
  25           0          0       0           0        0           1
  26           0          0       0           0        0           0
  27           0          0       0           0        0           0
  28           0          0       0           0        0           0
  29           0          0       0           0        0           0
  30           0          0       0           0        0           0
  31           1          0       0           0        0           0
  32           0          0       0           0        0           0
  33           0          0       0           0        0           0
  34           0          0       0           0        0           0
  35           0          0       0           0        0           1
  36           0          0       0           0        0           0
  37           0          0       0           0        0           0
  38           0          0       0           0        0           0
  39           0          0       0           0        0           0
  40           0          0       0           0        0           0
  41           0          0       0           0        0           0
  42           0          0       0           0        0           0
  43           0          0       0           0        0           0
  44           1          0       0           0        0           0
  45           0          0       0           0        0           0
  46           0          0       0           1        0           0
  47           0          0       0           0        0           1
  48           0          0       0           0        0           0
  49           0          0       0           0        0           0
  50           0          0       0           0        0           1
  51           0          0       1           0        0           0
  52           1          0       0           0        0           0
  53           0          0       0           0        0           0
  54           0          0       0           0        0           0
  55           0          0       0           0        1           0
  56           0          0       0           0        0           0
  57           0          0       0           0        0           0
  58           0          0       0           0        0           0
  59           0          0       0           0        0           0
  60           0          0       0           0        0           1
  61           0          0       0           0        0           0
  62           0          0       0           0        0           0
  63           0          0       0           0        0           0
  64           0          0       0           0        0           0
  65           0          0       0           0        0           0
  66           0          0       0           0        0           0
  67           0          0       0           0        0           0
  68           0          0       0           0        0           0
  69           0          0       0           0        0           0
  70           0          0       0           0        0           0
  71           0          0       0           0        0           0
  72           0          0       0           0        0           1
  73           0          0       0           1        0           0
  74           0          0       0           0        0           0
  75           0          0       0           0        0           0
  76           0          0       0           0        0           0
  77           0          0       0           0        0           1
  78           0          0       0           0        0           1
  79           0          0       0           0        0           1
  80           1          0       0           0        0           0
  81           0          0       0           0        0           0
  82           0          0       0           0        0           0
  83           0          0       0           0        0           0
  84           0          0       1           0        0           0
  85           0          0       0           0        0           1
  86           0          0       0           0        0           0
  87           0          0       0           0        0           0
  88           0          0       0           0        0           0
  89           0          0       0           0        0           0
  90           0          0       0           0        0           0
  91           0          0       0           0        0           0
  92           0          0       0           0        0           0
  93           0          0       0           0        0           0
  94           0          0       0           0        0           0
  95           0          0       0           1        0           1
  96           0          0       0           0        0           0
  97           0          0       0           0        0           0
  98           0          0       0           0        0           0
  99           0          0       0           0        0           0
  100          0          0       0           0        0           0
  101          0          0       0           0        0           0
  102          0          0       0           0        0           0
  103          0          1       0           1        0           0
  104          0          0       0           0        0           0
  105          0          0       0           1        0           0
  106          0          0       0           1        0           0
  107          0          0       0           0        0           0
  108          0          0       0           0        0           0
  109          0          0       0           0        0           0
  110          0          0       0           0        0           0
  111          0          0       0           0        0           0
  112          0          0       0           0        0           0
  113          0          0       0           0        0           0
  114          0          0       0           0        0           0
  115          0          0       0           0        0           0
  116          0          0       0           0        0           0
  117          0          0       0           0        0           0
  118          0          0       0           0        0           0
  119          0          0       0           0        0           0
  120          0          0       0           0        0           1
  121          0          0       0           0        0           0
  122          0          0       0           0        0           1
  123          0          0       0           0        0           0
  124          0          0       0           0        0           0
  125          0          0       0           0        0           0
  126          0          0       0           0        1           0
  127          0          0       0           0        0           0
  128          0          0       0           1        0           0
  129          0          0       0           0        0           0
  130          0          0       0           0        0           0
  131          0          0       0           0        0           0
  132          0          0       0           0        0           0
  133          0          0       0           0        0           0
  134          0          0       0           0        0           0
  135          0          0       0           0        0           0
  136          0          0       0           0        0           0
  137          0          0       0           0        0           0
  138          0          0       0           0        0           0
  139          0          0       0           0        0           0
  140          0          0       0           0        0           2
  141          0          0       0           0        0           0
  142          0          0       0           0        0           0
  143          0          0       0           0        0           0
  144          0          0       0           0        0           0
  145          0          0       0           0        0           0
  146          0          0       0           0        0           0
  147          0          0       0           0        0           0
  148          0          0       0           0        0           0
  149          0          0       0           0        0           1
  150          0          0       0           0        0           0
  151          0          0       0           0        0           0
  152          0          0       0           0        0           0
  153          0          0       0           0        0           0
  154          0          0       0           0        0           0
  155          0          0       0           0        0           0
  156          0          0       0           1        0           0
  157          0          0       0           0        0           0
  158          0          0       0           0        0           0
  159          0          0       0           0        0           0
  160          0          0       0           0        0           0
  161          0          0       0           0        0           1
  162          0          0       0           0        0           0
  163          0          0       0           0        0           0
  164          0          0       0           0        0           0
  165          0          0       0           0        0           0
  166          1          0       0           0        0           0
  167          0          0       0           0        0           0
  168          0          0       0           0        0           0
  169          0          0       0           0        0           0
  170          0          1       0           0        0           0
  171          0          0       0           0        0           0
  172          0          0       0           0        0           0
  173          0          0       0           0        0           0
  174          0          0       0           0        0           0
  175          0          0       0           0        1           1
  176          1          0       0           0        0           0
  177          0          0       0           0        0           0
  178          0          0       0           0        0           0
  179          0          0       0           0        0           0
  180          0          0       0           0        0           0
  181          0          0       0           0        0           0
  182          0          0       0           0        0           0
  183          0          0       0           0        0           1
  184          0          0       0           0        0           0
  185          0          0       0           0        0           0
  186          0          0       0           0        0           0
  187          0          0       0           0        0           0
  188          0          0       0           0        0           0
  189          0          0       0           0        0           0
  190          0          0       0           0        0           1
  191          0          0       0           0        0           0
  192          0          0       0           1        0           0
  193          0          0       0           0        0           0
  194          0          0       0           0        0           0
  195          0          0       0           0        0           0
  196          0          0       0           0        0           0
  197          0          0       0           0        0           0
  198          0          0       0           0        0           1
  199          1          0       0           0        0           1
  200          0          0       0           0        0           0
  201          0          0       0           0        0           1
  202          0          0       0           0        0           0
  203          0          0       0           0        0           0
  204          0          0       0           0        0           0
  205          0          0       0           0        0           0
  206          1          0       0           0        0           0
  207          0          0       0           0        0           0
  208          0          0       0           0        0           0
  209          0          1       1           0        0           0
  210          0          0       0           0        0           0
  211          0          0       0           0        0           0
  212          0          0       0           0        0           2
  213          0          0       0           0        0           0
  214          0          1       0           0        0           0
  215          0          0       0           0        0           0
  216          0          0       0           0        0           0
  217          0          0       0           0        0           0
  218          0          0       0           0        0           0
  219          0          0       0           0        0           0
  220          0          0       0           0        0           0
  221          0          0       0           0        0           0
  222          0          0       0           0        0           0
  223          0          0       0           0        0           0
  224          0          0       0           0        0           0
  225          0          0       0           0        0           1
  226          0          0       0           0        0           0
  227          0          0       0           0        0           0
  228          0          0       0           0        0           0
  229          0          0       0           0        0           0
  230          1          0       0           0        0           0
  231          0          1       0           0        0           0
  232          0          0       0           0        0           0
  233          0          0       0           0        0           0
  234          0          0       0           0        0           0
  235          0          0       0           0        0           0
  236          0          0       0           0        0           0
  237          0          0       0           0        0           0
  238          0          0       0           0        0           0
  239          0          0       0           0        0           0
  240          0          0       0           0        0           1
  241          0          0       0           0        0           0
  242          0          0       0           0        0           0
  243          0          0       0           0        0           0
  244          0          0       0           0        0           0
  245          0          0       0           0        0           0
  246          0          0       0           0        0           0
  247          0          0       0           0        0           0
  248          0          1       0           0        0           0
  249          0          0       0           0        0           0
  250          0          0       0           0        0           0
  251          0          0       0           0        0           0
  252          0          0       0           0        0           0
  253          0          0       0           0        0           0
  254          0          0       0           0        0           0
  255          0          0       0           0        0           0
  256          0          0       0           0        0           0
  257          0          0       0           0        0           1
  258          0          0       0           0        0           0
  259          0          0       0           0        0           0
  260          0          0       0           0        0           0
  261          0          0       0           0        0           0
  262          0          0       0           0        0           0
  263          0          0       0           0        0           0
  264          0          0       0           0        0           0
  265          0          0       0           0        0           0
  266          0          0       0           0        0           0
  267          0          0       0           0        0           0
  268          0          0       0           0        0           0
  269          0          0       0           0        0           0
  270          0          0       0           0        0           0
  271          0          0       0           0        0           0
  272          0          0       0           0        0           0
  273          0          0       0           0        0           0
  274          0          0       0           0        0           0
  275          0          0       0           0        0           0
  276          0          0       0           0        0           0
  277          0          0       0           0        1           0
  278          0          0       0           0        0           0
  279          0          0       0           0        0           0
  280          0          0       0           0        0           0
  281          0          0       0           0        0           0
  282          0          0       0           0        0           0
  283          0          0       0           0        0           0
  284          0          0       0           0        0           0
     Terms
Docs  internal interviews isnt ive job just keep know knowledge lack large
  1          0          0    0   0   0    0    0    0         1    0     0
  2          0          0    0   0   0    0    0    0         0    0     0
  3          0          0    0   0   0    0    0    0         0    0     0
  4          0          0    0   0   0    0    0    0         0    0     0
  5          0          0    0   0   0    0    0    0         0    0     0
  6          0          0    0   0   0    0    0    0         0    0     0
  7          0          0    0   0   0    0    0    0         0    0     0
  8          0          0    0   0   0    0    0    0         0    0     0
  9          0          0    0   0   0    0    0    0         0    0     0
  10         0          0    0   0   0    0    1    0         0    0     0
  11         0          0    0   0   1    0    0    0         0    0     0
  12         0          0    0   0   0    0    0    0         0    0     0
  13         0          0    0   1   0    1    0    0         0    0     0
  14         0          0    0   0   0    0    0    0         0    0     0
  15         0          0    0   0   0    0    0    0         0    0     0
  16         0          0    0   0   0    0    0    0         0    0     0
  17         0          0    0   0   0    0    0    0         0    0     0
  18         0          0    0   0   0    0    0    0         0    0     0
  19         0          0    0   0   0    0    0    0         0    0     0
  20         0          0    0   0   1    0    0    0         0    0     0
  21         0          0    0   0   0    0    0    0         0    0     0
  22         0          0    0   0   0    0    0    0         0    0     0
  23         0          0    0   1   0    0    0    0         0    0     0
  24         0          0    0   0   0    0    0    0         0    0     0
  25         0          0    0   0   0    0    0    0         0    0     0
  26         0          0    0   0   0    0    0    0         0    0     0
  27         0          0    0   0   0    0    0    0         0    0     0
  28         0          0    0   0   0    0    0    0         0    0     0
  29         0          0    0   0   1    0    0    0         0    0     0
  30         0          0    0   0   0    0    0    0         0    0     0
  31         0          0    0   1   0    0    0    0         0    0     0
  32         0          0    0   0   0    0    0    0         0    0     0
  33         0          0    0   0   0    0    0    0         0    0     0
  34         0          0    0   0   0    0    0    0         0    0     0
  35         0          0    0   0   0    0    0    0         0    0     0
  36         0          0    0   0   0    0    0    0         0    0     1
  37         0          0    0   0   0    0    0    0         0    0     0
  38         0          0    0   0   1    0    0    0         0    0     0
  39         0          0    0   1   0    0    0    0         0    0     0
  40         0          0    0   0   0    0    1    0         0    0     0
  41         0          0    0   0   0    1    0    0         0    0     1
  42         0          0    0   0   0    0    0    0         0    0     0
  43         0          0    0   0   0    0    0    0         0    0     0
  44         0          0    0   0   0    0    0    0         0    0     0
  45         0          0    0   2   0    0    0    0         0    0     0
  46         0          0    0   0   0    0    0    0         0    0     0
  47         0          0    0   1   0    1    0    0         0    0     0
  48         0          0    0   0   0    0    0    0         0    0     0
  49         0          0    0   0   0    0    0    0         0    0     0
  50         0          0    0   0   0    0    0    0         0    0     0
  51         0          0    0   0   0    0    0    0         0    0     0
  52         0          0    0   0   0    0    0    0         0    0     0
  53         0          0    0   0   0    0    0    0         0    0     0
  54         0          0    0   0   1    0    0    0         0    0     0
  55         0          0    0   0   0    0    0    0         0    0     0
  56         0          0    0   0   0    0    0    0         0    0     0
  57         0          0    0   0   0    0    0    1         0    0     0
  58         0          0    0   0   0    0    0    0         0    0     0
  59         0          0    0   0   0    0    0    0         0    0     0
  60         0          0    0   0   0    0    0    0         0    0     0
  61         0          0    0   0   0    0    0    0         0    0     0
  62         0          0    0   0   0    0    0    0         0    0     0
  63         0          0    0   0   0    0    0    0         0    0     0
  64         0          0    0   0   0    0    0    0         0    0     0
  65         0          0    0   0   0    0    0    0         0    0     0
  66         0          0    0   0   0    1    0    0         0    0     0
  67         0          0    0   0   1    0    0    0         0    0     0
  68         0          0    0   0   0    0    0    0         0    0     0
  69         0          0    0   0   0    0    0    0         0    0     0
  70         0          0    0   1   0    0    0    0         0    0     0
  71         0          0    0   1   0    0    0    0         0    1     0
  72         0          0    0   0   0    0    0    0         0    0     0
  73         0          0    0   0   0    0    0    0         0    0     0
  74         0          0    0   0   0    0    0    0         0    0     0
  75         0          0    0   0   0    0    0    0         0    0     0
  76         0          0    0   0   0    0    0    0         0    0     0
  77         0          0    0   0   0    0    0    0         0    0     0
  78         0          0    0   0   0    0    0    0         0    0     0
  79         0          0    0   0   0    0    0    0         0    0     0
  80         0          0    0   0   0    0    0    0         0    0     0
  81         0          0    0   1   0    0    0    0         0    0     1
  82         0          0    0   0   0    0    0    0         0    0     0
  83         0          0    0   0   0    0    0    0         0    0     0
  84         0          0    0   0   0    0    0    0         0    0     0
  85         0          0    0   2   0    0    0    0         0    0     0
  86         0          0    0   0   0    1    0    0         0    0     0
  87         0          0    0   0   0    0    0    0         0    0     1
  88         0          0    0   0   0    0    0    0         0    0     0
  89         0          0    0   0   0    0    0    0         0    0     0
  90         0          0    0   0   0    0    0    0         0    0     0
  91         0          0    0   0   0    0    0    0         0    0     0
  92         0          0    0   0   0    0    0    0         0    0     0
  93         0          0    0   0   0    0    0    0         0    0     0
  94         0          0    0   0   0    0    0    0         0    0     0
  95         0          0    0   0   0    0    0    0         0    0     0
  96         0          0    0   0   0    0    0    0         0    0     0
  97         0          0    0   0   0    0    0    0         0    0     0
  98         0          0    0   0   0    0    0    0         0    0     0
  99         0          0    0   0   0    0    0    0         0    0     0
  100        0          0    0   0   0    0    0    0         0    0     0
  101        0          0    0   0   0    0    0    0         0    0     0
  102        0          0    0   0   0    0    0    0         0    0     0
  103        0          0    0   0   0    0    0    0         0    0     0
  104        0          0    0   0   0    0    0    0         0    0     0
  105        0          0    0   1   0    0    0    0         0    0     0
  106        0          0    0   0   0    0    0    0         0    0     0
  107        0          0    0   0   0    0    0    0         0    0     0
  108        0          0    0   0   0    0    0    0         0    0     0
  109        0          0    0   1   0    0    0    0         0    0     0
  110        0          0    0   0   0    0    0    0         0    0     0
  111        0          0    0   0   0    0    0    0         0    0     0
  112        0          0    0   0   1    0    0    0         1    0     0
  113        0          0    0   0   0    0    0    0         0    0     0
  114        0          0    0   0   0    0    0    0         1    0     0
  115        0          0    0   0   0    0    0    0         0    0     0
  116        0          0    0   0   0    0    0    0         0    0     0
  117        0          0    0   0   0    0    0    0         0    0     0
  118        0          0    0   0   0    0    0    0         0    0     0
  119        0          0    0   0   0    0    0    0         0    0     0
  120        0          0    0   0   0    0    0    0         0    1     0
  121        0          0    0   0   0    0    0    0         0    0     0
  122        0          0    0   0   0    0    0    0         0    0     0
  123        0          0    0   0   0    0    0    0         0    0     0
  124        0          0    0   0   0    0    0    0         0    0     0
  125        0          0    0   0   0    0    0    0         0    0     0
  126        0          0    0   1   0    0    0    0         0    0     0
  127        0          0    0   0   0    0    0    0         0    0     0
  128        0          0    0   0   0    0    0    0         0    0     0
  129        0          0    0   0   0    0    0    0         0    0     0
  130        0          0    0   0   0    0    0    0         0    0     0
  131        0          0    0   0   0    0    0    0         0    0     0
  132        0          0    0   0   0    0    0    0         0    0     0
  133        0          0    0   0   0    0    0    0         0    0     0
  134        1          0    0   0   0    0    0    0         0    0     0
  135        0          0    0   0   0    0    0    0         0    0     0
  136        0          0    0   0   0    1    0    0         0    1     0
  137        0          0    0   0   0    0    0    0         0    0     0
  138        0          0    0   0   0    0    0    0         0    0     0
  139        0          0    0   0   0    0    0    0         0    0     0
  140        0          0    0   0   0    0    0    0         0    0     0
  141        0          0    0   0   0    0    0    0         0    0     0
  142        0          0    0   0   0    0    0    0         0    0     0
  143        0          0    1   1   0    0    0    0         0    0     0
  144        0          0    0   0   0    0    0    0         0    0     0
  145        0          0    0   0   0    0    0    0         0    0     0
  146        0          0    0   0   0    0    0    0         0    0     0
  147        0          0    0   0   0    0    0    0         0    0     0
  148        0          0    0   0   0    1    0    0         0    0     0
  149        0          0    0   0   0    0    0    0         0    0     0
  150        0          0    0   0   0    0    0    0         0    0     0
  151        0          0    0   0   0    0    0    0         0    0     0
  152        0          0    0   0   0    0    0    0         0    0     0
  153        0          0    1   0   0    0    0    0         0    0     0
  154        0          0    0   0   0    0    0    0         0    0     0
  155        0          0    0   0   0    0    0    0         0    0     0
  156        0          0    0   0   0    0    0    0         0    0     0
  157        0          0    0   0   0    0    0    0         0    0     0
  158        0          0    0   0   0    0    0    0         0    0     0
  159        0          0    0   0   0    0    0    0         0    0     0
  160        0          0    0   0   0    0    0    0         0    0     0
  161        0          0    0   0   1    0    0    0         0    0     0
  162        0          0    0   0   0    0    0    0         0    0     0
  163        0          0    0   0   0    0    0    0         0    0     0
  164        0          0    0   0   0    0    0    0         1    0     0
  165        0          0    0   0   0    0    0    0         0    0     0
  166        0          0    0   0   0    0    0    0         0    0     0
  167        0          0    0   0   0    0    0    0         0    0     0
  168        0          0    0   0   0    0    0    0         0    0     0
  169        0          0    0   0   0    1    0    0         0    0     0
  170        0          0    0   0   0    0    0    0         0    0     1
  171        0          0    0   0   0    0    0    0         0    0     0
  172        0          0    0   0   0    0    0    0         0    0     0
  173        0          0    0   0   0    0    0    0         1    0     0
  174        0          0    0   0   0    0    0    0         0    0     0
  175        0          0    0   0   0    0    0    0         0    0     0
  176        0          0    0   0   0    0    0    0         0    0     0
  177        0          0    0   0   0    0    0    0         0    0     0
  178        0          0    0   0   0    0    0    0         0    0     0
  179        0          0    0   0   1    0    0    0         0    0     0
  180        0          0    0   1   0    1    0    0         0    0     0
  181        0          0    0   0   0    0    0    0         0    0     0
  182        0          0    0   0   0    0    0    0         0    0     0
  183        0          0    0   0   0    0    0    0         0    0     0
  184        0          0    0   0   0    0    0    0         0    0     0
  185        0          0    0   0   0    0    0    1         0    0     0
  186        0          0    0   0   0    0    0    0         0    0     0
  187        0          0    0   0   0    0    0    0         0    0     0
  188        0          0    0   0   0    0    0    0         0    0     0
  189        0          0    0   0   0    0    0    0         0    0     0
  190        0          0    0   0   0    0    0    0         0    0     0
  191        0          0    0   0   0    0    0    0         0    0     0
  192        1          0    0   0   0    0    0    0         0    0     0
  193        1          0    0   0   0    0    0    0         0    0     0
  194        0          0    0   0   0    0    0    0         0    0     0
  195        0          0    0   0   0    0    0    0         0    0     0
  196        1          0    0   0   0    0    0    0         0    0     0
  197        0          0    0   0   0    0    0    0         0    0     0
  198        0          0    0   2   0    0    0    0         0    0     0
  199        0          0    0   0   0    0    0    0         0    0     0
  200        1          0    0   0   0    0    0    0         0    0     0
  201        0          0    0   0   0    0    0    0         0    0     0
  202        0          0    0   0   0    0    0    0         0    0     0
  203        0          0    0   0   0    0    0    0         0    0     0
  204        0          0    0   0   0    0    0    0         0    0     0
  205        0          0    0   0   0    0    0    0         0    0     0
  206        0          0    0   0   0    0    0    0         0    0     0
  207        0          0    0   0   0    0    0    0         0    0     0
  208        0          0    0   0   0    0    0    0         0    0     0
  209        0          0    0   0   0    0    0    0         0    0     0
  210        0          0    0   0   0    0    0    0         0    0     0
  211        0          0    0   0   0    0    0    0         0    0     0
  212        0          0    0   0   0    0    0    0         0    0     0
  213        0          0    0   0   0    0    0    0         0    0     0
  214        0          0    0   0   0    0    0    0         0    0     0
  215        0          0    0   0   0    0    0    0         0    0     0
  216        0          0    0   1   0    0    0    0         0    0     0
  217        0          0    0   0   0    0    0    0         0    0     0
  218        0          0    0   0   0    0    0    0         0    0     0
  219        0          0    0   0   0    0    0    0         0    0     0
  220        0          0    0   0   0    0    0    0         0    0     0
  221        0          0    0   0   1    0    0    0         0    0     0
  222        0          0    0   0   0    0    0    0         0    0     0
  223        0          0    0   0   0    0    0    0         0    0     0
  224        0          0    0   0   0    0    0    0         0    0     0
  225        0          0    0   1   0    0    0    0         0    0     0
  226        0          0    0   0   0    0    0    0         0    0     0
  227        0          0    0   0   0    1    0    0         0    0     0
  228        0          0    0   0   0    0    0    0         0    0     0
  229        0          0    0   0   0    0    0    0         0    0     0
  230        0          0    0   0   0    0    0    0         0    0     0
  231        0          0    0   0   0    1    0    0         0    0     0
  232        0          0    0   0   0    0    0    0         0    0     0
  233        0          0    0   0   0    0    0    0         0    0     0
  234        0          0    0   0   1    0    0    0         0    0     0
  235        0          0    0   0   1    0    0    0         0    0     0
  236        0          0    0   0   0    0    0    0         0    0     0
  237        0          0    0   0   0    0    0    0         0    0     0
  238        0          0    0   0   0    0    0    0         0    0     0
  239        0          0    0   0   0    0    0    0         0    0     0
  240        0          0    0   1   0    0    0    0         0    0     0
  241        0          0    0   0   0    1    0    0         0    0     0
  242        0          0    0   0   0    0    0    0         0    0     0
  243        0          0    0   0   0    0    0    0         0    0     0
  244        0          0    0   0   0    0    0    0         0    0     0
  245        0          0    0   0   0    0    0    0         0    0     0
  246        0          0    0   0   0    0    0    0         0    0     0
  247        0          0    0   0   0    0    0    0         0    0     0
  248        0          0    0   0   0    0    1    0         0    0     0
  249        0          0    0   0   0    0    0    0         0    0     0
  250        0          0    0   0   0    0    0    0         0    0     0
  251        0          0    0   0   0    0    0    0         0    0     0
  252        0          0    0   0   0    0    0    0         0    0     0
  253        0          0    0   0   0    0    0    0         0    0     0
  254        0          0    0   0   0    0    0    0         0    0     0
  255        0          0    0   0   0    0    0    0         0    0     0
  256        0          0    0   0   0    0    0    0         0    0     1
  257        0          0    0   0   0    0    0    0         0    0     0
  258        0          0    0   0   0    1    0    1         0    0     0
  259        0          0    0   0   1    0    0    0         0    0     0
  260        0          0    0   0   0    0    0    0         0    0     0
  261        0          0    0   0   0    0    0    0         0    0     0
  262        0          0    0   0   1    0    0    0         0    0     0
  263        0          0    0   0   0    0    0    0         0    0     0
  264        0          0    0   0   0    0    0    0         0    0     0
  265        0          0    1   0   0    1    0    0         0    0     0
  266        0          0    0   0   0    0    0    0         0    0     0
  267        0          0    0   0   1    0    0    0         0    1     0
  268        0          0    0   0   0    0    0    0         0    0     0
  269        0          0    0   0   0    0    0    0         0    0     0
  270        0          0    0   0   0    0    0    0         0    0     0
  271        0          0    0   0   0    0    0    0         0    0     0
  272        0          0    0   0   0    0    0    0         0    0     0
  273        0          0    0   0   0    1    0    0         0    0     0
  274        0          0    0   0   0    0    0    0         0    0     0
  275        0          0    0   0   0    0    0    0         0    0     0
  276        0          0    0   0   0    0    0    0         0    0     0
  277        0          0    0   0   1    0    0    0         0    0     0
  278        0          0    0   0   0    0    0    0         0    0     0
  279        0          0    0   0   0    0    0    0         0    0     0
  280        0          0    0   0   0    0    0    0         0    0     0
  281        0          0    0   0   0    0    0    1         0    0     0
  282        0          0    0   0   0    0    0    0         0    0     0
  283        0          0    0   0   0    0    0    0         0    0     0
  284        0          0    0   0   0    0    0    0         0    0     0
     Terms
Docs  leadership leading learn learning least less level levels life like
  1            0       0     0        0     0    0     0      0    0    0
  2            0       0     0        0     0    0     0      0    0    0
  3            0       0     0        0     0    0     0      0    0    0
  4            0       0     0        0     0    0     0      0    0    0
  5            0       0     0        0     0    0     0      0    0    0
  6            0       0     0        0     0    0     0      0    0    0
  7            0       0     0        0     0    0     0      0    0    0
  8            0       0     0        0     0    0     0      0    0    0
  9            0       0     0        0     0    0     0      0    0    0
  10           0       0     0        1     0    0     0      0    0    0
  11           0       0     0        0     0    0     0      0    0    0
  12           0       0     1        0     0    0     0      0    0    0
  13           0       0     0        0     0    0     0      0    0    1
  14           0       0     0        0     0    0     0      0    0    0
  15           0       0     0        0     0    0     0      0    0    0
  16           1       0     0        0     0    0     0      0    0    0
  17           0       0     0        0     0    0     0      0    0    0
  18           0       0     0        0     0    0     0      0    0    0
  19           0       0     0        0     0    0     0      0    0    0
  20           0       0     0        0     0    0     0      0    0    2
  21           0       0     0        0     0    0     0      0    0    0
  22           0       0     0        0     0    0     0      0    0    0
  23           0       0     0        0     0    1     0      0    0    1
  24           0       0     0        0     0    0     0      0    0    0
  25           0       0     0        0     0    0     0      0    0    0
  26           0       0     0        1     0    0     0      0    0    0
  27           0       0     0        0     0    0     0      0    0    0
  28           0       0     0        0     0    0     0      0    0    0
  29           0       0     0        0     0    0     0      0    0    0
  30           0       0     0        0     0    0     0      0    0    0
  31           0       0     0        0     0    0     0      0    0    0
  32           0       0     0        0     0    0     0      0    0    0
  33           0       0     0        0     0    0     0      0    0    0
  34           0       0     1        0     0    0     0      0    0    0
  35           0       0     0        0     0    0     0      0    0    0
  36           0       0     0        0     0    0     0      0    0    0
  37           0       0     0        0     0    0     0      0    0    1
  38           0       0     0        0     0    0     0      0    0    0
  39           0       0     1        0     0    0     0      0    0    0
  40           0       0     0        0     0    0     0      0    1    0
  41           0       0     0        0     0    0     0      0    0    0
  42           0       0     0        0     0    0     0      0    0    0
  43           0       0     0        0     0    0     0      0    0    0
  44           0       0     0        0     0    0     0      0    0    0
  45           0       0     0        0     0    0     0      0    0    0
  46           0       0     0        0     0    0     0      0    0    1
  47           0       0     0        0     0    0     0      0    0    0
  48           0       0     0        0     0    0     0      0    0    0
  49           0       0     0        0     0    0     0      0    0    0
  50           0       0     0        0     0    0     0      0    0    0
  51           0       0     0        0     0    0     0      0    0    0
  52           0       0     0        0     0    0     0      0    0    0
  53           0       0     0        0     0    0     0      0    0    0
  54           0       0     0        0     0    0     0      0    0    0
  55           0       0     0        0     0    0     0      0    0    0
  56           0       0     1        0     0    0     0      0    0    0
  57           0       0     0        0     0    0     0      0    0    0
  58           0       0     0        0     0    0     0      0    0    0
  59           0       0     0        0     0    0     0      0    0    0
  60           0       0     0        0     0    0     0      0    0    0
  61           0       0     0        0     0    0     0      0    0    0
  62           0       0     0        0     0    0     0      0    0    0
  63           0       0     0        0     0    0     0      0    0    0
  64           0       0     0        0     0    0     0      0    0    0
  65           0       0     0        0     0    0     0      0    0    0
  66           0       0     0        0     0    0     0      1    0    0
  67           0       0     0        0     0    0     0      0    0    0
  68           0       0     0        0     0    0     0      0    0    0
  69           0       1     0        0     0    0     0      0    0    0
  70           0       0     0        0     0    0     0      0    1    0
  71           0       0     0        0     0    0     0      0    0    0
  72           0       0     0        0     0    0     0      0    0    0
  73           0       0     0        1     0    0     0      0    0    0
  74           0       0     0        0     0    0     0      0    0    0
  75           0       0     0        0     0    0     0      0    0    0
  76           0       0     2        0     0    1     0      1    0    0
  77           0       0     0        0     0    0     0      0    0    0
  78           0       0     0        1     0    0     0      0    0    0
  79           0       0     0        0     0    0     0      0    0    0
  80           0       0     0        0     0    0     0      0    0    0
  81           0       0     0        0     0    0     0      0    0    1
  82           0       0     0        0     0    0     0      0    0    0
  83           0       0     0        0     1    0     0      0    0    0
  84           0       0     0        0     0    0     0      0    0    0
  85           0       0     0        0     0    0     0      0    0    0
  86           0       0     0        0     0    0     0      0    0    0
  87           0       0     0        0     0    0     0      0    0    0
  88           0       0     0        0     0    0     0      0    0    0
  89           0       0     0        0     0    0     0      0    0    0
  90           0       0     0        0     0    0     0      0    0    0
  91           0       0     0        0     0    0     0      0    0    0
  92           0       0     0        0     0    0     0      0    0    0
  93           0       0     0        0     0    0     0      0    0    0
  94           0       0     0        1     0    0     0      0    0    0
  95           0       0     1        0     0    0     0      0    0    0
  96           0       0     0        0     0    0     0      0    0    0
  97           0       1     0        0     0    0     0      0    0    0
  98           0       0     0        0     0    0     0      0    0    0
  99           0       0     0        0     0    0     0      0    0    0
  100          0       0     0        0     0    0     0      0    0    0
  101          0       0     0        0     0    0     0      0    0    0
  102          0       0     0        1     0    0     0      0    0    0
  103          0       0     0        0     0    0     0      0    0    0
  104          0       0     0        0     0    0     0      0    0    0
  105          0       0     0        0     0    0     0      0    0    0
  106          0       0     0        0     0    0     0      0    0    0
  107          0       0     0        0     0    0     0      0    0    0
  108          0       0     0        0     0    0     0      0    0    1
  109          0       0     0        0     0    0     0      0    0    0
  110          0       0     0        0     0    0     0      0    0    1
  111          0       0     1        0     0    0     0      0    0    0
  112          0       0     0        0     0    0     0      0    0    0
  113          0       0     0        0     0    0     0      0    0    0
  114          0       0     0        0     0    0     0      0    0    0
  115          0       0     0        0     0    0     0      0    0    0
  116          0       0     0        0     0    0     0      0    0    0
  117          0       0     0        0     0    0     0      0    0    1
  118          0       0     1        0     0    0     0      0    0    0
  119          0       0     0        0     0    0     0      0    0    0
  120          0       0     0        0     0    0     1      0    0    0
  121          0       0     0        0     0    0     0      0    0    2
  122          0       0     0        0     0    0     0      0    0    0
  123          0       0     0        0     0    0     0      0    0    0
  124          0       0     0        0     0    0     0      0    0    0
  125          0       0     0        0     0    0     0      0    0    0
  126          0       0     0        0     0    0     0      0    0    0
  127          0       0     1        0     0    0     0      0    0    0
  128          0       0     1        0     0    0     0      0    0    0
  129          0       0     0        0     0    0     1      0    0    0
  130          0       0     0        0     0    1     0      0    0    0
  131          0       0     0        0     0    0     0      0    0    0
  132          0       0     0        0     0    0     0      0    0    0
  133          0       0     0        0     0    0     0      0    0    1
  134          1       1     0        0     0    0     0      0    0    0
  135          0       0     0        0     0    0     0      0    0    0
  136          1       0     0        0     0    0     0      0    1    0
  137          0       0     1        0     0    0     0      0    0    0
  138          0       0     0        0     0    0     0      0    0    0
  139          0       0     0        0     0    0     0      0    0    0
  140          0       0     0        0     0    0     0      0    0    0
  141          0       0     0        0     0    0     0      0    0    0
  142          0       0     0        0     0    0     0      0    0    0
  143          0       0     0        0     0    0     0      1    1    0
  144          0       0     0        0     0    0     0      0    0    0
  145          0       0     0        0     0    0     0      0    0    0
  146          0       0     0        0     0    0     0      0    0    0
  147          0       0     1        0     1    0     0      0    0    0
  148          0       0     0        0     0    0     0      0    1    0
  149          0       0     0        0     0    0     0      0    0    0
  150          0       0     0        0     0    0     0      0    0    0
  151          0       0     0        0     0    0     0      0    0    0
  152          0       0     0        0     0    0     0      0    0    0
  153          0       0     0        0     0    0     0      0    0    0
  154          0       0     0        0     0    0     0      0    1    0
  155          0       0     0        0     0    0     0      0    0    0
  156          0       0     0        0     0    0     0      0    1    0
  157          0       0     1        0     0    0     0      0    0    0
  158          0       0     0        0     0    0     0      0    0    0
  159          0       0     0        0     0    0     0      0    0    0
  160          1       0     0        0     0    0     0      0    0    0
  161          0       0     0        0     0    0     0      0    0    0
  162          0       0     0        0     0    0     0      0    0    0
  163          0       0     0        0     0    0     0      0    0    0
  164          0       0     0        0     0    0     0      0    0    0
  165          0       0     0        0     0    0     0      0    0    0
  166          0       0     0        0     0    0     0      0    1    0
  167          0       0     1        0     0    0     0      0    0    0
  168          0       0     0        0     0    0     0      0    0    0
  169          0       0     0        0     0    0     0      0    0    1
  170          0       0     0        0     0    0     0      0    0    0
  171          0       0     0        0     0    0     0      0    0    0
  172          0       0     0        0     0    0     0      0    0    0
  173          0       0     0        0     0    0     0      0    0    0
  174          0       0     0        0     0    0     0      0    0    0
  175          0       0     0        0     1    0     0      0    0    0
  176          0       0     0        0     0    0     0      0    0    0
  177          0       0     0        0     0    0     0      0    0    0
  178          0       0     0        0     0    0     0      0    0    0
  179          0       0     0        0     0    0     0      0    2    0
  180          0       0     0        0     0    0     0      0    0    0
  181          0       0     0        0     0    0     0      0    0    0
  182          0       0     0        0     0    0     0      0    0    0
  183          0       0     0        0     0    0     0      0    0    1
  184          0       0     0        0     0    0     0      0    0    1
  185          0       0     0        0     0    0     0      0    0    1
  186          0       0     0        0     0    0     0      0    1    0
  187          0       0     0        0     0    0     0      0    0    0
  188          0       0     0        0     0    0     0      0    0    0
  189          0       0     0        0     0    0     0      0    0    1
  190          0       0     0        0     0    0     0      0    0    0
  191          0       0     0        0     0    0     0      0    1    0
  192          0       0     0        0     0    0     0      0    0    0
  193          0       0     0        0     0    0     1      0    0    0
  194          0       0     1        0     0    0     0      0    0    0
  195          0       0     0        0     0    0     0      0    0    0
  196          0       0     0        0     0    0     0      0    0    0
  197          0       0     0        0     0    0     0      0    0    0
  198          0       0     0        0     0    0     0      0    0    0
  199          0       0     0        0     0    0     0      0    0    0
  200          0       0     0        0     0    0     0      0    0    0
  201          0       0     0        0     0    0     0      0    0    0
  202          0       0     0        0     0    0     0      0    0    0
  203          0       0     0        0     0    0     0      0    0    0
  204          0       0     0        0     0    0     0      0    0    0
  205          0       0     0        0     0    0     0      0    0    0
  206          0       0     0        0     0    0     0      0    0    0
  207          0       0     0        0     0    0     0      0    0    0
  208          0       0     0        0     0    0     0      0    0    0
  209          0       0     0        0     0    0     0      0    0    0
  210          0       0     0        0     0    0     0      0    0    0
  211          0       0     0        0     0    0     0      0    0    0
  212          0       0     0        0     0    0     0      0    0    0
  213          0       0     0        0     0    0     0      0    0    0
  214          0       0     0        0     0    0     0      0    0    0
  215          0       0     0        0     0    0     0      0    0    0
  216          0       0     0        0     0    0     0      0    0    0
  217          0       0     0        0     0    0     0      0    0    0
  218          0       0     0        0     0    0     0      0    0    0
  219          0       0     0        0     0    0     0      0    0    0
  220          0       0     0        0     0    0     1      0    0    0
  221          0       0     0        0     0    0     0      0    1    0
  222          0       0     1        0     0    0     0      0    0    0
  223          0       0     0        0     0    0     0      0    0    0
  224          0       0     0        0     0    0     0      0    0    0
  225          0       0     0        0     0    0     0      0    0    0
  226          0       0     0        0     0    0     0      0    0    0
  227          0       0     0        0     0    0     0      0    0    0
  228          0       0     0        0     0    0     0      0    0    0
  229          0       0     0        0     0    0     0      0    0    0
  230          0       0     0        0     0    0     0      0    0    0
  231          0       0     0        0     0    0     0      0    0    0
  232          0       0     0        1     0    0     0      0    0    0
  233          0       0     0        0     0    0     0      0    0    0
  234          0       0     0        0     0    0     0      0    0    1
  235          0       0     0        0     0    0     0      0    0    0
  236          0       0     0        0     0    0     0      0    0    0
  237          0       0     0        0     0    0     0      0    0    0
  238          0       0     0        0     1    0     0      0    0    0
  239          0       0     0        0     0    0     0      0    0    0
  240          0       0     0        0     0    0     0      0    0    0
  241          0       0     0        0     0    0     0      0    0    0
  242          0       0     0        0     0    0     0      0    0    0
  243          0       0     0        0     0    0     0      0    0    0
  244          1       0     0        1     0    0     0      0    0    0
  245          0       0     0        0     0    0     0      0    0    0
  246          0       0     0        0     0    0     0      0    0    0
  247          0       0     0        0     0    0     0      0    0    0
  248          0       0     0        0     0    0     0      0    0    0
  249          0       1     0        0     0    0     0      0    0    0
  250          0       0     0        0     0    0     0      0    0    0
  251          0       0     0        0     0    0     0      0    0    0
  252          0       0     0        0     0    0     0      0    0    0
  253          0       0     0        0     0    0     0      0    0    0
  254          0       0     0        0     0    0     0      0    0    1
  255          0       0     0        0     0    0     0      0    1    0
  256          0       0     0        0     0    0     0      0    0    0
  257          1       0     0        0     0    0     0      0    0    0
  258          1       0     0        0     0    0     0      0    0    1
  259          0       0     0        0     0    0     0      1    0    0
  260          0       0     0        0     0    0     0      0    0    0
  261          0       0     0        0     0    0     0      0    1    0
  262          0       0     0        0     0    0     0      0    0    0
  263          0       0     0        0     0    0     0      0    0    0
  264          0       0     0        0     0    0     0      0    0    0
  265          0       0     0        0     0    0     0      0    0    0
  266          0       0     0        0     0    0     0      0    0    0
  267          0       0     0        0     0    0     0      0    0    0
  268          0       0     0        0     0    0     0      0    0    0
  269          0       0     0        0     0    0     0      0    0    0
  270          0       0     0        0     0    0     0      0    0    0
  271          0       0     0        0     0    0     0      0    0    0
  272          0       0     0        0     0    0     0      0    0    0
  273          0       0     0        0     0    0     0      0    0    0
  274          0       0     0        0     0    0     0      0    0    0
  275          0       0     0        0     0    0     0      0    0    0
  276          0       0     0        0     0    0     0      0    0    1
  277          0       0     0        0     1    0     1      1    0    0
  278          0       0     0        0     0    0     0      0    0    0
  279          0       0     0        0     0    0     0      0    0    0
  280          0       0     0        0     0    0     0      0    0    0
  281          0       0     0        0     0    0     0      0    0    1
  282          0       0     0        0     0    0     0      0    0    0
  283          0       0     0        0     0    0     0      0    0    0
  284          0       0     0        0     0    0     0      0    0    0
     Terms
Docs  little long lot lots love low lunch made make makes making manage
  1        0    0   0    0    0   0     0    0    0     0      0      0
  2        0    0   0    0    0   0     0    0    0     0      0      0
  3        0    0   0    0    0   0     0    0    0     0      0      0
  4        0    0   0    0    0   0     0    0    0     0      0      0
  5        0    0   0    0    0   0     0    0    0     0      0      0
  6        0    0   1    0    0   0     0    0    0     0      0      0
  7        0    0   0    0    0   0     0    0    0     0      0      0
  8        0    0   0    0    1   0     0    0    0     0      0      0
  9        0    0   0    0    0   0     0    0    0     0      0      0
  10       0    0   0    0    1   0     0    0    0     0      0      0
  11       0    0   0    0    0   0     0    0    0     0      0      0
  12       0    0   0    0    0   0     0    0    0     0      0      0
  13       0    0   0    0    0   0     0    0    1     1      0      0
  14       0    0   0    0    0   0     0    0    0     0      0      0
  15       0    0   0    0    0   0     1    0    0     0      0      0
  16       0    0   0    0    0   0     0    0    0     0      0      0
  17       0    0   0    0    0   0     0    0    1     0      0      0
  18       0    0   0    0    0   0     0    0    0     0      0      0
  19       0    0   0    0    0   0     0    0    1     0      0      0
  20       0    0   0    0    0   0     0    0    0     0      0      0
  21       0    0   0    0    0   0     0    0    0     0      0      0
  22       0    0   0    0    0   0     0    0    0     0      0      0
  23       0    0   0    0    0   0     0    0    0     0      0      0
  24       0    0   0    0    0   0     0    0    0     0      1      0
  25       0    0   0    0    0   0     0    0    0     0      0      0
  26       0    0   0    0    0   0     0    0    1     1      0      0
  27       0    0   0    1    0   0     0    0    0     0      0      0
  28       0    0   0    0    0   0     0    0    0     0      0      0
  29       0    0   0    0    0   0     0    0    0     0      0      0
  30       0    0   0    0    0   0     0    0    1     0      0      0
  31       0    0   0    0    1   0     0    0    0     0      0      0
  32       0    0   0    0    0   0     0    0    0     0      0      0
  33       0    0   0    0    2   0     0    0    1     0      0      0
  34       0    0   0    0    0   0     0    0    0     0      1      0
  35       0    0   0    0    0   0     0    0    1     0      0      0
  36       0    0   0    0    0   0     0    0    0     0      0      0
  37       0    0   1    0    0   0     0    0    0     0      0      0
  38       0    0   0    0    0   0     0    0    0     0      0      0
  39       0    0   0    0    0   0     0    0    0     0      1      0
  40       0    1   0    0    0   0     0    0    0     0      0      0
  41       0    0   1    0    0   0     0    0    1     0      0      0
  42       0    0   0    0    0   0     0    0    0     0      0      0
  43       0    0   1    0    0   0     0    0    0     0      0      0
  44       0    0   0    0    0   0     0    0    0     0      0      0
  45       0    0   0    0    0   0     0    0    0     0      0      0
  46       0    0   0    1    0   0     0    0    0     0      0      0
  47       0    0   0    0    0   0     0    0    1     0      0      0
  48       0    0   0    0    0   0     0    0    0     0      0      0
  49       0    0   0    0    0   0     0    0    0     0      0      0
  50       0    0   0    0    0   0     0    0    0     0      0      0
  51       0    0   0    1    0   0     0    0    2     0      0      0
  52       0    0   0    0    0   0     0    0    1     0      0      0
  53       0    0   0    0    0   0     0    0    0     0      0      0
  54       0    0   0    1    0   0     0    0    0     0      0      0
  55       0    0   0    0    0   0     0    0    1     0      0      0
  56       0    0   1    0    0   0     0    0    0     0      0      1
  57       0    0   0    0    0   0     0    0    0     0      0      0
  58       0    0   0    0    0   0     0    0    0     1      0      0
  59       0    0   0    0    0   0     0    0    0     0      0      0
  60       0    0   0    0    0   0     0    0    0     0      0      0
  61       0    0   0    0    0   0     0    0    1     0      0      0
  62       0    0   1    0    0   0     0    0    0     0      0      0
  63       0    0   0    0    0   0     0    0    0     1      0      0
  64       0    0   0    0    0   0     0    0    0     0      0      0
  65       0    0   0    0    0   0     0    0    0     0      1      0
  66       0    0   0    0    0   0     0    0    0     0      0      0
  67       0    0   0    0    0   0     0    0    0     0      0      0
  68       0    0   0    0    0   0     0    0    0     0      0      0
  69       0    0   0    1    2   0     0    0    0     0      0      0
  70       0    0   0    0    0   0     0    0    0     0      0      0
  71       0    0   0    0    0   0     0    0    1     0      0      0
  72       0    0   0    0    0   0     0    0    0     0      0      0
  73       0    0   1    0    0   0     0    0    0     0      0      0
  74       0    0   0    0    0   1     0    0    0     0      0      0
  75       0    0   0    0    0   0     0    0    0     0      0      0
  76       0    0   0    0    0   0     0    0    0     0      0      0
  77       0    0   0    0    0   0     0    0    0     0      0      0
  78       0    0   0    0    0   0     0    0    0     0      0      0
  79       1    0   0    0    0   0     0    1    0     0      0      0
  80       0    0   0    0    0   0     0    0    0     0      0      0
  81       0    0   0    0    0   0     1    0    1     0      0      0
  82       0    0   0    0    0   0     0    0    0     0      0      0
  83       0    0   0    0    0   0     0    0    0     0      0      0
  84       0    0   0    0    0   0     0    0    0     2      0      0
  85       0    0   0    0    0   0     0    0    0     0      0      0
  86       0    0   0    0    0   0     0    0    0     0      0      0
  87       0    0   1    0    0   0     0    0    0     0      0      0
  88       0    0   0    0    0   0     0    0    0     0      0      0
  89       0    0   0    0    0   0     0    0    0     0      0      0
  90       0    0   0    0    0   0     0    0    0     0      0      0
  91       0    0   0    0    0   0     0    0    0     0      0      0
  92       0    0   0    0    0   0     0    0    0     0      0      0
  93       0    0   0    0    0   0     0    0    0     0      0      0
  94       0    0   0    0    0   0     0    0    0     0      0      0
  95       0    0   0    1    0   0     0    0    0     0      0      0
  96       0    0   0    0    0   0     0    0    0     0      0      0
  97       0    0   0    0    0   0     0    0    0     0      0      0
  98       0    0   0    0    0   0     0    0    0     0      0      0
  99       0    0   0    0    0   0     0    0    0     1      0      0
  100      0    0   0    0    0   0     0    0    0     0      0      0
  101      0    0   0    0    0   0     0    0    0     0      0      0
  102      0    0   0    0    0   0     0    0    0     0      0      0
  103      0    0   0    1    0   0     0    0    0     0      0      0
  104      0    0   0    0    0   0     0    0    0     0      0      0
  105      0    0   0    0    0   0     0    0    0     0      0      0
  106      0    0   0    0    0   0     0    0    0     0      0      0
  107      0    0   1    0    0   0     0    0    0     0      0      0
  108      0    0   0    0    0   0     0    0    1     0      0      0
  109      0    0   0    0    0   0     0    0    0     0      0      0
  110      0    0   0    0    0   0     0    0    0     0      0      0
  111      0    0   1    0    0   0     0    0    0     0      0      0
  112      0    0   0    1    0   0     0    0    0     0      0      0
  113      0    0   1    0    0   0     0    0    0     0      0      0
  114      0    0   0    1    0   0     0    0    0     0      0      0
  115      0    0   0    0    0   0     0    0    0     0      0      0
  116      0    0   0    0    0   0     0    0    0     0      0      0
  117      0    0   0    0    0   0     0    0    1     0      0      0
  118      0    0   0    0    0   0     0    0    0     0      0      0
  119      0    0   0    0    0   0     0    0    0     0      0      0
  120      0    0   0    0    0   0     0    0    0     0      0      0
  121      0    0   0    0    0   0     0    0    0     1      0      0
  122      0    0   1    1    0   0     0    0    0     0      0      0
  123      0    0   1    1    0   0     0    0    0     0      0      0
  124      0    0   0    0    0   0     0    0    0     0      0      0
  125      1    0   0    0    0   0     0    0    0     0      0      0
  126      0    0   0    0    0   0     0    0    0     0      0      0
  127      0    0   0    0    0   0     0    0    0     0      0      0
  128      0    0   0    0    0   0     0    0    0     0      0      0
  129      0    0   0    0    0   0     0    0    0     0      0      0
  130      0    0   0    0    0   0     0    0    0     0      0      0
  131      0    0   0    0    0   0     0    0    0     0      0      0
  132      0    0   1    0    0   0     0    0    0     0      0      0
  133      0    0   0    0    0   0     0    0    0     0      0      0
  134      0    0   0    0    0   0     0    0    2     0      0      0
  135      1    0   0    0    0   0     0    0    0     0      0      0
  136      0    0   1    0    0   0     0    0    1     0      0      0
  137      0    0   1    0    0   0     0    0    0     0      0      0
  138      0    0   0    1    0   0     0    0    0     0      0      0
  139      0    0   0    0    0   0     0    0    0     0      0      0
  140      0    0   0    0    0   0     0    0    0     0      0      0
  141      0    0   0    0    0   0     0    1    0     0      0      0
  142      0    0   0    0    0   0     0    0    0     0      0      0
  143      0    0   0    0    0   0     0    0    0     0      0      0
  144      0    0   0    0    0   0     0    0    0     0      0      0
  145      0    0   0    1    0   0     0    0    0     0      0      0
  146      0    0   0    0    0   0     0    0    0     0      0      0
  147      0    0   0    0    0   0     0    0    0     0      0      0
  148      1    0   1    0    0   0     0    0    0     0      0      0
  149      0    0   0    0    0   0     0    0    0     0      0      0
  150      0    0   0    1    0   0     0    0    0     0      0      0
  151      0    0   0    0    0   0     0    0    0     0      0      0
  152      0    0   0    1    0   0     0    0    0     0      0      0
  153      0    0   1    2    0   0     0    0    0     0      0      0
  154      0    0   0    0    0   0     0    0    1     0      0      0
  155      0    0   0    0    0   0     1    0    0     0      0      0
  156      0    0   0    0    0   0     0    0    0     0      0      0
  157      0    0   0    0    0   0     0    0    0     0      0      0
  158      0    0   0    0    0   0     0    0    0     0      0      0
  159      0    0   0    0    0   0     0    0    0     0      0      0
  160      0    0   0    0    0   0     0    0    0     0      0      0
  161      0    0   0    0    0   0     0    0    0     0      0      0
  162      0    0   0    0    0   0     0    0    0     0      0      0
  163      0    0   0    0    0   0     0    0    0     0      0      0
  164      0    0   0    0    0   0     0    0    0     0      0      0
  165      0    0   0    0    0   0     0    0    0     0      0      0
  166      0    0   0    1    0   0     0    0    0     0      0      0
  167      0    0   1    0    0   0     0    0    0     0      0      0
  168      0    0   0    0    0   0     0    0    0     0      0      0
  169      0    0   1    0    0   0     0    0    0     0      0      0
  170      0    0   0    0    0   0     0    0    0     0      0      0
  171      0    0   0    0    0   0     0    0    0     0      0      0
  172      0    0   0    0    0   0     0    0    0     0      0      0
  173      0    0   0    0    0   0     0    0    0     0      0      0
  174      0    0   0    0    0   0     0    0    0     0      0      0
  175      0    0   0    0    0   0     0    0    0     0      0      0
  176      0    0   0    0    0   0     0    0    0     1      0      0
  177      0    0   0    0    0   0     0    0    0     0      0      0
  178      0    0   0    0    0   0     0    0    0     0      0      0
  179      0    0   0    0    0   0     0    0    0     0      0      0
  180      0    0   0    0    0   0     0    0    0     0      0      0
  181      0    0   0    0    0   0     0    0    0     0      0      0
  182      0    0   0    0    0   0     0    0    0     1      0      0
  183      0    0   0    1    0   0     0    0    0     0      0      0
  184      0    0   0    0    0   0     0    0    0     0      0      0
  185      0    0   0    0    0   0     0    0    0     0      0      0
  186      0    0   0    0    0   0     0    0    1     0      0      0
  187      0    0   0    0    0   0     0    0    0     0      0      0
  188      0    0   0    0    0   0     0    0    1     0      0      0
  189      0    0   0    0    0   0     0    0    0     0      0      0
  190      0    0   0    0    0   0     0    0    0     0      0      0
  191      0    0   0    0    0   0     0    0    0     0      0      0
  192      0    0   0    0    0   0     0    0    0     0      0      0
  193      0    0   0    0    0   0     0    0    0     0      0      0
  194      0    0   1    0    0   0     0    0    0     0      0      0
  195      0    0   0    0    0   0     0    0    0     0      0      0
  196      0    0   0    0    0   0     0    0    0     0      0      0
  197      0    0   0    0    0   0     1    0    0     0      0      0
  198      0    0   0    0    0   0     0    0    0     0      0      0
  199      0    0   0    0    0   0     0    0    0     0      0      0
  200      0    0   0    0    0   0     0    0    0     0      0      0
  201      0    0   0    0    0   0     0    0    0     0      0      0
  202      0    0   0    0    0   0     0    0    0     0      0      0
  203      0    0   0    1    0   0     0    0    0     0      0      0
  204      0    0   0    0    0   0     0    0    0     0      0      0
  205      0    0   0    0    0   0     0    0    0     0      0      0
  206      0    0   1    1    0   0     0    0    0     0      0      0
  207      0    0   0    0    0   0     0    0    0     0      0      0
  208      0    0   0    0    0   0     0    0    0     0      0      0
  209      0    0   0    0    0   0     0    0    0     0      0      0
  210      0    0   0    0    0   0     0    0    0     0      0      0
  211      0    0   0    0    0   0     0    0    0     0      0      0
  212      0    0   0    0    0   0     0    0    0     0      0      0
  213      0    0   0    0    0   0     0    0    0     0      0      0
  214      0    0   0    0    0   0     0    0    0     0      0      0
  215      0    0   0    0    1   0     0    0    0     0      0      0
  216      0    0   0    0    0   0     0    0    0     0      0      0
  217      0    0   0    0    0   0     0    0    0     0      0      0
  218      0    0   1    0    0   0     0    0    0     0      0      0
  219      0    0   0    0    0   0     0    0    0     0      0      0
  220      0    0   0    1    0   0     0    0    0     0      0      0
  221      0    0   0    0    0   0     0    0    1     0      0      0
  222      0    0   0    0    0   0     0    0    0     0      0      0
  223      0    0   0    0    0   0     0    0    0     0      0      0
  224      0    0   0    0    0   0     0    0    0     0      0      0
  225      0    1   0    0    0   0     0    0    0     0      0      0
  226      0    0   0    0    0   0     0    0    0     0      0      0
  227      0    0   1    0    0   0     0    0    1     0      0      0
  228      0    0   0    0    0   0     0    0    0     0      0      0
  229      0    0   0    0    0   0     0    0    0     0      0      0
  230      0    0   0    0    0   0     0    0    0     0      0      0
  231      0    0   0    0    0   0     0    0    0     0      0      0
  232      0    0   0    0    0   0     1    0    0     0      0      0
  233      0    0   0    0    0   0     0    0    0     0      0      0
  234      0    0   0    0    0   0     0    0    1     0      0      0
  235      0    0   0    0    0   0     0    0    0     0      0      0
  236      0    0   0    0    0   0     0    0    0     1      0      0
  237      0    0   0    0    0   0     0    0    0     0      0      0
  238      0    0   0    0    0   0     0    0    0     0      0      0
  239      0    0   0    0    0   0     0    0    0     0      0      0
  240      0    0   0    1    0   0     0    0    0     0      0      0
  241      0    0   1    0    0   0     0    0    0     0      0      0
  242      0    0   0    0    0   0     0    0    0     0      0      0
  243      0    0   0    0    0   0     0    0    0     0      0      0
  244      0    0   0    0    0   0     0    0    0     0      0      0
  245      0    0   0    0    0   0     0    0    0     0      0      0
  246      0    0   0    0    0   0     0    0    0     0      0      0
  247      0    0   0    0    0   0     0    0    0     0      0      0
  248      0    0   0    0    0   0     0    0    0     0      0      0
  249      0    0   0    0    0   0     0    0    0     0      0      0
  250      0    0   0    0    0   0     0    0    0     0      0      0
  251      0    0   0    0    0   0     0    0    0     0      0      0
  252      0    1   0    0    0   0     0    0    0     0      0      0
  253      0    0   0    0    0   0     0    0    0     0      0      0
  254      0    0   0    0    0   0     0    0    0     0      0      0
  255      0    0   0    0    0   0     0    0    0     0      0      0
  256      0    0   0    0    0   0     0    0    0     0      0      0
  257      0    0   0    0    0   0     0    0    0     0      0      0
  258      0    0   0    0    0   0     0    0    0     0      0      1
  259      0    0   0    0    0   0     0    0    0     0      0      0
  260      0    0   0    0    0   0     0    0    1     0      0      0
  261      0    0   0    0    0   0     0    0    0     0      0      0
  262      0    0   0    0    0   0     0    0    0     0      0      0
  263      0    0   0    0    0   0     0    0    0     0      0      0
  264      0    0   0    0    0   0     0    0    0     0      0      0
  265      0    0   0    0    0   0     0    0    0     0      0      0
  266      0    1   0    0    0   0     0    0    0     0      0      0
  267      0    0   0    0    0   0     0    1    0     0      0      0
  268      0    0   0    0    0   0     0    0    0     0      0      0
  269      0    0   0    0    0   0     0    0    0     0      0      0
  270      0    0   0    0    0   0     0    0    0     0      0      0
  271      0    0   0    0    0   0     0    0    0     0      0      0
  272      0    0   1    0    0   0     0    0    0     0      0      1
  273      0    0   0    0    0   0     0    0    0     0      0      0
  274      0    0   0    0    0   0     0    0    0     0      0      0
  275      0    0   0    0    0   0     0    0    0     0      0      0
  276      0    0   0    0    0   0     0    0    1     0      0      0
  277      1    0   0    0    0   0     0    0    0     0      0      0
  278      0    0   1    0    0   0     0    0    0     0      0      0
  279      0    0   0    0    0   0     0    0    0     0      0      0
  280      0    0   0    0    0   0     0    0    0     0      0      0
  281      0    0   0    0    0   0     0    0    0     0      0      0
  282      0    0   0    0    0   0     0    0    0     0      0      0
  283      0    0   0    0    0   0     0    0    0     0      0      0
  284      0    0   0    0    0   0     0    0    0     0      0      0
     Terms
Docs  management manager managers many massages may meals met middle
  1            0       0        0    0        0   0     0   0      0
  2            0       0        0    0        0   0     0   0      0
  3            0       0        0    0        0   0     0   0      0
  4            0       0        0    0        0   0     0   0      0
  5            0       0        0    0        0   0     0   0      0
  6            0       0        0    0        0   0     0   0      0
  7            0       0        0    0        0   0     0   0      0
  8            0       0        0    0        0   0     0   0      0
  9            1       0        0    0        0   0     0   0      0
  10           0       0        0    0        0   0     0   0      0
  11           0       0        0    0        0   0     0   1      0
  12           0       0        0    0        0   0     1   0      0
  13           0       0        0    0        0   0     0   0      0
  14           0       0        0    0        0   0     0   0      0
  15           0       0        0    0        0   0     0   0      0
  16           0       0        0    0        0   0     0   0      0
  17           0       0        0    0        0   0     0   0      0
  18           0       0        0    0        0   0     0   0      0
  19           0       0        0    0        0   0     0   0      0
  20           0       0        0    0        0   0     0   0      0
  21           0       0        0    0        0   0     0   0      0
  22           0       0        0    0        0   0     0   0      0
  23           0       0        0    0        0   0     0   0      0
  24           1       0        0    0        0   0     0   0      0
  25           0       0        0    0        0   0     0   0      0
  26           0       0        0    0        0   0     0   0      0
  27           1       0        0    0        0   0     0   0      0
  28           0       0        0    0        0   0     0   0      0
  29           0       0        0    1        0   0     0   0      0
  30           0       0        0    0        0   0     1   0      0
  31           2       0        0    1        0   0     0   0      0
  32           0       0        0    0        0   0     0   0      0
  33           0       0        0    0        0   0     0   0      0
  34           0       0        0    0        0   0     0   0      0
  35           0       0        0    0        0   0     0   0      0
  36           0       0        0    0        1   0     1   0      0
  37           0       0        0    0        0   0     0   0      0
  38           0       0        0    1        0   0     0   0      0
  39           0       0        1    0        0   0     0   0      0
  40           0       0        0    0        0   0     0   0      0
  41           0       0        0    0        0   0     0   0      0
  42           0       0        0    0        0   0     0   0      0
  43           0       0        0    0        0   0     0   0      0
  44           0       0        0    0        0   0     0   0      0
  45           1       0        0    0        0   0     0   0      0
  46           0       0        0    0        1   0     0   0      0
  47           0       0        0    1        0   0     0   1      0
  48           0       0        0    0        0   0     0   0      0
  49           1       0        0    1        0   0     0   0      0
  50           0       0        0    0        0   0     0   0      0
  51           0       0        0    0        0   0     0   0      0
  52           0       0        0    0        0   0     0   0      0
  53           0       0        0    0        1   0     0   0      0
  54           0       0        0    0        0   0     0   0      0
  55           0       0        0    0        0   0     0   0      0
  56           0       1        0    0        0   0     0   0      0
  57           0       0        0    0        0   1     0   0      0
  58           0       0        0    0        0   0     0   0      0
  59           0       0        0    0        0   0     0   0      0
  60           0       0        0    0        0   0     0   0      0
  61           0       0        0    0        0   0     0   0      0
  62           0       0        0    0        0   0     0   0      0
  63           0       0        0    0        1   0     0   0      0
  64           0       0        0    0        0   0     0   0      0
  65           0       0        0    0        0   0     0   0      0
  66           0       0        0    0        0   0     0   0      0
  67           0       0        0    0        0   0     0   0      0
  68           0       0        0    0        0   0     0   0      0
  69           1       0        0    0        0   0     0   0      0
  70           0       0        0    0        0   0     0   0      0
  71           0       0        0    1        0   0     0   0      0
  72           0       0        0    0        0   0     0   0      0
  73           0       0        1    0        0   1     0   0      1
  74           0       0        0    0        0   0     0   0      0
  75           0       0        0    0        0   0     0   0      0
  76           0       0        0    0        0   0     0   0      0
  77           0       0        0    0        0   0     0   0      0
  78           0       0        0    1        0   0     0   0      0
  79           0       0        0    0        0   0     0   1      0
  80           0       0        0    0        0   0     0   0      0
  81           0       0        0    0        0   0     0   0      0
  82           0       0        1    0        0   0     0   0      0
  83           0       0        0    0        0   0     0   0      0
  84           0       0        0    1        0   0     0   0      0
  85           0       0        0    0        0   0     0   0      0
  86           0       0        0    0        0   0     0   0      0
  87           0       0        0    0        0   0     0   0      0
  88           0       0        0    0        0   0     0   0      0
  89           0       0        0    0        0   0     0   0      0
  90           0       0        0    0        0   0     0   0      0
  91           0       0        0    0        0   0     0   0      0
  92           0       0        0    0        0   0     0   0      0
  93           0       0        0    0        0   0     0   0      0
  94           0       0        0    0        0   0     0   0      0
  95           0       0        0    0        0   0     1   0      0
  96           0       0        0    0        0   0     0   0      0
  97           0       0        0    0        0   0     0   0      0
  98           0       0        0    0        0   0     0   0      0
  99           1       0        0    0        0   0     0   0      0
  100          0       0        0    0        0   0     0   0      0
  101          0       0        0    0        0   0     0   0      0
  102          0       0        0    0        0   0     0   0      0
  103          0       0        0    0        0   0     0   0      0
  104          0       0        0    0        0   0     0   0      0
  105          0       0        0    0        0   0     0   0      0
  106          0       0        0    1        0   0     0   0      0
  107          0       0        0    0        0   0     0   0      0
  108          0       0        0    1        0   0     0   0      0
  109          0       0        0    0        0   0     1   0      0
  110          0       0        0    1        0   0     0   0      0
  111          0       0        0    0        0   0     0   0      0
  112          0       0        0    0        0   0     0   0      0
  113          0       0        0    0        0   0     0   0      0
  114          0       0        0    0        0   0     0   0      0
  115          0       0        0    0        0   0     0   0      0
  116          0       0        0    0        0   0     0   0      0
  117          0       0        0    0        0   0     0   0      0
  118          0       0        0    1        0   0     0   0      0
  119          0       0        0    0        0   0     0   0      0
  120          0       0        0    0        0   0     0   0      0
  121          0       0        0    0        0   0     0   0      0
  122          0       0        0    0        0   0     0   0      0
  123          0       0        0    0        0   0     0   0      0
  124          1       0        0    0        0   0     0   0      0
  125          0       0        0    0        0   0     0   0      0
  126          1       0        0    0        0   0     0   1      0
  127          0       0        0    0        0   0     0   0      0
  128          0       0        0    0        0   0     0   0      0
  129          0       0        0    0        0   0     0   0      0
  130          0       0        0    0        0   0     0   0      0
  131          0       0        0    0        0   0     0   0      0
  132          0       0        0    0        0   0     1   0      0
  133          0       0        0    0        0   0     0   0      0
  134          0       0        0    0        0   0     0   0      0
  135          0       0        0    0        0   0     0   0      0
  136          0       0        0    0        0   0     0   0      0
  137          0       0        0    0        0   0     0   0      0
  138          1       0        0    1        0   0     0   0      0
  139          0       0        0    0        0   0     0   0      0
  140          1       0        0    0        0   0     0   0      0
  141          0       0        0    0        0   0     0   0      0
  142          0       0        0    1        0   0     0   0      0
  143          1       1        0    0        0   0     0   0      0
  144          0       0        0    0        0   0     0   0      0
  145          0       0        0    0        0   0     0   0      0
  146          1       0        0    0        0   0     0   0      0
  147          0       0        1    0        0   0     0   0      0
  148          0       0        0    0        0   0     0   0      0
  149          0       0        0    0        0   0     0   0      0
  150          0       0        0    0        0   0     0   0      0
  151          0       0        0    0        0   0     0   0      0
  152          0       0        0    0        0   0     0   0      0
  153          0       0        0    0        0   0     0   0      0
  154          0       0        0    0        0   0     0   0      0
  155          0       0        0    0        1   0     0   0      0
  156          0       0        0    0        0   0     0   0      0
  157          0       0        0    0        0   0     0   0      0
  158          0       0        0    0        0   0     0   0      0
  159          0       0        0    0        0   0     0   0      0
  160          0       0        0    0        0   0     0   0      0
  161          0       0        0    0        0   0     0   0      0
  162          0       0        0    0        0   0     1   0      0
  163          0       0        0    0        0   0     0   0      0
  164          0       0        0    0        0   0     0   0      0
  165          0       0        0    0        0   0     0   0      0
  166          0       0        0    0        0   0     0   0      0
  167          0       0        0    0        0   0     0   0      0
  168          0       0        0    0        1   0     0   0      0
  169          0       0        0    1        0   0     0   0      0
  170          0       0        0    0        0   0     0   0      0
  171          0       0        1    0        0   0     0   0      0
  172          0       0        0    0        0   0     0   0      0
  173          0       0        0    0        0   0     0   0      0
  174          0       0        0    0        0   0     0   0      0
  175          0       0        0    0        0   0     0   0      0
  176          0       0        0    0        0   0     0   0      0
  177          0       0        0    0        0   0     0   0      0
  178          0       0        0    0        0   0     0   0      0
  179          0       0        0    0        0   0     0   0      0
  180          0       0        0    0        0   0     0   0      0
  181          0       0        1    0        0   0     0   0      0
  182          0       0        0    1        0   0     0   0      0
  183          0       0        0    0        0   0     0   0      0
  184          0       0        0    0        0   0     0   0      0
  185          0       0        0    1        0   0     0   0      0
  186          0       0        0    0        0   0     0   0      0
  187          0       0        0    0        0   0     0   0      0
  188          0       0        0    0        0   0     0   0      0
  189          0       0        0    0        0   0     0   0      0
  190          0       0        0    0        0   0     0   0      0
  191          0       0        0    0        0   0     0   0      0
  192          0       0        0    0        0   0     0   0      0
  193          1       0        0    1        0   0     0   0      0
  194          0       0        0    0        0   0     0   0      0
  195          0       0        0    0        0   0     0   0      0
  196          0       0        0    0        0   0     0   0      0
  197          0       0        0    0        0   0     0   0      0
  198          0       0        0    0        0   0     0   0      0
  199          0       0        0    0        0   0     0   0      0
  200          0       0        0    0        0   0     0   0      0
  201          0       0        0    0        0   0     0   0      0
  202          0       0        0    0        0   0     0   0      0
  203          0       0        0    0        0   0     0   0      0
  204          0       0        0    0        0   0     0   0      0
  205          0       0        0    0        0   0     0   0      0
  206          0       0        0    0        0   0     0   0      0
  207          0       0        0    0        0   0     0   0      0
  208          0       0        0    0        1   0     0   0      0
  209          0       0        0    0        0   0     0   0      0
  210          0       0        0    0        0   0     0   0      0
  211          0       0        0    0        0   0     0   0      0
  212          0       0        0    0        0   0     0   0      0
  213          0       0        0    0        1   0     0   0      0
  214          0       0        0    0        0   0     0   0      0
  215          0       0        1    0        0   0     0   0      0
  216          0       0        0    0        0   0     0   0      0
  217          0       0        0    0        0   0     0   0      0
  218          0       0        0    0        0   0     0   0      0
  219          0       0        0    0        0   0     0   0      0
  220          0       0        0    0        0   0     0   0      0
  221          0       0        0    0        0   0     0   0      0
  222          0       0        0    1        0   0     0   0      0
  223          0       0        0    0        0   0     0   0      0
  224          0       0        0    0        0   0     0   0      0
  225          0       0        0    0        0   0     0   0      0
  226          0       0        0    0        0   0     0   0      0
  227          0       0        0    0        0   0     0   0      0
  228          0       0        0    0        0   0     0   0      0
  229          0       0        0    0        1   0     0   0      0
  230          0       0        0    0        0   0     0   0      0
  231          0       0        0    0        0   0     0   0      0
  232          0       0        0    2        0   0     0   0      0
  233          0       0        0    0        0   0     0   0      0
  234          0       0        0    0        0   0     0   0      0
  235          0       0        0    0        0   0     0   1      0
  236          0       0        0    1        0   0     0   0      0
  237          0       0        0    0        0   0     1   0      0
  238          0       0        0    0        0   0     0   0      0
  239          0       0        0    0        0   0     0   0      0
  240          0       0        0    0        0   0     0   0      0
  241          0       0        0    0        0   0     0   0      0
  242          0       0        1    0        0   0     0   0      0
  243          0       0        0    0        0   0     0   0      0
  244          0       0        0    0        0   0     0   0      0
  245          0       0        0    0        0   0     0   0      0
  246          0       0        0    1        0   0     0   0      0
  247          0       0        0    0        0   0     0   0      0
  248          0       0        0    2        1   0     0   0      0
  249          0       0        0    1        0   0     0   0      0
  250          0       0        0    0        0   0     0   0      0
  251          0       0        0    0        0   0     0   0      0
  252          0       0        0    0        0   0     0   0      0
  253          0       0        0    0        0   0     0   0      1
  254          0       0        0    0        0   1     0   0      0
  255          0       0        0    0        0   0     0   0      0
  256          0       0        0    0        0   0     0   0      0
  257          0       0        0    1        0   0     0   0      0
  258          1       0        1    0        0   0     0   0      0
  259          0       0        0    0        0   0     0   0      0
  260          1       0        0    0        0   0     0   0      0
  261          0       0        0    0        0   0     0   0      0
  262          0       0        0    0        0   0     0   0      0
  263          0       0        0    0        0   0     0   0      0
  264          0       0        0    0        0   0     0   0      0
  265          0       0        1    0        0   0     0   0      0
  266          1       0        0    0        0   0     0   0      0
  267          0       0        2    0        0   0     0   0      1
  268          0       0        0    1        0   0     0   0      0
  269          0       0        0    0        0   0     0   0      0
  270          0       0        0    0        0   0     0   0      0
  271          0       0        0    0        0   0     0   0      0
  272          0       1        0    0        0   0     0   0      0
  273          0       0        0    0        0   3     0   0      0
  274          0       0        1    0        0   0     0   0      1
  275          0       0        0    0        0   0     0   0      0
  276          1       0        0    0        0   1     0   0      0
  277          2       1        0    0        0   0     0   0      1
  278          0       1        0    0        0   0     0   0      0
  279          0       0        0    0        0   0     0   0      0
  280          0       1        2    0        0   0     0   0      0
  281          0       0        1    0        0   0     0   0      0
  282          0       0        1    0        0   0     0   0      1
  283          0       0        0    0        0   1     0   0      0
  284          0       0        0    0        0   0     0   0      0
     Terms
Docs  millions mostly motivated move much name need needs never new nice
  1          0      0         0    0    0    0    0     0     0   0    0
  2          0      0         0    0    0    0    0     0     0   0    0
  3          0      0         0    0    0    0    0     0     0   0    0
  4          0      0         0    0    0    0    0     0     0   0    0
  5          0      0         0    0    0    0    1     0     0   0    0
  6          0      0         0    0    0    0    0     0     0   0    0
  7          0      0         0    0    0    0    0     0     0   1    0
  8          0      0         0    0    0    0    0     0     0   0    0
  9          0      0         0    0    0    0    0     0     0   0    0
  10         0      0         0    0    0    0    0     0     0   0    0
  11         0      0         0    0    0    0    0     0     0   0    0
  12         0      0         0    0    0    0    0     0     0   0    0
  13         0      0         0    0    0    0    0     0     0   0    0
  14         0      0         0    0    0    0    0     0     0   0    0
  15         0      0         0    0    0    0    0     0     0   0    0
  16         0      1         0    0    0    0    0     0     0   0    0
  17         1      0         0    0    0    0    0     0     0   0    0
  18         0      0         0    0    0    0    0     0     0   0    0
  19         0      0         0    1    0    0    1     0     0   0    0
  20         0      0         0    0    0    0    0     0     0   0    0
  21         0      0         0    0    0    0    0     0     0   0    1
  22         0      0         0    0    0    0    0     0     0   0    0
  23         0      0         0    0    1    0    0     0     0   0    0
  24         0      0         0    1    0    0    0     0     0   1    0
  25         0      0         0    0    0    0    0     0     0   0    0
  26         0      0         0    0    0    0    0     0     0   0    0
  27         0      0         0    0    0    0    0     0     0   0    0
  28         0      0         0    0    0    0    0     0     0   0    0
  29         0      0         0    0    0    0    0     0     0   0    0
  30         0      0         0    0    0    0    0     0     0   0    0
  31         0      0         0    0    0    0    0     0     0   1    0
  32         0      0         0    0    0    0    0     0     0   0    0
  33         0      0         0    0    0    0    0     0     0   0    0
  34         0      0         0    0    0    0    0     0     0   0    0
  35         0      0         0    0    0    0    0     0     0   0    0
  36         0      0         0    0    1    0    0     0     0   0    0
  37         0      0         0    0    0    0    0     0     1   0    0
  38         0      0         0    1    0    0    0     0     0   0    0
  39         0      0         0    0    0    0    0     0     0   0    0
  40         0      0         0    0    0    0    0     0     0   0    0
  41         0      0         0    0    0    0    0     0     0   0    0
  42         0      0         0    0    0    0    0     0     0   0    0
  43         0      0         0    0    0    0    0     0     0   0    0
  44         0      0         0    0    0    0    0     0     0   0    0
  45         0      0         0    0    0    0    0     0     0   0    0
  46         0      0         0    0    0    0    0     0     0   1    0
  47         0      0         0    0    0    0    0     0     0   0    0
  48         0      0         0    0    0    0    0     0     0   0    0
  49         0      0         0    0    0    0    0     0     0   0    0
  50         0      1         0    0    0    0    0     0     0   0    0
  51         0      0         0    0    1    0    0     0     0   0    0
  52         0      0         0    0    0    0    0     0     0   0    0
  53         0      0         0    0    0    0    0     0     0   0    0
  54         0      0         0    0    0    0    0     0     0   0    0
  55         0      0         0    0    0    0    0     0     0   1    0
  56         0      0         0    0    0    0    0     0     0   0    1
  57         0      0         0    0    0    0    0     0     0   0    0
  58         0      0         0    0    2    0    0     0     0   0    0
  59         0      0         0    0    0    0    0     0     0   0    0
  60         0      0         0    0    0    0    0     0     0   0    0
  61         0      0         0    0    0    0    0     0     0   0    0
  62         0      0         0    0    0    0    0     0     0   0    0
  63         0      0         0    0    0    0    0     0     0   0    0
  64         0      0         0    0    0    0    0     0     0   0    1
  65         0      0         0    0    0    0    0     0     0   0    0
  66         0      0         0    0    0    0    0     0     0   0    0
  67         0      0         0    0    1    0    0     0     0   0    0
  68         0      0         0    0    0    0    0     0     0   0    0
  69         0      0         0    0    0    0    0     0     0   0    0
  70         0      0         0    0    0    0    0     0     0   0    0
  71         0      0         0    0    0    0    0     0     0   0    0
  72         1      0         0    0    0    0    0     0     0   0    0
  73         0      1         0    0    1    0    0     0     0   0    0
  74         0      0         0    0    0    0    0     0     0   0    0
  75         0      0         0    0    0    0    0     0     0   0    0
  76         0      0         0    0    0    0    0     0     0   0    0
  77         0      0         0    0    0    0    0     0     1   0    0
  78         0      0         0    0    0    0    0     0     0   0    0
  79         0      0         1    0    0    0    0     0     0   0    0
  80         0      0         0    0    0    0    0     0     0   0    0
  81         0      0         0    0    0    0    1     0     0   0    0
  82         0      0         1    0    0    0    0     0     0   0    0
  83         0      0         0    0    0    0    0     0     0   0    0
  84         0      0         0    0    1    0    0     0     0   1    0
  85         0      0         0    0    0    0    0     0     0   0    0
  86         0      0         0    0    0    0    0     0     0   0    0
  87         0      0         0    0    0    0    0     0     0   0    0
  88         0      0         0    0    0    0    0     0     0   0    0
  89         0      0         0    0    0    0    0     0     0   0    0
  90         0      0         0    1    0    0    0     0     0   0    0
  91         0      0         0    0    0    0    0     0     0   0    0
  92         0      0         0    0    0    0    0     0     0   0    0
  93         0      0         0    0    0    0    0     0     0   0    0
  94         0      0         0    0    0    0    0     0     0   0    0
  95         0      0         0    0    0    0    0     0     0   0    0
  96         2      0         1    0    0    0    0     0     0   0    0
  97         0      0         0    0    0    0    0     0     0   0    0
  98         0      0         0    0    0    0    0     0     0   0    0
  99         0      0         0    0    0    0    0     0     0   0    0
  100        0      0         0    0    0    0    0     0     0   0    0
  101        0      0         0    0    0    0    0     0     0   0    0
  102        0      0         0    0    0    0    0     0     0   0    0
  103        0      0         0    0    0    0    0     0     0   0    0
  104        0      0         0    0    0    0    0     0     0   0    0
  105        0      0         0    0    0    0    0     0     0   0    0
  106        0      0         0    0    0    0    0     0     0   0    0
  107        0      0         0    0    0    0    0     0     1   0    1
  108        0      0         0    0    0    0    0     0     0   0    0
  109        0      0         0    0    0    0    0     0     0   0    0
  110        0      0         0    0    0    0    0     0     0   0    0
  111        0      0         0    0    0    0    0     0     0   0    0
  112        0      0         0    0    0    0    0     0     0   0    0
  113        0      0         0    0    0    0    0     0     0   0    0
  114        0      0         0    0    0    0    0     0     0   0    0
  115        0      0         0    0    0    0    0     0     0   0    0
  116        0      0         0    0    0    0    0     0     0   0    0
  117        0      0         0    0    0    0    0     0     0   0    0
  118        0      0         0    0    0    0    0     0     0   0    1
  119        0      0         0    0    0    0    0     0     0   0    0
  120        0      0         0    0    0    0    0     0     0   0    0
  121        0      0         0    0    0    0    0     0     0   0    0
  122        0      0         0    0    0    0    0     0     0   0    0
  123        0      0         0    0    0    0    0     0     0   0    0
  124        0      0         0    0    0    0    0     0     0   0    0
  125        0      0         0    0    0    0    0     0     0   0    0
  126        0      0         0    0    0    0    0     0     0   0    0
  127        0      0         0    0    0    0    0     0     0   0    0
  128        0      0         0    0    0    0    0     0     0   0    0
  129        0      0         0    0    0    0    0     0     0   0    0
  130        0      0         0    0    0    0    0     0     0   0    0
  131        0      0         0    0    0    0    0     0     0   0    0
  132        0      0         0    0    0    0    0     0     0   0    0
  133        0      0         0    0    0    0    0     0     0   0    0
  134        0      0         0    0    0    0    0     0     0   0    0
  135        0      0         0    0    0    0    0     0     0   0    0
  136        1      0         0    0    0    0    0     0     0   0    0
  137        0      0         0    0    0    0    0     0     0   0    0
  138        0      0         0    0    0    0    0     0     0   1    0
  139        0      0         0    0    0    0    0     0     0   0    0
  140        0      0         0    0    0    0    0     0     0   0    0
  141        0      0         0    0    0    0    0     0     0   0    0
  142        0      0         1    0    1    0    0     0     0   0    0
  143        0      0         0    0    0    0    0     0     0   0    0
  144        0      0         0    0    0    0    0     0     0   0    0
  145        0      0         0    0    0    0    0     0     0   0    0
  146        0      0         0    0    0    1    0     0     0   0    0
  147        0      0         0    0    0    0    0     0     0   1    0
  148        0      0         0    0    0    0    0     0     0   0    0
  149        0      0         0    0    0    0    0     0     0   0    0
  150        0      0         1    0    0    0    0     0     0   1    0
  151        0      0         0    0    0    0    0     1     0   0    0
  152        0      0         0    0    0    0    0     0     0   0    0
  153        0      0         0    0    1    0    0     0     0   0    0
  154        0      0         0    0    0    0    0     0     0   0    0
  155        0      0         0    0    0    0    0     0     0   0    0
  156        0      0         0    0    0    0    0     0     0   0    0
  157        0      0         0    0    0    0    0     0     0   0    0
  158        0      0         0    0    0    0    0     0     0   0    0
  159        0      0         0    0    0    0    0     0     0   0    0
  160        0      0         0    0    0    0    0     0     0   0    0
  161        0      0         0    0    0    0    0     0     0   0    1
  162        0      0         0    0    0    0    0     0     0   0    0
  163        1      0         0    0    0    0    0     0     0   0    0
  164        0      0         0    0    0    0    0     0     0   0    0
  165        0      0         0    0    0    0    0     0     0   0    0
  166        0      0         0    0    0    0    0     0     0   0    0
  167        0      0         0    0    0    0    0     0     0   0    0
  168        0      0         0    0    0    1    0     0     0   0    0
  169        0      0         0    0    0    0    0     0     0   0    1
  170        0      0         0    1    0    0    0     0     0   0    0
  171        0      0         0    0    1    0    0     0     0   0    0
  172        0      0         0    0    0    0    0     0     0   0    1
  173        0      0         0    0    0    0    0     0     0   0    0
  174        0      0         0    0    0    0    0     0     0   0    0
  175        0      0         0    0    0    0    0     0     0   1    0
  176        0      0         0    0    0    0    0     0     0   0    0
  177        0      0         0    0    0    0    0     0     0   0    0
  178        0      0         0    0    0    0    0     0     0   0    0
  179        0      0         0    0    0    0    0     0     0   0    0
  180        0      0         0    0    0    0    0     0     0   0    0
  181        0      0         0    0    0    0    0     0     0   0    0
  182        0      0         0    0    0    0    0     0     0   0    0
  183        0      0         0    0    0    0    0     0     0   0    0
  184        0      0         0    0    0    0    0     0     0   0    0
  185        0      0         0    0    0    0    0     0     0   0    1
  186        0      0         0    0    0    0    1     0     0   0    0
  187        0      0         0    0    0    0    0     0     0   0    0
  188        0      0         0    0    0    0    0     0     0   0    0
  189        0      0         0    0    0    0    0     0     0   1    0
  190        0      0         0    0    0    0    0     0     0   0    0
  191        0      0         0    0    0    0    0     0     0   0    0
  192        0      0         0    0    0    0    0     0     0   0    0
  193        0      0         0    0    0    0    0     0     0   0    0
  194        0      0         0    0    0    0    0     0     0   0    0
  195        0      0         0    0    0    0    0     0     0   0    0
  196        0      0         0    0    0    0    0     0     0   1    0
  197        0      0         0    0    0    0    0     0     0   0    0
  198        0      0         0    0    0    0    0     0     0   0    0
  199        0      0         0    0    0    0    0     0     0   0    0
  200        0      0         0    0    0    1    0     0     0   0    0
  201        0      0         0    0    0    0    0     0     0   0    0
  202        0      0         0    0    0    0    0     0     2   0    0
  203        0      0         0    0    0    0    0     0     0   0    0
  204        0      0         0    0    0    0    0     0     0   0    0
  205        0      0         0    0    0    0    0     0     0   0    0
  206        0      0         0    0    0    0    0     0     0   0    0
  207        0      0         0    0    0    0    0     0     0   0    0
  208        0      0         0    0    0    0    0     0     0   0    0
  209        0      0         0    0    0    0    0     0     0   0    0
  210        0      0         0    0    0    0    0     0     1   0    0
  211        0      0         0    0    0    0    0     0     0   1    0
  212        0      0         0    0    0    0    0     0     0   0    0
  213        0      0         1    0    0    0    0     0     0   1    0
  214        0      0         0    0    0    0    0     0     0   0    0
  215        0      0         0    0    0    0    0     0     0   0    0
  216        0      0         0    0    0    0    0     0     0   0    0
  217        0      0         0    0    0    0    0     0     0   0    0
  218        0      0         0    0    0    0    0     0     0   0    0
  219        0      0         0    0    1    0    0     0     0   0    0
  220        0      0         0    0    0    0    0     0     0   0    0
  221        1      0         0    0    0    0    0     0     0   0    0
  222        0      0         0    0    0    0    0     0     0   0    0
  223        0      0         0    0    0    0    0     0     0   0    0
  224        0      0         0    0    0    0    0     0     0   0    0
  225        0      0         0    0    0    0    0     0     0   0    0
  226        0      0         0    0    0    0    0     0     0   0    0
  227        0      0         0    0    0    0    0     0     0   0    0
  228        0      0         0    0    0    0    0     0     0   0    0
  229        0      0         0    0    0    0    0     0     0   0    0
  230        0      0         0    0    0    0    0     0     0   0    0
  231        0      0         0    0    0    0    0     0     0   0    0
  232        0      0         0    1    0    0    0     0     0   0    0
  233        0      0         0    1    0    0    0     0     0   0    0
  234        0      0         0    0    0    0    0     0     0   0    0
  235        0      0         0    0    0    0    0     0     0   0    0
  236        0      0         0    0    0    0    0     0     0   0    0
  237        0      0         0    0    0    0    1     0     0   0    0
  238        0      0         0    0    0    0    0     0     0   0    0
  239        0      0         0    0    0    0    0     0     0   0    0
  240        0      0         0    0    0    0    0     0     0   0    0
  241        0      0         0    0    0    0    0     0     0   0    0
  242        0      0         0    0    0    0    0     0     0   0    0
  243        0      0         0    0    0    0    0     0     0   0    0
  244        0      0         0    0    0    0    0     0     0   0    0
  245        0      0         0    0    0    0    0     0     0   0    0
  246        0      0         0    0    0    0    0     0     0   0    0
  247        0      0         0    0    0    0    0     0     0   0    0
  248        0      0         0    0    0    0    0     0     0   0    0
  249        0      0         0    0    0    0    0     0     0   0    0
  250        0      0         0    0    1    0    0     0     0   0    0
  251        0      0         0    0    0    0    0     0     0   0    0
  252        0      0         0    0    0    0    0     0     0   0    0
  253        0      0         0    0    0    0    0     0     0   0    0
  254        0      0         0    0    0    1    0     0     0   0    0
  255        0      0         0    0    1    0    0     0     0   0    0
  256        0      0         0    0    1    0    0     0     0   0    0
  257        0      0         0    0    1    0    0     0     0   0    0
  258        0      0         0    0    0    0    0     0     0   0    0
  259        0      0         0    0    0    0    0     0     0   0    0
  260        0      0         0    0    0    0    0     0     1   0    0
  261        0      0         0    0    0    0    1     0     0   0    0
  262        0      0         0    0    0    0    0     0     0   0    0
  263        0      0         0    0    1    0    0     0     0   0    0
  264        0      0         0    0    0    0    0     1     0   0    0
  265        0      0         0    0    1    0    0     0     0   0    0
  266        0      0         0    0    0    0    0     0     0   0    0
  267        0      0         0    0    0    0    0     0     0   0    0
  268        0      0         0    0    0    0    0     0     0   0    0
  269        0      0         0    0    0    0    0     0     0   0    0
  270        0      0         0    0    0    0    0     0     0   0    0
  271        0      0         0    0    0    0    0     0     0   0    0
  272        0      0         0    0    0    0    1     0     0   0    0
  273        0      0         0    0    1    0    0     0     0   0    0
  274        0      0         0    0    0    0    0     0     0   0    0
  275        0      0         0    0    0    0    0     0     0   0    0
  276        0      0         0    0    0    0    1     0     0   1    0
  277        0      0         0    0    0    0    0     0     0   0    0
  278        0      0         0    0    0    0    0     0     0   0    0
  279        0      0         0    0    0    0    0     0     0   0    0
  280        0      0         0    0    0    0    0     0     0   0    0
  281        0      0         0    0    0    0    0     0     0   0    0
  282        0      0         0    0    0    0    0     0     0   0    0
  283        0      0         0    0    0    0    0     0     0   0    0
  284        0      0         0    0    1    0    0     0     0   0    0
     Terms
Docs  nothing now number office offices often one onsite open
  1         0   0      0      0       0     0   1      0    0
  2         0   0      0      0       0     0   0      0    0
  3         0   0      0      0       0     0   0      0    0
  4         0   0      0      0       0     0   0      0    0
  5         0   0      0      0       0     0   0      0    0
  6         0   0      0      0       0     0   0      0    0
  7         0   0      0      0       0     0   0      0    0
  8         0   0      0      0       0     0   0      0    0
  9         0   0      0      0       0     0   0      0    1
  10        0   0      0      0       0     0   0      0    0
  11        0   0      0      0       0     0   1      0    1
  12        0   0      1      0       0     0   0      0    0
  13        0   0      0      0       0     0   1      0    0
  14        0   0      0      0       0     0   0      0    0
  15        0   0      0      0       0     0   0      0    0
  16        0   0      0      0       0     0   0      0    0
  17        0   0      0      0       0     0   0      0    0
  18        0   0      0      0       0     0   0      0    1
  19        0   0      0      0       0     0   1      0    0
  20        0   0      0      0       0     0   0      0    0
  21        0   0      0      0       0     0   1      0    0
  22        0   0      0      0       0     0   0      0    0
  23        0   0      0      0       0     0   0      0    0
  24        0   0      0      0       0     0   0      0    0
  25        0   0      0      0       0     0   0      0    0
  26        0   0      0      0       0     0   1      0    0
  27        0   0      0      0       0     0   0      0    0
  28        0   0      0      0       0     0   0      0    0
  29        0   0      0      0       0     0   0      0    0
  30        0   0      0      0       0     0   0      0    0
  31        0   0      0      0       0     0   0      0    0
  32        0   0      0      0       0     0   0      0    0
  33        0   0      0      0       0     0   1      0    0
  34        0   0      0      0       0     0   0      0    0
  35        0   0      0      0       0     0   0      0    0
  36        0   0      0      0       0     0   0      0    0
  37        0   0      0      0       0     0   0      0    0
  38        0   0      0      0       0     0   1      0    0
  39        0   0      0      0       0     0   1      0    0
  40        0   0      0      0       0     0   0      0    0
  41        0   0      0      0       0     0   0      0    0
  42        0   1      0      0       0     0   0      0    0
  43        0   0      0      0       0     0   0      0    0
  44        0   0      0      0       0     0   1      0    0
  45        0   0      0      0       0     0   0      0    0
  46        0   0      0      1       0     0   0      0    2
  47        0   0      0      0       0     0   0      0    0
  48        0   0      0      0       0     0   0      0    0
  49        0   0      0      0       0     1   0      0    0
  50        0   0      0      0       0     0   0      0    0
  51        0   0      0      0       0     0   0      0    0
  52        0   0      0      0       0     0   0      0    0
  53        0   0      0      0       0     0   0      1    0
  54        0   0      0      0       0     0   0      0    1
  55        0   0      0      0       0     0   0      0    0
  56        0   0      0      0       0     0   0      0    0
  57        0   0      0      0       0     0   0      0    0
  58        0   0      0      0       0     0   0      0    0
  59        0   0      0      0       0     0   0      0    0
  60        0   0      0      0       0     0   0      0    0
  61        0   0      0      0       0     0   0      0    0
  62        0   0      0      0       0     0   0      0    0
  63        0   0      0      0       0     0   0      1    0
  64        0   0      0      0       0     0   0      0    0
  65        0   0      0      0       0     0   0      0    0
  66        0   0      0      0       0     0   1      0    0
  67        0   0      0      0       0     0   0      0    0
  68        0   0      0      0       0     0   0      0    0
  69        0   0      0      0       0     0   0      0    0
  70        0   0      0      0       0     0   1      0    0
  71        0   0      0      0       0     0   0      0    0
  72        0   0      0      0       0     0   0      0    0
  73        0   0      0      0       0     0   0      0    0
  74        0   0      0      0       0     0   1      0    0
  75        0   0      0      0       0     0   0      0    0
  76        0   0      0      0       0     0   0      0    1
  77        0   0      0      0       0     0   0      0    1
  78        0   0      0      0       0     0   0      0    0
  79        0   0      0      0       0     0   0      0    0
  80        0   0      0      0       0     0   0      0    0
  81        0   0      0      0       0     0   0      0    0
  82        0   0      0      0       0     0   0      0    0
  83        0   0      0      0       0     0   0      0    1
  84        0   0      0      0       0     0   0      0    0
  85        0   0      0      0       0     0   0      0    0
  86        0   0      0      0       0     0   0      0    0
  87        0   0      0      0       0     0   0      0    0
  88        0   0      0      0       0     0   0      0    0
  89        0   0      0      0       0     0   0      0    0
  90        0   0      0      0       0     0   0      0    0
  91        0   0      0      0       0     0   0      0    0
  92        0   0      0      0       0     0   0      0    0
  93        0   0      0      0       0     0   0      0    0
  94        0   0      0      0       0     0   0      0    0
  95        0   0      0      0       0     0   0      0    0
  96        0   0      0      0       0     0   0      0    0
  97        0   0      0      0       0     0   0      0    0
  98        0   0      0      0       0     0   0      0    0
  99        0   0      0      0       0     0   0      0    0
  100       0   0      0      0       0     0   2      0    0
  101       0   0      0      0       0     0   0      0    0
  102       0   0      0      0       0     0   0      0    0
  103       0   0      0      0       0     0   0      0    1
  104       0   0      0      0       0     0   1      0    0
  105       0   0      0      0       0     0   1      0    0
  106       0   0      1      0       0     0   0      0    0
  107       0   0      0      0       0     0   0      0    0
  108       0   0      0      0       0     0   1      0    0
  109       0   0      0      0       1     0   0      0    1
  110       0   0      0      0       0     0   0      0    0
  111       0   0      0      0       0     0   1      0    0
  112       0   0      0      0       0     0   0      0    0
  113       0   0      0      0       0     0   0      0    0
  114       0   0      0      0       0     0   0      0    0
  115       0   0      0      0       0     0   0      0    0
  116       0   0      0      0       0     0   0      0    0
  117       0   0      0      0       0     0   0      0    0
  118       0   0      0      0       0     0   0      0    0
  119       0   0      0      0       0     0   0      0    0
  120       0   0      0      0       0     0   0      0    0
  121       0   0      0      0       0     0   0      0    0
  122       0   0      0      0       0     0   0      0    0
  123       0   0      0      0       0     0   0      0    0
  124       0   0      0      0       0     0   0      1    0
  125       0   0      0      0       0     0   0      0    1
  126       0   0      0      0       0     0   0      0    1
  127       0   0      0      0       0     0   0      0    0
  128       0   0      0      0       0     0   0      0    0
  129       0   0      0      0       0     0   0      0    0
  130       0   0      0      0       0     0   0      0    0
  131       0   0      0      0       0     0   0      0    0
  132       0   0      0      0       0     0   0      0    0
  133       0   0      0      0       0     0   0      0    0
  134       0   0      0      0       0     0   0      0    0
  135       0   0      0      0       0     0   0      0    0
  136       0   0      0      0       0     0   0      0    0
  137       0   0      0      0       0     0   0      0    0
  138       0   0      0      0       0     0   0      0    0
  139       0   0      0      0       0     0   2      0    0
  140       0   0      0      0       0     0   0      0    0
  141       0   0      0      0       0     0   0      0    0
  142       0   0      0      0       0     0   0      0    0
  143       0   0      0      0       0     0   0      0    1
  144       0   0      0      0       0     0   0      0    0
  145       0   0      0      0       0     0   0      0    0
  146       0   0      0      0       0     0   0      0    1
  147       0   0      0      0       0     0   0      0    0
  148       0   0      0      0       0     0   0      1    0
  149       0   0      0      1       0     0   0      0    0
  150       0   0      0      0       0     0   0      0    0
  151       0   0      0      0       0     0   0      0    0
  152       0   0      0      0       0     0   0      0    0
  153       0   0      0      0       0     0   0      0    0
  154       0   0      0      0       0     0   0      0    0
  155       0   0      0      0       0     0   0      0    0
  156       0   0      0      0       0     0   0      0    0
  157       0   0      0      0       0     0   0      0    0
  158       0   0      0      0       0     0   0      0    0
  159       0   0      0      0       0     0   0      0    2
  160       0   0      0      0       0     0   0      0    0
  161       0   0      0      0       0     0   0      0    0
  162       0   0      0      0       0     0   0      0    0
  163       0   0      0      0       0     0   0      0    0
  164       0   0      0      0       0     0   0      0    0
  165       0   0      0      0       0     0   0      0    0
  166       0   0      0      0       0     0   0      0    0
  167       0   0      0      0       0     0   0      0    0
  168       0   0      0      0       0     0   0      0    0
  169       0   0      0      0       0     0   0      0    0
  170       0   0      0      0       0     0   1      0    0
  171       0   0      0      0       0     0   0      0    1
  172       0   0      0      0       0     0   0      0    0
  173       0   0      0      0       0     0   0      0    1
  174       0   0      0      0       0     0   0      0    0
  175       0   0      0      1       0     0   0      0    0
  176       0   0      0      0       0     0   0      0    0
  177       0   0      0      0       0     0   0      0    0
  178       0   0      0      0       0     0   0      0    0
  179       0   0      0      0       0     0   0      0    0
  180       0   0      0      0       0     0   0      0    0
  181       0   0      0      0       0     0   0      0    0
  182       0   0      0      0       0     0   0      0    0
  183       0   0      0      0       0     0   0      0    0
  184       0   0      0      0       0     0   0      0    0
  185       0   0      0      0       0     0   0      0    0
  186       0   0      0      0       0     0   0      0    0
  187       0   0      0      0       0     0   0      0    0
  188       0   0      0      0       0     0   0      0    0
  189       0   0      0      0       0     0   0      0    1
  190       0   0      0      0       0     0   0      0    0
  191       0   0      0      0       0     0   0      0    0
  192       0   0      0      2       0     0   0      0    0
  193       0   0      0      0       0     0   0      0    1
  194       0   0      0      0       0     0   0      0    0
  195       0   0      0      0       0     0   0      0    0
  196       0   0      0      0       0     0   0      0    0
  197       0   0      0      0       0     0   0      0    0
  198       0   0      0      0       0     0   0      0    0
  199       0   0      0      0       0     0   0      0    0
  200       0   0      0      0       0     0   0      0    0
  201       0   0      0      0       0     0   0      0    0
  202       0   0      0      0       0     0   0      0    0
  203       0   0      0      0       0     0   0      0    0
  204       0   0      0      0       0     0   1      1    0
  205       0   0      0      0       0     0   0      0    0
  206       0   0      0      0       0     0   0      0    0
  207       0   0      0      0       0     0   0      0    0
  208       0   0      0      0       0     0   0      0    0
  209       0   0      0      0       0     0   0      0    0
  210       0   0      0      0       0     0   0      0    0
  211       0   0      0      0       0     0   0      0    0
  212       0   0      0      0       0     0   0      0    0
  213       0   0      0      0       0     0   0      0    0
  214       0   0      0      0       0     0   0      0    0
  215       0   0      0      0       0     0   0      0    0
  216       0   0      1      0       0     0   0      0    0
  217       0   0      0      0       0     0   0      0    0
  218       0   0      0      0       0     0   0      0    0
  219       0   0      0      0       0     0   0      0    0
  220       0   0      0      0       0     0   0      0    0
  221       0   0      0      0       0     0   0      0    0
  222       0   0      0      0       0     0   0      0    0
  223       0   0      0      0       0     0   0      0    0
  224       0   0      0      0       0     0   0      0    0
  225       0   0      0      0       0     0   0      0    0
  226       0   0      0      0       0     0   0      0    0
  227       0   0      0      0       0     0   0      0    0
  228       0   0      0      0       0     0   0      0    0
  229       0   0      0      0       0     0   0      0    0
  230       0   0      0      0       0     0   0      0    0
  231       0   0      0      0       0     0   0      0    0
  232       0   0      0      0       0     0   0      0    0
  233       0   0      0      0       0     0   0      0    0
  234       0   0      0      0       0     0   0      0    0
  235       0   0      0      1       0     0   0      0    0
  236       0   0      0      0       0     0   0      0    0
  237       0   0      0      0       0     0   0      0    0
  238       0   0      0      0       0     0   1      0    0
  239       0   0      0      0       0     0   0      0    0
  240       0   0      0      0       1     0   0      0    0
  241       0   0      0      0       0     0   0      0    0
  242       0   0      0      0       0     0   0      0    0
  243       0   0      0      0       0     0   0      0    0
  244       0   0      0      0       0     0   0      0    0
  245       0   0      0      0       0     0   0      0    0
  246       0   0      0      0       0     0   0      0    0
  247       0   0      0      0       0     0   0      0    0
  248       0   0      0      0       0     0   0      0    0
  249       0   0      0      0       0     0   0      0    0
  250       0   0      0      0       0     0   0      0    0
  251       0   0      0      0       0     0   0      0    0
  252       0   0      0      0       0     0   0      0    0
  253       0   0      0      1       0     0   0      0    0
  254       0   0      1      0       0     1   0      0    0
  255       0   0      0      0       0     0   0      0    0
  256       0   0      0      0       0     0   0      0    0
  257       0   0      0      0       0     0   0      0    0
  258       0   0      0      0       0     0   0      0    0
  259       1   0      0      0       0     0   0      0    0
  260       0   0      0      0       0     0   0      0    0
  261       0   0      0      0       0     0   0      0    0
  262       0   0      0      0       0     0   0      0    0
  263       0   0      0      0       0     0   0      0    0
  264       0   0      0      0       0     0   0      0    0
  265       0   0      0      0       0     0   0      0    0
  266       0   0      0      0       0     0   0      0    0
  267       0   0      0      0       0     0   0      0    0
  268       0   0      0      0       0     0   0      0    0
  269       0   0      0      0       0     0   0      0    0
  270       0   0      0      0       0     0   0      0    0
  271       0   0      0      0       0     0   0      0    0
  272       0   0      0      0       0     0   0      0    0
  273       0   0      1      0       0     0   1      0    0
  274       0   0      0      0       0     0   0      0    0
  275       0   0      0      0       0     0   1      0    0
  276       0   0      0      0       0     1   0      0    0
  277       0   0      0      0       0     1   0      0    0
  278       0   0      0      0       0     0   0      0    0
  279       0   0      0      0       0     0   0      0    0
  280       0   0      0      0       0     0   0      0    0
  281       0   0      0      0       0     0   0      0    0
  282       0   0      0      0       0     0   0      0    0
  283       0   0      0      0       0     0   0      0    0
  284       0   0      0      0       0     0   0      0    0
     Terms
Docs  opportunities opportunity order org organization outside part pay
  1               0           0     0   0            0       0    0   0
  2               0           0     0   0            0       0    0   0
  3               0           0     0   0            0       0    0   0
  4               0           0     0   0            0       0    0   0
  5               0           0     0   0            0       0    0   0
  6               0           0     0   0            0       0    1   0
  7               0           0     0   0            0       0    0   0
  8               0           0     0   0            0       0    0   0
  9               0           0     0   0            0       0    0   0
  10              0           0     0   0            0       0    0   0
  11              0           1     0   0            0       0    0   0
  12              0           0     0   0            0       0    1   0
  13              0           0     0   0            0       0    0   0
  14              0           0     0   0            0       0    0   0
  15              0           0     0   0            0       0    0   0
  16              0           0     0   0            0       0    0   0
  17              0           0     0   0            0       0    0   0
  18              0           0     0   0            0       0    0   0
  19              0           0     0   0            0       0    0   0
  20              0           0     0   0            0       0    0   0
  21              0           0     0   0            0       0    0   0
  22              0           0     0   0            0       0    0   0
  23              0           0     0   0            0       0    0   1
  24              0           0     0   0            0       0    0   0
  25              0           1     0   0            0       0    0   0
  26              0           0     0   0            0       0    0   0
  27              0           0     0   0            0       0    0   0
  28              0           0     0   0            0       0    0   0
  29              0           0     0   0            0       0    0   0
  30              0           0     0   0            0       0    0   0
  31              0           0     0   0            0       0    0   0
  32              0           0     0   0            0       0    0   0
  33              0           0     0   0            0       0    0   0
  34              0           0     0   0            1       0    0   0
  35              0           0     0   0            0       0    1   0
  36              0           0     0   0            0       0    0   0
  37              0           0     0   0            0       0    0   0
  38              0           0     0   0            0       0    0   0
  39              0           0     0   0            0       0    0   0
  40              0           0     0   0            0       0    0   0
  41              0           0     0   0            0       0    0   0
  42              0           0     0   0            0       0    0   0
  43              1           0     0   0            0       0    0   0
  44              0           0     0   0            0       0    0   0
  45              0           0     0   0            0       0    0   0
  46              0           0     0   0            0       0    0   1
  47              0           0     0   0            0       0    0   0
  48              0           0     0   0            0       0    0   0
  49              0           0     0   0            0       0    0   0
  50              0           0     0   0            0       0    0   0
  51              0           0     0   0            0       0    0   0
  52              0           0     0   0            0       0    1   0
  53              0           0     0   0            0       0    0   0
  54              0           0     0   0            0       0    0   0
  55              0           0     0   0            0       0    0   0
  56              0           0     0   0            0       0    0   0
  57              0           0     0   0            0       0    0   0
  58              0           0     0   0            0       0    0   0
  59              0           0     0   0            0       0    0   0
  60              0           0     0   0            0       0    0   0
  61              0           0     0   0            0       0    0   0
  62              0           0     0   0            0       0    0   0
  63              0           0     0   0            0       0    0   0
  64              0           1     0   0            0       0    0   0
  65              0           0     0   0            0       0    0   0
  66              0           0     0   0            0       0    0   0
  67              0           0     0   0            0       0    0   1
  68              0           0     0   0            0       0    0   0
  69              0           0     0   0            0       0    0   0
  70              0           0     0   0            0       0    0   0
  71              0           0     0   0            0       0    0   0
  72              0           0     0   0            0       0    0   0
  73              0           0     0   0            0       0    0   0
  74              0           0     0   0            0       0    0   0
  75              0           0     0   0            0       0    0   0
  76              0           0     0   0            1       0    0   0
  77              0           0     0   0            0       0    0   0
  78              1           0     0   0            0       0    0   1
  79              0           0     0   0            0       0    1   0
  80              0           0     0   0            0       0    0   0
  81              0           0     0   0            0       0    0   0
  82              0           0     0   0            0       0    1   0
  83              0           0     0   0            0       0    0   0
  84              0           0     0   0            0       0    0   0
  85              0           0     0   0            0       0    0   0
  86              0           0     0   0            0       0    0   0
  87              0           0     0   0            0       0    0   0
  88              0           0     0   0            0       0    0   0
  89              0           0     0   0            0       0    0   1
  90              0           0     0   0            0       0    0   0
  91              0           0     0   0            0       0    0   0
  92              0           0     0   0            0       0    0   0
  93              0           0     0   0            0       0    0   0
  94              1           0     0   0            0       0    0   0
  95              1           0     0   0            0       0    0   0
  96              0           0     0   0            0       0    0   0
  97              1           0     0   0            0       0    0   0
  98              0           0     0   0            0       0    0   0
  99              0           0     0   0            0       0    0   0
  100             0           0     0   0            0       0    0   0
  101             0           1     0   0            0       0    0   0
  102             0           1     0   0            0       0    0   0
  103             1           0     0   0            0       0    0   0
  104             0           0     0   0            0       0    0   0
  105             0           0     0   0            0       0    0   0
  106             1           0     0   0            0       0    0   0
  107             0           0     0   0            0       0    0   0
  108             0           0     0   0            0       0    0   0
  109             1           0     0   0            1       0    0   0
  110             0           0     0   0            0       0    0   0
  111             0           0     0   0            0       0    0   0
  112             0           0     0   0            0       0    0   0
  113             0           0     0   0            0       0    0   0
  114             0           0     0   0            0       0    0   0
  115             0           0     0   0            0       0    0   1
  116             0           0     0   0            0       0    0   0
  117             0           0     0   0            0       0    0   0
  118             0           0     0   0            0       0    0   0
  119             0           1     0   0            0       0    0   0
  120             0           0     0   0            0       0    0   0
  121             0           0     0   0            0       0    0   0
  122             0           0     1   0            0       0    0   0
  123             0           0     0   0            0       0    0   0
  124             0           0     0   0            0       0    0   0
  125             0           0     0   0            0       0    0   0
  126             0           0     0   0            0       0    0   0
  127             0           0     0   0            0       0    0   0
  128             1           0     0   0            0       0    0   1
  129             0           0     0   0            0       0    0   0
  130             0           0     0   0            0       0    0   0
  131             0           0     0   0            0       0    0   0
  132             0           0     0   0            0       0    0   0
  133             1           0     0   0            0       0    0   0
  134             0           0     0   0            0       0    0   0
  135             0           0     0   0            0       0    0   0
  136             0           0     0   0            0       0    0   0
  137             0           0     0   0            1       0    0   0
  138             0           0     0   0            0       0    0   0
  139             0           0     0   0            0       1    0   0
  140             0           0     0   0            0       0    0   0
  141             0           0     0   0            0       0    0   0
  142             0           0     0   0            0       0    0   0
  143             0           0     0   0            0       0    0   0
  144             0           0     0   0            0       0    0   0
  145             0           1     0   0            0       0    0   0
  146             0           0     0   0            0       0    0   0
  147             0           0     0   0            0       0    0   0
  148             0           0     0   0            0       0    0   0
  149             0           0     0   0            0       0    0   0
  150             1           0     0   0            0       0    0   0
  151             0           0     0   0            0       0    0   0
  152             0           0     0   0            0       0    0   0
  153             0           0     0   0            0       0    0   0
  154             0           0     0   0            0       0    0   0
  155             0           0     0   0            0       0    0   0
  156             0           1     0   0            0       0    0   0
  157             0           0     0   0            0       0    0   0
  158             0           0     0   0            0       0    0   0
  159             0           0     0   0            0       0    0   0
  160             0           0     0   0            1       0    0   0
  161             0           0     0   0            0       0    0   0
  162             0           0     0   0            0       0    0   1
  163             0           0     0   0            0       0    1   0
  164             0           0     0   0            0       0    0   0
  165             0           0     0   0            0       0    0   0
  166             0           1     0   0            0       0    1   0
  167             1           0     0   0            0       0    0   0
  168             0           1     0   0            0       0    0   0
  169             0           0     0   0            0       0    0   0
  170             0           0     0   0            0       0    0   0
  171             0           0     0   0            0       0    0   0
  172             0           0     0   0            0       0    0   0
  173             0           0     0   0            0       0    0   0
  174             2           0     0   0            0       0    0   0
  175             0           0     0   0            0       0    0   0
  176             0           0     0   0            0       0    0   0
  177             0           0     0   0            0       0    0   0
  178             0           0     0   0            0       0    0   0
  179             0           0     0   0            0       0    0   0
  180             0           0     0   0            0       0    0   0
  181             0           0     0   0            0       0    0   1
  182             0           0     0   0            0       0    0   0
  183             0           0     0   0            0       0    0   0
  184             0           0     0   0            0       0    0   0
  185             0           0     0   0            0       0    0   0
  186             0           0     0   0            0       0    0   0
  187             0           0     0   0            0       0    0   0
  188             0           0     0   0            0       0    0   0
  189             0           0     0   0            0       0    0   0
  190             0           0     0   0            0       0    0   0
  191             0           0     0   0            0       0    0   0
  192             0           0     0   0            0       1    0   0
  193             0           0     0   0            0       0    0   0
  194             0           0     0   0            0       0    0   0
  195             0           0     0   0            0       0    0   0
  196             0           0     0   0            0       0    0   0
  197             0           0     0   0            0       0    0   0
  198             0           0     0   0            0       0    0   0
  199             0           0     1   0            0       0    0   0
  200             0           0     0   0            0       0    0   0
  201             0           0     0   0            0       0    0   0
  202             0           0     0   0            0       0    0   0
  203             0           0     0   0            0       0    0   0
  204             0           0     0   0            0       0    0   0
  205             0           0     0   0            0       0    0   0
  206             0           0     0   0            0       0    0   0
  207             0           0     0   0            0       0    0   0
  208             0           0     0   0            0       0    0   0
  209             0           0     0   0            0       0    0   0
  210             0           0     0   0            0       0    0   1
  211             0           0     0   0            0       0    0   0
  212             0           0     0   0            0       0    0   0
  213             0           0     0   0            0       0    0   0
  214             0           0     0   0            0       0    0   0
  215             0           0     0   0            0       0    0   0
  216             0           0     0   0            0       0    0   0
  217             0           0     0   0            0       0    0   0
  218             0           0     0   0            0       0    0   0
  219             0           0     0   0            0       0    0   0
  220             0           1     0   0            0       0    0   1
  221             0           1     0   0            0       0    0   0
  222             0           0     0   0            0       0    0   0
  223             0           0     0   0            0       0    0   0
  224             0           0     0   0            0       0    0   0
  225             0           0     0   0            0       0    0   0
  226             0           0     0   0            0       0    0   0
  227             0           0     0   0            0       0    0   1
  228             0           0     0   0            0       0    0   0
  229             0           0     0   0            0       0    0   1
  230             0           0     0   0            0       0    0   0
  231             0           0     0   0            0       0    0   1
  232             0           0     0   0            0       0    0   0
  233             0           0     0   0            0       0    0   0
  234             0           0     0   0            0       0    0   0
  235             0           0     0   0            0       0    0   0
  236             0           0     0   0            0       0    0   0
  237             0           0     0   0            0       0    0   0
  238             0           0     0   0            0       0    0   0
  239             0           0     0   0            0       0    0   0
  240             0           1     0   0            0       0    0   0
  241             0           0     0   0            0       0    0   0
  242             0           0     0   0            0       0    0   0
  243             0           0     0   0            0       0    0   0
  244             0           0     0   0            0       0    0   0
  245             0           0     0   0            0       0    0   0
  246             0           0     0   0            0       0    0   0
  247             0           0     0   0            0       0    0   0
  248             0           0     0   0            0       0    0   0
  249             0           0     0   0            0       0    0   0
  250             0           0     0   0            0       0    0   0
  251             0           0     0   0            0       0    0   0
  252             0           0     0   0            0       0    0   0
  253             0           0     0   0            0       0    0   0
  254             0           0     0   0            0       0    0   0
  255             0           0     0   0            0       0    0   0
  256             0           0     0   0            0       0    0   0
  257             0           0     0   0            0       0    0   0
  258             0           0     0   0            0       0    0   0
  259             0           0     0   0            0       0    0   0
  260             0           0     0   0            0       0    0   0
  261             0           0     0   0            0       0    0   0
  262             1           0     0   0            0       0    0   0
  263             0           0     0   0            0       0    0   0
  264             0           0     0   0            0       0    0   0
  265             0           0     0   0            0       0    0   0
  266             0           0     0   0            0       0    0   1
  267             1           0     0   0            0       0    0   0
  268             0           0     0   0            0       1    0   0
  269             0           0     0   0            0       0    0   0
  270             0           0     0   0            0       0    0   0
  271             0           0     0   0            0       0    0   0
  272             0           0     0   0            0       0    0   0
  273             1           0     0   0            0       0    0   0
  274             0           0     0   0            0       0    0   0
  275             0           0     0   0            0       0    0   0
  276             1           0     1   0            0       0    0   0
  277             0           0     0   0            0       0    0   0
  278             0           0     0   0            0       0    0   0
  279             0           0     0   0            0       0    0   0
  280             0           0     0   0            0       0    0   0
  281             0           0     0   0            0       0    0   0
  282             0           0     0   0            0       0    0   0
  283             0           0     0   0            0       0    0   0
  284             0           0     0   0            0       0    0   0
     Terms
Docs  peers people performance perks person personal place places play
  1       0      2           0     0      0        0     1      0    0
  2       0      2           0     0      0        0     0      0    0
  3       0      0           0     0      0        0     0      0    0
  4       0      0           0     0      0        0     0      0    0
  5       0      0           0     0      0        0     0      0    0
  6       0      2           0     1      0        0     0      0    0
  7       0      0           0     0      0        0     0      0    0
  8       0      1           0     0      0        0     0      0    0
  9       0      0           0     0      0        0     0      0    0
  10      0      1           0     0      0        0     0      0    0
  11      0      1           0     0      0        0     0      0    0
  12      0      1           0     0      0        0     0      0    0
  13      0      1           0     0      0        0     0      1    0
  14      0      1           0     0      0        0     0      0    0
  15      0      2           0     0      0        0     0      0    0
  16      0      0           0     1      0        1     1      0    0
  17      0      2           0     0      0        0     0      0    0
  18      0      0           0     0      0        0     0      0    0
  19      0      0           0     1      0        0     0      0    0
  20      0      0           0     0      0        0     0      0    0
  21      0      1           0     0      0        0     0      0    0
  22      0      0           0     1      0        0     1      0    0
  23      0      0           0     0      0        0     0      0    0
  24      0      1           0     1      0        0     0      0    0
  25      0      0           0     0      0        0     0      0    0
  26      0      0           0     0      0        0     0      0    0
  27      0      0           0     0      0        0     0      0    0
  28      0      0           0     0      0        0     0      0    0
  29      0      2           0     0      0        0     0      0    0
  30      0      0           0     0      0        0     1      0    0
  31      0      1           0     0      0        0     0      0    0
  32      0      1           0     0      0        0     0      0    0
  33      0      1           0     1      0        0     0      0    1
  34      0      2           0     0      0        0     1      0    0
  35      0      1           0     0      0        0     0      0    0
  36      0      0           0     1      0        0     0      0    0
  37      0      0           0     1      0        0     0      0    0
  38      0      0           0     0      0        0     0      0    0
  39      0      1           0     0      0        0     2      0    0
  40      0      0           0     0      0        0     0      0    0
  41      0      2           0     0      0        0     1      0    0
  42      0      3           0     0      0        0     0      0    0
  43      0      0           0     0      0        0     0      0    0
  44      0      2           0     1      0        0     0      0    0
  45      0      0           0     1      0        0     0      0    0
  46      0      1           0     1      0        0     1      0    0
  47      0      3           0     0      0        0     0      0    0
  48      0      0           0     0      0        0     0      0    0
  49      0      0           0     0      0        0     1      0    0
  50      0      1           0     0      0        0     1      0    0
  51      0      0           0     1      0        0     0      0    0
  52      0      2           0     0      0        0     0      0    0
  53      0      1           0     1      0        0     0      0    0
  54      0      0           0     1      0        0     0      0    0
  55      0      0           0     0      0        0     0      0    0
  56      0      1           0     0      0        0     0      0    0
  57      0      1           0     0      0        0     0      0    0
  58      0      3           0     0      0        0     0      0    0
  59      0      0           0     0      0        0     2      0    0
  60      0      0           0     1      0        0     0      0    0
  61      0      0           0     0      0        0     0      0    0
  62      0      0           0     0      0        0     0      0    0
  63      0      1           0     0      0        0     0      0    0
  64      0      1           0     0      0        0     1      0    0
  65      0      0           0     0      0        0     1      0    0
  66      0      0           0     0      0        0     0      0    0
  67      0      0           0     0      0        0     0      0    0
  68      0      2           0     0      0        0     0      0    1
  69      0      1           0     1      0        0     0      0    0
  70      0      1           0     0      0        0     0      0    0
  71      0      2           0     0      0        0     1      0    0
  72      0      1           0     0      0        0     0      0    0
  73      0      0           0     1      0        0     0      0    0
  74      0      0           0     0      0        0     2      0    0
  75      0      3           0     0      0        0     1      1    0
  76      0      1           0     1      0        0     0      0    0
  77      0      1           0     0      0        0     1      0    0
  78      0      0           0     0      0        0     0      0    0
  79      0      1           0     1      0        0     0      0    0
  80      0      0           0     0      0        0     0      0    0
  81      0      0           0     0      0        0     1      0    0
  82      0      0           0     0      0        0     0      0    0
  83      0      0           0     0      0        0     0      0    0
  84      0      0           0     1      0        0     0      1    0
  85      0      1           0     0      0        0     0      0    0
  86      0      0           0     0      0        0     0      0    0
  87      0      0           0     0      0        0     0      0    0
  88      0      1           0     0      0        0     0      0    0
  89      0      0           0     0      0        0     0      0    0
  90      0      1           0     0      0        0     0      0    0
  91      0      1           0     0      0        0     0      0    0
  92      0      0           0     0      0        0     0      0    0
  93      0      0           0     1      0        0     1      0    0
  94      0      0           0     0      0        0     0      0    0
  95      0      1           0     0      0        0     0      0    1
  96      0      1           0     0      0        0     0      0    0
  97      0      0           0     0      0        0     0      0    0
  98      0      0           0     0      0        0     0      0    0
  99      0      0           0     0      0        0     1      0    0
  100     0      0           0     0      0        0     0      0    0
  101     0      0           0     1      0        0     0      0    0
  102     0      0           0     0      0        0     0      0    0
  103     0      2           0     0      0        0     0      0    0
  104     0      0           0     1      0        0     0      1    0
  105     0      1           0     0      0        0     0      0    0
  106     0      0           0     1      0        1     0      0    0
  107     0      0           0     0      0        0     0      1    0
  108     0      1           0     0      0        0     1      0    0
  109     0      0           0     0      0        1     0      0    0
  110     0      1           0     0      0        0     0      0    0
  111     0      0           0     0      0        0     0      0    0
  112     0      1           0     1      0        0     0      0    0
  113     0      1           0     0      0        0     0      0    0
  114     0      0           0     0      0        0     0      0    0
  115     0      0           0     0      0        0     0      0    0
  116     0      2           0     0      0        0     0      0    0
  117     0      1           0     0      0        0     0      0    0
  118     0      1           0     0      0        0     2      0    0
  119     0      1           0     0      0        0     0      0    0
  120     0      1           0     0      0        0     0      0    0
  121     0      2           0     2      0        0     1      0    0
  122     0      0           0     0      0        0     0      0    0
  123     0      0           0     0      0        0     0      0    0
  124     0      1           0     0      0        0     0      0    0
  125     0      0           0     1      0        0     1      0    0
  126     0      1           0     0      0        1     0      0    0
  127     0      0           0     0      0        0     0      0    0
  128     0      1           0     1      0        0     0      0    0
  129     0      2           0     0      0        0     0      0    0
  130     0      0           0     1      0        0     0      0    0
  131     0      2           0     1      0        0     0      0    0
  132     0      0           0     0      0        0     1      0    0
  133     0      2           0     0      0        0     0      0    0
  134     0      0           0     0      0        0     1      0    0
  135     0      0           0     0      0        0     0      0    0
  136     0      1           0     0      0        0     2      0    0
  137     0      1           0     0      0        0     0      0    0
  138     0      0           0     1      0        0     0      0    0
  139     0      2           0     1      0        0     0      0    0
  140     0      0           0     0      0        0     0      0    0
  141     0      0           0     0      0        0     0      0    0
  142     0      1           0     0      0        0     1      0    0
  143     0      0           0     1      0        0     0      0    0
  144     0      0           0     0      0        0     0      0    0
  145     0      1           0     1      0        0     0      0    0
  146     0      0           0     0      0        0     0      0    0
  147     0      0           0     0      0        1     0      0    0
  148     0      0           0     0      0        0     0      0    0
  149     0      0           0     0      0        0     0      0    0
  150     0      1           0     0      0        0     0      0    0
  151     0      0           0     1      0        0     0      0    0
  152     0      0           0     0      0        0     0      0    0
  153     0      0           0     0      0        0     0      0    0
  154     0      1           0     0      0        0     0      0    0
  155     0      0           0     0      0        0     0      0    0
  156     0      0           0     0      0        0     0      0    0
  157     0      1           0     1      0        0     0      0    0
  158     0      1           0     0      0        0     0      0    0
  159     0      0           0     0      0        0     0      0    0
  160     0      0           0     1      0        0     0      0    0
  161     0      0           0     0      0        0     0      0    0
  162     0      0           0     0      0        0     0      0    0
  163     0      1           0     1      0        0     0      0    0
  164     0      0           0     0      0        0     1      0    0
  165     0      0           0     0      0        0     0      0    0
  166     0      0           0     1      0        0     0      0    0
  167     0      2           0     0      0        0     0      0    0
  168     0      1           0     1      0        0     0      0    0
  169     0      3           0     0      0        0     0      0    0
  170     0      1           0     1      0        0     0      0    0
  171     0      0           0     0      0        0     0      0    0
  172     0      0           0     0      0        0     0      0    0
  173     0      0           0     0      0        0     1      0    0
  174     0      0           0     0      0        0     0      0    0
  175     0      1           0     0      0        0     1      0    0
  176     0      1           0     0      0        0     0      0    0
  177     0      1           0     0      0        0     0      0    0
  178     0      1           0     0      0        0     0      0    0
  179     0      0           0     0      0        0     0      0    0
  180     0      0           0     0      0        0     0      0    0
  181     1      1           0     1      0        0     0      0    0
  182     0      0           0     0      0        0     0      0    0
  183     0      0           0     0      0        0     0      0    0
  184     0      1           0     0      0        0     0      0    0
  185     0      0           0     0      0        0     0      0    0
  186     0      1           0     0      0        0     0      0    0
  187     0      1           0     0      0        0     0      0    0
  188     0      0           0     0      0        0     0      0    0
  189     0      0           0     0      0        0     0      0    0
  190     0      0           0     0      0        0     0      0    0
  191     0      0           0     0      0        0     0      0    0
  192     0      0           0     0      1        0     0      0    0
  193     0      0           0     0      0        0     0      0    1
  194     0      1           0     0      0        0     0      0    0
  195     0      1           0     0      0        0     0      0    0
  196     0      0           0     1      0        0     0      0    0
  197     0      0           0     0      0        0     0      0    0
  198     0      1           0     0      0        0     2      0    0
  199     0      0           0     1      0        0     0      0    0
  200     0      0           0     0      0        0     0      0    0
  201     0      1           0     0      0        0     0      0    0
  202     0      0           0     1      0        0     0      0    0
  203     0      0           0     0      0        0     0      0    0
  204     0      3           0     0      0        0     0      0    0
  205     0      1           0     0      0        0     0      0    0
  206     0      1           0     1      0        0     0      0    0
  207     0      0           0     0      0        0     0      0    0
  208     0      2           0     1      0        0     0      0    0
  209     0      1           0     1      0        0     0      0    0
  210     0      0           1     0      0        0     0      0    0
  211     0      0           0     0      0        0     0      0    0
  212     0      1           0     0      0        0     0      0    0
  213     0      1           0     1      0        0     0      0    0
  214     0      0           0     0      0        0     0      0    0
  215     0      0           0     0      0        0     0      0    0
  216     0      1           0     1      0        0     0      0    0
  217     0      0           0     1      0        0     0      0    0
  218     0      1           0     1      0        0     0      0    0
  219     0      0           0     0      0        0     1      0    0
  220     0      0           0     0      0        0     0      0    0
  221     0      2           0     0      0        0     0      0    0
  222     0      1           0     0      0        0     0      0    0
  223     0      0           0     0      0        0     0      0    0
  224     0      1           0     0      0        0     0      0    0
  225     0      1           0     0      0        0     0      0    0
  226     0      0           0     0      0        0     0      0    0
  227     0      1           0     0      0        0     0      0    0
  228     0      0           0     0      0        0     0      0    0
  229     0      0           0     0      0        0     0      0    0
  230     0      1           0     0      0        0     0      0    0
  231     0      2           0     1      0        0     0      0    0
  232     0      1           0     1      0        0     0      0    0
  233     0      2           0     0      0        0     0      0    0
  234     0      1           0     0      0        0     0      0    0
  235     0      0           0     0      1        0     0      0    1
  236     0      1           0     0      0        0     1      0    0
  237     0      0           0     0      0        0     0      0    0
  238     0      0           0     1      0        0     0      0    0
  239     0      0           0     0      0        0     0      0    0
  240     0      0           0     0      0        0     0      0    0
  241     0      1           0     0      0        0     0      0    0
  242     0      0           0     0      0        0     0      0    0
  243     0      0           0     0      0        0     0      0    0
  244     0      1           0     0      0        0     0      0    0
  245     0      0           0     0      0        0     1      0    0
  246     0      0           0     1      0        0     1      0    0
  247     0      0           0     0      0        0     0      0    0
  248     0      0           0     0      0        0     0      0    0
  249     0      0           0     0      0        0     0      0    0
  250     0      0           0     0      0        0     0      0    0
  251     0      0           0     0      0        0     0      0    0
  252     0      0           0     0      0        0     0      0    0
  253     0      0           0     0      0        0     0      0    0
  254     0      0           0     0      0        0     0      0    0
  255     0      0           0     0      0        1     0      0    0
  256     0      0           0     0      0        0     0      0    0
  257     0      1           0     0      0        0     0      0    0
  258     0      0           0     1      0        0     0      0    0
  259     0      0           0     0      0        0     0      0    0
  260     0      1           0     0      0        0     0      0    0
  261     0      0           0     0      0        0     0      0    0
  262     0      0           0     0      0        0     0      0    0
  263     0      0           0     0      0        0     0      0    0
  264     0      0           0     0      0        0     0      0    0
  265     0      0           0     0      0        0     0      0    1
  266     0      0           0     0      0        0     0      0    0
  267     0      2           0     0      0        0     0      0    0
  268     0      0           0     0      0        0     0      0    0
  269     0      0           0     0      0        0     0      0    0
  270     0      0           0     0      0        0     0      0    0
  271     0      0           0     0      0        0     0      0    0
  272     0      2           0     0      0        0     0      0    0
  273     0      0           0     0      0        0     0      0    0
  274     0      0           0     0      0        0     0      0    0
  275     0      0           0     0      0        0     0      0    0
  276     1      0           0     0      0        0     0      0    0
  277     0      0           0     0      0        0     0      0    0
  278     0      0           0     0      0        0     0      0    0
  279     0      0           0     0      0        0     0      0    0
  280     0      0           0     0      0        0     0      0    0
  281     0      0           0     0      0        0     0      0    0
  282     0      0           0     0      0        0     0      0    0
  283     0      0           0     0      0        0     0      0    0
  284     0      0           0     0      0        0     0      0    0
     Terms
Docs  political politics poor positive pretty probably problem problems
  1           0        0    0        0      0        0       0        0
  2           0        0    0        0      0        0       0        0
  3           0        0    0        0      0        0       0        0
  4           0        0    0        0      0        1       0        0
  5           0        0    0        0      0        0       0        0
  6           0        0    0        0      0        0       0        0
  7           0        0    0        0      0        0       0        0
  8           0        0    0        0      0        0       0        0
  9           0        0    0        0      0        0       0        0
  10          0        0    0        0      0        0       0        0
  11          0        0    0        0      0        0       0        0
  12          0        0    0        0      0        0       0        0
  13          0        0    0        0      0        0       0        0
  14          0        0    0        0      0        0       0        0
  15          0        0    0        0      0        0       0        0
  16          0        0    0        0      0        0       0        0
  17          0        0    0        0      0        0       0        0
  18          0        0    0        0      0        0       0        0
  19          0        0    0        0      0        0       0        0
  20          0        0    0        0      0        0       0        0
  21          0        0    0        0      0        0       0        0
  22          0        0    0        0      0        0       0        0
  23          0        1    0        0      0        0       0        0
  24          0        0    0        0      0        0       0        0
  25          0        0    0        0      0        0       0        0
  26          0        0    0        0      0        0       0        0
  27          0        0    0        0      0        0       0        0
  28          0        0    0        0      0        0       0        0
  29          0        0    0        0      0        0       0        1
  30          0        0    0        0      0        0       0        0
  31          0        0    0        0      0        0       0        0
  32          0        0    0        0      0        0       0        0
  33          0        0    0        1      0        0       0        0
  34          0        0    0        0      1        0       0        0
  35          0        0    0        0      0        0       0        1
  36          0        0    0        0      0        0       0        0
  37          0        0    0        0      2        0       0        0
  38          0        0    0        0      1        0       0        1
  39          0        0    0        0      0        0       0        0
  40          0        0    0        0      0        0       0        0
  41          0        0    0        0      0        0       0        0
  42          0        0    0        0      0        0       0        1
  43          0        0    0        0      0        0       0        2
  44          0        0    0        0      0        0       0        0
  45          0        0    0        0      0        0       0        0
  46          0        0    0        0      0        0       0        0
  47          0        0    0        0      0        0       0        0
  48          0        0    0        0      0        0       0        0
  49          0        0    0        0      0        0       0        0
  50          0        0    0        0      0        0       0        0
  51          0        0    0        0      0        0       0        0
  52          0        0    0        0      0        0       0        0
  53          0        0    0        0      0        0       0        0
  54          0        0    0        0      1        0       0        0
  55          0        0    0        0      0        0       0        1
  56          0        0    0        0      0        0       0        0
  57          0        0    0        0      0        0       0        0
  58          0        0    0        0      0        0       0        0
  59          0        0    0        0      0        0       0        0
  60          0        0    0        0      0        0       0        0
  61          0        0    0        0      0        0       0        0
  62          0        0    0        0      0        0       0        0
  63          0        0    0        0      0        0       0        0
  64          0        0    0        1      0        0       0        0
  65          0        0    0        0      0        0       0        0
  66          0        0    0        0      0        0       0        0
  67          0        0    0        0      0        0       0        0
  68          0        0    0        0      0        0       0        0
  69          0        0    0        0      0        0       0        0
  70          0        0    0        1      0        0       0        0
  71          0        0    0        0      0        0       0        0
  72          0        0    0        0      0        0       0        1
  73          0        0    0        1      0        0       0        1
  74          0        0    0        0      0        0       0        0
  75          0        0    0        0      0        0       0        0
  76          0        0    0        0      0        0       0        0
  77          0        0    0        1      0        0       0        0
  78          0        0    0        0      0        0       0        0
  79          0        0    0        0      0        0       0        0
  80          0        0    0        0      0        0       0        0
  81          0        0    0        0      0        0       0        1
  82          0        0    0        1      0        0       0        0
  83          0        0    0        0      0        0       0        0
  84          0        0    0        0      0        0       0        0
  85          0        0    0        0      0        0       0        0
  86          0        0    0        0      0        0       1        0
  87          0        0    0        0      0        0       0        0
  88          0        0    0        0      0        0       0        0
  89          0        0    0        0      0        0       0        0
  90          0        0    0        0      0        0       0        0
  91          0        0    0        0      0        0       0        0
  92          0        0    0        0      0        0       0        0
  93          0        0    0        0      0        0       0        0
  94          0        0    0        0      0        0       0        0
  95          0        0    0        0      0        0       0        0
  96          0        0    0        0      0        0       0        1
  97          0        0    0        0      0        0       0        0
  98          0        0    0        0      0        0       0        0
  99          0        0    0        0      0        0       0        0
  100         0        0    0        0      0        0       0        0
  101         0        0    0        0      1        0       0        0
  102         0        0    0        0      0        0       0        0
  103         0        0    0        0      0        0       0        0
  104         0        0    0        0      0        0       0        0
  105         0        0    0        0      0        0       0        0
  106         0        0    0        0      0        0       0        0
  107         0        0    0        0      0        0       0        0
  108         0        0    0        0      0        0       0        0
  109         0        0    0        0      0        0       0        0
  110         0        0    0        0      0        0       0        0
  111         0        0    0        0      0        0       0        0
  112         0        0    0        0      0        0       0        0
  113         0        0    0        0      0        0       0        0
  114         0        0    0        0      0        0       0        0
  115         0        0    0        0      0        1       0        0
  116         0        0    0        0      0        0       0        0
  117         0        0    0        0      0        0       0        0
  118         0        0    0        0      0        0       0        0
  119         0        0    0        0      0        0       0        0
  120         0        0    0        0      0        0       0        1
  121         1        0    0        0      0        0       0        0
  122         0        0    0        0      0        0       0        0
  123         0        0    0        0      0        0       0        0
  124         0        0    0        0      0        0       0        0
  125         0        0    0        0      0        0       0        0
  126         0        0    0        0      0        0       0        0
  127         0        0    0        0      0        0       0        0
  128         0        0    0        0      0        0       0        0
  129         0        0    0        0      0        0       0        0
  130         0        1    0        0      0        0       0        0
  131         0        0    0        0      0        0       0        0
  132         0        0    0        0      0        0       0        0
  133         0        0    0        0      0        0       0        0
  134         0        0    0        0      0        0       0        0
  135         0        0    0        0      0        0       0        0
  136         0        0    0        0      0        0       0        0
  137         0        0    0        0      0        0       0        0
  138         0        0    0        0      0        0       0        0
  139         0        0    0        0      0        0       0        0
  140         0        0    0        0      0        0       0        0
  141         0        0    0        0      0        0       0        0
  142         0        0    0        0      0        0       0        0
  143         0        0    0        0      0        0       0        0
  144         0        0    0        0      0        0       0        0
  145         0        0    0        0      0        0       0        0
  146         0        0    0        0      0        0       0        0
  147         0        0    0        0      0        0       0        0
  148         0        0    0        0      0        0       0        0
  149         0        0    0        0      0        0       0        0
  150         0        0    0        0      0        0       0        0
  151         0        0    0        0      0        0       0        0
  152         0        0    0        0      0        0       0        0
  153         0        1    0        0      0        0       0        1
  154         0        0    0        0      0        0       0        0
  155         0        0    0        0      0        0       0        0
  156         0        0    0        0      0        0       0        0
  157         0        0    0        0      0        0       0        0
  158         0        0    0        0      0        0       0        0
  159         0        0    0        0      0        0       0        0
  160         0        0    0        0      0        0       0        0
  161         0        0    0        0      0        0       0        1
  162         0        0    0        0      0        0       0        0
  163         0        0    0        0      0        0       0        0
  164         0        0    0        0      0        0       0        0
  165         0        0    0        0      0        0       0        0
  166         0        0    0        0      0        0       0        0
  167         0        0    0        0      0        0       0        1
  168         0        0    0        0      0        0       0        1
  169         0        0    0        0      0        0       0        0
  170         0        0    0        0      0        1       0        0
  171         0        0    0        0      0        0       0        0
  172         0        0    0        0      0        0       0        0
  173         0        0    0        0      0        0       0        0
  174         0        0    0        0      0        0       0        0
  175         0        0    0        0      0        0       0        0
  176         0        0    0        0      0        0       0        0
  177         0        0    0        0      0        0       0        0
  178         0        0    0        0      0        0       0        0
  179         0        0    0        0      0        0       0        0
  180         0        0    0        0      0        0       0        0
  181         0        0    0        0      0        0       0        0
  182         0        0    0        0      0        0       0        0
  183         0        0    0        0      0        0       0        0
  184         0        0    0        0      0        0       0        0
  185         0        0    0        0      0        0       0        0
  186         0        0    0        0      0        0       0        0
  187         0        0    0        0      0        0       0        0
  188         0        0    0        0      0        0       0        0
  189         0        0    0        0      0        0       0        0
  190         0        0    0        0      0        0       0        0
  191         0        0    0        0      0        0       0        0
  192         0        0    0        0      0        0       0        0
  193         0        1    0        0      0        0       0        0
  194         0        0    0        0      0        0       0        0
  195         0        0    0        0      0        0       0        0
  196         0        0    0        0      0        0       0        0
  197         0        0    0        0      0        0       0        0
  198         0        0    0        0      0        0       0        0
  199         0        0    0        0      0        0       0        0
  200         0        0    0        0      0        0       0        0
  201         0        0    0        0      0        0       0        0
  202         0        0    0        0      0        0       0        0
  203         0        0    0        0      0        0       0        0
  204         0        0    0        0      0        0       0        0
  205         0        0    0        0      0        0       0        0
  206         0        0    0        0      0        0       0        0
  207         0        0    0        0      0        0       0        0
  208         0        0    0        0      0        0       0        0
  209         0        0    0        0      0        0       0        0
  210         0        0    0        0      0        0       0        0
  211         0        0    0        0      0        0       0        0
  212         0        0    0        0      0        0       0        1
  213         0        0    0        0      0        0       1        0
  214         0        0    0        0      0        0       0        0
  215         0        0    0        0      0        0       0        0
  216         0        0    0        0      0        0       0        0
  217         0        0    0        0      0        0       0        0
  218         0        0    0        0      0        0       0        0
  219         0        0    0        0      0        0       0        0
  220         0        0    0        0      0        0       0        0
  221         0        0    0        0      0        0       0        0
  222         0        0    0        0      0        0       0        0
  223         0        0    0        0      0        0       0        0
  224         0        0    0        0      0        0       0        0
  225         0        0    0        0      0        0       0        0
  226         0        0    0        0      0        0       0        0
  227         0        0    0        0      0        0       0        0
  228         0        0    0        0      0        0       0        0
  229         0        0    0        0      0        0       0        0
  230         0        0    0        0      0        0       0        0
  231         0        0    0        0      0        0       0        0
  232         0        0    0        0      0        1       0        0
  233         0        0    0        0      0        0       0        0
  234         0        0    0        0      0        0       0        0
  235         0        0    0        0      0        0       0        0
  236         0        0    0        0      0        0       0        0
  237         0        0    0        0      0        0       0        0
  238         0        0    0        0      0        1       0        0
  239         0        0    0        0      0        0       0        0
  240         0        0    0        0      0        0       0        0
  241         0        0    0        0      0        0       1        0
  242         0        0    0        0      0        0       0        0
  243         0        0    0        0      0        0       0        0
  244         0        0    0        0      0        0       0        0
  245         0        0    0        0      0        0       0        0
  246         0        0    0        0      0        0       0        0
  247         0        0    0        0      0        0       0        0
  248         0        0    0        0      0        0       0        0
  249         0        0    0        0      0        0       0        0
  250         0        0    0        0      0        0       0        0
  251         0        0    0        0      0        0       0        0
  252         0        0    0        0      0        0       0        0
  253         0        1    0        0      0        0       0        0
  254         0        0    0        0      0        0       0        0
  255         0        0    0        0      0        0       0        0
  256         0        1    0        0      0        0       0        0
  257         0        0    0        0      0        0       0        0
  258         0        0    0        0      1        0       0        0
  259         0        0    0        0      0        0       0        0
  260         0        0    0        0      0        0       0        0
  261         0        0    0        0      0        0       0        0
  262         0        0    0        0      0        0       0        0
  263         0        0    0        0      0        0       0        0
  264         0        0    0        0      0        0       0        0
  265         0        1    0        0      0        0       0        0
  266         0        0    0        0      0        0       0        0
  267         1        0    0        0      0        0       0        0
  268         0        0    0        0      0        0       0        0
  269         0        0    0        0      0        0       0        0
  270         0        0    0        0      0        0       0        1
  271         0        0    1        0      0        0       0        0
  272         0        0    0        0      0        0       0        0
  273         0        0    0        0      0        0       0        0
  274         0        0    0        0      0        0       0        0
  275         0        0    0        0      0        0       0        0
  276         0        0    0        0      0        0       0        0
  277         0        0    0        0      0        0       0        0
  278         1        0    0        0      0        0       0        0
  279         0        0    0        0      0        0       0        0
  280         0        0    0        0      0        0       0        0
  281         0        0    0        0      0        0       0        0
  282         0        0    0        0      0        0       0        0
  283         0        0    0        0      0        0       0        0
  284         0        0    0        0      0        0       0        0
     Terms
Docs  process product products professional project projects promoted
  1         0       0        0            0       0        1        0
  2         0       0        0            0       0        0        0
  3         0       0        0            0       0        1        0
  4         0       0        0            0       0        0        0
  5         0       0        0            0       0        0        0
  6         0       0        0            0       0        0        0
  7         0       0        0            0       0        0        0
  8         0       0        0            0       0        0        0
  9         0       0        0            0       0        0        0
  10        0       0        0            0       0        0        0
  11        0       0        0            0       0        0        0
  12        0       0        0            0       0        0        0
  13        0       0        0            0       0        0        0
  14        0       0        0            0       0        0        0
  15        0       0        0            0       0        0        0
  16        0       0        1            0       0        0        0
  17        0       0        0            0       0        0        0
  18        0       0        1            0       0        0        0
  19        0       0        0            0       0        1        0
  20        0       0        0            1       0        0        0
  21        0       0        0            0       0        0        0
  22        0       0        0            0       0        0        0
  23        0       0        0            0       0        0        0
  24        0       0        0            0       2        1        0
  25        0       0        0            0       0        1        0
  26        0       0        0            0       0        0        0
  27        0       0        0            0       0        0        0
  28        0       0        0            0       0        0        0
  29        0       0        0            0       0        0        0
  30        0       0        0            0       0        0        0
  31        0       0        0            0       0        1        0
  32        0       0        0            0       0        0        0
  33        0       0        0            0       0        0        0
  34        0       0        0            0       0        0        0
  35        0       0        0            0       0        0        0
  36        0       0        0            0       0        0        0
  37        0       0        0            0       0        0        0
  38        0       0        0            0       0        0        0
  39        0       0        0            0       0        0        0
  40        0       0        0            0       0        0        0
  41        0       0        0            0       0        0        0
  42        0       0        0            0       0        0        0
  43        0       0        0            0       0        0        0
  44        0       0        0            0       0        0        0
  45        1       0        0            0       0        0        0
  46        0       0        0            0       0        0        0
  47        0       0        0            0       0        0        0
  48        0       0        0            0       0        0        0
  49        0       1        0            0       0        1        0
  50        0       0        0            0       0        0        0
  51        0       0        0            0       0        1        0
  52        0       0        1            0       0        0        0
  53        0       0        0            0       0        0        0
  54        0       0        0            0       0        1        0
  55        0       0        1            0       0        1        0
  56        0       0        0            0       0        1        0
  57        0       0        0            0       0        0        0
  58        0       0        1            0       0        0        0
  59        0       0        0            0       0        0        0
  60        0       0        1            0       0        0        0
  61        0       0        0            0       0        0        0
  62        0       0        0            0       0        0        0
  63        0       0        0            0       0        0        0
  64        0       0        0            0       0        0        0
  65        0       0        0            0       0        0        0
  66        0       0        0            0       0        0        0
  67        0       0        0            0       0        0        0
  68        0       0        0            0       0        0        0
  69        0       0        1            0       0        0        0
  70        0       0        0            0       0        0        0
  71        0       0        0            0       0        0        0
  72        0       0        0            0       0        2        0
  73        0       0        0            0       0        0        0
  74        0       0        0            0       0        0        0
  75        0       0        0            1       0        0        0
  76        0       0        0            0       0        0        0
  77        0       0        0            0       0        1        0
  78        0       0        0            0       0        1        0
  79        0       0        0            0       0        0        0
  80        0       0        0            0       0        0        0
  81        0       0        0            0       0        0        0
  82        0       2        1            0       0        0        0
  83        0       0        0            0       0        0        0
  84        0       0        0            0       0        1        0
  85        0       0        0            0       0        0        0
  86        0       0        0            0       0        0        0
  87        0       0        0            0       0        0        0
  88        0       0        0            0       0        0        0
  89        0       0        0            0       0        0        0
  90        0       0        0            0       0        0        0
  91        0       0        0            0       0        0        0
  92        0       0        0            0       0        0        0
  93        0       0        0            0       0        0        0
  94        0       0        0            0       1        0        0
  95        0       0        0            0       0        0        0
  96        0       0        0            0       0        0        0
  97        0       0        0            0       0        0        0
  98        0       0        0            0       0        0        0
  99        0       0        0            0       0        0        0
  100       0       0        0            0       0        0        0
  101       0       0        0            0       0        0        0
  102       0       0        0            2       0        0        0
  103       0       0        0            0       0        0        0
  104       0       0        0            0       0        0        0
  105       0       0        0            0       0        0        0
  106       0       0        0            0       0        0        0
  107       0       0        0            0       0        0        0
  108       0       0        0            0       0        0        0
  109       0       0        0            1       0        0        0
  110       0       0        0            0       0        0        0
  111       0       0        0            0       0        0        0
  112       0       0        0            0       0        0        0
  113       0       0        0            0       0        0        0
  114       0       0        0            0       0        0        0
  115       0       0        0            0       0        0        0
  116       0       0        0            0       0        0        0
  117       0       0        0            0       0        0        0
  118       0       0        0            0       0        0        0
  119       0       0        0            0       0        0        0
  120       0       0        0            0       0        0        0
  121       0       0        0            0       0        0        0
  122       0       0        0            0       0        0        0
  123       0       0        0            0       0        0        0
  124       0       0        0            0       0        1        0
  125       0       0        0            0       0        0        0
  126       0       0        0            0       0        0        0
  127       0       0        0            0       0        0        0
  128       0       0        0            0       0        0        0
  129       0       0        0            0       0        0        0
  130       0       0        0            0       0        0        0
  131       0       0        0            0       0        0        0
  132       0       0        0            0       0        0        0
  133       0       0        0            0       2        1        0
  134       0       0        0            0       0        0        0
  135       0       0        0            0       0        0        0
  136       0       0        1            0       0        0        0
  137       0       0        0            0       0        0        0
  138       0       0        1            0       0        0        0
  139       0       0        0            0       0        0        0
  140       0       0        0            0       1        0        0
  141       0       0        0            0       0        0        0
  142       0       0        0            0       0        0        0
  143       0       0        0            0       0        1        0
  144       0       0        0            0       0        1        0
  145       0       0        0            0       0        0        0
  146       0       0        0            0       0        0        0
  147       0       0        0            0       0        0        0
  148       0       0        0            0       0        0        0
  149       0       0        0            0       0        1        0
  150       0       0        0            0       0        0        0
  151       0       0        0            0       0        0        0
  152       0       0        0            0       0        0        0
  153       0       2        0            0       0        0        0
  154       0       0        0            0       0        0        0
  155       0       0        0            0       0        0        0
  156       0       0        0            0       0        0        0
  157       0       0        0            0       0        1        0
  158       0       0        0            0       0        0        0
  159       0       0        0            0       0        0        0
  160       0       2        0            0       0        0        0
  161       0       0        0            0       0        0        0
  162       0       0        0            0       0        0        0
  163       0       0        0            0       0        0        0
  164       0       0        0            0       0        0        0
  165       0       0        0            0       0        0        0
  166       0       0        1            0       0        0        0
  167       0       0        0            0       0        0        0
  168       0       0        0            0       0        0        0
  169       0       0        0            0       0        0        0
  170       0       1        0            0       0        0        0
  171       0       0        0            0       0        0        0
  172       0       0        0            0       0        0        0
  173       0       0        0            0       0        0        0
  174       0       0        0            0       0        0        0
  175       0       0        0            0       0        2        0
  176       0       0        0            0       0        0        0
  177       0       0        0            0       0        2        0
  178       0       0        0            0       0        0        0
  179       0       0        0            0       0        0        0
  180       0       0        0            0       0        0        0
  181       0       0        0            0       0        0        0
  182       0       0        0            0       0        1        0
  183       0       0        0            0       1        0        0
  184       0       0        0            0       0        0        0
  185       0       0        0            0       0        0        0
  186       0       0        0            0       0        0        0
  187       0       0        0            0       0        0        0
  188       0       0        0            0       0        0        0
  189       0       0        0            0       0        0        0
  190       0       0        0            0       0        1        0
  191       0       0        0            0       0        0        0
  192       0       0        1            0       0        0        0
  193       0       0        2            0       0        0        0
  194       0       0        0            0       0        0        0
  195       0       0        0            0       0        0        0
  196       0       0        0            0       0        0        0
  197       0       0        0            0       0        0        0
  198       0       0        1            0       0        1        0
  199       0       0        0            0       0        1        0
  200       0       0        0            0       0        0        0
  201       0       0        0            0       0        1        0
  202       0       0        0            0       0        1        0
  203       0       0        0            0       0        1        0
  204       0       0        0            0       0        0        0
  205       0       0        0            0       0        0        0
  206       0       0        0            0       0        0        0
  207       0       0        0            0       0        1        0
  208       0       0        1            0       0        0        0
  209       0       0        0            0       1        0        0
  210       0       0        0            0       0        0        0
  211       0       0        0            0       0        0        0
  212       0       1        0            0       0        1        0
  213       0       0        0            0       0        0        0
  214       0       0        0            0       0        0        0
  215       0       0        0            0       0        1        0
  216       0       0        0            0       0        0        0
  217       0       0        0            0       0        0        0
  218       0       0        0            0       0        0        0
  219       0       0        0            0       0        0        0
  220       0       0        0            0       0        0        0
  221       0       0        0            0       1        0        0
  222       0       0        0            0       0        0        0
  223       0       0        0            0       0        0        0
  224       0       0        0            0       0        0        0
  225       0       0        0            0       0        0        0
  226       0       0        0            0       0        0        0
  227       0       0        0            0       0        0        0
  228       0       0        0            0       0        0        0
  229       0       0        0            0       0        0        0
  230       0       0        0            0       0        0        0
  231       0       0        0            0       0        0        0
  232       0       1        0            0       0        0        0
  233       0       0        0            0       0        0        0
  234       0       0        0            0       0        0        0
  235       0       0        0            0       0        0        0
  236       0       0        1            0       0        0        0
  237       0       0        0            0       0        0        0
  238       0       0        0            0       0        0        0
  239       0       0        0            0       0        0        0
  240       0       0        0            0       0        0        0
  241       0       0        0            0       0        0        0
  242       0       0        0            0       0        0        0
  243       0       0        0            0       1        0        0
  244       0       0        0            0       0        0        0
  245       0       0        0            0       0        0        0
  246       0       0        0            0       0        0        0
  247       0       0        0            0       0        0        0
  248       0       0        0            0       0        0        0
  249       0       0        0            0       0        0        0
  250       0       0        1            0       0        0        0
  251       0       0        0            0       0        0        0
  252       0       0        0            0       0        0        0
  253       0       0        0            0       0        0        0
  254       0       0        0            0       0        0        0
  255       0       0        0            0       0        0        0
  256       0       0        0            0       0        0        0
  257       0       0        0            0       0        0        0
  258       0       0        0            0       0        0        0
  259       0       0        0            0       0        0        0
  260       0       0        0            0       0        0        0
  261       0       0        0            0       0        0        0
  262       0       0        0            0       0        0        0
  263       0       0        0            0       0        0        0
  264       0       0        0            0       0        0        0
  265       1       0        0            0       0        0        0
  266       0       0        0            0       0        0        0
  267       0       0        0            0       0        0        0
  268       1       0        0            0       0        0        0
  269       0       0        0            0       0        0        0
  270       0       0        0            0       0        0        0
  271       0       0        0            0       0        0        0
  272       0       0        0            0       0        0        0
  273       0       0        0            0       0        0        0
  274       0       0        0            0       0        0        0
  275       0       0        0            0       0        0        0
  276       0       0        0            0       1        0        0
  277       0       0        0            0       0        0        0
  278       0       0        0            0       0        0        0
  279       0       0        0            0       0        0        0
  280       0       0        0            0       0        0        0
  281       0       1        0            0       0        1        0
  282       0       0        0            0       0        0        0
  283       0       0        0            0       0        0        0
  284       0       0        0            0       0        0        0
     Terms
Docs  promotion promotions pros put quality quite rather real really
  1           0          0    0   0       0     0      0    0      0
  2           0          0    0   0       0     0      0    0      0
  3           0          0    1   0       0     0      0    0      0
  4           0          0    0   0       0     0      0    0      0
  5           0          0    0   0       0     0      0    0      0
  6           0          0    0   0       0     0      0    0      0
  7           0          0    0   0       0     0      0    0      0
  8           0          0    0   0       0     0      0    0      0
  9           0          0    0   0       0     0      0    0      0
  10          0          0    0   0       0     0      0    0      0
  11          0          0    1   0       0     0      0    0      0
  12          0          0    0   0       0     0      0    0      0
  13          0          0    0   0       0     0      0    0      2
  14          0          0    0   0       0     0      0    0      0
  15          0          0    0   0       0     0      0    0      2
  16          0          0    0   0       1     0      0    0      0
  17          0          0    0   0       0     0      0    0      0
  18          0          0    0   0       0     0      1    0      0
  19          0          0    0   0       0     0      0    0      0
  20          0          0    0   0       0     1      0    0      0
  21          0          0    0   0       0     0      0    0      2
  22          0          0    0   0       0     0      0    0      0
  23          0          0    0   0       0     0      0    0      0
  24          0          0    0   0       0     0      0    1      0
  25          0          0    0   0       0     0      0    0      0
  26          0          0    0   0       0     0      0    0      0
  27          0          0    0   0       0     0      0    0      0
  28          0          0    0   0       0     0      0    0      0
  29          0          0    0   0       0     0      0    0      2
  30          0          0    0   0       0     0      0    0      0
  31          0          0    0   0       0     0      0    0      0
  32          0          0    0   0       0     0      0    0      1
  33          0          0    0   0       0     0      0    0      0
  34          0          0    0   0       0     0      0    0      0
  35          0          0    0   0       0     0      0    0      0
  36          0          0    0   0       0     0      0    0      0
  37          0          0    0   0       0     0      0    0      0
  38          0          0    0   0       0     0      0    0      0
  39          0          0    0   0       0     0      0    0      0
  40          0          0    0   0       0     0      0    0      0
  41          0          0    0   0       1     0      0    0      1
  42          0          0    0   0       0     0      0    0      1
  43          0          0    0   0       0     0      0    0      0
  44          0          0    0   0       0     0      0    0      1
  45          0          0    0   0       0     0      0    0      0
  46          0          0    0   0       0     0      0    0      0
  47          0          0    0   0       0     0      0    0      0
  48          0          0    0   0       0     0      0    0      0
  49          0          0    0   0       0     0      0    0      0
  50          0          0    0   0       0     0      0    0      0
  51          0          0    0   0       0     0      0    0      0
  52          0          0    0   0       0     0      0    0      0
  53          0          0    0   0       0     0      0    0      2
  54          0          0    0   0       0     0      0    0      1
  55          0          0    0   0       0     0      0    0      0
  56          0          0    0   0       0     0      0    0      1
  57          0          0    0   0       0     0      0    0      0
  58          0          0    0   0       0     0      0    0      0
  59          0          0    0   0       0     0      0    0      0
  60          0          0    0   0       0     0      0    0      0
  61          0          0    0   0       0     0      0    0      0
  62          0          0    0   0       0     0      0    0      0
  63          0          0    0   0       0     0      0    0      0
  64          0          0    0   0       0     0      0    0      0
  65          0          0    0   0       0     0      0    0      0
  66          0          0    0   0       0     0      2    0      0
  67          0          0    0   0       0     0      0    0      0
  68          0          0    0   0       0     0      0    0      0
  69          0          0    0   0       0     0      0    0      0
  70          0          0    0   0       0     0      0    0      0
  71          0          0    0   0       0     0      0    0      0
  72          0          0    0   1       0     0      0    1      1
  73          0          0    0   0       0     0      0    0      0
  74          0          0    0   0       0     0      0    0      0
  75          0          0    0   0       0     0      0    0      0
  76          0          0    0   0       0     0      0    0      0
  77          0          0    0   0       0     0      0    0      0
  78          0          0    0   0       0     0      0    0      0
  79          0          0    0   0       0     0      0    0      0
  80          0          0    0   0       0     0      0    0      0
  81          0          0    0   0       0     0      0    0      0
  82          0          0    0   0       0     0      0    0      0
  83          0          0    0   0       0     0      0    0      0
  84          0          0    0   0       0     0      0    0      0
  85          0          0    0   0       0     0      0    0      0
  86          0          0    0   0       0     0      0    0      0
  87          0          0    0   0       0     0      0    0      0
  88          0          0    0   0       0     0      0    0      0
  89          0          0    0   0       0     0      0    0      0
  90          0          0    0   0       0     0      0    0      0
  91          0          0    0   0       0     0      0    0      0
  92          0          0    0   0       0     0      0    0      0
  93          0          0    0   0       0     0      0    0      0
  94          0          1    0   0       0     0      0    0      0
  95          0          0    0   0       0     0      0    0      0
  96          0          0    0   0       0     0      0    0      0
  97          0          0    0   0       0     0      0    0      0
  98          0          0    0   0       0     0      0    0      0
  99          0          0    0   0       0     0      0    0      0
  100         0          0    0   0       0     0      0    0      0
  101         0          0    0   0       0     0      0    0      0
  102         0          0    0   0       0     0      0    0      0
  103         0          0    0   0       0     0      0    0      0
  104         0          0    0   0       0     0      0    0      0
  105         0          0    0   0       0     0      0    0      0
  106         0          0    0   0       0     0      0    0      0
  107         0          0    0   0       0     0      0    0      0
  108         0          0    0   0       0     0      0    0      0
  109         0          0    0   0       0     0      0    0      0
  110         0          0    0   0       0     0      0    0      0
  111         0          0    0   0       0     0      0    0      0
  112         0          0    0   0       0     0      0    0      0
  113         0          0    0   0       0     0      0    0      1
  114         0          0    0   0       0     0      0    0      0
  115         0          0    0   0       0     0      0    0      0
  116         0          0    0   0       0     0      0    0      0
  117         0          0    0   0       0     0      0    0      1
  118         0          0    0   0       0     0      0    0      0
  119         0          0    0   0       0     0      0    0      0
  120         0          0    0   0       0     0      0    0      0
  121         0          0    0   0       0     0      0    0      2
  122         0          0    0   0       0     0      0    0      0
  123         1          0    0   0       0     1      0    0      0
  124         0          0    0   0       0     0      0    0      0
  125         0          0    0   0       0     0      0    0      0
  126         0          0    0   0       0     0      0    0      0
  127         0          0    0   0       0     0      0    0      0
  128         0          0    0   0       0     0      0    0      0
  129         0          0    0   0       0     0      0    0      2
  130         0          0    0   0       1     0      0    0      0
  131         0          0    0   0       0     0      0    0      0
  132         0          0    0   0       0     0      0    0      0
  133         0          0    0   0       0     0      0    0      0
  134         0          0    0   0       0     1      0    0      0
  135         0          0    0   0       0     0      0    0      0
  136         0          0    0   0       0     0      0    0      1
  137         0          0    0   0       0     0      0    0      0
  138         0          0    0   0       0     0      0    0      0
  139         0          0    0   0       0     0      0    0      2
  140         0          0    0   0       0     0      0    0      0
  141         0          0    0   0       0     0      0    0      2
  142         0          0    0   0       0     0      0    0      0
  143         0          0    0   0       0     0      0    0      0
  144         0          0    0   0       0     0      0    0      0
  145         0          0    0   0       0     0      0    0      0
  146         0          0    0   0       0     0      0    0      0
  147         0          0    0   0       1     0      0    0      0
  148         0          0    0   0       0     0      0    0      0
  149         0          0    0   0       0     0      0    0      0
  150         0          0    0   0       0     0      0    0      0
  151         0          0    0   0       0     0      0    0      0
  152         0          0    0   0       0     0      0    0      0
  153         0          0    0   0       0     0      0    0      0
  154         0          0    0   0       0     0      0    0      0
  155         0          0    0   0       0     0      0    0      0
  156         0          0    0   0       1     0      0    0      0
  157         0          0    0   0       0     0      0    0      0
  158         0          0    0   0       0     0      0    0      0
  159         0          0    0   0       0     0      0    0      1
  160         0          0    0   0       0     0      0    0      1
  161         0          0    0   0       0     0      0    0      0
  162         0          0    0   0       0     0      0    1      0
  163         0          0    0   0       0     0      0    1      0
  164         0          0    0   0       0     0      0    0      0
  165         0          0    0   0       0     0      0    0      1
  166         0          0    0   0       0     0      0    0      1
  167         0          0    0   0       0     0      0    0      0
  168         0          0    0   0       0     0      0    0      0
  169         0          0    0   0       0     0      0    0      0
  170         0          0    0   0       0     1      0    0      1
  171         0          0    0   0       0     0      0    0      1
  172         0          0    0   0       0     0      0    0      0
  173         0          0    0   0       0     0      0    0      0
  174         0          0    0   0       0     0      0    0      0
  175         0          0    0   0       0     0      0    0      1
  176         0          0    0   0       0     0      0    0      0
  177         0          0    0   0       0     0      0    0      0
  178         0          0    0   0       0     0      0    0      0
  179         0          0    0   0       0     0      0    0      0
  180         0          0    0   0       0     0      0    0      0
  181         0          0    0   0       0     0      0    0      0
  182         0          0    0   0       0     0      0    0      0
  183         0          0    0   0       0     0      0    0      0
  184         0          0    0   0       0     0      0    0      0
  185         0          0    0   0       0     0      0    0      0
  186         0          0    0   0       0     0      0    0      0
  187         0          0    0   0       0     0      0    0      0
  188         0          0    0   0       0     0      0    0      0
  189         0          0    0   0       0     0      0    0      1
  190         0          0    0   0       0     0      0    0      0
  191         0          0    0   0       0     0      0    0      0
  192         0          0    0   0       0     0      0    0      1
  193         0          0    0   0       0     0      0    0      1
  194         0          0    0   0       0     0      0    0      0
  195         0          0    0   0       0     0      0    0      1
  196         0          0    0   0       0     0      0    0      0
  197         0          0    0   0       0     0      0    0      0
  198         0          0    0   0       0     0      0    0      1
  199         0          0    0   0       0     0      0    0      0
  200         0          0    0   0       0     0      0    0      0
  201         0          0    0   0       0     0      0    0      1
  202         0          0    0   0       0     0      0    0      0
  203         0          0    0   0       0     0      0    0      0
  204         0          0    0   0       0     0      0    0      0
  205         0          0    0   0       0     0      0    0      0
  206         0          0    0   0       0     0      0    0      0
  207         0          0    0   0       0     0      0    0      0
  208         0          0    0   0       0     0      0    0      0
  209         0          0    0   0       0     0      0    0      0
  210         0          0    0   0       0     0      0    0      0
  211         0          0    0   0       0     0      0    0      0
  212         0          0    0   0       0     0      0    0      0
  213         0          0    0   0       0     0      0    0      0
  214         0          0    0   0       0     0      0    0      0
  215         0          0    0   0       0     0      0    0      0
  216         0          0    0   0       0     0      0    0      0
  217         0          0    0   0       0     0      0    0      0
  218         0          0    0   0       0     0      0    0      0
  219         0          0    0   0       0     0      0    0      0
  220         0          0    0   0       0     0      0    0      0
  221         0          0    0   0       0     0      0    0      0
  222         0          0    0   0       0     0      0    0      0
  223         0          0    0   0       0     0      0    0      0
  224         0          0    0   0       0     0      0    0      0
  225         0          0    0   0       0     0      0    0      0
  226         0          0    0   0       0     0      0    0      1
  227         0          0    0   0       0     0      0    0      0
  228         0          0    0   0       0     0      0    0      0
  229         0          0    0   0       0     0      0    0      0
  230         0          0    0   0       0     0      0    0      0
  231         0          0    0   0       0     0      0    0      0
  232         0          0    0   0       0     0      0    0      0
  233         0          0    0   0       0     0      0    0      0
  234         0          0    0   1       0     0      0    0      0
  235         0          0    0   0       0     0      0    0      0
  236         0          0    0   0       0     0      0    0      0
  237         0          0    0   0       0     0      0    0      0
  238         0          0    0   0       0     0      0    0      0
  239         0          0    0   0       0     0      0    0      0
  240         0          0    0   0       0     0      0    0      0
  241         0          0    0   0       0     0      0    0      0
  242         0          0    0   0       0     0      0    0      0
  243         0          0    0   0       0     0      0    0      0
  244         0          0    0   0       0     0      0    0      0
  245         0          0    0   0       0     0      0    0      0
  246         0          0    0   0       0     0      0    0      0
  247         0          0    0   0       0     0      0    0      0
  248         0          0    0   0       0     0      0    0      0
  249         0          0    0   0       0     0      0    0      0
  250         0          0    0   0       0     0      0    0      1
  251         0          0    0   0       0     0      0    0      0
  252         1          0    0   0       0     0      0    0      0
  253         0          0    0   0       0     0      0    0      0
  254         0          0    0   0       0     0      0    0      0
  255         0          0    0   0       0     0      0    0      0
  256         0          0    0   0       0     0      0    0      0
  257         0          0    0   0       0     0      0    0      0
  258         0          0    0   0       0     0      0    0      0
  259         0          1    0   0       0     0      0    0      0
  260         0          0    0   0       0     0      0    0      1
  261         0          0    0   0       0     0      0    0      0
  262         0          0    0   0       0     0      0    0      0
  263         0          0    0   0       0     0      0    0      0
  264         0          0    0   0       0     0      0    0      0
  265         0          0    0   0       0     0      0    1      1
  266         0          0    0   0       0     0      0    0      0
  267         0          0    0   0       0     0      0    0      0
  268         0          0    0   0       0     0      0    0      0
  269         0          0    0   0       0     0      0    0      0
  270         0          0    0   0       0     0      0    0      0
  271         1          0    0   0       0     0      0    0      0
  272         1          0    0   0       0     0      0    0      0
  273         1          0    0   0       0     0      0    0      0
  274         0          0    0   0       0     0      0    0      0
  275         0          0    0   0       0     0      0    0      0
  276         0          0    0   0       0     0      0    1      0
  277         0          0    0   0       0     0      0    0      0
  278         0          0    0   0       0     0      0    0      0
  279         0          0    0   0       0     0      0    0      0
  280         0          0    0   0       0     0      0    0      1
  281         0          0    0   0       0     0      0    0      0
  282         0          0    0   0       0     0      0    0      0
  283         0          0    0   0       0     0      0    0      0
  284         0          0    0   0       0     0      0    0      0
     Terms
Docs  reason recognition recruiting resources respect right role room said
  1        0           0          0         0       0     0    0    0    0
  2        0           0          0         0       0     0    0    0    0
  3        0           0          0         0       0     0    0    0    0
  4        0           0          0         0       0     0    0    0    0
  5        0           0          0         0       0     0    0    0    0
  6        0           0          0         0       0     0    0    0    0
  7        0           0          0         0       0     0    0    0    0
  8        0           0          0         0       0     0    0    0    0
  9        0           0          0         0       0     0    0    0    0
  10       1           0          0         0       0     0    0    0    0
  11       0           0          0         0       0     0    0    0    0
  12       0           0          0         0       0     0    0    0    0
  13       0           0          0         0       0     0    0    0    0
  14       0           0          0         0       0     0    0    0    0
  15       0           0          0         0       0     0    0    0    0
  16       0           0          0         0       0     0    0    0    0
  17       0           0          0         0       0     0    0    0    0
  18       0           0          0         0       0     0    0    0    0
  19       0           0          0         0       0     0    0    0    0
  20       0           0          0         0       0     0    0    0    0
  21       0           0          0         0       0     0    0    0    0
  22       0           0          0         0       0     0    0    0    0
  23       0           0          0         0       0     0    0    0    0
  24       0           0          0         0       0     0    0    1    0
  25       0           0          0         0       0     0    0    0    0
  26       0           0          0         0       0     0    0    0    0
  27       0           0          0         0       0     0    0    0    0
  28       0           0          0         0       0     0    0    0    0
  29       0           0          0         0       0     1    0    0    0
  30       1           0          0         0       0     0    0    0    0
  31       0           0          0         0       0     0    0    0    0
  32       0           0          0         0       0     0    0    0    0
  33       0           0          0         0       0     0    0    0    0
  34       0           0          0         0       0     0    0    0    0
  35       0           0          0         0       0     0    0    0    0
  36       0           0          0         0       0     0    0    0    0
  37       0           0          0         0       0     0    0    0    0
  38       0           0          0         0       0     0    0    0    0
  39       0           0          0         0       0     0    0    0    0
  40       0           0          0         0       0     0    0    0    0
  41       0           0          0         0       0     0    0    0    0
  42       1           0          0         0       0     0    0    0    0
  43       0           0          0         1       0     0    0    0    0
  44       0           0          0         0       0     0    0    0    0
  45       0           0          0         0       0     0    0    0    0
  46       0           0          0         0       0     0    0    0    0
  47       0           0          0         0       0     0    0    0    0
  48       0           0          0         0       0     0    0    0    0
  49       0           0          0         0       0     0    0    0    0
  50       0           0          0         0       0     0    0    0    0
  51       0           0          0         1       0     1    0    0    0
  52       0           0          0         0       0     0    0    0    0
  53       0           0          0         1       0     0    0    0    0
  54       0           0          0         1       0     0    0    0    0
  55       0           0          0         1       0     0    0    0    0
  56       0           0          0         0       0     0    0    0    0
  57       0           0          0         0       0     0    0    0    0
  58       0           0          0         0       1     0    0    0    0
  59       0           0          0         0       0     0    0    0    0
  60       0           0          0         0       0     0    0    0    0
  61       0           0          0         0       0     0    0    0    0
  62       0           0          0         0       0     0    0    0    0
  63       0           0          0         0       0     0    0    0    0
  64       1           0          0         1       0     0    0    0    0
  65       0           0          0         0       0     0    0    0    0
  66       1           0          0         0       0     0    0    0    0
  67       0           0          0         0       0     0    0    0    0
  68       0           0          0         0       0     0    0    0    0
  69       0           0          0         0       0     0    0    0    0
  70       0           0          0         0       0     0    0    0    0
  71       0           0          0         1       0     0    0    0    0
  72       0           0          0         1       0     0    0    0    0
  73       0           0          0         0       0     0    0    0    0
  74       0           0          0         0       0     1    0    0    0
  75       1           0          0         0       0     0    0    0    0
  76       0           0          0         0       0     0    0    0    0
  77       0           0          0         0       0     0    0    0    0
  78       0           0          0         1       0     0    0    0    0
  79       0           0          0         0       0     0    0    0    0
  80       0           0          0         0       0     0    0    0    0
  81       0           0          0         0       1     0    0    0    0
  82       0           0          0         0       0     0    0    0    0
  83       0           0          0         0       0     0    0    0    0
  84       0           0          0         0       0     0    0    0    1
  85       0           0          0         0       0     0    0    0    0
  86       0           0          0         0       0     0    0    0    0
  87       0           0          0         0       0     0    0    0    0
  88       0           0          0         0       0     0    0    0    0
  89       0           0          0         0       0     0    0    0    0
  90       0           0          0         0       1     0    0    0    0
  91       0           0          0         0       0     0    0    0    0
  92       0           0          0         0       0     0    0    0    0
  93       0           0          0         0       0     0    0    0    0
  94       0           0          0         0       0     0    0    0    0
  95       0           0          0         0       0     0    0    0    0
  96       0           0          0         0       0     0    0    0    0
  97       0           0          0         0       0     0    0    0    0
  98       0           0          0         0       0     0    0    0    0
  99       0           0          0         0       0     0    0    0    0
  100      0           0          0         0       0     0    0    0    0
  101      0           0          0         0       0     0    0    0    0
  102      0           0          0         0       0     0    0    0    0
  103      0           0          0         0       1     0    0    0    0
  104      0           0          0         1       0     0    0    0    0
  105      0           0          0         0       0     0    0    0    0
  106      0           0          0         0       0     0    0    0    0
  107      0           0          0         1       0     0    0    0    0
  108      0           0          0         0       0     1    0    0    0
  109      0           0          0         0       0     0    0    0    0
  110      0           0          0         0       0     0    0    0    0
  111      0           0          0         0       0     0    0    0    0
  112      0           0          0         0       0     0    0    0    0
  113      0           0          0         0       0     0    0    0    0
  114      0           0          0         0       0     0    0    0    0
  115      0           0          0         0       0     0    0    0    0
  116      0           0          0         0       0     0    0    0    0
  117      0           0          0         0       0     0    0    0    0
  118      0           0          0         0       0     0    0    0    0
  119      0           0          0         0       0     0    0    0    0
  120      0           0          0         0       0     0    0    0    0
  121      0           0          0         0       0     0    0    0    0
  122      0           0          0         0       0     0    0    0    0
  123      0           0          0         0       0     0    0    1    0
  124      0           0          0         0       0     0    0    0    0
  125      0           0          0         0       0     0    0    0    0
  126      0           0          0         0       0     0    0    0    0
  127      0           0          0         0       0     0    0    0    0
  128      0           0          1         0       0     0    0    0    0
  129      0           0          0         0       0     1    0    0    0
  130      0           0          0         0       0     0    0    0    0
  131      0           0          0         0       0     1    0    0    0
  132      0           0          0         0       0     0    0    0    0
  133      0           0          0         0       0     0    0    0    0
  134      0           0          0         0       0     0    0    0    0
  135      0           0          0         0       0     0    0    0    0
  136      0           0          0         0       0     0    0    0    0
  137      0           0          0         0       0     0    0    0    0
  138      0           0          0         0       0     0    0    0    0
  139      0           0          0         0       1     0    0    0    0
  140      0           0          0         0       0     0    0    0    0
  141      0           0          0         0       0     0    0    0    0
  142      0           0          0         0       0     0    0    0    0
  143      0           0          0         0       0     0    0    0    0
  144      0           0          0         0       0     0    0    0    0
  145      0           0          0         0       1     0    0    0    0
  146      0           0          0         0       0     0    0    0    0
  147      0           0          0         0       0     0    0    0    0
  148      0           0          0         0       0     0    0    1    0
  149      0           0          0         0       0     0    0    0    0
  150      0           0          0         0       0     0    0    0    0
  151      0           0          0         0       0     0    0    0    0
  152      0           0          0         1       0     0    0    0    0
  153      0           0          0         0       0     0    0    0    0
  154      0           0          0         0       0     0    0    0    0
  155      0           0          0         0       0     0    0    1    0
  156      0           0          0         0       0     0    0    0    0
  157      0           0          0         0       0     0    0    0    0
  158      0           0          0         0       0     0    0    0    0
  159      0           0          0         0       0     0    0    0    0
  160      0           0          0         0       0     0    0    0    0
  161      0           0          0         0       0     1    0    0    0
  162      0           0          0         0       0     0    0    0    0
  163      0           0          0         0       0     0    0    0    0
  164      0           0          0         0       0     0    0    0    0
  165      0           0          0         0       0     0    0    0    0
  166      0           0          0         0       0     0    0    0    0
  167      0           0          0         0       0     0    0    0    0
  168      0           0          0         0       0     0    0    0    0
  169      0           0          0         0       0     0    0    0    0
  170      0           0          0         0       0     0    0    0    0
  171      0           0          0         0       0     0    1    0    0
  172      0           0          0         0       0     0    0    0    0
  173      0           0          0         0       0     0    0    0    0
  174      0           0          0         1       0     0    0    0    0
  175      0           0          0         0       0     0    0    0    0
  176      0           0          0         0       0     0    0    0    0
  177      0           0          0         0       0     0    0    0    0
  178      0           0          0         0       0     0    0    0    0
  179      0           0          0         0       0     0    0    0    0
  180      0           0          0         0       0     0    0    0    0
  181      0           0          0         0       0     0    0    0    0
  182      0           0          0         0       0     0    0    0    0
  183      0           0          0         0       0     0    0    0    0
  184      0           0          0         0       0     0    0    0    0
  185      0           0          0         0       0     0    0    0    0
  186      0           0          0         0       0     0    0    0    0
  187      0           0          0         0       0     0    0    0    0
  188      0           0          0         0       0     0    0    0    0
  189      0           0          0         0       0     0    0    0    0
  190      0           0          0         0       0     0    0    0    0
  191      0           0          0         0       0     0    0    0    0
  192      0           0          0         1       0     0    0    0    0
  193      0           0          0         0       0     1    0    0    0
  194      0           0          0         0       0     0    0    0    0
  195      0           0          0         0       0     0    0    0    0
  196      0           0          0         0       0     0    0    0    0
  197      0           0          0         0       0     0    0    1    0
  198      0           0          0         0       0     0    0    0    0
  199      0           0          0         0       0     0    0    0    0
  200      0           1          0         0       0     0    0    0    0
  201      0           0          0         0       0     0    0    0    0
  202      0           0          0         0       0     0    0    0    0
  203      0           0          0         0       0     0    0    0    0
  204      0           0          0         0       0     0    0    0    0
  205      0           0          0         0       0     0    0    0    0
  206      0           0          0         0       0     0    0    0    0
  207      0           0          0         0       0     0    0    0    0
  208      0           0          0         0       0     0    0    0    0
  209      0           0          0         0       0     0    0    0    0
  210      0           0          0         0       0     0    0    0    0
  211      0           0          0         0       0     0    0    0    0
  212      0           0          0         0       0     0    0    0    0
  213      0           0          0         0       0     0    0    1    0
  214      0           0          0         0       0     0    0    0    0
  215      0           0          0         0       0     0    0    0    0
  216      0           0          0         0       0     0    0    0    0
  217      0           0          0         0       0     0    0    0    0
  218      0           0          0         0       0     0    0    0    0
  219      0           0          0         0       0     0    0    0    0
  220      0           0          0         0       0     0    0    0    0
  221      0           0          0         0       0     0    0    0    0
  222      0           0          0         0       0     0    0    0    0
  223      0           0          0         0       0     0    0    0    0
  224      0           0          0         0       0     0    0    0    0
  225      0           0          0         0       0     0    0    0    0
  226      0           0          0         0       0     0    0    0    0
  227      0           0          0         0       0     0    0    0    0
  228      0           0          0         0       0     0    0    0    0
  229      0           0          0         0       0     0    0    0    0
  230      0           0          0         0       0     0    0    0    0
  231      0           0          0         0       0     0    0    0    0
  232      0           0          0         0       0     0    0    0    0
  233      0           0          0         0       0     1    0    0    0
  234      0           0          0         0       0     0    0    0    0
  235      0           0          0         0       0     0    0    0    0
  236      0           0          0         0       0     0    0    0    0
  237      0           0          0         0       0     0    0    0    0
  238      0           0          0         0       0     0    0    0    0
  239      0           0          0         0       0     0    0    0    0
  240      0           0          0         0       0     0    0    0    0
  241      0           0          0         0       0     0    0    0    0
  242      0           0          0         0       0     0    0    0    0
  243      1           0          0         0       0     0    0    0    0
  244      0           0          0         0       0     0    0    0    0
  245      0           0          0         0       0     0    0    0    0
  246      0           0          0         0       0     0    0    0    0
  247      0           0          0         0       0     0    0    0    0
  248      0           0          0         0       0     0    0    0    0
  249      0           0          0         0       0     0    0    0    0
  250      0           0          0         0       0     0    0    0    0
  251      0           0          1         0       0     0    0    0    0
  252      0           0          0         0       0     0    0    0    0
  253      0           0          0         0       0     0    0    0    0
  254      0           0          0         0       0     0    0    0    0
  255      0           0          0         0       0     0    0    0    0
  256      0           0          0         0       0     0    0    0    0
  257      0           0          0         0       0     0    0    0    0
  258      0           0          0         0       0     0    0    0    0
  259      0           0          0         0       0     0    0    0    0
  260      0           0          0         0       0     0    0    0    0
  261      0           0          0         0       0     0    0    0    0
  262      0           0          0         0       0     0    0    0    0
  263      0           0          0         0       0     0    0    0    0
  264      0           0          0         0       0     0    0    0    0
  265      0           0          0         0       0     0    0    0    0
  266      0           0          0         0       0     0    0    0    0
  267      0           0          0         0       0     0    0    0    0
  268      0           0          0         0       0     0    0    0    0
  269      0           0          0         1       0     0    0    0    0
  270      0           0          0         0       0     0    0    0    0
  271      0           0          0         0       0     0    0    0    0
  272      0           0          0         0       0     0    0    0    0
  273      0           0          0         0       0     0    0    0    0
  274      0           0          0         0       0     0    0    0    0
  275      0           0          0         0       0     0    0    0    0
  276      0           0          0         0       0     0    0    0    0
  277      0           0          0         0       0     0    0    0    0
  278      0           0          0         0       0     0    0    0    0
  279      0           0          0         0       0     0    0    0    0
  280      0           0          0         0       0     0    0    0    0
  281      0           0          0         0       0     0    0    0    0
  282      0           0          0         0       0     0    0    0    0
  283      0           0          0         0       0     0    0    0    0
  284      0           0          0         0       0     0    0    0    0
     Terms
Docs  salary sales say see seem seems seen senior sense several shuttle
  1        0     0   0   0    0     0    0      0     0       0       0
  2        0     0   0   0    0     0    0      0     0       0       0
  3        0     0   0   0    0     0    0      0     0       0       0
  4        0     0   0   0    0     0    0      0     0       0       0
  5        0     0   0   0    0     0    0      0     0       0       0
  6        0     0   0   0    0     0    0      0     0       0       0
  7        0     0   0   0    0     0    0      0     0       0       0
  8        0     0   0   0    0     0    0      0     0       0       0
  9        0     0   0   0    0     0    0      1     0       0       0
  10       0     0   0   0    0     0    0      0     0       0       0
  11       0     1   0   0    0     0    0      0     0       0       0
  12       0     0   0   0    0     0    0      0     0       0       0
  13       0     0   0   0    0     0    0      0     0       0       0
  14       0     0   0   0    0     0    0      0     0       0       0
  15       0     0   0   0    0     0    0      0     0       0       0
  16       0     0   0   0    0     0    0      0     1       0       0
  17       0     0   0   0    0     0    1      0     0       0       0
  18       0     0   0   0    0     0    0      0     0       0       0
  19       0     0   0   0    0     0    0      0     0       0       0
  20       0     0   0   0    0     0    0      0     0       0       0
  21       1     0   0   0    0     0    0      0     0       0       0
  22       0     0   0   0    0     0    0      0     0       0       0
  23       0     0   0   0    0     0    0      0     0       0       0
  24       0     0   0   0    0     0    0      0     0       0       0
  25       0     0   0   0    0     0    0      0     0       0       0
  26       0     0   0   0    0     0    0      0     0       0       0
  27       0     0   0   0    0     0    0      1     0       0       0
  28       0     0   0   0    0     0    0      0     0       0       0
  29       0     0   0   1    0     0    0      0     0       0       0
  30       0     0   0   0    0     0    0      0     0       0       0
  31       0     0   0   0    0     0    0      0     0       0       0
  32       0     0   0   0    0     0    0      0     0       0       0
  33       0     0   0   1    0     0    0      0     0       0       0
  34       0     0   0   0    0     0    0      0     0       0       0
  35       0     0   0   0    0     0    0      0     0       0       0
  36       0     0   0   0    0     0    0      0     0       0       0
  37       0     0   0   0    0     0    0      0     0       0       0
  38       0     0   0   0    0     0    0      0     0       0       0
  39       0     0   1   0    0     0    0      0     0       0       0
  40       0     0   0   0    0     0    0      0     0       0       0
  41       0     0   0   0    0     0    0      0     0       0       0
  42       0     0   0   0    0     0    0      0     0       0       0
  43       0     0   0   0    0     0    0      1     0       0       0
  44       0     0   0   0    0     0    1      0     0       0       0
  45       0     0   0   0    0     0    0      0     0       0       0
  46       0     0   0   0    0     0    0      0     0       0       0
  47       0     0   0   0    0     0    0      0     0       0       0
  48       0     0   0   0    0     0    0      0     0       0       0
  49       0     0   0   0    0     0    0      0     0       0       0
  50       0     0   0   0    0     0    0      0     0       0       0
  51       0     0   0   0    0     0    0      0     0       0       0
  52       0     0   0   0    0     0    0      0     0       0       0
  53       0     0   1   0    0     0    0      0     0       0       0
  54       0     0   0   0    0     0    0      0     0       0       0
  55       0     0   0   0    0     0    0      0     0       0       0
  56       1     0   0   0    0     0    0      0     0       0       0
  57       0     0   0   0    0     0    0      0     0       0       0
  58       0     0   0   0    0     0    0      0     0       0       0
  59       0     0   0   0    0     0    0      0     0       0       0
  60       0     0   0   0    0     0    0      0     0       0       0
  61       1     0   0   0    0     0    0      0     0       0       0
  62       0     0   0   0    0     0    0      0     0       0       0
  63       0     0   0   0    0     0    0      0     0       0       1
  64       0     0   0   0    0     0    0      0     0       0       0
  65       0     0   0   0    0     0    0      0     1       0       0
  66       0     0   0   0    0     0    0      0     0       0       0
  67       0     0   0   0    0     0    0      0     0       0       0
  68       0     0   0   0    0     0    0      0     0       0       0
  69       0     0   0   0    0     0    0      0     0       0       1
  70       0     0   0   0    0     0    0      0     0       0       0
  71       0     0   1   0    0     0    0      0     0       0       0
  72       0     0   0   0    0     1    0      0     0       0       0
  73       0     0   0   0    0     0    0      0     0       0       0
  74       0     0   0   0    0     0    0      0     0       0       0
  75       0     0   0   0    0     0    0      0     0       0       0
  76       0     0   0   0    0     0    0      0     0       0       0
  77       0     0   0   0    0     0    0      0     0       0       0
  78       0     0   0   0    0     0    0      0     0       0       0
  79       0     0   0   0    0     0    0      0     0       0       0
  80       0     0   0   0    0     0    0      0     0       0       0
  81       0     0   0   0    0     0    0      0     0       0       0
  82       0     0   0   0    0     0    0      0     0       0       0
  83       0     0   0   0    0     0    0      0     0       0       0
  84       0     0   0   0    0     0    0      0     1       0       0
  85       0     0   0   0    0     0    0      0     0       0       0
  86       0     0   0   0    0     0    0      0     0       0       0
  87       0     0   0   0    0     0    0      0     0       0       0
  88       0     0   0   0    0     0    0      0     0       0       0
  89       0     0   0   0    0     0    0      0     0       0       0
  90       0     0   0   0    0     0    0      0     0       0       0
  91       0     0   0   0    0     0    0      0     0       0       0
  92       0     0   0   0    0     0    0      0     0       1       0
  93       0     0   0   0    0     0    0      0     0       0       0
  94       0     0   0   0    0     0    0      0     0       1       0
  95       0     0   0   0    0     0    0      0     0       0       0
  96       0     0   0   0    0     0    0      0     0       0       0
  97       0     0   0   0    0     0    0      0     0       0       0
  98       0     0   0   0    0     0    0      0     0       0       0
  99       0     0   0   0    0     0    0      0     0       0       0
  100      0     0   0   0    0     0    0      0     0       0       0
  101      0     0   0   0    0     0    0      0     0       0       0
  102      1     0   0   0    0     0    0      0     0       0       0
  103      0     0   0   0    0     0    0      0     0       0       0
  104      0     0   0   0    0     0    0      0     0       0       0
  105      0     0   0   0    0     0    0      0     0       0       0
  106      0     0   0   0    0     0    0      0     0       0       0
  107      0     0   0   0    0     0    0      0     0       0       0
  108      0     0   0   0    0     0    0      0     0       0       0
  109      0     0   0   0    0     0    0      0     0       1       0
  110      0     0   0   0    0     0    0      0     0       0       0
  111      0     0   0   0    0     0    0      0     0       0       0
  112      0     0   0   0    0     0    0      0     0       0       0
  113      0     0   0   0    0     0    0      0     0       0       0
  114      0     0   0   0    0     0    0      0     0       0       0
  115      0     0   0   0    0     0    1      0     0       0       0
  116      0     0   0   0    0     0    0      0     0       0       0
  117      0     0   0   0    0     0    0      0     0       0       0
  118      0     0   0   0    0     0    0      0     0       0       0
  119      0     0   0   0    0     0    0      0     0       0       0
  120      0     0   0   0    0     0    0      0     0       0       0
  121      0     0   0   1    0     0    0      0     0       0       0
  122      0     0   0   0    0     0    0      0     0       0       0
  123      1     0   0   1    0     0    0      0     0       0       0
  124      1     0   0   0    0     0    0      0     0       0       0
  125      0     0   0   0    0     0    0      0     0       0       0
  126      0     0   0   0    0     0    0      1     0       0       0
  127      0     0   0   0    0     0    0      0     0       0       0
  128      0     0   0   0    0     0    0      0     0       0       0
  129      0     0   0   0    0     0    0      0     0       0       0
  130      0     0   0   0    0     0    0      0     0       0       0
  131      1     0   0   0    0     0    0      0     0       0       0
  132      0     0   0   0    0     0    0      0     0       0       0
  133      0     0   0   0    0     0    0      0     0       1       0
  134      0     0   0   0    0     0    1      0     0       0       0
  135      0     0   0   0    0     0    0      0     0       0       0
  136      0     0   1   0    0     0    0      0     0       0       0
  137      0     0   0   0    0     0    0      0     0       0       0
  138      0     0   0   0    0     0    0      1     0       0       0
  139      0     0   0   0    0     0    0      0     0       0       0
  140      0     0   0   0    0     0    0      0     0       0       0
  141      0     0   0   0    0     0    0      0     0       0       0
  142      0     0   0   0    0     0    0      0     0       0       0
  143      0     0   0   0    0     0    0      0     0       0       0
  144      0     0   0   0    0     0    0      0     0       0       0
  145      0     0   0   0    0     0    0      0     0       0       0
  146      0     0   0   0    0     0    0      0     0       0       0
  147      0     0   1   0    0     0    0      0     0       0       0
  148      0     0   0   0    0     0    0      0     0       0       0
  149      0     0   0   0    0     0    0      0     0       0       0
  150      0     0   0   0    0     0    0      0     0       0       0
  151      0     0   0   0    0     0    0      0     0       0       0
  152      0     0   0   0    0     0    0      0     0       0       0
  153      0     0   0   0    0     0    0      0     0       0       0
  154      0     0   0   0    0     0    0      0     1       0       0
  155      0     0   0   0    0     0    0      0     0       0       0
  156      0     0   0   0    0     0    0      0     0       0       0
  157      1     0   0   0    0     0    0      0     0       0       0
  158      0     0   0   0    0     0    0      0     0       0       0
  159      0     0   0   0    0     0    0      0     0       0       0
  160      0     0   0   0    0     0    0      0     0       0       0
  161      0     0   0   0    0     0    0      0     0       0       0
  162      0     0   0   0    0     0    0      0     0       0       0
  163      0     0   0   0    0     0    1      0     0       0       0
  164      0     0   0   0    0     0    0      0     0       0       0
  165      0     0   0   0    0     0    0      0     0       0       0
  166      0     0   0   0    0     0    0      0     0       0       0
  167      0     0   0   0    0     0    0      0     0       0       0
  168      0     0   0   0    0     0    0      0     0       0       0
  169      0     0   0   0    0     0    0      0     0       0       0
  170      0     0   0   0    0     0    0      0     0       0       0
  171      0     0   0   0    0     0    0      1     0       0       0
  172      1     0   0   0    0     0    0      0     0       0       0
  173      0     0   0   0    0     0    0      0     0       0       0
  174      0     0   0   0    0     0    0      0     0       0       0
  175      0     0   0   0    0     0    0      0     0       0       0
  176      0     0   0   0    0     0    0      0     0       0       0
  177      0     0   0   0    0     0    0      0     0       0       0
  178      0     0   0   0    0     0    0      0     0       0       0
  179      0     0   0   0    0     0    0      0     0       0       0
  180      0     0   0   0    0     0    0      0     0       0       0
  181      0     0   0   0    0     0    0      0     0       0       0
  182      0     0   0   0    0     0    0      0     1       0       0
  183      0     0   0   0    0     0    0      0     0       0       0
  184      0     0   0   0    0     0    0      0     0       0       0
  185      1     0   0   0    0     0    0      0     0       0       0
  186      0     0   0   0    0     0    0      0     0       0       0
  187      0     0   0   0    0     0    0      0     0       0       0
  188      0     0   0   0    0     0    0      0     0       0       0
  189      0     0   0   0    0     0    0      0     0       0       0
  190      0     0   0   0    0     0    0      0     0       0       0
  191      1     0   0   0    0     0    0      0     0       0       0
  192      0     0   0   0    0     0    0      0     0       0       0
  193      0     0   0   0    0     0    0      0     0       0       0
  194      0     0   0   0    0     0    0      0     0       0       0
  195      0     0   0   0    0     0    0      0     0       0       0
  196      0     0   0   0    0     0    0      0     0       0       0
  197      0     0   0   0    0     0    0      0     0       0       0
  198      0     0   0   0    0     0    0      0     0       0       0
  199      0     0   0   0    0     0    0      0     0       0       0
  200      0     0   0   0    0     0    0      0     0       0       0
  201      0     0   0   0    0     0    0      0     0       0       0
  202      0     0   0   0    0     0    0      0     0       0       0
  203      0     0   0   0    0     0    0      0     0       0       0
  204      0     0   0   0    0     0    0      0     0       0       0
  205      0     0   0   0    0     0    0      0     0       0       0
  206      0     0   0   0    0     0    0      0     0       0       0
  207      0     0   0   0    0     0    0      0     0       0       0
  208      0     0   0   0    0     0    0      0     0       0       1
  209      0     0   0   0    0     0    0      0     0       0       0
  210      0     0   0   0    0     0    0      0     0       0       0
  211      0     0   0   0    0     0    0      0     0       0       0
  212      0     0   0   0    0     0    0      0     0       0       0
  213      0     0   0   0    0     0    0      0     0       0       0
  214      0     0   0   0    0     0    0      0     0       0       0
  215      0     0   0   0    0     0    0      0     0       0       0
  216      0     0   0   0    0     0    0      0     0       0       0
  217      0     0   0   0    0     0    0      0     0       0       0
  218      0     0   0   0    0     0    0      0     0       0       0
  219      0     0   0   0    0     0    0      0     0       0       0
  220      0     0   0   0    0     0    0      0     0       0       0
  221      0     0   0   0    0     0    0      0     0       0       0
  222      0     0   0   0    0     0    0      0     0       0       0
  223      0     0   0   0    0     0    0      0     0       0       0
  224      0     0   0   0    0     0    0      0     0       0       0
  225      0     0   0   0    0     0    0      0     0       0       0
  226      0     0   0   0    0     0    0      0     0       0       0
  227      0     0   1   0    0     0    0      0     0       0       0
  228      0     0   0   0    0     0    0      0     0       0       0
  229      0     0   0   0    0     0    0      0     0       0       0
  230      0     0   0   0    0     0    0      0     0       0       0
  231      0     0   0   0    0     0    0      0     0       0       0
  232      1     0   0   0    0     0    0      0     0       0       1
  233      0     0   0   0    0     0    0      0     0       0       0
  234      0     0   0   0    0     0    0      0     0       0       0
  235      0     0   1   0    0     0    0      0     0       0       0
  236      0     0   0   0    0     0    0      0     0       0       0
  237      0     0   0   0    0     0    0      0     0       0       0
  238      0     0   0   0    0     0    0      0     0       1       0
  239      0     0   0   0    0     0    0      0     0       0       0
  240      0     0   0   0    0     0    0      0     0       0       0
  241      0     0   0   0    0     0    0      0     0       0       0
  242      0     0   0   0    0     0    0      0     0       0       0
  243      0     0   0   0    0     0    0      0     0       0       0
  244      0     0   0   0    0     0    0      0     0       0       0
  245      0     0   0   0    0     0    0      0     0       0       0
  246      0     0   0   0    0     0    0      0     0       0       0
  247      0     0   0   0    0     0    0      0     0       0       0
  248      0     0   0   0    0     0    0      0     0       0       0
  249      0     0   0   0    0     0    0      0     0       0       0
  250      0     0   0   0    0     0    0      0     0       0       0
  251      0     0   0   0    0     0    0      0     0       0       0
  252      0     0   0   0    0     0    0      0     0       0       0
  253      0     0   0   0    0     0    0      0     0       0       0
  254      0     0   0   0    0     0    0      0     0       0       0
  255      0     0   0   0    0     0    0      0     0       0       0
  256      0     0   0   0    0     0    0      0     0       0       0
  257      0     0   0   0    0     0    0      0     0       0       0
  258      0     0   0   0    0     0    0      0     0       0       0
  259      0     0   0   0    0     0    0      0     0       0       0
  260      0     0   0   0    0     0    0      0     0       0       0
  261      0     0   0   0    0     0    0      0     0       0       2
  262      0     0   0   0    0     0    0      0     0       0       0
  263      0     0   0   0    0     0    0      0     0       0       0
  264      0     0   0   0    0     0    0      0     0       0       0
  265      0     0   0   0    0     0    0      0     0       0       0
  266      0     0   0   0    0     0    0      0     0       0       0
  267      0     0   0   0    1     0    0      0     0       0       0
  268      0     0   0   0    0     0    0      0     0       0       0
  269      0     0   0   0    0     0    0      0     0       0       0
  270      0     0   0   0    0     0    0      0     0       0       0
  271      0     0   0   0    0     0    0      0     0       0       0
  272      0     0   0   0    0     0    0      0     1       0       0
  273      0     0   0   0    0     0    0      0     0       0       0
  274      0     0   0   0    0     0    0      0     0       0       0
  275      0     0   0   0    0     0    0      0     0       0       0
  276      0     0   0   0    0     0    0      0     0       0       0
  277      0     0   0   0    0     1    0      0     0       0       0
  278      0     0   0   0    0     0    0      0     0       0       0
  279      1     0   0   0    0     0    0      0     0       0       0
  280      0     0   0   0    0     0    0      0     0       0       0
  281      0     0   0   0    0     0    0      0     0       0       0
  282      0     0   0   0    0     0    0      0     1       0       0
  283      0     0   0   1    0     0    0      0     0       0       0
  284      0     0   0   0    0     0    0      0     0       0       0
     Terms
Docs  similar since skills slow smart smartest social software someone
  1         0     0      0    0     0        0      0        0       0
  2         0     0      0    0     1        0      0        0       0
  3         0     0      0    0     0        0      0        0       0
  4         0     0      0    0     0        0      0        0       0
  5         0     0      0    0     0        0      0        0       0
  6         0     0      0    0     1        0      0        0       0
  7         0     0      0    0     0        0      0        0       0
  8         0     0      0    0     0        0      0        0       0
  9         0     0      0    0     0        0      0        0       0
  10        0     0      0    0     0        0      0        0       0
  11        0     0      0    0     0        0      0        0       0
  12        0     0      0    0     1        0      0        0       0
  13        0     0      0    0     0        0      0        0       0
  14        0     0      0    0     0        0      0        0       0
  15        0     0      0    0     1        0      0        0       0
  16        0     0      0    0     0        0      0        0       0
  17        0     0      0    0     1        0      0        0       0
  18        0     0      0    0     0        0      0        0       0
  19        0     0      0    0     0        0      0        0       0
  20        0     0      1    0     0        0      0        1       0
  21        0     0      0    0     0        0      0        0       0
  22        0     0      0    0     0        0      0        0       0
  23        0     0      0    0     0        0      0        0       0
  24        0     0      0    0     0        0      0        0       0
  25        0     0      0    0     0        0      0        0       0
  26        0     0      0    0     1        0      0        0       0
  27        0     0      0    0     0        0      0        0       0
  28        0     0      0    0     0        0      0        0       0
  29        0     0      0    0     0        0      0        0       0
  30        0     0      0    0     0        0      0        0       0
  31        0     0      0    0     0        0      0        0       0
  32        0     0      0    0     1        0      0        0       0
  33        0     0      0    0     0        0      0        0       0
  34        0     0      0    0     0        0      0        0       0
  35        0     0      0    0     0        0      0        0       0
  36        0     0      0    0     0        0      0        0       0
  37        0     0      0    0     0        0      1        0       0
  38        0     0      0    0     0        0      0        0       0
  39        0     0      0    0     0        0      0        0       0
  40        0     0      0    0     0        0      0        0       0
  41        0     0      0    0     1        0      0        0       0
  42        0     0      0    0     0        0      0        0       0
  43        0     0      0    0     0        0      0        0       0
  44        0     0      0    0     1        0      0        0       0
  45        0     0      1    0     0        1      0        1       0
  46        0     0      0    0     0        0      0        0       0
  47        0     0      0    0     0        0      0        0       0
  48        0     0      0    0     1        0      0        0       0
  49        0     0      0    0     0        0      0        0       0
  50        0     0      0    0     1        0      0        0       0
  51        0     0      0    0     0        0      0        0       0
  52        0     0      0    0     0        1      0        0       0
  53        0     0      0    0     1        0      1        0       0
  54        0     0      0    0     0        0      0        0       0
  55        0     0      0    0     0        0      0        0       0
  56        0     0      0    0     1        0      0        0       0
  57        0     0      0    0     0        0      0        0       0
  58        0     0      0    0     0        0      0        0       0
  59        0     0      0    0     0        0      0        0       0
  60        0     0      0    0     0        0      0        0       0
  61        0     0      0    0     1        0      0        0       0
  62        0     0      0    0     0        0      0        1       0
  63        0     0      0    0     0        0      0        0       0
  64        0     0      0    0     1        0      0        1       0
  65        0     0      0    0     0        0      0        0       0
  66        0     1      0    0     0        0      0        0       0
  67        0     0      0    0     0        0      0        0       0
  68        0     0      0    0     0        0      0        0       0
  69        0     0      0    0     1        0      0        0       0
  70        0     0      2    0     0        0      0        0       0
  71        0     0      0    0     1        0      0        0       0
  72        0     0      0    0     0        0      0        0       0
  73        0     0      0    0     0        0      0        0       0
  74        0     0      0    0     0        0      0        0       0
  75        0     0      0    0     0        0      0        0       0
  76        0     0      0    0     0        0      1        0       0
  77        0     0      0    0     1        0      0        0       0
  78        0     0      0    0     1        0      0        0       0
  79        0     0      0    0     0        0      0        0       0
  80        0     0      0    0     0        0      0        0       0
  81        0     0      0    0     0        0      0        0       0
  82        0     0      0    0     1        0      0        0       0
  83        0     0      0    0     0        0      0        0       0
  84        0     0      0    0     0        0      0        0       0
  85        0     0      0    0     1        0      0        0       0
  86        0     0      0    0     0        0      0        0       0
  87        0     0      0    0     0        0      0        0       0
  88        0     0      0    0     0        0      0        0       0
  89        0     0      0    0     0        0      0        0       0
  90        0     0      0    0     0        0      0        0       0
  91        0     0      0    0     0        0      0        0       0
  92        0     0      0    0     0        0      0        0       0
  93        0     0      0    0     0        0      0        0       0
  94        0     0      0    0     0        0      0        0       0
  95        0     0      0    0     0        0      0        0       0
  96        0     0      0    0     1        0      0        0       0
  97        0     0      0    0     0        0      0        0       0
  98        0     0      0    0     0        0      0        0       0
  99        0     0      0    0     0        0      0        0       0
  100       0     0      0    0     0        0      0        0       0
  101       0     0      0    0     0        0      0        0       0
  102       0     0      0    0     0        0      0        0       0
  103       0     0      0    0     0        0      0        0       0
  104       0     0      0    0     0        0      0        0       0
  105       0     0      0    0     0        0      0        0       0
  106       0     0      0    0     0        0      0        0       0
  107       0     0      0    0     0        0      0        0       0
  108       0     0      0    0     1        0      0        0       0
  109       0     0      0    0     0        0      0        0       0
  110       0     0      0    0     0        0      0        0       0
  111       0     0      0    0     0        0      0        0       0
  112       0     0      0    0     1        0      0        0       0
  113       0     0      0    0     0        0      0        0       0
  114       0     0      0    0     0        0      0        0       0
  115       0     0      0    0     0        0      0        0       0
  116       0     0      0    0     1        0      0        0       0
  117       0     0      0    0     0        0      0        0       0
  118       0     0      0    0     0        0      0        0       0
  119       0     0      0    0     0        0      0        0       0
  120       0     0      0    0     0        0      0        0       0
  121       0     0      0    0     1        0      0        0       0
  122       0     0      0    0     1        0      0        0       0
  123       0     0      0    0     0        0      0        0       0
  124       0     0      0    0     1        0      0        0       0
  125       0     0      0    0     1        0      0        0       0
  126       0     0      0    0     0        1      0        0       0
  127       0     0      0    0     0        0      0        0       0
  128       0     0      0    0     0        0      0        0       0
  129       0     0      0    0     1        0      0        0       0
  130       1     0      0    0     0        0      0        0       0
  131       0     0      0    0     1        0      0        0       0
  132       0     0      0    0     1        0      0        1       0
  133       0     0      0    0     1        0      0        0       0
  134       0     0      0    0     1        0      0        0       0
  135       0     0      0    0     0        0      0        0       0
  136       0     0      0    0     0        0      0        0       0
  137       0     0      0    0     0        0      0        1       0
  138       0     0      0    0     0        0      0        0       0
  139       0     0      0    0     0        1      0        0       0
  140       0     0      0    0     0        0      0        0       0
  141       0     0      0    0     0        0      0        0       0
  142       0     0      0    0     0        0      0        0       0
  143       0     0      0    0     0        0      0        0       0
  144       0     0      0    0     0        0      0        0       0
  145       0     0      0    0     0        0      0        0       0
  146       0     0      0    0     1        0      0        0       0
  147       0     0      0    0     0        0      0        0       0
  148       0     0      0    0     0        0      0        0       0
  149       0     0      0    0     1        0      0        0       0
  150       0     0      0    0     1        0      0        0       0
  151       0     0      0    0     1        0      0        0       0
  152       0     0      0    0     0        0      0        0       0
  153       0     0      0    0     0        0      0        0       0
  154       0     0      0    0     0        0      0        0       0
  155       0     0      0    0     0        0      0        0       0
  156       0     0      0    0     0        0      0        0       0
  157       0     0      0    0     1        0      0        0       0
  158       0     0      0    0     1        0      0        0       0
  159       0     0      0    0     0        0      0        0       0
  160       0     0      0    0     1        0      0        1       0
  161       0     0      0    0     1        0      0        0       0
  162       0     0      0    0     0        0      0        0       0
  163       0     0      0    0     0        0      0        0       0
  164       0     0      0    0     0        0      0        0       0
  165       0     0      0    0     0        0      0        0       0
  166       0     0      0    0     0        0      0        0       0
  167       0     0      0    0     1        0      0        0       0
  168       0     0      0    0     1        0      0        0       0
  169       0     0      0    0     1        0      0        0       0
  170       0     0      0    0     1        0      0        0       0
  171       0     0      0    0     0        0      0        0       0
  172       0     0      0    0     0        0      0        0       0
  173       0     0      1    0     0        0      0        0       0
  174       0     0      0    0     1        0      0        0       0
  175       0     0      0    0     1        0      0        0       0
  176       0     0      0    0     0        0      0        0       0
  177       0     0      0    0     1        0      0        0       0
  178       0     0      0    0     1        0      0        0       0
  179       0     0      0    0     0        0      0        0       0
  180       0     0      0    0     1        0      0        0       0
  181       0     0      0    0     0        0      0        0       0
  182       0     0      0    0     0        0      0        0       0
  183       0     0      0    0     0        0      0        0       0
  184       0     0      0    0     0        0      0        0       0
  185       0     0      0    0     0        0      0        0       0
  186       0     0      0    0     1        0      0        0       0
  187       0     0      0    0     0        0      0        0       0
  188       0     0      0    0     0        0      0        0       0
  189       0     0      0    0     0        0      0        0       0
  190       0     0      0    0     0        0      0        2       0
  191       0     0      0    0     0        0      0        0       0
  192       0     0      0    0     0        0      0        0       0
  193       0     0      0    0     0        0      0        0       0
  194       0     0      0    0     0        0      0        0       0
  195       0     0      0    0     1        0      0        0       0
  196       0     0      0    0     1        0      0        0       0
  197       0     0      0    0     1        0      0        0       0
  198       0     0      0    0     1        0      0        0       0
  199       0     0      0    0     0        0      0        0       0
  200       0     0      1    0     0        0      0        0       0
  201       0     0      0    0     1        0      0        0       0
  202       0     0      0    0     0        0      0        0       0
  203       0     0      0    0     0        0      0        0       0
  204       0     0      0    0     1        0      0        0       0
  205       0     0      0    0     0        0      0        0       0
  206       0     0      0    0     1        0      0        0       0
  207       0     0      0    0     0        0      0        0       0
  208       0     0      0    0     0        0      0        0       0
  209       0     0      0    0     0        0      0        0       0
  210       0     0      0    0     0        0      0        0       0
  211       0     0      0    0     0        0      0        0       0
  212       0     0      0    0     1        0      0        0       0
  213       0     0      0    0     0        0      0        0       0
  214       0     0      0    0     0        0      0        0       0
  215       0     0      0    0     0        0      0        0       0
  216       0     0      0    0     0        0      0        0       0
  217       0     0      0    0     0        0      0        0       0
  218       0     0      0    0     1        0      0        0       0
  219       0     0      0    0     0        0      0        1       0
  220       0     0      0    0     0        0      0        0       0
  221       0     0      0    0     1        0      0        0       0
  222       0     0      0    0     0        0      0        0       0
  223       0     0      0    0     0        0      0        0       0
  224       0     0      0    0     0        1      0        0       0
  225       0     0      0    0     0        0      0        0       0
  226       0     0      0    0     1        0      0        0       0
  227       0     0      0    0     1        0      0        0       0
  228       0     0      0    0     0        0      0        0       0
  229       0     0      0    0     0        0      0        0       0
  230       0     0      0    0     1        0      0        0       0
  231       0     0      0    0     0        0      0        0       0
  232       0     0      0    0     1        0      1        0       0
  233       0     0      0    0     0        1      0        0       0
  234       0     0      0    0     1        0      0        0       0
  235       1     0      0    0     0        0      0        0       0
  236       0     0      0    0     1        0      0        0       0
  237       0     0      0    0     0        0      0        0       0
  238       0     0      0    0     0        0      0        0       0
  239       0     0      0    0     0        0      0        0       0
  240       0     0      0    0     0        0      0        0       0
  241       0     0      0    0     1        0      0        0       0
  242       0     0      0    0     0        0      0        0       0
  243       0     0      0    0     0        0      0        0       0
  244       0     0      0    0     0        0      0        0       0
  245       0     0      0    0     0        0      0        0       0
  246       0     0      0    0     0        0      0        0       0
  247       0     0      0    0     0        0      0        0       0
  248       0     0      0    0     0        0      0        0       0
  249       0     0      0    0     0        0      0        0       0
  250       0     0      0    0     0        0      0        0       0
  251       0     0      0    1     0        0      0        0       0
  252       0     0      0    0     0        0      0        0       0
  253       0     0      0    0     0        0      0        0       0
  254       0     0      0    0     0        0      0        0       1
  255       0     0      0    0     0        0      0        0       0
  256       0     0      0    0     0        0      0        0       0
  257       0     0      0    0     0        0      0        0       0
  258       0     0      0    0     0        0      0        0       0
  259       0     0      0    0     0        0      0        0       1
  260       0     0      0    0     0        0      0        0       0
  261       0     0      0    0     0        0      0        0       0
  262       0     0      0    0     0        0      0        0       0
  263       0     0      0    0     0        0      0        0       0
  264       0     0      0    0     0        0      0        0       0
  265       0     0      0    0     0        0      0        0       0
  266       0     0      0    0     0        0      0        0       0
  267       0     0      0    0     0        0      0        0       0
  268       0     0      0    1     0        0      0        0       0
  269       0     0      0    0     0        0      0        0       0
  270       1     0      0    0     0        0      0        0       0
  271       0     0      0    0     0        0      0        0       0
  272       0     0      0    0     0        0      0        0       0
  273       0     1      0    0     0        0      0        0       0
  274       0     0      0    0     0        0      0        0       0
  275       0     1      0    0     0        0      0        0       0
  276       0     0      0    0     0        0      0        0       0
  277       0     0      1    0     0        0      0        0       0
  278       0     0      0    0     0        0      0        0       0
  279       0     0      0    0     0        0      0        0       0
  280       0     0      0    0     0        0      0        0       0
  281       0     0      0    0     0        0      0        0       0
  282       0     0      0    0     0        0      0        0       0
  283       0     0      0    0     0        0      0        0       0
  284       0     0      0    0     0        0      0        0       0
     Terms
Docs  something sometimes spend start startup still strong structure stuff
  1           0         0     0     0       0     0      0         0     0
  2           0         0     0     0       0     0      0         0     0
  3           0         0     0     0       0     0      0         0     0
  4           0         0     0     0       0     0      0         0     0
  5           0         0     0     0       0     0      0         0     0
  6           0         0     0     0       0     0      0         0     0
  7           0         0     0     0       0     0      0         0     0
  8           0         0     0     0       0     0      0         0     0
  9           0         0     0     0       0     0      0         0     0
  10          0         0     0     0       0     0      0         0     0
  11          0         0     0     0       0     0      1         0     0
  12          0         0     0     0       0     0      0         0     0
  13          1         0     0     0       0     0      0         0     0
  14          0         0     0     0       0     0      0         0     0
  15          0         0     0     0       0     0      0         0     0
  16          0         0     0     0       0     0      0         0     0
  17          0         0     0     0       0     0      0         0     0
  18          0         0     0     0       0     0      0         0     0
  19          0         0     0     0       0     0      0         0     0
  20          0         0     0     0       0     0      0         0     0
  21          0         0     0     0       0     0      1         0     0
  22          0         0     0     0       0     0      0         0     0
  23          0         0     0     0       0     0      0         0     0
  24          0         0     0     0       0     0      0         0     0
  25          0         0     0     0       0     0      0         0     0
  26          0         0     0     0       0     0      0         0     0
  27          0         0     0     0       0     0      1         0     0
  28          0         0     0     0       0     0      0         0     0
  29          0         0     0     0       0     0      0         0     0
  30          1         0     0     0       0     0      0         0     0
  31          0         0     0     0       0     0      0         0     0
  32          1         0     0     0       0     0      0         0     0
  33          0         0     0     0       0     0      0         0     0
  34          0         0     0     0       0     0      0         0     0
  35          0         0     0     0       0     0      1         0     0
  36          0         0     0     0       0     0      0         0     0
  37          0         0     0     0       0     0      0         0     0
  38          0         0     0     0       0     0      0         0     0
  39          0         0     0     0       0     0      0         0     0
  40          0         0     0     0       0     0      0         0     0
  41          0         0     0     0       0     0      0         0     0
  42          0         0     0     0       0     0      0         0     0
  43          0         0     0     0       0     0      0         0     0
  44          0         0     0     0       0     0      0         0     0
  45          0         0     0     0       0     0      0         0     0
  46          0         0     0     0       0     0      0         0     0
  47          0         0     0     0       0     0      0         0     0
  48          0         0     0     0       0     0      0         0     0
  49          0         0     0     0       0     0      0         0     0
  50          0         0     0     0       0     0      0         0     0
  51          0         0     0     0       0     0      0         0     1
  52          0         0     0     0       0     0      0         0     0
  53          0         0     0     0       0     0      0         0     0
  54          0         0     1     0       0     0      0         0     0
  55          0         0     0     1       0     0      0         0     0
  56          0         0     0     0       0     0      0         0     0
  57          0         0     0     0       0     0      0         0     0
  58          1         0     0     0       0     0      0         0     0
  59          0         0     0     0       0     0      0         0     0
  60          0         0     0     0       0     0      0         0     0
  61          0         0     0     0       0     0      0         0     0
  62          0         0     0     0       0     0      0         0     0
  63          0         0     0     0       0     0      0         0     0
  64          0         0     0     0       0     0      0         0     0
  65          0         0     0     0       0     0      0         0     0
  66          0         0     0     0       0     0      0         0     0
  67          0         0     1     0       0     0      0         0     0
  68          0         0     0     0       0     0      0         0     0
  69          0         0     0     0       0     0      0         0     0
  70          0         0     0     0       0     0      0         0     0
  71          0         0     0     0       0     0      0         0     0
  72          0         0     0     0       0     0      0         0     0
  73          0         0     0     0       0     1      0         0     0
  74          0         0     0     1       0     0      0         0     0
  75          0         0     0     0       0     0      0         0     0
  76          0         0     0     0       0     0      0         0     0
  77          0         0     0     0       0     0      0         0     0
  78          0         0     0     0       0     0      0         0     0
  79          0         0     0     0       0     0      0         0     0
  80          0         0     0     0       0     0      0         0     0
  81          0         0     0     0       0     0      0         0     0
  82          0         0     0     0       0     0      0         0     0
  83          0         0     0     0       0     0      0         0     0
  84          0         0     1     0       0     0      0         0     0
  85          0         0     0     0       0     0      0         0     0
  86          0         0     0     0       0     0      0         0     0
  87          0         0     0     0       0     0      0         0     0
  88          0         0     0     0       0     0      0         0     0
  89          0         0     0     0       0     0      0         0     0
  90          0         0     0     0       0     0      0         0     0
  91          0         0     0     0       0     0      0         0     0
  92          0         0     0     0       0     0      0         0     0
  93          0         0     0     0       0     0      0         0     0
  94          0         0     0     0       0     1      0         0     0
  95          0         0     0     0       0     0      0         0     0
  96          0         0     0     0       0     0      0         0     0
  97          0         0     0     0       0     0      0         0     0
  98          0         0     0     0       0     0      0         0     0
  99          0         0     0     0       0     1      0         0     0
  100         0         0     0     0       0     0      0         0     0
  101         0         0     0     0       0     0      0         0     0
  102         0         0     0     0       0     0      0         0     0
  103         0         0     0     0       0     1      0         0     0
  104         0         0     0     0       0     1      0         0     0
  105         0         0     0     0       0     0      0         0     0
  106         0         0     0     0       0     0      0         0     0
  107         0         0     0     0       0     0      0         0     0
  108         0         0     0     0       1     0      0         0     0
  109         0         0     0     0       0     0      0         0     0
  110         0         0     0     0       0     0      0         0     0
  111         0         0     0     0       0     0      0         0     0
  112         0         0     0     0       0     0      0         0     0
  113         0         0     0     0       0     0      0         0     0
  114         0         0     0     0       0     0      0         0     0
  115         0         0     0     0       0     0      0         0     0
  116         0         0     0     0       0     0      0         0     0
  117         0         0     0     0       0     0      0         0     0
  118         0         0     0     0       0     1      0         0     0
  119         0         0     0     0       1     0      0         0     0
  120         0         0     0     0       0     0      0         0     0
  121         0         0     0     0       0     0      0         0     0
  122         0         0     0     0       0     0      0         0     0
  123         0         0     0     0       0     0      0         0     0
  124         0         0     0     0       0     0      0         0     0
  125         0         0     0     0       0     0      0         0     0
  126         0         0     0     0       0     0      0         0     0
  127         0         0     0     0       0     0      0         0     0
  128         0         0     0     0       0     0      0         0     0
  129         0         0     0     0       0     0      0         0     0
  130         0         0     0     0       0     0      0         0     0
  131         0         0     0     0       0     0      0         0     0
  132         0         0     0     0       0     0      0         0     0
  133         0         0     0     0       0     0      0         0     0
  134         0         0     0     0       0     0      0         0     0
  135         0         0     0     0       0     0      0         0     0
  136         0         0     0     0       0     0      0         0     0
  137         1         0     0     0       0     0      0         0     0
  138         0         0     0     0       0     0      0         0     0
  139         0         0     0     0       0     0      0         0     0
  140         0         0     0     0       0     0      0         1     0
  141         0         0     0     0       0     0      0         0     0
  142         0         0     0     0       0     0      0         0     0
  143         0         0     0     0       0     0      0         0     0
  144         0         0     0     0       0     0      0         0     0
  145         0         0     0     0       0     0      0         0     0
  146         0         0     0     0       0     0      0         0     0
  147         1         0     0     0       0     0      0         0     0
  148         0         0     0     0       0     0      0         0     0
  149         0         0     0     0       0     0      0         0     0
  150         0         0     0     0       0     0      0         0     0
  151         0         0     0     0       0     0      0         0     1
  152         0         0     0     0       0     0      0         0     0
  153         0         0     0     0       0     0      0         0     0
  154         0         0     0     0       0     0      0         0     0
  155         0         0     0     0       0     0      0         0     0
  156         0         0     0     0       0     0      0         0     0
  157         0         0     0     0       0     0      0         0     0
  158         0         0     0     0       0     0      0         0     0
  159         0         0     0     0       0     0      0         0     0
  160         0         0     0     0       0     0      1         0     0
  161         0         0     0     0       0     0      0         0     0
  162         0         0     0     0       0     1      0         0     0
  163         0         0     0     0       0     0      0         0     0
  164         0         0     0     0       0     0      0         0     0
  165         0         0     0     0       0     0      0         0     0
  166         0         0     0     0       0     0      0         0     0
  167         0         0     0     0       0     0      0         0     0
  168         0         0     0     0       0     0      0         0     0
  169         0         0     0     0       0     0      0         0     0
  170         0         0     0     0       1     0      0         0     0
  171         0         0     0     0       0     0      0         0     0
  172         0         0     0     0       0     0      0         0     0
  173         0         0     0     0       0     0      0         0     0
  174         0         0     0     0       0     0      0         0     0
  175         0         0     0     0       0     0      0         0     0
  176         0         0     0     0       0     0      0         0     0
  177         0         0     0     0       0     0      0         0     0
  178         0         0     0     0       0     0      0         0     0
  179         0         0     0     0       0     0      0         0     0
  180         0         0     0     0       0     0      0         0     0
  181         0         0     0     0       0     0      0         0     0
  182         0         0     0     0       0     0      0         0     0
  183         0         0     0     0       0     0      0         0     0
  184         0         0     0     0       0     0      0         0     0
  185         0         0     0     0       0     0      0         0     0
  186         0         0     0     0       0     0      0         0     0
  187         0         0     0     0       0     0      0         0     0
  188         0         0     0     0       0     0      0         0     0
  189         0         0     0     0       0     0      0         0     0
  190         0         0     0     0       0     0      0         0     0
  191         0         0     0     0       0     0      0         0     0
  192         0         0     0     0       0     0      0         0     0
  193         0         0     0     0       0     1      0         0     0
  194         0         0     0     0       0     0      0         0     0
  195         0         0     0     0       0     0      0         0     0
  196         1         0     0     0       0     0      0         0     0
  197         0         0     0     0       0     0      0         0     0
  198         0         0     0     0       0     0      0         0     0
  199         0         0     0     0       0     0      1         0     0
  200         0         0     0     0       0     0      0         0     0
  201         0         0     0     0       0     0      0         0     0
  202         0         0     0     0       0     0      0         0     0
  203         0         0     0     0       0     0      0         0     0
  204         0         0     0     0       0     0      0         0     0
  205         0         0     0     0       0     0      0         0     0
  206         0         0     0     0       0     1      1         0     0
  207         0         0     0     0       0     0      0         0     0
  208         0         0     0     0       0     0      0         0     0
  209         0         0     0     0       0     0      0         0     0
  210         0         0     0     0       0     0      0         0     0
  211         0         0     0     0       0     0      0         0     0
  212         0         0     0     0       0     0      0         0     0
  213         0         0     0     0       0     0      0         0     0
  214         0         0     0     0       0     0      0         0     0
  215         0         0     0     0       0     0      0         0     0
  216         0         0     0     0       0     0      0         0     0
  217         0         0     0     0       0     0      0         0     0
  218         0         0     0     0       0     0      0         0     0
  219         0         0     0     0       0     0      0         0     0
  220         0         0     0     0       0     0      0         1     0
  221         1         0     0     0       0     0      0         0     0
  222         0         0     0     0       0     0      0         0     0
  223         0         0     0     0       0     0      0         0     0
  224         0         0     0     0       0     0      0         0     0
  225         0         0     0     0       0     0      0         0     0
  226         0         0     0     0       0     0      0         0     1
  227         0         0     0     0       0     0      0         0     0
  228         0         0     0     0       0     0      0         0     0
  229         0         0     0     0       0     0      0         0     0
  230         0         0     0     0       0     0      0         0     0
  231         0         0     0     0       0     0      0         0     0
  232         0         0     0     0       0     0      0         0     0
  233         0         0     0     0       0     0      0         0     0
  234         0         0     0     0       0     0      0         0     0
  235         0         0     0     0       0     0      0         0     0
  236         0         0     0     0       0     0      0         0     0
  237         0         0     0     0       0     0      0         0     0
  238         0         0     0     0       0     0      0         0     0
  239         0         0     0     0       0     0      0         0     0
  240         1         0     0     0       0     0      0         0     0
  241         0         0     0     0       0     0      0         0     0
  242         0         0     0     0       0     0      0         0     0
  243         0         0     0     0       0     0      0         0     0
  244         0         0     0     0       0     0      0         0     0
  245         0         0     0     0       1     1      1         0     0
  246         0         0     0     0       0     0      0         0     0
  247         0         0     0     0       0     0      0         0     0
  248         0         0     0     0       0     0      0         0     0
  249         0         0     0     0       0     0      0         0     0
  250         0         0     0     0       0     0      0         0     0
  251         0         0     0     0       0     0      0         0     0
  252         0         0     0     0       0     0      0         0     0
  253         0         0     0     0       0     0      0         0     0
  254         0         0     0     0       0     0      0         0     0
  255         0         0     0     0       0     0      0         0     0
  256         0         0     0     0       0     0      0         0     0
  257         0         0     0     0       0     0      0         0     0
  258         0         0     0     0       0     0      0         0     0
  259         1         0     0     0       0     0      0         0     0
  260         0         0     0     0       0     0      1         0     0
  261         0         0     0     0       0     0      0         0     0
  262         0         0     0     0       0     0      0         0     0
  263         0         0     0     0       0     0      0         0     0
  264         0         0     0     0       0     0      0         0     0
  265         0         0     0     0       0     0      0         0     0
  266         0         0     0     0       0     0      0         0     0
  267         0         0     0     0       0     0      2         0     0
  268         0         0     0     0       0     0      0         0     0
  269         0         0     0     0       0     0      0         0     0
  270         0         0     0     0       0     0      0         0     0
  271         0         0     0     0       0     0      0         0     0
  272         0         1     0     0       0     0      0         0     0
  273         0         0     0     1       0     0      0         0     0
  274         0         0     0     0       0     0      0         0     0
  275         0         0     0     0       0     0      0         0     0
  276         1         0     0     0       0     0      0         0     0
  277         0         0     0     0       0     0      0         0     0
  278         0         0     0     0       0     0      0         0     0
  279         0         0     0     0       0     0      0         0     0
  280         0         0     0     0       0     0      0         0     0
  281         0         0     0     0       0     0      0         0     0
  282         0         0     0     0       0     0      0         0     0
  283         0         0     0     0       0     0      0         0     0
  284         0         0     0     0       0     0      0         0     0
     Terms
Docs  style super sure surrounded system take talent talented talk team
  1       0     0    0          0      0    0      0        0    0    0
  2       0     0    0          0      0    0      0        0    0    0
  3       0     0    0          0      0    0      0        0    0    0
  4       0     0    0          0      0    0      0        0    0    0
  5       0     0    0          0      0    0      0        0    0    0
  6       0     0    0          0      0    0      0        0    0    0
  7       0     0    0          0      0    0      0        0    0    0
  8       0     0    0          0      0    0      0        0    0    0
  9       0     0    0          0      0    0      0        0    0    0
  10      0     0    0          0      0    0      0        0    0    0
  11      0     0    0          0      0    0      0        0    0    0
  12      0     0    0          0      0    0      0        0    0    1
  13      0     0    0          1      0    0      0        0    0    0
  14      0     0    0          0      0    0      0        0    0    0
  15      0     0    0          0      0    0      0        0    0    0
  16      0     0    0          0      0    0      0        0    0    0
  17      0     0    0          0      0    0      0        0    0    0
  18      0     0    0          0      0    0      0        0    0    0
  19      0     0    1          0      0    0      0        0    0    0
  20      0     0    0          0      1    0      0        0    0    0
  21      0     0    0          0      0    0      0        0    0    0
  22      0     0    0          0      0    0      0        0    0    0
  23      0     0    0          0      0    0      0        0    0    0
  24      0     0    0          0      0    0      0        0    0    0
  25      0     0    0          0      0    0      0        0    0    0
  26      0     0    0          0      0    0      0        0    0    0
  27      0     0    0          0      0    0      0        0    0    0
  28      0     0    0          0      1    0      0        0    0    0
  29      0     0    0          0      0    0      0        0    0    0
  30      0     0    0          0      0    0      0        0    0    0
  31      0     0    0          0      0    0      0        0    0    2
  32      0     0    0          0      0    0      0        0    0    0
  33      0     0    0          0      0    0      0        0    0    0
  34      0     0    1          1      0    0      0        0    0    1
  35      0     0    1          0      0    0      0        0    0    0
  36      0     0    0          0      0    0      0        0    0    0
  37      0     0    0          0      0    0      0        0    0    0
  38      0     0    0          0      0    0      0        0    0    0
  39      0     0    0          0      0    0      0        1    0    0
  40      0     0    0          0      0    0      0        0    0    0
  41      0     0    0          0      0    0      0        0    0    0
  42      0     0    0          0      0    0      0        0    0    0
  43      0     0    0          0      0    0      0        1    0    0
  44      0     0    0          0      0    0      0        0    0    0
  45      0     0    0          0      0    0      0        0    0    0
  46      0     0    0          0      0    0      0        0    0    0
  47      0     0    0          0      0    0      0        0    0    0
  48      0     0    0          0      0    0      0        0    0    0
  49      0     0    0          0      0    0      0        0    0    0
  50      0     0    0          0      0    0      0        0    0    0
  51      0     0    0          0      0    0      0        0    0    0
  52      0     0    0          0      0    0      0        0    0    0
  53      0     0    0          0      0    0      0        0    0    0
  54      0     0    0          0      0    0      0        0    0    0
  55      0     0    0          0      0    0      0        1    0    0
  56      0     0    0          0      0    0      0        0    0    0
  57      0     0    0          0      0    0      0        0    0    0
  58      0     0    0          0      0    0      0        1    0    0
  59      0     0    0          0      0    0      0        0    0    0
  60      0     0    0          0      0    0      0        0    0    0
  61      0     0    1          0      0    0      0        0    0    0
  62      0     0    0          0      0    0      1        0    0    0
  63      0     0    0          0      0    0      0        0    0    0
  64      0     0    0          0      0    0      0        0    0    0
  65      0     0    0          0      0    0      0        0    0    0
  66      0     0    0          0      0    0      0        0    0    0
  67      0     0    0          0      0    0      0        0    0    0
  68      0     0    0          0      0    0      0        0    0    0
  69      0     0    0          0      0    0      0        0    0    1
  70      0     0    0          0      0    0      0        1    0    0
  71      0     1    0          0      0    0      0        0    0    0
  72      0     0    0          0      0    0      0        0    0    0
  73      0     0    0          0      0    0      0        0    0    0
  74      0     0    0          0      0    0      0        0    0    0
  75      0     0    0          0      0    0      0        0    0    0
  76      0     0    0          0      0    0      0        0    0    0
  77      0     0    0          0      0    0      0        0    0    0
  78      0     0    0          0      0    0      0        0    0    0
  79      0     0    0          1      0    0      0        0    0    2
  80      0     0    0          0      0    0      0        0    0    0
  81      0     0    0          0      0    0      0        0    0    0
  82      0     0    0          0      0    0      0        0    0    0
  83      0     0    0          0      0    0      0        0    0    0
  84      0     0    0          0      0    0      0        0    0    0
  85      0     0    0          0      0    0      0        0    0    0
  86      0     0    0          0      0    1      0        0    0    0
  87      0     0    0          0      0    0      0        0    0    1
  88      0     0    0          0      0    0      0        0    0    0
  89      0     0    0          0      0    0      0        0    0    0
  90      0     0    0          0      0    0      0        0    0    0
  91      0     0    0          0      0    0      0        0    0    0
  92      0     0    0          0      0    0      0        0    0    0
  93      0     0    0          0      0    0      1        0    0    0
  94      0     0    0          0      0    0      0        0    0    0
  95      0     0    0          0      0    0      0        0    0    0
  96      0     0    0          0      0    0      0        0    0    0
  97      0     0    0          0      0    0      0        0    0    0
  98      0     0    0          0      0    0      0        0    0    0
  99      0     0    0          0      0    0      0        0    0    0
  100     0     0    0          0      0    0      0        0    0    0
  101     0     0    0          0      0    0      0        0    0    0
  102     0     0    0          0      0    0      0        0    0    0
  103     0     0    0          0      0    0      0        0    0    0
  104     0     0    0          0      0    0      0        0    0    0
  105     0     0    0          0      0    0      0        0    0    0
  106     0     0    0          0      0    0      0        0    0    0
  107     0     0    0          0      0    0      0        0    0    0
  108     0     0    0          1      0    0      0        0    0    0
  109     0     0    0          0      0    0      0        0    0    0
  110     0     0    0          0      0    0      0        0    0    0
  111     0     0    0          0      0    0      0        0    0    0
  112     0     0    0          0      0    0      0        0    0    0
  113     0     0    0          0      0    0      0        0    0    0
  114     0     0    0          0      0    0      0        0    0    0
  115     0     0    0          0      0    0      0        0    0    1
  116     0     0    0          0      0    0      0        0    0    0
  117     0     0    0          0      0    0      0        0    0    0
  118     0     0    0          0      0    0      1        1    0    0
  119     0     0    0          0      0    0      0        0    0    0
  120     0     0    0          0      0    0      0        0    0    0
  121     0     0    0          0      0    0      0        0    0    1
  122     0     0    0          0      0    0      0        0    0    0
  123     0     0    0          0      0    0      0        0    0    0
  124     0     0    0          0      0    0      0        0    0    0
  125     0     0    0          0      0    0      0        0    0    0
  126     0     0    0          0      0    0      0        0    0    0
  127     0     0    0          0      0    0      0        0    0    0
  128     0     0    0          1      1    0      0        0    0    0
  129     0     0    0          0      0    0      0        0    0    0
  130     0     0    0          0      0    0      0        0    0    0
  131     0     0    0          0      0    0      0        0    0    0
  132     0     0    0          0      0    0      0        0    0    0
  133     0     0    0          0      0    0      0        0    0    0
  134     0     0    0          0      0    0      0        0    0    1
  135     0     0    0          0      0    0      0        0    0    0
  136     0     0    0          0      0    0      0        0    0    0
  137     0     0    0          0      0    0      0        0    0    0
  138     0     0    0          0      0    0      0        0    0    0
  139     0     0    1          1      0    0      0        0    1    0
  140     0     0    0          0      0    0      0        0    0    0
  141     0     0    0          0      0    0      0        0    0    0
  142     0     0    0          0      0    0      1        0    0    0
  143     0     0    0          0      0    1      0        0    0    0
  144     0     0    0          0      0    0      0        0    0    0
  145     0     0    0          0      0    0      0        0    0    0
  146     0     0    0          0      0    0      0        0    0    0
  147     0     0    0          0      0    0      0        0    0    0
  148     0     0    0          0      0    0      0        0    0    0
  149     0     0    0          0      0    0      0        0    0    0
  150     0     0    0          0      0    0      0        0    0    0
  151     0     0    0          0      0    0      0        0    0    0
  152     0     0    0          0      0    0      0        0    0    0
  153     0     0    0          0      0    1      0        0    0    0
  154     0     0    0          0      0    0      0        0    0    0
  155     0     0    0          0      0    0      0        0    0    0
  156     0     0    0          0      0    0      0        0    0    0
  157     0     1    0          0      0    0      0        0    0    0
  158     0     0    0          0      0    0      0        1    0    0
  159     0     0    0          0      0    0      0        0    0    0
  160     0     0    0          0      0    0      0        0    0    1
  161     0     0    0          0      0    0      0        0    0    0
  162     0     0    0          0      0    0      0        0    0    0
  163     0     0    0          0      0    0      0        0    0    0
  164     0     0    0          0      0    0      0        0    0    0
  165     0     0    0          0      0    0      0        0    0    0
  166     0     0    0          0      0    0      0        0    0    0
  167     0     1    0          0      0    0      0        0    0    0
  168     0     0    0          0      0    0      0        0    0    0
  169     0     0    0          0      0    0      0        0    0    0
  170     0     0    0          0      0    0      0        0    0    0
  171     0     0    0          0      0    0      0        0    0    0
  172     0     0    0          0      0    0      0        0    0    0
  173     0     0    0          0      0    0      0        0    0    0
  174     0     0    0          0      0    0      0        0    0    0
  175     0     0    0          0      0    0      0        0    0    0
  176     0     0    0          0      0    0      0        0    0    0
  177     0     0    0          0      0    0      0        0    0    0
  178     0     0    0          0      0    0      0        0    0    0
  179     0     0    0          0      0    0      0        0    0    1
  180     0     0    0          0      0    0      0        0    0    0
  181     0     0    0          0      0    0      0        0    0    0
  182     0     0    0          0      0    0      0        0    0    0
  183     0     0    0          0      0    0      0        0    0    0
  184     0     0    0          0      0    0      0        0    0    0
  185     0     0    0          0      0    0      0        0    0    0
  186     0     2    0          0      0    0      0        0    0    0
  187     0     0    0          0      0    0      0        0    0    0
  188     0     0    0          0      0    0      0        0    0    0
  189     0     0    0          0      0    0      0        0    0    0
  190     0     0    0          0      0    0      0        0    0    0
  191     0     0    0          0      0    0      0        0    0    0
  192     0     0    0          0      0    0      0        0    0    0
  193     0     0    0          0      0    0      0        0    0    0
  194     0     0    0          0      0    0      0        0    0    0
  195     0     0    0          0      0    0      0        0    0    0
  196     0     0    0          0      0    0      0        0    0    0
  197     0     0    0          0      0    0      0        0    0    0
  198     0     0    0          0      0    0      0        0    0    0
  199     0     0    0          0      0    0      0        0    0    0
  200     0     0    0          0      0    0      0        0    0    0
  201     0     0    0          0      0    0      0        0    0    0
  202     0     0    0          0      0    0      0        0    0    0
  203     0     0    0          0      0    0      0        0    0    0
  204     0     0    0          0      0    0      0        0    1    0
  205     0     0    0          0      0    0      0        0    0    0
  206     0     0    0          0      0    0      0        0    0    0
  207     0     0    0          0      0    0      0        0    0    0
  208     0     0    0          0      0    0      0        0    0    0
  209     0     0    0          0      0    0      0        0    0    0
  210     0     0    0          0      0    0      0        0    0    0
  211     0     0    0          0      0    0      0        0    0    0
  212     0     0    0          0      0    0      0        0    0    0
  213     0     0    0          0      0    0      0        0    0    0
  214     0     0    0          0      0    0      0        0    0    0
  215     0     0    0          0      0    0      0        0    0    0
  216     0     0    0          0      0    0      0        0    0    0
  217     0     0    0          0      0    0      0        0    0    0
  218     0     0    0          0      0    0      0        0    0    0
  219     0     0    0          0      0    0      0        0    0    0
  220     0     0    0          0      0    0      0        0    0    0
  221     0     0    0          0      0    0      0        0    0    0
  222     0     0    0          0      0    0      0        0    0    0
  223     0     0    0          0      0    0      0        0    0    0
  224     0     0    0          0      0    0      0        0    0    0
  225     0     0    0          0      0    0      0        0    0    0
  226     0     0    0          0      0    0      0        0    0    0
  227     0     0    0          0      0    0      0        0    0    0
  228     0     0    0          0      0    0      0        0    0    0
  229     0     0    0          0      0    0      0        0    0    1
  230     0     0    0          0      0    0      0        0    0    0
  231     0     0    0          0      0    0      0        0    0    0
  232     0     0    0          0      0    0      0        0    0    0
  233     0     0    0          0      0    0      0        0    0    0
  234     0     0    0          0      0    0      0        0    0    0
  235     0     0    0          0      0    0      0        0    0    0
  236     0     0    0          0      0    0      0        0    0    0
  237     0     0    0          0      0    2      0        0    0    0
  238     0     0    0          0      0    0      0        0    0    0
  239     0     0    0          0      0    0      0        0    0    0
  240     0     0    0          0      0    0      0        0    0    0
  241     0     0    0          0      0    0      0        0    0    0
  242     0     0    0          0      0    0      0        0    0    0
  243     0     0    0          0      0    0      0        0    0    0
  244     0     0    0          0      0    0      0        0    0    0
  245     0     0    0          0      0    0      0        1    0    0
  246     0     0    0          0      0    0      0        0    0    0
  247     0     0    0          0      0    0      0        0    0    0
  248     0     0    0          0      0    0      0        0    0    0
  249     0     0    0          0      0    0      0        0    0    0
  250     0     0    0          0      0    0      0        0    0    0
  251     0     0    0          0      0    0      0        0    0    0
  252     0     0    0          0      0    0      0        0    0    0
  253     0     0    0          0      0    0      0        0    0    0
  254     0     0    0          0      0    0      0        0    0    0
  255     0     0    0          0      0    0      0        0    0    0
  256     0     0    0          0      0    0      0        0    0    0
  257     0     0    0          0      0    0      0        0    0    0
  258     0     0    0          0      0    0      0        0    0    0
  259     0     0    0          0      0    0      0        0    0    0
  260     0     0    0          0      0    0      0        0    0    0
  261     0     0    0          0      0    1      0        0    0    0
  262     0     0    0          0      0    0      0        0    0    0
  263     0     0    0          0      0    0      0        0    0    0
  264     0     0    0          0      0    0      0        0    0    0
  265     0     0    0          0      0    0      0        0    0    0
  266     0     0    0          0      0    0      0        0    0    0
  267     0     0    0          0      0    0      0        0    0    0
  268     0     0    0          0      0    0      0        0    0    0
  269     0     0    0          0      0    0      0        0    0    0
  270     0     0    0          0      0    0      0        0    0    0
  271     0     0    0          0      0    0      0        0    0    0
  272     0     0    0          0      0    0      0        0    0    0
  273     0     0    0          0      0    0      0        0    0    0
  274     1     0    0          0      0    0      0        0    0    0
  275     0     0    0          0      0    0      0        0    0    0
  276     0     0    0          0      0    0      0        0    0    0
  277     0     0    0          0      0    0      0        0    0    0
  278     0     0    0          0      0    0      0        0    0    0
  279     0     0    0          0      0    0      0        0    0    0
  280     0     0    0          0      0    0      0        0    0    1
  281     0     0    0          0      0    0      0        0    0    0
  282     0     0    0          0      0    0      0        0    0    0
  283     0     0    0          0      0    0      0        0    0    0
  284     0     0    0          0      0    0      1        0    0    0
     Terms
Docs  teams tech technology theres thing things think thinking though time
  1       0    0          0      0     0      0     0        0      0    0
  2       0    0          0      0     0      0     0        0      0    0
  3       0    0          0      0     0      0     0        0      0    0
  4       0    0          0      0     0      0     0        0      0    0
  5       0    0          0      0     0      0     0        0      0    0
  6       0    0          0      0     0      0     0        0      0    0
  7       0    1          1      0     0      0     0        0      0    0
  8       0    0          0      0     0      0     0        0      0    0
  9       0    0          0      0     0      0     0        0      0    0
  10      0    0          0      0     0      0     0        0      0    0
  11      0    0          0      0     0      0     0        0      0    0
  12      0    0          0      0     0      0     0        0      0    0
  13      0    0          0      0     0      0     0        0      0    0
  14      0    0          0      0     0      0     0        0      0    0
  15      0    0          0      1     0      0     1        0      0    0
  16      0    0          0      0     0      0     0        0      0    0
  17      0    0          0      0     0      0     0        0      0    0
  18      0    0          0      0     0      0     0        0      0    0
  19      0    0          0      0     0      1     0        0      0    0
  20      0    0          0      0     1      0     0        0      0    0
  21      0    0          0      0     0      1     0        0      0    0
  22      0    0          0      0     0      0     0        0      0    0
  23      1    0          0      0     0      0     0        0      0    0
  24      0    0          0      0     0      0     0        0      0    0
  25      0    0          0      0     0      0     0        0      0    0
  26      0    0          0      0     0      0     0        0      0    0
  27      0    0          0      0     0      0     0        0      0    1
  28      0    0          0      0     0      0     0        0      0    0
  29      0    0          0      0     0      0     1        0      0    0
  30      0    0          0      0     0      0     0        0      0    0
  31      0    0          1      0     0      0     0        0      0    0
  32      0    0          0      0     0      0     0        0      0    0
  33      0    0          1      0     0      0     0        0      0    0
  34      0    0          0      0     0      0     0        1      0    0
  35      0    0          0      0     0      0     0        0      0    0
  36      0    0          0      0     0      0     0        0      0    0
  37      0    0          0      0     0      0     1        0      0    0
  38      0    0          0      0     0      0     0        0      0    0
  39      0    0          0      0     0      0     0        0      0    1
  40      0    0          1      0     0      1     0        0      0    0
  41      0    0          0      0     0      0     0        0      0    0
  42      0    0          0      0     0      0     0        0      0    0
  43      0    0          0      0     0      0     0        0      0    0
  44      0    0          1      0     0      0     0        0      0    0
  45      0    0          0      0     0      0     0        0      0    0
  46      0    2          0      0     0      0     0        0      0    0
  47      0    0          0      0     0      1     0        0      0    0
  48      0    0          0      0     0      0     0        0      0    0
  49      1    0          0      0     0      0     0        0      0    0
  50      0    0          0      0     0      0     0        0      0    0
  51      0    0          0      0     1      0     0        0      0    0
  52      0    0          0      0     0      1     0        0      0    0
  53      0    0          0      0     0      0     0        0      0    0
  54      0    0          0      1     0      0     0        0      0    1
  55      0    0          0      0     0      0     0        0      0    0
  56      0    0          0      0     0      1     0        0      0    3
  57      0    0          0      0     0      0     0        0      0    0
  58      0    0          0      0     0      0     0        0      0    0
  59      0    0          0      0     0      0     0        0      0    0
  60      0    0          0      0     0      0     0        0      0    0
  61      0    0          0      0     0      0     0        0      0    0
  62      0    0          0      0     0      0     0        0      0    0
  63      0    0          0      0     0      0     0        0      0    0
  64      0    0          0      0     0      0     0        0      0    0
  65      0    0          0      0     0      0     0        0      0    0
  66      0    0          0      0     0      0     0        0      0    0
  67      0    0          0      0     0      0     0        0      0    0
  68      0    0          1      0     0      0     0        0      0    0
  69      0    1          0      0     0      0     0        0      0    0
  70      0    0          0      0     0      0     0        0      0    2
  71      0    1          0      0     0      1     0        0      0    0
  72      0    0          0      0     0      0     0        0      0    0
  73      0    0          0      0     0      0     0        0      1    0
  74      0    0          0      0     0      0     0        0      0    0
  75      0    0          0      0     0      0     0        0      0    0
  76      0    0          0      0     0      0     0        0      0    0
  77      0    0          0      0     0      0     0        0      0    0
  78      0    0          0      0     0      0     0        0      0    0
  79      0    0          0      0     0      1     0        0      0    0
  80      0    0          0      0     0      0     0        0      0    0
  81      0    0          0      0     0      0     0        0      0    0
  82      0    0          0      0     0      0     0        0      0    0
  83      0    0          0      0     0      0     0        0      0    0
  84      0    0          0      0     0      1     0        0      0    1
  85      0    0          0      0     0      1     0        0      0    0
  86      0    0          0      0     0      0     0        0      0    0
  87      0    0          0      0     0      0     1        1      0    0
  88      0    0          0      0     0      0     0        0      0    0
  89      0    0          0      0     0      0     0        0      0    0
  90      0    0          0      0     0      1     0        0      0    0
  91      0    0          0      0     0      0     0        0      0    1
  92      0    1          0      0     0      0     0        0      0    1
  93      0    0          0      0     0      0     0        0      0    0
  94      0    0          0      0     0      0     0        0      0    0
  95      0    0          0      0     0      0     0        0      0    0
  96      0    0          0      0     0      1     0        0      0    0
  97      0    0          0      0     0      0     0        0      0    1
  98      0    0          0      0     0      0     0        0      0    0
  99      0    0          0      0     0      0     0        0      0    0
  100     0    0          0      0     0      0     0        0      0    0
  101     0    0          0      0     0      0     1        0      0    0
  102     0    0          0      0     0      0     0        0      0    0
  103     0    0          0      0     0      0     0        0      0    0
  104     0    0          0      0     0      0     0        0      0    0
  105     0    0          0      0     0      0     0        0      0    0
  106     0    0          0      0     0      0     0        0      0    0
  107     0    0          0      0     0      1     1        0      0    0
  108     1    0          0      0     0      1     0        0      0    0
  109     0    1          0      0     0      0     0        0      0    0
  110     0    0          0      0     0      0     0        0      0    1
  111     0    0          0      0     0      0     0        0      0    0
  112     0    0          1      0     0      0     0        0      0    0
  113     0    0          0      0     0      0     0        0      0    0
  114     0    0          0      0     0      0     0        0      0    0
  115     0    0          0      0     0      1     0        0      0    0
  116     0    0          0      0     0      0     0        0      0    0
  117     0    0          0      0     0      0     0        0      0    0
  118     0    0          0      0     0      0     0        0      0    0
  119     0    0          0      0     0      0     0        0      0    0
  120     0    0          0      0     0      0     0        0      0    1
  121     0    0          0      0     0      0     0        0      0    0
  122     0    0          0      0     0      0     0        0      0    0
  123     0    0          0      0     0      0     0        0      0    0
  124     0    0          0      0     0      0     0        0      0    0
  125     0    0          0      0     0      0     0        0      0    0
  126     0    0          0      0     0      0     0        0      0    0
  127     0    0          0      0     0      0     0        0      0    0
  128     0    0          0      0     0      0     0        0      0    0
  129     0    0          0      0     0      0     0        0      0    0
  130     0    0          0      0     0      0     0        0      0    0
  131     0    0          0      0     0      0     0        0      0    0
  132     0    0          0      0     0      0     0        0      0    0
  133     0    0          0      0     0      0     0        0      0    0
  134     0    0          0      0     0      1     0        0      0    0
  135     0    0          0      0     0      0     0        0      0    0
  136     0    0          0      0     1      0     0        0      0    0
  137     0    0          0      1     0      0     0        0      0    0
  138     0    0          0      0     0      0     0        0      0    0
  139     0    0          0      0     1      0     0        0      0    0
  140     0    0          0      0     0      0     0        0      0    0
  141     0    0          0      0     0      0     0        0      0    0
  142     0    0          0      0     0      0     0        0      0    0
  143     0    0          0      0     0      0     0        0      0    1
  144     0    0          0      0     0      0     0        0      0    0
  145     0    0          0      0     0      0     0        0      0    0
  146     0    0          0      0     0      0     0        0      0    0
  147     0    0          0      0     0      0     0        0      0    0
  148     0    1          0      0     0      0     0        0      0    0
  149     0    0          0      0     0      0     0        0      0    0
  150     0    0          0      0     0      1     0        0      0    0
  151     0    0          0      0     0      0     0        0      0    0
  152     0    0          0      0     0      0     0        0      0    0
  153     0    0          1      0     0      0     0        0      0    0
  154     0    0          0      0     0      0     0        0      0    0
  155     0    0          0      0     0      0     0        0      0    0
  156     0    0          0      0     0      0     0        0      0    0
  157     0    0          0      0     0      0     0        0      0    0
  158     0    0          0      0     0      0     0        0      0    0
  159     0    0          0      0     0      0     0        0      0    0
  160     1    0          0      0     0      0     0        0      0    0
  161     0    0          0      0     0      0     0        0      0    0
  162     0    0          0      0     0      0     0        0      0    0
  163     0    0          0      0     0      0     0        0      0    0
  164     0    0          0      0     0      0     0        0      0    0
  165     0    0          0      0     0      0     0        0      0    0
  166     0    0          0      0     0      0     0        0      0    0
  167     0    0          0      0     0      1     0        0      0    1
  168     0    0          0      0     0      0     0        0      0    0
  169     0    0          0      0     0      0     0        0      0    0
  170     0    0          0      0     0      1     0        0      0    0
  171     0    0          0      1     0      0     0        0      0    0
  172     0    0          0      0     0      0     0        0      0    0
  173     0    0          0      0     0      0     0        0      0    0
  174     0    0          0      0     0      0     0        0      0    0
  175     0    0          0      0     0      0     0        0      0    0
  176     0    0          0      0     0      0     0        0      0    0
  177     0    0          0      0     0      0     0        0      0    0
  178     0    0          0      0     0      0     0        0      0    0
  179     0    0          0      0     0      0     0        0      0    0
  180     0    0          0      0     0      0     0        0      0    0
  181     0    0          0      0     0      0     0        0      0    0
  182     0    0          0      0     0      0     0        0      0    0
  183     0    0          0      0     0      0     0        0      0    0
  184     0    0          0      0     0      0     0        0      0    0
  185     0    0          0      0     0      0     0        0      0    0
  186     0    0          0      0     0      0     0        0      0    0
  187     0    0          0      0     0      0     0        0      0    0
  188     0    0          0      0     0      0     0        0      0    0
  189     0    0          0      0     0      1     0        0      0    0
  190     0    0          0      0     0      0     0        0      0    0
  191     0    0          0      0     0      0     0        0      0    0
  192     0    0          0      0     0      0     0        0      0    0
  193     0    0          0      0     2      1     1        0      0    0
  194     0    0          0      0     0      0     0        0      0    0
  195     0    0          0      0     0      0     0        0      0    0
  196     0    0          0      0     0      0     0        0      0    0
  197     0    0          0      0     0      0     0        0      0    0
  198     0    0          0      0     0      0     0        1      0    0
  199     0    0          0      0     0      0     0        0      0    0
  200     0    1          0      0     0      0     0        0      0    0
  201     0    0          0      0     0      0     0        0      0    0
  202     0    0          0      0     0      0     0        0      0    0
  203     0    0          0      0     0      0     0        0      0    0
  204     0    0          0      0     0      0     0        2      0    0
  205     0    0          0      0     0      0     0        0      0    0
  206     0    0          0      0     0      0     0        0      0    0
  207     0    0          0      0     0      0     0        0      0    0
  208     0    0          0      0     0      0     0        0      0    0
  209     0    0          1      0     0      1     0        0      0    0
  210     0    0          0      0     0      0     0        0      0    0
  211     0    0          0      0     0      1     0        0      0    0
  212     0    0          0      0     0      0     1        0      0    0
  213     0    0          0      0     0      0     0        0      0    0
  214     0    0          0      0     0      0     0        0      0    0
  215     0    0          0      0     0      0     0        0      0    0
  216     0    0          0      0     0      0     0        0      0    0
  217     0    0          0      0     0      0     0        0      0    0
  218     0    0          0      0     0      0     0        0      0    0
  219     0    0          0      0     0      0     0        0      0    0
  220     0    0          0      0     0      0     0        0      0    0
  221     0    0          0      0     0      0     0        0      0    0
  222     0    1          0      0     0      0     0        0      0    0
  223     0    0          0      0     0      0     0        0      0    0
  224     0    0          0      0     0      0     0        0      0    0
  225     0    0          0      0     0      0     0        0      0    0
  226     0    0          0      0     0      0     0        0      0    0
  227     0    0          1      0     0      0     0        0      0    0
  228     0    0          0      0     0      0     0        0      0    0
  229     0    0          0      0     0      0     0        0      0    0
  230     0    0          0      0     0      0     0        0      0    0
  231     0    0          0      0     0      0     0        0      0    0
  232     0    0          1      0     0      0     0        0      0    0
  233     0    0          0      0     1      0     0        0      0    0
  234     0    0          0      0     0      0     0        0      0    0
  235     0    0          0      0     0      0     0        0      0    0
  236     0    0          0      0     0      0     0        0      0    0
  237     0    0          0      0     0      0     0        0      0    0
  238     0    0          0      0     0      1     0        0      0    0
  239     0    0          0      0     0      0     0        0      0    0
  240     1    0          0      0     0      0     0        0      0    0
  241     0    0          0      0     0      0     0        0      0    0
  242     0    0          0      0     0      0     0        0      0    0
  243     0    1          0      0     0      0     0        0      0    1
  244     0    0          0      0     0      0     0        0      0    0
  245     0    0          0      0     0      0     0        0      0    0
  246     0    0          0      0     0      0     0        0      0    0
  247     0    0          0      0     0      0     0        0      0    0
  248     0    0          0      0     0      2     0        0      0    0
  249     0    0          1      0     0      0     0        0      0    0
  250     0    0          0      0     0      0     0        0      0    1
  251     0    0          0      0     0      0     0        0      0    0
  252     0    0          0      0     0      0     0        0      0    0
  253     0    0          0      0     0      0     0        0      0    0
  254     0    0          0      0     0      0     0        0      0    0
  255     0    0          0      0     0      0     0        0      0    0
  256     0    0          0      0     0      0     0        0      0    0
  257     0    0          0      0     0      0     0        0      0    0
  258     0    0          0      0     0      0     0        0      0    2
  259     0    0          0      0     0      0     0        0      0    0
  260     0    0          0      0     0      0     0        0      0    0
  261     0    0          0      0     0      0     0        0      0    0
  262     0    1          0      0     0      0     0        0      0    0
  263     0    0          0      0     0      0     0        0      0    0
  264     0    0          0      0     0      0     0        0      0    0
  265     0    0          0      0     0      0     0        0      0    0
  266     0    0          0      0     0      0     0        0      0    1
  267     0    0          0      0     0      0     0        0      0    0
  268     0    0          0      0     0      0     0        0      0    0
  269     0    0          0      0     0      0     0        0      0    0
  270     0    0          0      0     0      0     0        0      0    0
  271     0    0          0      0     0      0     0        0      0    0
  272     0    0          0      0     0      0     0        0      0    0
  273     0    0          0      0     0      0     0        0      0    0
  274     0    0          0      0     0      0     0        0      0    0
  275     0    0          0      0     0      0     0        0      0    0
  276     0    0          0      0     0      0     0        0      0    2
  277     0    0          0      0     0      0     0        0      0    0
  278     0    0          0      0     0      0     0        0      0    0
  279     0    0          0      0     0      0     0        0      0    0
  280     0    0          0      0     0      0     0        0      0    0
  281     0    0          0      0     0      0     0        0      0    0
  282     0    0          0      0     0      0     0        0      0    0
  283     0    0          0      0     0      0     0        0      0    0
  284     0    0          0      0     0      0     0        0      0    0
     Terms
Docs  tools top transparency transparent treated truly try unless use used
  1       0   0            0           0       0     0   0      0   0    0
  2       0   0            0           0       0     0   0      0   0    0
  3       0   0            0           0       0     1   0      0   0    0
  4       0   0            0           0       0     0   0      0   0    0
  5       0   0            0           0       0     0   0      0   0    0
  6       0   0            0           0       0     0   0      0   0    0
  7       0   0            0           0       0     0   0      0   0    0
  8       0   0            0           0       0     0   0      0   0    0
  9       0   0            0           0       0     0   0      0   0    0
  10      0   0            0           0       0     0   0      0   0    0
  11      0   0            0           0       0     0   0      0   0    0
  12      0   0            0           0       0     0   0      0   0    0
  13      0   0            0           0       0     0   0      0   0    0
  14      0   0            0           0       0     0   0      0   0    0
  15      0   0            0           0       0     0   0      0   0    0
  16      0   0            0           0       0     0   0      0   0    0
  17      0   0            0           0       0     0   0      0   0    0
  18      0   0            0           0       0     0   0      0   0    0
  19      1   0            0           0       1     0   0      0   0    0
  20      0   0            0           0       0     0   0      0   0    0
  21      0   0            0           1       0     0   0      0   0    0
  22      0   0            0           0       0     0   0      0   0    0
  23      0   0            0           0       0     0   0      0   0    0
  24      0   0            0           0       0     0   0      0   0    0
  25      0   0            0           0       0     0   0      0   0    0
  26      0   0            0           0       0     0   0      0   0    0
  27      0   0            0           0       0     0   0      0   0    0
  28      0   0            0           0       0     0   0      0   0    0
  29      0   0            0           0       0     0   0      0   0    0
  30      0   0            0           0       0     0   0      0   0    0
  31      0   0            0           0       0     0   0      0   0    0
  32      0   0            0           0       0     0   0      0   0    1
  33      0   0            0           0       0     0   0      0   0    0
  34      0   0            0           0       0     2   0      0   0    0
  35      0   0            0           0       0     0   0      0   0    0
  36      0   0            0           0       0     0   0      0   0    0
  37      0   0            0           0       0     0   0      0   0    0
  38      0   0            0           0       0     0   0      0   0    0
  39      0   0            0           0       0     0   0      0   0    0
  40      0   0            0           0       0     0   0      0   0    0
  41      0   0            0           0       0     0   1      0   0    0
  42      0   0            0           0       0     0   0      0   0    0
  43      0   0            0           0       0     0   0      0   0    0
  44      0   0            0           0       0     2   0      0   0    0
  45      0   0            0           0       0     0   0      0   0    0
  46      0   0            0           0       0     0   0      0   1    0
  47      0   0            0           0       0     0   0      0   0    0
  48      0   0            0           0       0     0   0      0   0    0
  49      0   0            0           0       0     0   0      0   0    0
  50      0   0            0           0       0     0   0      0   0    0
  51      1   0            0           0       0     0   0      0   0    0
  52      0   0            0           0       0     1   0      0   0    0
  53      0   0            0           0       0     0   0      0   0    0
  54      0   0            0           1       0     0   0      0   0    0
  55      0   0            0           0       0     0   0      0   0    0
  56      0   0            0           0       0     0   0      0   0    0
  57      0   0            0           0       0     0   0      0   0    0
  58      0   0            0           1       0     0   0      0   1    0
  59      0   0            0           0       0     0   0      0   0    0
  60      0   0            0           0       0     0   0      0   0    0
  61      0   0            0           0       0     0   0      0   0    0
  62      0   0            0           0       0     0   0      0   0    0
  63      0   0            0           0       0     0   0      0   0    0
  64      0   1            0           0       0     0   0      0   0    0
  65      0   0            0           0       0     0   0      0   0    0
  66      0   0            0           0       0     0   0      0   0    0
  67      0   0            0           0       0     0   0      0   0    0
  68      0   0            0           0       0     0   0      0   0    0
  69      0   0            1           0       0     0   0      0   0    0
  70      0   0            0           0       0     0   0      0   0    0
  71      0   0            0           0       0     0   0      0   0    0
  72      0   0            0           0       0     0   0      0   0    0
  73      0   0            0           0       0     0   0      0   0    0
  74      0   0            0           0       0     0   0      0   0    0
  75      0   0            0           0       0     0   0      0   0    0
  76      0   0            1           1       0     1   0      0   0    0
  77      0   0            0           0       0     0   0      0   0    0
  78      0   0            0           0       0     0   0      0   0    0
  79      0   0            0           0       0     0   0      0   0    0
  80      0   0            0           0       0     1   0      0   0    0
  81      0   0            0           0       1     0   0      0   0    0
  82      0   0            0           0       0     0   0      0   0    0
  83      0   0            0           0       0     0   0      0   0    0
  84      0   0            0           0       0     0   0      0   0    0
  85      0   0            0           0       0     0   0      0   0    0
  86      0   0            0           0       0     0   0      0   0    0
  87      0   0            0           0       0     0   0      0   0    0
  88      0   0            0           0       0     0   0      0   0    0
  89      0   0            0           0       0     0   0      0   0    0
  90      0   0            0           0       0     0   0      0   0    0
  91      0   1            0           0       0     0   0      0   0    0
  92      0   0            0           0       0     0   0      0   0    0
  93      0   0            0           0       0     0   0      0   0    0
  94      0   0            0           0       0     0   0      0   0    0
  95      0   0            0           0       0     0   0      0   0    0
  96      0   0            0           0       0     0   0      0   1    0
  97      0   0            0           0       0     0   0      0   0    0
  98      0   0            0           0       0     0   0      0   0    0
  99      0   0            0           0       0     0   0      0   0    0
  100     0   1            0           0       0     0   0      0   0    0
  101     0   0            0           0       0     0   0      0   0    0
  102     0   0            0           0       0     0   0      0   0    0
  103     0   0            0           0       0     0   0      0   0    0
  104     0   0            0           0       0     0   0      0   0    0
  105     0   0            0           0       0     0   0      0   0    0
  106     0   0            0           0       0     0   0      0   0    0
  107     0   0            0           0       0     0   0      0   0    0
  108     0   0            0           0       0     0   0      0   0    0
  109     0   0            0           0       0     0   0      0   0    0
  110     0   0            0           0       0     0   0      0   0    0
  111     0   0            0           0       0     0   0      0   0    0
  112     0   0            0           0       0     0   0      0   0    0
  113     0   0            0           0       0     0   0      0   0    0
  114     0   0            0           0       0     0   0      0   0    0
  115     0   0            0           0       0     0   0      0   0    0
  116     0   0            0           0       0     0   0      0   0    0
  117     0   0            0           0       0     0   0      0   0    0
  118     0   1            0           0       0     0   0      0   0    0
  119     0   0            0           0       0     0   0      0   0    0
  120     0   0            0           0       0     0   0      0   0    0
  121     0   0            0           0       0     0   0      0   0    0
  122     0   0            0           0       0     0   0      0   0    0
  123     0   0            0           0       0     0   0      0   0    0
  124     0   0            0           0       0     0   0      0   0    0
  125     0   0            0           0       0     0   0      0   0    0
  126     0   0            0           0       0     0   0      0   0    0
  127     0   0            0           0       0     0   0      0   0    0
  128     0   0            0           1       0     0   0      0   0    0
  129     0   1            1           0       0     0   0      0   0    0
  130     0   0            0           0       0     0   0      0   0    0
  131     0   0            0           0       0     0   0      0   0    0
  132     0   0            0           0       0     0   0      0   0    0
  133     0   0            0           0       0     0   0      0   0    0
  134     0   0            1           0       0     0   1      0   0    0
  135     0   0            0           0       0     0   0      0   0    0
  136     0   0            0           0       0     0   0      0   0    0
  137     0   0            0           0       0     0   0      0   0    0
  138     0   0            0           0       0     0   0      0   0    0
  139     0   0            0           0       0     0   0      0   0    0
  140     0   0            0           0       0     0   0      0   0    0
  141     0   0            0           0       0     0   0      0   0    0
  142     0   0            0           0       0     0   0      0   0    0
  143     0   0            0           0       0     0   0      0   0    0
  144     0   0            0           0       0     0   0      0   0    0
  145     0   0            0           0       0     0   0      0   0    0
  146     0   0            0           1       0     0   0      0   0    0
  147     0   0            0           0       0     0   0      0   0    0
  148     0   0            0           0       0     0   0      0   0    0
  149     0   0            0           0       0     0   0      0   0    0
  150     0   0            0           0       0     0   1      0   0    0
  151     0   0            0           0       0     0   0      0   0    0
  152     0   0            0           0       0     0   0      0   0    0
  153     0   0            0           0       0     0   0      0   0    0
  154     0   0            0           0       0     0   0      0   0    0
  155     0   0            0           0       0     0   0      0   0    0
  156     0   0            0           0       0     0   0      0   0    0
  157     0   0            0           0       0     0   0      0   0    0
  158     0   0            0           0       0     0   0      0   0    0
  159     0   0            0           0       0     0   0      0   0    0
  160     0   0            1           0       0     0   0      0   0    0
  161     0   0            0           0       0     0   0      0   0    0
  162     0   0            0           0       0     0   0      0   0    1
  163     0   0            0           0       0     0   0      0   0    0
  164     0   0            1           0       0     0   0      0   0    0
  165     0   1            0           0       0     0   0      0   0    0
  166     0   0            0           0       0     0   0      0   0    0
  167     0   0            0           0       0     0   1      0   0    0
  168     1   0            0           0       0     0   0      0   0    0
  169     0   0            0           0       0     0   0      0   0    0
  170     0   0            0           0       0     0   0      0   0    0
  171     0   0            0           0       0     0   0      0   0    0
  172     0   0            0           0       0     0   0      0   0    0
  173     0   0            0           0       0     0   0      0   0    0
  174     0   0            0           0       0     0   0      0   0    0
  175     0   0            0           0       0     0   0      0   0    0
  176     0   0            0           0       0     0   0      0   0    0
  177     0   0            0           0       0     0   0      0   0    0
  178     0   0            0           0       0     0   0      0   0    0
  179     0   0            0           0       0     0   0      0   0    0
  180     0   0            0           0       0     0   0      0   0    0
  181     1   0            0           0       0     0   0      0   0    0
  182     0   0            0           0       0     0   0      0   0    0
  183     0   0            0           0       0     0   0      0   0    0
  184     0   0            0           0       0     0   0      0   0    0
  185     0   0            0           0       0     0   0      0   0    0
  186     1   0            0           0       0     0   0      0   0    0
  187     0   0            0           0       0     0   0      0   0    0
  188     0   0            0           0       0     0   0      0   0    0
  189     0   0            0           0       0     0   0      0   0    0
  190     0   0            0           0       0     0   0      0   0    0
  191     0   0            0           0       0     0   0      0   0    0
  192     0   0            0           0       0     0   0      0   0    0
  193     0   0            0           0       0     0   0      0   0    0
  194     0   0            0           0       0     0   0      0   0    0
  195     0   0            0           0       0     0   1      0   0    0
  196     0   0            0           0       0     0   0      0   0    0
  197     0   0            0           0       0     0   0      0   0    0
  198     0   0            0           0       0     0   0      0   0    0
  199     0   0            0           0       0     0   0      0   0    0
  200     0   0            0           0       0     0   0      0   0    0
  201     0   0            0           0       0     0   0      0   0    0
  202     0   0            0           0       0     0   0      0   0    0
  203     0   0            0           0       0     0   0      0   0    0
  204     0   0            0           0       0     0   0      0   0    0
  205     0   0            0           0       0     0   0      0   0    0
  206     0   0            0           0       0     0   0      0   0    0
  207     0   0            0           0       0     0   0      0   0    0
  208     0   0            0           0       0     0   0      0   0    0
  209     0   0            0           0       0     0   0      0   0    0
  210     0   0            0           0       0     0   0      0   0    0
  211     0   0            0           0       0     0   0      0   0    0
  212     0   0            0           0       0     0   0      0   0    0
  213     0   0            0           0       0     0   0      0   0    0
  214     0   0            0           0       0     0   0      0   0    0
  215     0   1            0           0       0     0   0      0   0    0
  216     0   0            0           0       0     0   0      0   0    0
  217     0   0            0           0       0     0   0      0   0    0
  218     0   0            0           0       0     0   0      0   0    0
  219     0   0            0           0       0     0   0      0   0    0
  220     0   0            0           0       0     0   0      0   0    0
  221     0   0            0           0       0     0   0      0   0    0
  222     0   0            0           0       0     0   0      0   0    0
  223     0   0            0           0       0     0   0      0   0    0
  224     0   0            0           0       0     0   0      0   0    0
  225     0   0            0           0       0     0   0      0   0    0
  226     0   0            0           0       0     0   0      0   0    0
  227     0   0            0           0       0     0   0      0   0    0
  228     0   0            0           0       0     0   0      0   0    0
  229     0   0            0           0       0     0   0      0   0    0
  230     0   0            0           0       0     0   0      0   0    0
  231     0   0            0           0       0     0   0      0   0    0
  232     0   0            0           0       0     0   0      0   0    0
  233     0   0            0           0       0     0   0      0   0    0
  234     0   0            0           0       0     0   0      0   0    0
  235     0   0            0           0       0     0   0      0   0    0
  236     0   0            0           0       0     0   0      0   0    0
  237     0   0            0           0       0     0   0      0   0    0
  238     0   0            0           0       0     0   0      0   0    0
  239     0   0            0           0       0     0   0      0   0    0
  240     0   0            0           0       0     0   0      0   0    0
  241     0   0            0           0       0     0   0      0   0    0
  242     0   0            0           0       0     0   0      0   0    0
  243     0   0            0           0       0     0   0      0   0    0
  244     0   0            0           0       0     0   0      0   0    0
  245     0   0            0           0       0     0   0      0   0    0
  246     0   0            0           0       0     0   0      0   0    0
  247     0   0            0           0       0     0   0      0   0    0
  248     0   0            0           0       0     0   0      0   0    0
  249     0   0            0           0       0     0   0      0   0    0
  250     0   0            0           0       0     0   0      0   0    0
  251     0   0            0           0       0     0   0      0   0    0
  252     0   0            0           0       0     0   0      0   0    0
  253     0   0            0           0       0     0   0      0   0    0
  254     0   0            0           0       0     0   0      0   0    0
  255     0   0            0           0       0     0   0      0   0    0
  256     0   0            0           0       0     0   0      0   0    0
  257     0   0            0           0       0     0   0      0   0    0
  258     0   0            0           0       0     0   0      0   0    0
  259     0   0            0           0       0     0   0      0   0    0
  260     0   0            0           0       0     0   0      0   0    0
  261     0   0            0           0       0     0   0      0   0    0
  262     0   0            0           0       0     0   0      0   0    0
  263     0   0            0           0       0     0   0      0   0    0
  264     0   0            0           0       0     0   0      0   0    0
  265     0   0            0           0       0     0   0      0   0    0
  266     0   0            0           0       0     0   0      0   0    0
  267     0   0            0           0       0     0   0      0   0    0
  268     0   0            0           0       0     0   0      0   0    0
  269     0   1            0           0       0     0   0      0   0    0
  270     0   0            0           0       0     0   0      0   0    0
  271     0   0            0           0       0     0   0      0   0    0
  272     0   0            0           0       0     0   0      0   1    0
  273     0   0            0           0       0     0   0      0   0    0
  274     0   0            0           0       0     0   0      0   0    0
  275     0   0            0           0       0     0   0      0   0    0
  276     0   0            0           0       0     0   0      0   1    0
  277     0   0            0           0       0     0   0      0   0    0
  278     0   0            0           0       0     0   0      0   0    0
  279     0   0            0           0       0     0   0      0   0    0
  280     0   0            0           0       0     0   0      0   0    0
  281     0   0            0           0       0     0   0      0   0    0
  282     0   0            0           0       0     0   0      0   0    0
  283     0   0            0           0       0     0   0      0   0    0
  284     0   0            0           0       0     0   0      0   1    0
     Terms
Docs  values variety want way well whats will willing within without
  1        0       0    0   0    0     0    0       1      0       0
  2        0       0    0   0    0     0    0       0      0       0
  3        0       1    0   0    0     0    0       0      0       0
  4        0       0    1   0    0     0    0       0      0       0
  5        0       0    1   0    0     0    0       0      0       0
  6        0       0    0   0    0     0    0       0      0       0
  7        0       0    0   0    0     0    0       0      0       0
  8        0       0    0   0    1     0    0       0      0       0
  9        0       0    0   0    0     0    0       0      0       0
  10       0       0    0   0    1     0    0       0      0       0
  11       0       0    0   0    0     0    0       0      0       0
  12       0       0    0   0    1     0    0       0      0       0
  13       0       0    0   1    0     0    0       0      0       0
  14       0       0    0   0    0     0    0       0      0       0
  15       0       0    0   0    0     0    0       0      0       0
  16       0       0    0   0    1     0    0       0      0       0
  17       0       0    0   0    0     0    0       0      0       0
  18       0       0    0   0    0     0    0       0      0       0
  19       0       0    1   0    1     0    0       0      0       0
  20       0       0    0   0    0     0    0       0      0       0
  21       0       0    0   0    0     0    0       0      0       0
  22       0       0    0   0    0     0    0       0      0       0
  23       0       0    0   0    0     0    0       0      0       0
  24       0       1    0   0    0     0    0       0      0       0
  25       0       0    0   0    0     0    0       0      0       0
  26       0       0    0   0    0     0    0       0      0       0
  27       0       0    0   0    0     0    0       0      0       0
  28       0       0    0   0    0     0    0       0      0       0
  29       0       0    0   0    0     0    0       0      0       0
  30       0       0    0   1    0     0    0       0      0       0
  31       0       0    0   0    0     0    0       0      1       0
  32       0       0    0   0    0     0    0       0      0       0
  33       0       0    1   1    0     0    0       0      0       0
  34       0       0    0   0    0     0    0       0      0       0
  35       0       0    0   0    0     0    0       0      0       0
  36       0       0    0   0    0     0    0       0      0       0
  37       0       1    1   0    0     0    0       0      0       0
  38       0       0    0   0    0     0    0       0      0       1
  39       0       0    0   0    0     0    1       0      0       0
  40       0       0    0   0    0     0    0       0      0       0
  41       0       0    1   0    1     0    0       0      0       0
  42       0       0    0   0    0     0    0       0      0       0
  43       0       0    0   0    0     0    0       0      0       0
  44       0       0    0   0    1     0    0       0      0       0
  45       0       0    0   1    0     0    0       0      0       0
  46       0       0    0   0    0     0    0       0      0       0
  47       0       0    0   0    0     0    0       0      0       0
  48       0       0    0   0    0     0    0       0      0       0
  49       0       0    0   0    0     0    0       0      0       0
  50       0       0    0   0    0     0    1       0      0       0
  51       0       0    0   0    0     0    0       0      0       0
  52       0       0    0   1    0     0    0       0      0       0
  53       0       0    0   0    0     0    0       0      0       1
  54       0       0    0   0    0     0    0       0      1       0
  55       0       0    0   0    0     0    0       0      0       0
  56       0       0    0   0    0     0    0       0      0       0
  57       0       0    1   0    2     0    0       0      0       0
  58       0       0    0   0    0     0    0       0      0       0
  59       0       0    0   0    0     0    0       0      0       0
  60       0       0    0   0    0     0    0       0      0       0
  61       0       0    0   0    0     0    0       0      0       0
  62       0       0    0   0    0     0    0       0      0       0
  63       0       0    0   0    0     0    0       0      0       0
  64       0       0    0   0    1     0    0       0      0       0
  65       0       0    0   0    0     0    0       0      0       0
  66       0       0    0   0    0     0    0       0      0       0
  67       0       0    0   0    0     0    0       0      0       0
  68       0       0    0   0    0     0    0       0      0       0
  69       0       0    0   1    0     1    0       0      0       0
  70       0       0    0   0    0     0    0       0      0       0
  71       0       0    0   0    0     0    0       0      0       1
  72       0       0    0   0    0     0    0       0      0       0
  73       0       0    0   0    0     0    0       0      0       0
  74       0       0    0   0    1     0    0       0      0       0
  75       0       0    0   0    0     0    0       0      0       0
  76       0       0    0   0    0     0    0       0      1       0
  77       0       0    0   0    0     0    0       0      0       0
  78       0       0    0   0    0     0    0       0      0       0
  79       0       0    0   0    0     0    0       0      0       0
  80       0       0    0   0    0     0    0       0      0       0
  81       0       0    0   0    0     0    0       0      0       0
  82       0       0    0   0    0     0    0       0      0       0
  83       0       0    0   0    0     0    0       0      0       0
  84       0       0    0   0    0     0    0       0      0       0
  85       0       0    0   0    0     0    0       0      0       0
  86       0       0    0   1    0     0    0       1      0       0
  87       0       0    0   0    0     0    0       0      0       0
  88       0       0    0   0    1     0    0       0      0       0
  89       0       0    0   0    0     0    0       0      0       0
  90       0       0    0   0    0     0    0       0      0       0
  91       0       0    0   0    0     0    0       0      0       0
  92       0       0    0   0    0     0    0       0      0       0
  93       0       0    0   1    0     0    0       0      0       0
  94       0       0    0   0    0     0    0       0      0       0
  95       0       0    0   0    0     0    0       0      0       0
  96       1       0    0   0    0     0    0       0      0       0
  97       0       0    0   0    0     0    0       0      0       0
  98       0       0    0   0    0     0    0       0      0       0
  99       0       0    0   0    0     0    0       0      0       0
  100      0       0    0   0    0     0    0       0      0       0
  101      0       0    0   0    0     0    0       0      0       0
  102      0       0    0   0    0     0    0       0      0       0
  103      0       0    0   0    0     0    0       0      0       0
  104      0       0    0   0    0     0    0       0      0       0
  105      0       0    0   0    0     0    0       0      0       0
  106      0       0    0   0    0     0    0       0      0       0
  107      0       0    0   0    0     0    0       0      0       0
  108      0       0    1   0    0     0    0       0      0       0
  109      0       0    0   0    0     0    0       0      0       0
  110      0       0    0   0    1     0    0       0      0       0
  111      0       0    0   0    0     0    0       0      0       0
  112      0       0    0   0    0     0    0       0      0       0
  113      0       0    0   0    0     0    0       0      0       0
  114      0       0    0   0    0     0    0       0      0       0
  115      0       0    0   0    0     0    0       0      0       0
  116      0       0    0   0    0     0    0       0      0       0
  117      0       0    0   0    0     0    0       0      0       0
  118      0       0    0   0    0     0    0       0      0       0
  119      0       0    0   0    0     0    0       0      0       0
  120      0       0    0   0    0     0    0       0      0       0
  121      1       0    0   0    0     0    0       0      0       0
  122      0       0    0   0    0     0    0       0      0       0
  123      0       0    0   0    0     0    0       0      0       0
  124      0       1    0   0    0     0    0       0      0       0
  125      0       0    0   0    0     0    0       0      0       0
  126      0       0    0   1    0     0    0       0      0       0
  127      0       0    0   0    0     0    0       0      1       0
  128      0       0    0   0    0     0    0       0      0       0
  129      0       0    0   0    0     0    0       0      0       0
  130      0       0    0   0    0     0    0       0      0       0
  131      0       0    0   1    0     0    0       0      0       0
  132      0       0    0   0    0     0    0       0      0       0
  133      0       0    0   0    0     0    0       0      1       0
  134      0       0    0   0    0     0    1       0      0       0
  135      0       0    0   0    0     0    0       0      0       0
  136      0       0    0   1    0     0    0       0      0       0
  137      0       0    0   0    0     0    0       0      0       0
  138      0       0    0   0    0     0    0       0      0       0
  139      0       0    0   0    0     0    0       0      0       0
  140      0       0    0   0    0     0    0       0      0       0
  141      0       0    0   0    1     0    0       0      0       0
  142      0       0    0   0    0     0    0       0      0       0
  143      0       0    0   0    0     0    0       0      0       0
  144      0       0    0   0    0     0    0       0      0       0
  145      0       0    0   0    0     0    0       0      0       0
  146      0       0    0   0    0     0    0       0      0       0
  147      0       0    0   0    0     0    0       0      0       0
  148      0       0    0   0    0     0    1       0      0       0
  149      0       0    0   0    0     0    0       0      0       0
  150      0       0    0   0    1     0    0       0      0       0
  151      0       0    0   0    0     0    0       0      0       0
  152      0       0    0   0    0     0    0       0      0       0
  153      0       0    0   0    0     0    0       0      0       0
  154      0       0    0   0    0     0    0       0      0       0
  155      0       0    0   0    0     0    0       0      0       0
  156      0       0    0   0    0     0    0       0      0       0
  157      0       0    0   0    0     0    0       0      0       0
  158      1       0    0   0    0     0    0       0      0       0
  159      0       0    0   0    0     0    0       0      0       0
  160      0       0    0   0    0     0    0       0      0       0
  161      0       0    0   0    0     0    0       0      0       0
  162      0       0    0   0    0     0    1       0      0       0
  163      0       0    0   0    0     0    0       0      0       0
  164      0       0    0   0    0     0    0       0      0       0
  165      0       0    0   0    0     0    0       0      0       0
  166      0       0    0   0    0     0    0       0      0       0
  167      0       0    0   0    0     0    0       0      0       0
  168      0       0    0   0    0     0    0       0      0       0
  169      0       0    0   0    1     0    0       0      0       0
  170      0       0    0   0    0     0    0       0      0       0
  171      0       0    1   0    0     0    0       0      0       0
  172      0       0    0   0    0     0    0       0      0       0
  173      0       0    0   0    0     0    0       0      0       0
  174      0       0    0   0    0     0    0       0      0       0
  175      0       0    0   0    0     0    0       0      0       0
  176      0       0    0   0    0     0    0       0      0       0
  177      0       0    0   0    0     0    0       1      0       0
  178      0       0    0   0    0     0    0       0      0       0
  179      0       0    0   0    0     0    0       0      0       0
  180      0       0    0   0    0     0    0       0      0       0
  181      0       0    0   0    0     0    0       0      0       0
  182      0       0    0   0    0     0    1       0      0       0
  183      0       0    0   0    0     0    0       0      0       0
  184      0       0    0   0    0     0    0       0      0       0
  185      0       0    0   0    0     0    0       0      0       0
  186      0       0    0   0    0     0    0       0      0       0
  187      0       0    0   0    0     0    0       0      0       0
  188      0       0    0   0    0     0    0       0      0       0
  189      0       0    0   0    1     0    0       0      0       0
  190      0       0    0   0    1     0    0       0      0       0
  191      0       0    0   0    0     0    0       0      0       0
  192      0       0    1   0    0     0    0       0      0       0
  193      0       0    0   0    0     0    0       0      0       0
  194      0       0    0   0    0     0    0       0      0       0
  195      1       0    0   0    0     1    0       0      0       0
  196      0       0    0   0    0     0    0       0      0       0
  197      0       0    0   0    0     0    0       0      0       0
  198      0       1    0   0    0     0    0       0      0       0
  199      0       0    0   0    0     0    0       0      0       0
  200      0       0    0   0    0     0    0       0      0       0
  201      0       0    0   0    0     0    0       0      0       0
  202      0       0    0   0    0     0    0       0      0       0
  203      0       0    0   0    0     0    0       0      0       0
  204      0       0    0   0    0     0    0       0      0       0
  205      0       0    0   0    0     0    0       0      0       0
  206      0       0    0   0    0     0    0       0      0       0
  207      0       0    0   0    0     0    0       0      0       0
  208      0       0    0   0    0     0    0       0      0       0
  209      0       0    0   0    0     0    0       0      0       0
  210      0       0    0   0    0     0    0       0      0       0
  211      0       0    0   0    0     0    0       0      0       0
  212      0       0    0   0    0     0    0       0      0       0
  213      0       0    0   0    0     0    0       0      0       0
  214      0       0    0   0    0     0    0       0      0       0
  215      0       1    0   0    0     0    0       0      0       0
  216      0       0    0   0    0     0    1       0      0       0
  217      0       0    0   0    0     0    0       0      0       0
  218      0       0    0   0    0     0    0       0      0       0
  219      0       0    0   0    0     0    0       0      0       0
  220      0       0    0   0    1     0    0       0      0       0
  221      0       0    0   0    0     0    0       0      0       0
  222      0       0    0   0    0     0    0       0      0       0
  223      0       0    0   0    1     0    0       0      0       0
  224      0       0    0   0    0     0    0       0      0       0
  225      0       0    0   0    0     0    0       0      0       0
  226      0       0    0   0    0     0    0       0      0       0
  227      0       0    1   0    1     0    0       0      0       0
  228      0       0    0   0    0     0    0       0      0       0
  229      0       0    0   0    0     0    0       0      0       0
  230      0       0    0   0    0     0    0       0      0       0
  231      0       0    0   0    1     0    0       0      0       0
  232      0       0    0   0    0     0    0       0      1       0
  233      0       0    0   0    0     0    0       0      1       0
  234      0       0    0   0    0     0    0       1      0       0
  235      0       0    0   0    0     0    0       0      0       0
  236      0       0    0   0    0     0    0       0      0       0
  237      0       0    0   0    0     0    0       0      0       0
  238      0       0    0   0    0     0    0       0      0       0
  239      0       0    0   0    0     0    0       0      0       0
  240      0       0    0   0    0     0    0       0      0       0
  241      0       0    1   0    0     0    0       0      0       0
  242      0       0    0   0    0     0    0       0      0       0
  243      0       0    0   0    0     0    0       0      0       0
  244      0       0    0   0    0     0    0       0      0       0
  245      0       0    0   0    0     0    0       0      0       0
  246      0       0    0   0    0     0    0       0      0       0
  247      0       0    0   0    0     0    0       0      0       0
  248      0       0    0   0    0     0    0       0      0       0
  249      0       0    0   0    0     2    0       0      0       0
  250      0       0    0   0    0     0    0       0      0       0
  251      0       0    0   0    0     0    0       0      0       0
  252      0       0    0   0    0     0    0       0      0       0
  253      0       0    0   0    0     0    0       0      0       0
  254      0       0    0   0    0     0    0       0      0       0
  255      0       0    0   0    0     0    0       0      0       0
  256      0       0    0   0    0     0    0       0      0       0
  257      0       0    0   0    0     0    0       0      0       0
  258      0       0    0   0    0     0    0       0      0       0
  259      0       0    0   0    0     0    0       0      0       0
  260      0       0    0   0    0     0    0       0      0       0
  261      0       0    0   0    1     0    0       0      0       0
  262      0       0    0   0    0     0    0       0      0       0
  263      0       0    0   0    0     0    0       0      0       0
  264      0       0    0   0    0     0    0       0      0       0
  265      0       0    0   2    0     0    0       0      0       0
  266      0       0    0   0    0     0    0       0      0       0
  267      0       0    0   0    0     0    0       0      0       0
  268      0       0    0   0    0     0    0       0      0       0
  269      0       0    0   0    0     0    0       0      0       0
  270      0       0    0   0    0     0    0       0      0       0
  271      0       0    0   0    0     0    0       0      0       0
  272      0       0    0   0    0     0    0       0      0       0
  273      0       0    0   0    0     0    0       0      0       0
  274      0       0    0   0    0     0    0       0      0       0
  275      0       0    0   0    0     0    0       0      0       0
  276      0       0    0   1    0     0    0       0      0       0
  277      0       0    0   0    0     0    0       0      0       0
  278      0       0    0   0    0     0    0       0      0       0
  279      0       0    0   0    0     0    0       0      0       0
  280      0       0    0   0    0     0    0       0      0       0
  281      0       0    0   0    0     0    1       0      0       0
  282      0       0    0   0    0     0    0       0      0       0
  283      0       0    0   0    0     0    0       0      0       0
  284      0       0    0   0    0     0    0       0      0       0
     Terms
Docs  wonderful work worked working worklife works world year years yet
  1           0    1      1       0        0     1     1    0     0   0
  2           0    2      0       0        0     0     0    0     0   0
  3           0    0      0       0        0     0     0    0     0   0
  4           0    1      0       0        0     0     0    0     0   0
  5           0    0      0       0        0     0     0    0     0   0
  6           0    1      0       0        0     0     0    0     0   0
  7           0    0      0       1        0     0     0    0     0   0
  8           0    3      0       0        0     0     0    0     0   0
  9           0    0      0       0        0     0     0    0     0   0
  10          0    1      0       0        0     0     1    0     0   0
  11          0    1      0       0        0     0     1    0     0   0
  12          0    0      0       1        0     0     0    0     0   0
  13          0    0      1       0        0     0     0    0     0   0
  14          0    0      0       0        0     0     0    0     0   0
  15          0    2      0       0        0     0     0    0     0   0
  16          0    1      0       0        0     0     0    0     0   0
  17          0    0      0       0        0     0     1    0     0   0
  18          0    0      0       0        0     0     0    0     0   0
  19          0    3      0       2        0     0     0    0     0   0
  20          0    1      0       1        0     0     0    0     0   0
  21          0    1      0       0        0     0     0    0     0   0
  22          0    1      0       0        0     0     0    0     0   0
  23          0    0      0       0        0     0     0    0     0   0
  24          1    0      0       0        0     0     0    0     0   0
  25          0    1      0       0        0     0     0    0     0   0
  26          0    0      0       0        0     0     0    0     0   0
  27          0    0      0       0        0     0     1    0     0   0
  28          0    1      0       0        0     0     0    0     0   0
  29          0    1      0       0        0     0     0    0     0   0
  30          0    2      0       0        0     0     0    0     0   0
  31          0    0      1       1        0     0     1    0     0   0
  32          0    1      0       1        0     0     0    0     0   0
  33          0    2      0       0        0     0     1    0     0   0
  34          0    0      0       0        0     0     1    1     0   0
  35          0    2      0       0        0     0     1    0     0   0
  36          0    0      0       0        0     0     0    0     0   0
  37          0    2      0       0        0     0     0    0     0   0
  38          0    1      0       0        0     0     0    0     0   0
  39          0    1      0       3        0     0     0    0     0   0
  40          0    1      0       1        0     0     0    0     0   0
  41          0    1      0       0        0     0     0    0     0   0
  42          0    2      0       1        0     0     0    0     0   0
  43          0    5      0       0        0     0     0    0     0   0
  44          0    1      0       0        0     0     0    0     0   0
  45          1    2      0       0        0     0     0    0     0   0
  46          0    2      0       0        0     0     0    0     0   0
  47          0    3      0       0        0     0     0    0     0   0
  48          0    0      0       0        0     0     0    0     0   0
  49          1    1      0       0        0     0     0    0     0   0
  50          0    3      0       0        0     0     0    0     0   0
  51          0    0      0       0        0     0     0    0     0   0
  52          0    1      0       0        0     0     0    0     0   0
  53          0    0      0       0        0     0     0    0     0   0
  54          0    0      0       0        0     0     0    0     0   0
  55          0    0      0       1        0     0     0    0     0   0
  56          0    0      0       0        0     0     0    0     0   0
  57          0    0      0       0        0     0     0    0     0   0
  58          0    0      0       0        0     0     1    0     0   0
  59          0    2      0       0        0     0     0    0     0   0
  60          0    0      0       0        0     0     0    0     0   0
  61          0    0      0       0        0     0     0    0     0   0
  62          0    0      0       0        0     0     0    0     0   0
  63          0    2      0       0        0     0     0    0     0   0
  64          0    0      0       1        0     0     1    0     0   0
  65          0    1      0       0        0     0     1    0     0   0
  66          0    3      0       0        0     0     0    0     0   0
  67          0    3      0       0        0     0     0    0     0   0
  68          0    2      0       0        0     0     0    0     0   0
  69          0    0      0       0        0     0     0    0     0   0
  70          0    0      1       0        0     0     0    0     0   0
  71          0    0      2       0        0     0     0    0     0   0
  72          0    2      0       0        0     0     1    0     0   0
  73          0    2      0       1        0     0     0    0     0   0
  74          0    1      0       0        0     0     0    0     0   0
  75          0    2      0       0        0     0     1    0     0   0
  76          0    0      0       0        0     0     0    0     0   0
  77          0    0      1       0        0     0     0    0     0   0
  78          0    0      0       0        0     0     0    0     0   0
  79          0    1      0       0        0     0     0    0     0   0
  80          0    1      0       0        0     0     0    0     0   0
  81          0    0      0       0        0     0     0    0     0   0
  82          0    1      0       0        0     0     0    0     0   0
  83          1    1      0       0        0     0     0    0     0   0
  84          0    1      0       4        0     0     0    0     0   0
  85          0    2      1       1        0     0     0    0     1   0
  86          0    1      0       0        0     0     0    0     0   0
  87          0    0      0       0        0     0     0    0     0   0
  88          0    1      0       0        0     0     0    0     0   0
  89          0    1      0       0        0     0     0    0     0   0
  90          0    0      0       0        0     0     0    0     0   0
  91          0    0      0       1        0     0     1    0     0   0
  92          0    0      0       0        0     0     1    0     0   0
  93          0    0      0       1        0     0     0    0     0   0
  94          0    0      0       0        0     0     0    0     0   0
  95          0    2      0       0        0     0     0    0     0   0
  96          0    0      0       1        0     0     0    0     0   0
  97          0    0      0       0        0     0     0    0     0   0
  98          0    0      0       0        0     0     0    0     0   0
  99          0    1      0       0        0     0     0    0     0   0
  100         0    1      0       0        0     0     0    0     0   0
  101         0    0      0       0        0     0     0    0     0   0
  102         0    0      0       1        0     0     0    0     0   1
  103         0    1      0       0        0     0     0    0     0   0
  104         0    0      0       0        1     0     0    0     0   0
  105         0    0      1       0        0     0     0    0     0   0
  106         0    0      0       0        0     0     0    0     0   0
  107         0    0      0       0        0     0     0    0     0   0
  108         0    0      0       0        0     0     2    0     0   0
  109         0    0      0       0        0     0     0    0     0   0
  110         0    0      0       0        0     0     0    0     0   1
  111         1    1      0       0        0     0     0    0     0   0
  112         0    0      0       0        0     0     1    0     0   0
  113         0    2      0       0        0     0     0    0     0   0
  114         0    2      0       0        0     0     0    0     0   0
  115         0    0      0       0        0     0     0    0     0   0
  116         0    1      0       0        0     0     0    0     0   0
  117         0    1      0       0        0     0     1    0     0   0
  118         0    0      0       1        0     0     0    0     0   0
  119         0    0      0       0        0     0     0    0     0   0
  120         1    2      0       0        0     0     0    0     0   0
  121         0    1      0       0        0     0     0    0     0   0
  122         0    1      0       0        0     0     0    0     0   0
  123         1    0      0       0        0     0     0    0     0   0
  124         0    0      0       1        0     0     0    0     0   0
  125         0    0      0       0        1     0     0    0     0   0
  126         0    0      0       0        0     0     0    0     0   0
  127         0    0      0       1        0     0     0    0     0   0
  128         0    0      0       0        0     0     0    0     0   0
  129         0    0      0       0        0     0     0    0     0   0
  130         0    0      0       0        0     0     0    0     0   0
  131         0    0      0       0        0     0     0    0     0   0
  132         0    0      0       0        0     0     0    0     0   0
  133         0    1      1       2        0     0     0    0     0   0
  134         0    1      0       1        0     0     0    0     0   0
  135         0    0      0       0        0     0     0    0     0   0
  136         0    1      0       0        0     0     0    0     0   0
  137         0    0      0       0        0     0     0    0     0   0
  138         1    0      0       0        0     0     0    0     0   0
  139         0    0      0       0        0     0     1    0     0   0
  140         0    2      0       0        0     0     0    0     0   0
  141         0    1      0       0        0     0     0    0     0   0
  142         0    2      0       0        0     0     0    0     0   0
  143         0    2      0       0        0     0     1    1     0   1
  144         0    0      0       0        0     0     1    0     0   0
  145         0    1      0       0        0     0     1    0     0   0
  146         0    0      0       0        0     0     0    0     0   0
  147         0    0      0       0        0     0     0    0     0   0
  148         0    2      0       0        0     0     0    0     0   0
  149         0    0      0       0        0     0     0    0     0   0
  150         0    0      0       0        0     0     0    0     0   0
  151         0    1      0       0        0     0     0    0     0   0
  152         0    0      0       0        0     0     0    0     0   0
  153         0    1      0       0        0     0     0    0     0   0
  154         0    0      0       0        0     0     0    0     0   0
  155         0    0      0       0        0     0     0    0     0   0
  156         0    0      0       0        0     0     0    0     0   0
  157         0    0      0       1        0     0     0    0     0   0
  158         0    1      0       0        0     0     0    0     0   0
  159         0    1      0       0        0     0     0    0     0   0
  160         0    0      0       0        0     0     0    0     0   0
  161         0    0      0       0        0     0     0    0     0   0
  162         0    2      0       0        0     0     0    0     0   0
  163         0    1      0       1        0     0     0    0     0   0
  164         0    1      0       0        0     0     0    0     0   0
  165         0    0      0       0        0     0     0    0     0   0
  166         0    2      0       0        0     0     0    0     0   0
  167         0    2      0       1        0     0     0    0     0   0
  168         0    1      0       1        0     0     2    0     0   0
  169         0    3      0       0        0     0     0    0     0   0
  170         0    1      0       1        0     1     0    0     0   0
  171         0    0      0       0        1     0     0    0     0   0
  172         0    0      0       0        0     0     0    0     0   0
  173         0    1      0       0        0     0     0    0     0   0
  174         0    2      0       0        1     0     0    0     0   0
  175         0    3      0       0        0     0     0    0     0   0
  176         0    1      0       0        0     0     0    0     0   0
  177         0    0      0       0        0     0     0    0     0   0
  178         0    2      0       0        0     0     1    0     0   0
  179         0    1      0       0        0     0     0    0     0   0
  180         0    0      0       0        0     0     0    0     1   0
  181         0    0      0       0        0     0     0    0     0   0
  182         0    0      0       0        0     0     0    0     0   0
  183         0    0      0       1        0     0     0    0     0   0
  184         0    0      0       0        0     0     0    0     0   0
  185         0    0      0       0        0     0     0    0     0   0
  186         0    1      0       0        0     0     0    0     0   0
  187         0    0      0       0        0     0     0    0     0   0
  188         0    0      0       0        0     0     0    0     0   0
  189         0    1      0       0        0     0     0    0     0   0
  190         0    2      0       0        0     0     0    0     0   0
  191         0    1      0       0        0     0     0    0     0   0
  192         0    0      0       1        0     0     1    0     0   0
  193         0    0      0       0        0     0     0    0     0   0
  194         0    0      0       1        0     0     0    0     0   0
  195         0    0      0       1        0     0     0    0     0   0
  196         0    0      0       0        0     0     0    0     0   0
  197         0    0      0       1        0     0     0    0     0   0
  198         0    0      2       0        0     0     0    0     0   0
  199         0    1      0       0        0     0     0    0     0   0
  200         0    0      0       0        0     0     0    0     0   0
  201         0    1      0       0        0     0     0    0     0   0
  202         0    1      0       0        0     0     0    0     0   0
  203         0    0      0       0        0     0     0    0     0   0
  204         0    2      0       0        0     1     1    0     0   0
  205         0    0      0       0        0     0     0    0     0   0
  206         0    0      0       0        0     0     0    0     0   0
  207         0    1      0       0        0     0     0    0     0   0
  208         0    0      0       1        0     0     0    0     0   0
  209         0    2      0       0        0     0     0    0     0   0
  210         0    0      0       0        0     0     0    0     0   0
  211         0    0      0       0        0     0     0    0     0   0
  212         0    0      0       0        0     0     0    0     0   0
  213         0    2      0       0        0     0     0    0     0   0
  214         0    0      0       0        0     0     0    0     0   0
  215         0    1      0       0        0     0     0    0     0   0
  216         0    0      1       0        0     0     0    0     0   0
  217         0    2      0       0        0     0     0    0     0   0
  218         0    1      0       0        0     0     0    0     0   0
  219         1    1      0       1        0     0     0    0     0   0
  220         0    1      0       1        0     0     0    0     0   0
  221         0    2      0       0        0     0     0    0     0   0
  222         0    1      0       0        0     0     0    0     0   0
  223         0    0      0       0        0     0     0    0     0   0
  224         0    0      0       0        0     0     0    0     0   0
  225         0    1      0       0        0     0     0    0     0   0
  226         0    1      0       0        0     0     0    0     0   0
  227         0    1      0       0        0     1     0    0     0   0
  228         0    3      0       0        0     0     0    0     0   0
  229         0    1      0       0        0     0     0    0     0   0
  230         0    0      0       0        0     0     0    0     0   0
  231         0    0      0       0        0     0     0    0     0   0
  232         0    1      1       1        0     0     0    1     0   0
  233         0    1      1       0        0     0     0    0     0   0
  234         0    1      0       0        0     1     0    0     0   0
  235         0    2      0       0        0     0     0    0     0   0
  236         0    0      0       2        0     0     0    0     0   0
  237         0    2      0       0        0     0     0    0     0   0
  238         0    1      0       1        0     0     1    0     0   0
  239         0    1      0       0        1     0     0    0     0   0
  240         0    0      1       0        0     0     0    0     0   0
  241         0    0      0       1        0     0     0    0     0   0
  242         0    0      0       0        0     0     0    0     0   0
  243         0    1      0       1        0     0     0    0     0   0
  244         0    1      0       0        0     0     1    0     0   0
  245         0    2      0       0        0     0     0    0     0   0
  246         0    1      0       0        0     0     0    0     0   0
  247         0    0      0       0        0     0     0    0     0   0
  248         0    0      0       0        0     0     0    0     0   0
  249         0    0      0       0        0     0     1    0     0   0
  250         0    0      0       0        0     0     0    0     0   0
  251         0    0      0       1        0     0     0    0     0   0
  252         0    0      0       0        0     0     0    0     0   0
  253         0    0      0       0        0     0     0    0     0   0
  254         0    0      0       1        0     0     0    0     0   0
  255         0    1      0       0        0     0     0    0     0   0
  256         0    0      0       0        0     0     0    0     0   0
  257         0    2      1       0        0     0     0    0     0   0
  258         0    0      0       0        0     0     0    1     0   0
  259         0    0      0       0        0     0     0    0     0   0
  260         0    0      0       2        0     0     0    0     0   0
  261         0    3      0       0        0     0     0    0     0   0
  262         0    0      0       0        0     0     0    0     0   0
  263         0    0      0       1        0     0     0    0     0   0
  264         0    0      0       0        0     0     0    0     0   0
  265         0    0      0       1        0     0     0    0     0   0
  266         0    1      0       1        0     0     0    0     0   0
  267         0    0      0       0        1     0     0    0     0   0
  268         0    0      0       0        0     0     0    0     0   0
  269         0    0      0       0        0     0     0    0     0   0
  270         0    0      0       0        0     0     0    0     0   0
  271         0    0      0       0        0     0     0    0     0   0
  272         0    1      0       0        0     0     0    0     0   0
  273         0    1      0       0        0     0     0    1     0   0
  274         0    2      0       0        0     0     0    0     0   0
  275         0    0      0       0        0     0     0    0     0   0
  276         0    0      0       0        0     0     0    0     0   0
  277         0    0      0       0        0     0     0    0     0   0
  278         0    0      0       0        0     0     0    0     0   0
  279         0    1      0       0        0     0     0    0     0   0
  280         0    0      0       0        0     0     0    0     0   0
  281         0    0      0       0        0     0     0    0     0   0
  282         0    0      0       0        1     0     0    0     0   0
  283         0    0      0       0        0     0     0    0     0   0
  284         0    1      0       0        0     0     0    0     0   0
     Terms
Docs  youll young youre
  1       0     0     0
  2       0     0     0
  3       0     0     0
  4       0     0     0
  5       0     0     0
  6       0     0     0
  7       0     0     0
  8       0     0     0
  9       0     0     0
  10      0     0     0
  11      0     0     0
  12      0     0     0
  13      0     0     0
  14      0     0     0
  15      0     0     0
  16      0     0     0
  17      0     0     0
  18      0     0     0
  19      0     0     0
  20      0     0     0
  21      0     0     0
  22      0     0     0
  23      0     0     0
  24      0     0     0
  25      0     0     0
  26      0     0     0
  27      0     0     0
  28      0     0     0
  29      0     0     0
  30      0     0     0
  31      0     0     0
  32      0     0     0
  33      0     0     0
  34      0     0     0
  35      0     0     1
  36      0     0     0
  37      0     0     0
  38      0     0     2
  39      0     0     0
  40      0     0     0
  41      0     0     0
  42      0     0     0
  43      0     0     0
  44      0     0     0
  45      0     0     0
  46      0     0     0
  47      0     1     0
  48      0     0     0
  49      0     0     0
  50      0     0     0
  51      0     0     0
  52      1     0     0
  53      0     0     0
  54      0     0     0
  55      0     1     0
  56      0     0     0
  57      0     0     0
  58      0     0     0
  59      0     0     0
  60      0     0     0
  61      0     0     0
  62      0     0     0
  63      0     0     0
  64      0     0     0
  65      0     0     0
  66      0     0     0
  67      0     0     0
  68      0     0     0
  69      0     0     0
  70      0     0     0
  71      0     0     0
  72      1     0     1
  73      1     0     0
  74      0     0     0
  75      1     0     0
  76      0     0     0
  77      0     0     0
  78      0     0     0
  79      0     0     0
  80      0     0     0
  81      0     0     0
  82      0     0     0
  83      0     0     0
  84      0     0     1
  85      0     0     0
  86      0     0     0
  87      0     0     1
  88      0     0     0
  89      0     0     0
  90      0     0     0
  91      0     0     1
  92      0     0     0
  93      0     1     0
  94      0     0     0
  95      0     0     0
  96      0     0     0
  97      0     0     0
  98      0     0     0
  99      0     0     0
  100     0     0     0
  101     1     0     0
  102     0     0     0
  103     0     0     0
  104     0     0     0
  105     0     0     0
  106     0     1     0
  107     0     0     0
  108     0     0     0
  109     0     0     0
  110     0     0     0
  111     0     0     0
  112     0     0     0
  113     0     0     0
  114     0     0     0
  115     0     0     0
  116     0     0     0
  117     0     0     1
  118     0     0     0
  119     0     0     0
  120     0     0     0
  121     0     0     0
  122     0     0     0
  123     0     0     0
  124     0     0     0
  125     0     0     0
  126     0     0     0
  127     0     0     0
  128     0     0     0
  129     0     0     0
  130     0     0     0
  131     0     0     0
  132     0     0     0
  133     0     0     1
  134     0     0     0
  135     0     0     0
  136     0     0     0
  137     0     0     0
  138     0     0     0
  139     0     0     0
  140     0     0     0
  141     0     0     0
  142     0     0     0
  143     0     0     0
  144     0     0     0
  145     0     0     0
  146     0     0     0
  147     0     0     0
  148     0     1     0
  149     0     0     0
  150     0     0     0
  151     0     0     0
  152     0     0     0
  153     0     0     0
  154     0     0     0
  155     0     0     0
  156     0     0     0
  157     0     0     0
  158     0     0     0
  159     0     0     0
  160     0     0     0
  161     0     0     0
  162     0     0     0
  163     0     0     0
  164     0     0     0
  165     0     0     0
  166     0     0     0
  167     0     0     0
  168     0     0     0
  169     0     0     0
  170     0     0     0
  171     0     0     0
  172     0     0     0
  173     0     0     0
  174     0     0     0
  175     0     0     0
  176     0     0     0
  177     0     0     0
  178     0     0     0
  179     0     0     0
  180     0     0     0
  181     0     0     0
  182     0     0     0
  183     0     0     0
  184     0     1     0
  185     0     0     0
  186     0     0     0
  187     0     0     0
  188     0     0     0
  189     0     0     0
  190     0     0     0
  191     0     0     0
  192     0     0     0
  193     0     0     0
  194     0     0     0
  195     0     0     0
  196     0     0     0
  197     0     0     0
  198     0     0     0
  199     0     0     0
  200     0     0     0
  201     0     0     0
  202     0     0     0
  203     0     0     0
  204     0     0     0
  205     0     0     0
  206     0     0     0
  207     0     0     0
  208     0     0     0
  209     0     0     0
  210     0     0     0
  211     0     0     0
  212     0     0     0
  213     0     0     0
  214     0     0     0
  215     0     0     0
  216     0     0     0
  217     0     0     0
  218     0     0     0
  219     0     0     0
  220     0     0     0
  221     0     0     0
  222     0     0     0
  223     0     0     0
  224     0     0     0
  225     0     0     0
  226     0     0     0
  227     0     0     0
  228     0     0     0
  229     0     0     0
  230     0     0     0
  231     0     0     0
  232     0     0     0
  233     0     0     1
  234     0     0     1
  235     0     0     0
  236     0     0     0
  237     0     0     0
  238     0     0     1
  239     0     0     0
  240     0     0     0
  241     0     0     0
  242     0     0     0
  243     0     0     0
  244     0     0     0
  245     0     0     0
  246     0     0     0
  247     0     0     0
  248     0     0     0
  249     0     0     0
  250     0     0     0
  251     0     0     0
  252     0     0     0
  253     0     0     0
  254     0     0     0
  255     0     0     0
  256     0     0     0
  257     0     0     0
  258     0     0     0
  259     0     0     0
  260     0     0     0
  261     2     0     0
  262     0     0     0
  263     0     0     0
  264     0     0     0
  265     0     0     0
  266     0     0     0
  267     0     0     0
  268     0     0     0
  269     0     0     0
  270     0     0     0
  271     0     0     0
  272     0     0     0
  273     0     0     0
  274     0     0     1
  275     0     0     0
  276     0     0     0
  277     0     0     0
  278     0     0     0
  279     0     0     0
  280     0     0     0
  281     0     0     0
  282     0     0     0
  283     0     0     0
  284     0     0     0
 [ reached getOption("max.print") -- omitted 216 rows ]
```

```r
head(df_txt, 20)
```

```
   ability able access actually advance advancement almost also always
1        0    0      0        0       0           0      0    1      0
2        0    0      0        0       0           0      0    0      0
3        0    0      0        0       0           0      0    0      0
4        0    0      0        0       0           0      0    0      0
5        0    0      0        0       0           0      0    0      1
6        0    0      0        0       0           0      0    0      0
7        0    0      0        0       0           0      0    0      0
8        0    0      0        0       0           0      0    0      0
9        0    0      0        0       0           1      0    0      0
10       0    0      0        0       0           0      0    2      1
11       0    0      0        0       0           0      0    0      0
12       0    0      0        0       0           0      0    0      0
13       0    0      0        0       0           0      0    1      0
14       0    0      0        0       0           0      0    0      0
15       0    0      0        0       0           0      0    0      0
16       0    0      0        0       0           0      0    0      0
17       0    0      0        0       0           0      0    0      0
18       0    0      0        0       0           0      0    1      0
19       0    0      0        0       0           0      0    0      0
20       0    0      0        0       0           0      0    0      0
   amazing another anything areas around arrogant atmosphere autonomy
1        0       0        0     0      0        0          0        0
2        0       0        0     0      0        0          0        0
3        0       0        0     0      0        0          0        0
4        0       0        0     0      0        0          0        0
5        0       0        0     0      0        0          0        0
6        0       0        0     0      0        0          0        0
7        0       0        0     0      0        0          0        0
8        0       0        0     0      0        0          0        0
9        1       0        0     0      0        0          1        0
10       1       1        0     0      0        0          1        0
11       0       0        0     0      0        0          0        0
12       0       0        0     1      2        0          0        0
13       0       0        0     0      1        0          0        0
14       0       0        0     0      0        0          0        0
15       0       0        0     0      0        0          0        0
16       0       0        0     0      0        0          0        0
17       0       0        0     0      0        0          0        0
18       0       0        0     0      0        0          0        0
19       0       0        0     0      0        0          0        0
20       0       0        0     0      0        0          0        0
   available awesome back bad balance become becoming benefits best better
1          0       0    0   0       0      0        0        0    0      0
2          0       0    0   0       0      0        0        0    0      0
3          0       0    0   0       0      0        0        0    0      0
4          0       0    0   0       0      0        0        1    0      0
5          1       0    0   0       0      0        0        1    0      0
6          0       0    0   0       0      0        0        0    1      0
7          0       0    0   0       0      0        0        0    0      0
8          0       0    0   0       0      0        0        0    0      0
9          0       0    0   0       0      0        0        0    0      0
10         0       0    0   0       0      0        0        0    0      0
11         0       0    0   0       0      0        0        0    0      0
12         0       0    0   0       0      0        0        1    2      0
13         0       0    0   0       0      0        0        0    0      1
14         0       0    0   0       0      0        0        0    0      0
15         0       0    0   0       0      0        0        0    0      1
16         0       0    0   0       0      0        0        0    0      0
17         0       0    0   0       0      0        0        0    0      0
18         0       0    0   0       0      0        0        0    0      0
19         0       0    0   0       0      0        0        0    0      0
20         0       0    0   0       0      0        0        0    0      0
   big bonus bright brightest brilliant build bureaucracy business campus
1    0     0      0         0         0     0           0        0      0
2    0     0      0         0         0     0           0        0      0
3    0     0      0         0         0     0           0        0      0
4    0     0      0         0         0     0           0        0      0
5    0     0      0         0         0     0           0        0      0
6    0     0      0         0         0     0           0        0      0
7    0     0      0         0         0     0           0        0      0
8    0     0      0         0         0     0           0        0      0
9    0     0      0         0         0     0           0        0      0
10   0     0      0         1         0     0           0        0      1
11   0     0      0         0         0     0           0        0      0
12   0     0      0         0         0     0           0        0      0
13   0     0      0         0         0     0           0        0      0
14   0     0      0         0         0     0           0        0      0
15   0     1      0         0         0     0           0        0      0
16   0     0      0         0         0     0           0        0      0
17   1     0      0         0         0     0           0        0      0
18   0     0      0         0         0     0           0        0      0
19   0     0      0         0         0     0           0        0      0
20   0     0      0         0         0     0           0        0      0
   can cant care career challenges challenging chance change changing
1    0    0    0      0          0           0      0      0        0
2    0    0    0      0          0           0      0      0        0
3    0    0    0      0          0           0      0      0        0
4    1    0    0      0          0           0      0      0        0
5    0    0    0      0          0           0      0      0        0
6    0    0    0      0          0           0      0      0        0
7    0    0    0      0          0           0      0      0        0
8    0    0    0      0          0           0      0      0        0
9    0    0    0      1          0           0      0      0        0
10   1    0    0      0          0           0      0      0        0
11   1    0    0      0          0           0      0      1        0
12   1    0    0      0          0           0      0      0        0
13   1    0    0      0          0           0      0      0        0
14   0    0    0      0          0           0      0      0        0
15   0    0    0      0          0           0      0      0        0
16   0    0    0      0          0           0      0      0        0
17   0    0    0      0          0           0      1      0        0
18   0    0    0      0          0           0      0      0        0
19   0    0    0      0          0           0      0      0        0
20   0    0    0      0          0           0      0      0        0
   class code colleagues college come coming communication companies
1      0    0          0       0    0      0             0         0
2      0    0          0       0    0      0             0         0
3      0    0          0       0    0      0             0         0
4      0    0          0       0    0      0             0         0
5      0    0          0       0    0      0             0         0
6      0    0          0       0    0      0             0         0
7      0    0          0       0    0      0             0         0
8      0    0          0       0    1      0             0         0
9      0    0          0       0    0      0             0         0
10     0    0          0       0    0      0             0         0
11     0    0          0       0    0      0             0         0
12     0    0          0       0    0      0             0         0
13     0    0          0       0    0      0             0         0
14     0    0          0       0    0      0             0         0
15     0    0          0       0    0      0             0         0
16     0    0          0       0    0      0             0         0
17     0    0          0       0    0      0             0         0
18     0    0          0       0    0      0             0         0
19     0    0          0       0    0      0             0         0
20     0    0          0       0    0      0             0         1
   company compensation competent competitive completely cons constant
1        0            0         0           0          0    0        0
2        0            0         0           0          0    0        0
3        0            0         0           0          0    0        0
4        0            0         0           0          0    0        0
5        0            0         0           0          0    0        0
6        0            0         0           0          0    0        0
7        0            0         0           0          0    0        0
8        0            0         0           0          0    0        0
9        0            0         0           0          0    0        0
10       0            0         0           0          0    0        0
11       0            0         0           0          0    0        0
12       0            0         0           0          0    0        0
13       0            0         0           0          0    0        0
14       0            0         0           0          0    0        0
15       0            0         0           0          0    0        0
16       0            0         0           0          0    0        0
17       0            0         0           0          0    0        0
18       1            0         0           0          0    0        0
19       0            0         0           0          0    0        0
20       0            0         0           0          0    0        0
   contractors contribute cool corporate coworkers creative culture day
1            0          0    1         0         0        0       0   0
2            0          0    0         0         0        0       0   0
3            0          0    0         0         0        0       0   0
4            0          0    0         0         0        0       0   0
5            0          0    0         0         0        0       0   0
6            0          0    0         0         0        0       0   0
7            0          0    0         0         0        0       0   1
8            0          0    0         0         0        0       0   1
9            0          0    0         0         0        0       0   0
10           0          0    0         0         0        0       0   1
11           0          0    0         0         0        0       0   0
12           0          0    0         0         0        0       0   1
13           0          0    0         0         0        1       0   0
14           0          0    0         0         0        0       0   0
15           0          0    0         0         0        0       0   0
16           0          0    0         0         0        0       0   0
17           0          0    0         0         0        0       0   0
18           0          0    0         0         0        0       0   0
19           0          0    0         0         0        0       0   0
20           0          0    0         0         0        0       0   0
   days decisions department development different difficult doesnt done
1     0         0          0           0         0         0      0    0
2     0         0          0           0         0         0      0    0
3     0         0          0           0         1         0      0    0
4     0         0          0           0         0         0      0    0
5     0         0          0           0         0         0      0    0
6     0         0          0           0         0         0      0    0
7     0         0          0           0         0         0      0    0
8     0         0          0           0         0         0      0    0
9     0         0          0           1         0         0      0    0
10    0         0          0           0         0         0      0    0
11    0         0          0           0         0         0      0    0
12    0         0          0           0         0         0      0    0
13    0         0          0           0         0         0      0    0
14    0         0          0           0         0         0      0    0
15    0         0          0           0         0         0      0    0
16    0         0          0           0         0         0      0    0
17    0         0          0           0         0         0      0    0
18    0         0          0           0         0         0      0    1
19    0         0          0           0         0         0      0    2
20    0         0          0           0         0         0      0    1
   dont driven easy else employee employees end engineer engineering
1     0      0    0    1        0         0   0        0           0
2     0      0    0    0        0         0   0        0           0
3     0      0    0    0        0         0   0        0           0
4     0      0    0    0        0         0   0        0           0
5     0      0    0    0        0         0   0        0           0
6     0      0    0    0        0         0   0        0           0
7     0      0    0    0        0         0   0        0           0
8     0      0    0    0        0         0   0        0           0
9     0      0    0    0        1         0   0        0           0
10    0      0    0    0        0         0   0        0           0
11    0      0    0    0        0         0   0        0           0
12    0      0    0    0        1         0   0        0           0
13    0      0    0    0        0         0   0        0           0
14    0      0    0    0        0         0   0        0           0
15    0      0    0    0        0         0   0        0           0
16    0      0    0    0        0         2   0        0           0
17    0      0    0    0        0         0   0        0           0
18    0      0    0    0        0         1   0        0           0
19    0      0    0    0        0         1   0        0           0
20    1      0    0    0        0         0   0        2           0
   engineers enjoy enough environment etc even ever every everyone
1          0     0      0           0   0    0    0     0        0
2          0     0      0           0   0    0    0     0        0
3          0     0      0           0   0    0    0     0        0
4          0     0      0           0   0    0    0     0        0
5          0     0      0           0   1    0    0     0        0
6          0     0      0           0   0    0    0     0        0
7          0     0      0           0   0    0    0     1        0
8          0     0      0           1   0    0    0     1        0
9          0     0      0           0   0    0    0     0        0
10         0     0      0           0   0    0    0     1        0
11         0     0      0           0   0    0    0     1        0
12         0     0      0           0   1    0    0     0        0
13         0     0      0           1   0    1    0     0        2
14         0     0      0           0   0    0    0     0        0
15         0     0      0           0   0    1    0     0        0
16         0     0      0           0   0    0    0     0        0
17         0     0      0           1   0    0    0     0        0
18         0     0      0           0   0    0    1     0        0
19         0     0      0           1   0    0    0     0        0
20         0     0      0           0   0    0    0     0        0
   everything excellent exciting expect expected experience extremely fast
1           0         0        0      0        0          0         0    0
2           0         0        0      0        0          0         0    0
3           0         0        0      0        0          0         0    0
4           0         0        0      0        0          0         0    0
5           0         0        0      0        0          0         0    0
6           0         0        0      0        0          0         0    0
7           0         0        0      0        0          0         0    0
8           0         0        0      0        0          0         0    0
9           0         0        0      0        0          0         0    0
10          0         0        0      0        0          0         0    0
11          0         0        0      0        0          0         0    0
12          0         1        0      0        0          0         0    0
13          0         0        0      0        0          0         0    0
14          0         0        0      0        0          0         0    0
15          0         0        0      0        0          0         0    0
16          0         0        0      0        0          1         0    0
17          0         0        0      0        0          0         0    0
18          0         0        0      0        0          0         0    0
19          0         0        0      0        0          0         0    1
20          0         0        0      0        0          0         0    0
   feedback feel find first flat flexibility flexible focus food free
1         0    0    0     1    0           0        0     0    0    0
2         0    0    0     0    0           0        0     0    0    0
3         0    0    0     0    0           0        0     0    0    0
4         0    0    0     0    0           0        1     0    0    0
5         0    0    0     0    0           0        0     0    1    1
6         0    0    0     0    0           0        0     0    0    0
7         0    0    0     0    0           0        0     0    0    0
8         0    0    0     0    0           0        0     0    0    0
9         0    0    0     0    0           0        0     0    0    0
10        0    0    0     0    0           0        1     0    1    0
11        0    0    0     0    0           0        0     0    1    1
12        0    0    0     0    0           0        0     0    1    1
13        0    1    0     1    0           0        0     0    0    0
14        0    0    0     0    0           0        0     0    0    0
15        0    0    0     0    0           0        0     0    0    1
16        0    0    0     0    0           0        0     0    0    0
17        0    0    0     0    0           0        0     0    0    0
18        0    0    0     0    0           0        0     0    0    0
19        0    0    0     0    0           0        0     0    0    0
20        0    0    0     0    0           0        0     0    0    0
   freedom fresh friendly full fun game general generally get getting give
1        0     0        0    0   0    0       0         0   1       0    0
2        0     0        0    0   0    0       0         0   0       0    0
3        0     0        0    0   0    0       0         0   0       0    0
4        0     0        0    0   0    0       0         0   0       0    0
5        0     0        0    0   0    0       0         0   0       0    0
6        0     0        0    0   0    0       0         0   0       0    0
7        0     0        0    0   0    0       0         0   0       0    0
8        0     0        0    0   0    0       0         0   0       0    0
9        0     0        0    0   0    0       0         0   0       0    0
10       0     0        0    0   1    0       0         0   0       0    0
11       0     0        0    0   0    0       0         0   0       0    0
12       0     0        0    0   0    1       0         0   0       0    0
13       0     0        0    0   0    0       0         0   0       0    0
14       0     0        0    0   0    0       0         0   0       0    0
15       0     0        0    0   0    0       0         0   0       0    0
16       0     0        0    0   0    0       0         0   0       0    0
17       0     0        0    0   0    0       0         0   0       0    0
18       0     0        0    0   0    0       0         0   0       0    0
19       0     0        0    0   0    0       0         0   2       0    0
20       0     0        0    0   0    0       0         0   1       0    0
   given go going good google got gourmet great group groups growth hard
1      0  0     0    0      0   0       0     1     0      0      0    0
2      0  0     0    0      0   0       0     0     0      0      0    0
3      0  0     0    0      0   0       0     0     0      0      0    0
4      0  0     0    0      1   0       0     1     0      0      0    0
5      0  0     0    0      0   0       0     1     0      0      0    0
6      0  0     0    0      0   0       0     0     0      0      0    0
7      0  0     0    0      0   0       0     0     0      0      0    0
8      0  0     0    0      0   0       0     1     0      0      0    0
9      0  0     0    0      0   0       0     1     0      0      0    0
10     0  0     0    0      0   0       0     0     0      0      0    0
11     0  0     0    0      4   0       0     0     1      1      0    0
12     0  0     0    0      1   0       0     1     0      0      0    0
13     0  1     0    1      1   0       0     0     0      0      0    0
14     0  0     0    0      0   0       0     2     0      0      0    0
15     0  0     0    1      2   0       0     0     0      0      0    0
16     0  0     0    0      2   0       0     0     0      0      0    0
17     0  0     0    1      0   0       0     0     0      0      0    0
18     0  0     0    0      1   0       0     0     0      0      0    0
19     0  0     0    0      0   0       0     0     0      0      0    0
20     0  0     0    0      1   0       0     0     0      0      0    0
   help high highly hire hired horrible hours hr huge ideas impact
1     0    0      0    0     0        0     0  0    0     0      0
2     0    0      0    0     0        0     0  0    0     0      0
3     0    0      0    0     0        0     0  0    0     0      0
4     0    0      0    0     0        0     1  0    0     0      0
5     0    0      0    0     0        0     0  0    0     0      0
6     0    0      0    0     0        0     0  0    0     0      0
7     0    1      0    0     0        0     0  0    0     0      0
8     0    0      0    0     0        0     0  0    0     0      0
9     0    0      0    0     0        0     0  0    0     0      0
10    0    0      0    0     0        0     0  0    0     0      0
11    0    0      0    0     0        0     0  0    0     0      1
12    0    0      0    0     0        0     0  0    0     0      0
13    0    0      0    0     0        0     0  0    0     0      0
14    0    0      0    0     0        0     0  0    0     0      1
15    0    1      0    0     0        0     0  0    0     0      0
16    0    1      0    0     0        0     0  0    0     0      0
17    0    0      0    0     0        0     0  0    0     0      0
18    0    0      0    0     0        0     0  0    0     1      0
19    0    0      0    0     0        0     0  0    0     0      0
20    0    0      0    0     0        0     0  0    0     0      0
   incredible incredibly individual industry information infrastructure
1           0          0          0        1           0              0
2           0          0          0        0           0              0
3           0          0          0        0           0              0
4           0          0          0        0           0              0
5           0          0          0        0           0              0
6           0          0          0        0           0              0
7           0          0          0        0           0              0
8           0          0          0        0           0              0
9           0          0          0        0           0              0
10          0          0          0        0           0              0
11          0          0          0        0           0              0
12          0          0          0        0           0              0
13          0          0          0        0           0              0
14          0          0          0        0           0              0
15          0          0          0        0           0              0
16          0          0          0        0           0              0
17          0          0          0        0           0              0
18          0          0          0        0           0              0
19          0          0          0        0           0              0
20          0          0          0        0           0              0
   innovation innovative instead intelligent interest interesting internal
1           0          0       0           0        0           0        0
2           0          0       0           0        0           0        0
3           0          0       0           0        0           0        0
4           0          0       0           0        0           0        0
5           0          0       0           0        0           0        0
6           0          0       0           0        0           0        0
7           0          0       0           0        0           0        0
8           0          0       0           0        0           0        0
9           1          0       0           0        0           0        0
10          0          0       0           0        0           0        0
11          0          0       0           0        0           0        0
12          0          0       0           0        0           0        0
13          0          0       0           0        0           0        0
14          0          0       0           0        0           0        0
15          0          0       0           0        0           0        0
16          0          0       0           0        0           1        0
17          0          0       0           0        0           0        0
18          0          0       0           0        0           0        0
19          0          0       0           0        0           0        0
20          0          0       0           0        0           0        0
   interviews isnt ive job just keep know knowledge lack large leadership
1           0    0   0   0    0    0    0         1    0     0          0
2           0    0   0   0    0    0    0         0    0     0          0
3           0    0   0   0    0    0    0         0    0     0          0
4           0    0   0   0    0    0    0         0    0     0          0
5           0    0   0   0    0    0    0         0    0     0          0
6           0    0   0   0    0    0    0         0    0     0          0
7           0    0   0   0    0    0    0         0    0     0          0
8           0    0   0   0    0    0    0         0    0     0          0
9           0    0   0   0    0    0    0         0    0     0          0
10          0    0   0   0    0    1    0         0    0     0          0
11          0    0   0   1    0    0    0         0    0     0          0
12          0    0   0   0    0    0    0         0    0     0          0
13          0    0   1   0    1    0    0         0    0     0          0
14          0    0   0   0    0    0    0         0    0     0          0
15          0    0   0   0    0    0    0         0    0     0          0
16          0    0   0   0    0    0    0         0    0     0          1
17          0    0   0   0    0    0    0         0    0     0          0
18          0    0   0   0    0    0    0         0    0     0          0
19          0    0   0   0    0    0    0         0    0     0          0
20          0    0   0   1    0    0    0         0    0     0          0
   leading learn learning least less level levels life like little long
1        0     0        0     0    0     0      0    0    0      0    0
2        0     0        0     0    0     0      0    0    0      0    0
3        0     0        0     0    0     0      0    0    0      0    0
4        0     0        0     0    0     0      0    0    0      0    0
5        0     0        0     0    0     0      0    0    0      0    0
6        0     0        0     0    0     0      0    0    0      0    0
7        0     0        0     0    0     0      0    0    0      0    0
8        0     0        0     0    0     0      0    0    0      0    0
9        0     0        0     0    0     0      0    0    0      0    0
10       0     0        1     0    0     0      0    0    0      0    0
11       0     0        0     0    0     0      0    0    0      0    0
12       0     1        0     0    0     0      0    0    0      0    0
13       0     0        0     0    0     0      0    0    1      0    0
14       0     0        0     0    0     0      0    0    0      0    0
15       0     0        0     0    0     0      0    0    0      0    0
16       0     0        0     0    0     0      0    0    0      0    0
17       0     0        0     0    0     0      0    0    0      0    0
18       0     0        0     0    0     0      0    0    0      0    0
19       0     0        0     0    0     0      0    0    0      0    0
20       0     0        0     0    0     0      0    0    2      0    0
   lot lots love low lunch made make makes making manage management
1    0    0    0   0     0    0    0     0      0      0          0
2    0    0    0   0     0    0    0     0      0      0          0
3    0    0    0   0     0    0    0     0      0      0          0
4    0    0    0   0     0    0    0     0      0      0          0
5    0    0    0   0     0    0    0     0      0      0          0
6    1    0    0   0     0    0    0     0      0      0          0
7    0    0    0   0     0    0    0     0      0      0          0
8    0    0    1   0     0    0    0     0      0      0          0
9    0    0    0   0     0    0    0     0      0      0          1
10   0    0    1   0     0    0    0     0      0      0          0
11   0    0    0   0     0    0    0     0      0      0          0
12   0    0    0   0     0    0    0     0      0      0          0
13   0    0    0   0     0    0    1     1      0      0          0
14   0    0    0   0     0    0    0     0      0      0          0
15   0    0    0   0     1    0    0     0      0      0          0
16   0    0    0   0     0    0    0     0      0      0          0
17   0    0    0   0     0    0    1     0      0      0          0
18   0    0    0   0     0    0    0     0      0      0          0
19   0    0    0   0     0    0    1     0      0      0          0
20   0    0    0   0     0    0    0     0      0      0          0
   manager managers many massages may meals met middle millions mostly
1        0        0    0        0   0     0   0      0        0      0
2        0        0    0        0   0     0   0      0        0      0
3        0        0    0        0   0     0   0      0        0      0
4        0        0    0        0   0     0   0      0        0      0
5        0        0    0        0   0     0   0      0        0      0
6        0        0    0        0   0     0   0      0        0      0
7        0        0    0        0   0     0   0      0        0      0
8        0        0    0        0   0     0   0      0        0      0
9        0        0    0        0   0     0   0      0        0      0
10       0        0    0        0   0     0   0      0        0      0
11       0        0    0        0   0     0   1      0        0      0
12       0        0    0        0   0     1   0      0        0      0
13       0        0    0        0   0     0   0      0        0      0
14       0        0    0        0   0     0   0      0        0      0
15       0        0    0        0   0     0   0      0        0      0
16       0        0    0        0   0     0   0      0        0      1
17       0        0    0        0   0     0   0      0        1      0
18       0        0    0        0   0     0   0      0        0      0
19       0        0    0        0   0     0   0      0        0      0
20       0        0    0        0   0     0   0      0        0      0
   motivated move much name need needs never new nice nothing now number
1          0    0    0    0    0     0     0   0    0       0   0      0
2          0    0    0    0    0     0     0   0    0       0   0      0
3          0    0    0    0    0     0     0   0    0       0   0      0
4          0    0    0    0    0     0     0   0    0       0   0      0
5          0    0    0    0    1     0     0   0    0       0   0      0
6          0    0    0    0    0     0     0   0    0       0   0      0
7          0    0    0    0    0     0     0   1    0       0   0      0
8          0    0    0    0    0     0     0   0    0       0   0      0
9          0    0    0    0    0     0     0   0    0       0   0      0
10         0    0    0    0    0     0     0   0    0       0   0      0
11         0    0    0    0    0     0     0   0    0       0   0      0
12         0    0    0    0    0     0     0   0    0       0   0      1
13         0    0    0    0    0     0     0   0    0       0   0      0
14         0    0    0    0    0     0     0   0    0       0   0      0
15         0    0    0    0    0     0     0   0    0       0   0      0
16         0    0    0    0    0     0     0   0    0       0   0      0
17         0    0    0    0    0     0     0   0    0       0   0      0
18         0    0    0    0    0     0     0   0    0       0   0      0
19         0    1    0    0    1     0     0   0    0       0   0      0
20         0    0    0    0    0     0     0   0    0       0   0      0
   office offices often one onsite open opportunities opportunity order
1       0       0     0   1      0    0             0           0     0
2       0       0     0   0      0    0             0           0     0
3       0       0     0   0      0    0             0           0     0
4       0       0     0   0      0    0             0           0     0
5       0       0     0   0      0    0             0           0     0
6       0       0     0   0      0    0             0           0     0
7       0       0     0   0      0    0             0           0     0
8       0       0     0   0      0    0             0           0     0
9       0       0     0   0      0    1             0           0     0
10      0       0     0   0      0    0             0           0     0
11      0       0     0   1      0    1             0           1     0
12      0       0     0   0      0    0             0           0     0
13      0       0     0   1      0    0             0           0     0
14      0       0     0   0      0    0             0           0     0
15      0       0     0   0      0    0             0           0     0
16      0       0     0   0      0    0             0           0     0
17      0       0     0   0      0    0             0           0     0
18      0       0     0   0      0    1             0           0     0
19      0       0     0   1      0    0             0           0     0
20      0       0     0   0      0    0             0           0     0
   org organization outside part pay peers people performance perks person
1    0            0       0    0   0     0      2           0     0      0
2    0            0       0    0   0     0      2           0     0      0
3    0            0       0    0   0     0      0           0     0      0
4    0            0       0    0   0     0      0           0     0      0
5    0            0       0    0   0     0      0           0     0      0
6    0            0       0    1   0     0      2           0     1      0
7    0            0       0    0   0     0      0           0     0      0
8    0            0       0    0   0     0      1           0     0      0
9    0            0       0    0   0     0      0           0     0      0
10   0            0       0    0   0     0      1           0     0      0
11   0            0       0    0   0     0      1           0     0      0
12   0            0       0    1   0     0      1           0     0      0
13   0            0       0    0   0     0      1           0     0      0
14   0            0       0    0   0     0      1           0     0      0
15   0            0       0    0   0     0      2           0     0      0
16   0            0       0    0   0     0      0           0     1      0
17   0            0       0    0   0     0      2           0     0      0
18   0            0       0    0   0     0      0           0     0      0
19   0            0       0    0   0     0      0           0     1      0
20   0            0       0    0   0     0      0           0     0      0
   personal place places play political politics poor positive pretty
1         0     1      0    0         0        0    0        0      0
2         0     0      0    0         0        0    0        0      0
3         0     0      0    0         0        0    0        0      0
4         0     0      0    0         0        0    0        0      0
5         0     0      0    0         0        0    0        0      0
6         0     0      0    0         0        0    0        0      0
7         0     0      0    0         0        0    0        0      0
8         0     0      0    0         0        0    0        0      0
9         0     0      0    0         0        0    0        0      0
10        0     0      0    0         0        0    0        0      0
11        0     0      0    0         0        0    0        0      0
12        0     0      0    0         0        0    0        0      0
13        0     0      1    0         0        0    0        0      0
14        0     0      0    0         0        0    0        0      0
15        0     0      0    0         0        0    0        0      0
16        1     1      0    0         0        0    0        0      0
17        0     0      0    0         0        0    0        0      0
18        0     0      0    0         0        0    0        0      0
19        0     0      0    0         0        0    0        0      0
20        0     0      0    0         0        0    0        0      0
   probably problem problems process product products professional project
1         0       0        0       0       0        0            0       0
2         0       0        0       0       0        0            0       0
3         0       0        0       0       0        0            0       0
4         1       0        0       0       0        0            0       0
5         0       0        0       0       0        0            0       0
6         0       0        0       0       0        0            0       0
7         0       0        0       0       0        0            0       0
8         0       0        0       0       0        0            0       0
9         0       0        0       0       0        0            0       0
10        0       0        0       0       0        0            0       0
11        0       0        0       0       0        0            0       0
12        0       0        0       0       0        0            0       0
13        0       0        0       0       0        0            0       0
14        0       0        0       0       0        0            0       0
15        0       0        0       0       0        0            0       0
16        0       0        0       0       0        1            0       0
17        0       0        0       0       0        0            0       0
18        0       0        0       0       0        1            0       0
19        0       0        0       0       0        0            0       0
20        0       0        0       0       0        0            1       0
   projects promoted promotion promotions pros put quality quite rather
1         1        0         0          0    0   0       0     0      0
2         0        0         0          0    0   0       0     0      0
3         1        0         0          0    1   0       0     0      0
4         0        0         0          0    0   0       0     0      0
5         0        0         0          0    0   0       0     0      0
6         0        0         0          0    0   0       0     0      0
7         0        0         0          0    0   0       0     0      0
8         0        0         0          0    0   0       0     0      0
9         0        0         0          0    0   0       0     0      0
10        0        0         0          0    0   0       0     0      0
11        0        0         0          0    1   0       0     0      0
12        0        0         0          0    0   0       0     0      0
13        0        0         0          0    0   0       0     0      0
14        0        0         0          0    0   0       0     0      0
15        0        0         0          0    0   0       0     0      0
16        0        0         0          0    0   0       1     0      0
17        0        0         0          0    0   0       0     0      0
18        0        0         0          0    0   0       0     0      1
19        1        0         0          0    0   0       0     0      0
20        0        0         0          0    0   0       0     1      0
   real really reason recognition recruiting resources respect right role
1     0      0      0           0          0         0       0     0    0
2     0      0      0           0          0         0       0     0    0
3     0      0      0           0          0         0       0     0    0
4     0      0      0           0          0         0       0     0    0
5     0      0      0           0          0         0       0     0    0
6     0      0      0           0          0         0       0     0    0
7     0      0      0           0          0         0       0     0    0
8     0      0      0           0          0         0       0     0    0
9     0      0      0           0          0         0       0     0    0
10    0      0      1           0          0         0       0     0    0
11    0      0      0           0          0         0       0     0    0
12    0      0      0           0          0         0       0     0    0
13    0      2      0           0          0         0       0     0    0
14    0      0      0           0          0         0       0     0    0
15    0      2      0           0          0         0       0     0    0
16    0      0      0           0          0         0       0     0    0
17    0      0      0           0          0         0       0     0    0
18    0      0      0           0          0         0       0     0    0
19    0      0      0           0          0         0       0     0    0
20    0      0      0           0          0         0       0     0    0
   room said salary sales say see seem seems seen senior sense several
1     0    0      0     0   0   0    0     0    0      0     0       0
2     0    0      0     0   0   0    0     0    0      0     0       0
3     0    0      0     0   0   0    0     0    0      0     0       0
4     0    0      0     0   0   0    0     0    0      0     0       0
5     0    0      0     0   0   0    0     0    0      0     0       0
6     0    0      0     0   0   0    0     0    0      0     0       0
7     0    0      0     0   0   0    0     0    0      0     0       0
8     0    0      0     0   0   0    0     0    0      0     0       0
9     0    0      0     0   0   0    0     0    0      1     0       0
10    0    0      0     0   0   0    0     0    0      0     0       0
11    0    0      0     1   0   0    0     0    0      0     0       0
12    0    0      0     0   0   0    0     0    0      0     0       0
13    0    0      0     0   0   0    0     0    0      0     0       0
14    0    0      0     0   0   0    0     0    0      0     0       0
15    0    0      0     0   0   0    0     0    0      0     0       0
16    0    0      0     0   0   0    0     0    0      0     1       0
17    0    0      0     0   0   0    0     0    1      0     0       0
18    0    0      0     0   0   0    0     0    0      0     0       0
19    0    0      0     0   0   0    0     0    0      0     0       0
20    0    0      0     0   0   0    0     0    0      0     0       0
   shuttle similar since skills slow smart smartest social software
1        0       0     0      0    0     0        0      0        0
2        0       0     0      0    0     1        0      0        0
3        0       0     0      0    0     0        0      0        0
4        0       0     0      0    0     0        0      0        0
5        0       0     0      0    0     0        0      0        0
6        0       0     0      0    0     1        0      0        0
7        0       0     0      0    0     0        0      0        0
8        0       0     0      0    0     0        0      0        0
9        0       0     0      0    0     0        0      0        0
10       0       0     0      0    0     0        0      0        0
11       0       0     0      0    0     0        0      0        0
12       0       0     0      0    0     1        0      0        0
13       0       0     0      0    0     0        0      0        0
14       0       0     0      0    0     0        0      0        0
15       0       0     0      0    0     1        0      0        0
16       0       0     0      0    0     0        0      0        0
17       0       0     0      0    0     1        0      0        0
18       0       0     0      0    0     0        0      0        0
19       0       0     0      0    0     0        0      0        0
20       0       0     0      1    0     0        0      0        1
   someone something sometimes spend start startup still strong structure
1        0         0         0     0     0       0     0      0         0
2        0         0         0     0     0       0     0      0         0
3        0         0         0     0     0       0     0      0         0
4        0         0         0     0     0       0     0      0         0
5        0         0         0     0     0       0     0      0         0
6        0         0         0     0     0       0     0      0         0
7        0         0         0     0     0       0     0      0         0
8        0         0         0     0     0       0     0      0         0
9        0         0         0     0     0       0     0      0         0
10       0         0         0     0     0       0     0      0         0
11       0         0         0     0     0       0     0      1         0
12       0         0         0     0     0       0     0      0         0
13       0         1         0     0     0       0     0      0         0
14       0         0         0     0     0       0     0      0         0
15       0         0         0     0     0       0     0      0         0
16       0         0         0     0     0       0     0      0         0
17       0         0         0     0     0       0     0      0         0
18       0         0         0     0     0       0     0      0         0
19       0         0         0     0     0       0     0      0         0
20       0         0         0     0     0       0     0      0         0
   stuff style super sure surrounded system take talent talented talk team
1      0     0     0    0          0      0    0      0        0    0    0
2      0     0     0    0          0      0    0      0        0    0    0
3      0     0     0    0          0      0    0      0        0    0    0
4      0     0     0    0          0      0    0      0        0    0    0
5      0     0     0    0          0      0    0      0        0    0    0
6      0     0     0    0          0      0    0      0        0    0    0
7      0     0     0    0          0      0    0      0        0    0    0
8      0     0     0    0          0      0    0      0        0    0    0
9      0     0     0    0          0      0    0      0        0    0    0
10     0     0     0    0          0      0    0      0        0    0    0
11     0     0     0    0          0      0    0      0        0    0    0
12     0     0     0    0          0      0    0      0        0    0    1
13     0     0     0    0          1      0    0      0        0    0    0
14     0     0     0    0          0      0    0      0        0    0    0
15     0     0     0    0          0      0    0      0        0    0    0
16     0     0     0    0          0      0    0      0        0    0    0
17     0     0     0    0          0      0    0      0        0    0    0
18     0     0     0    0          0      0    0      0        0    0    0
19     0     0     0    1          0      0    0      0        0    0    0
20     0     0     0    0          0      1    0      0        0    0    0
   teams tech technology theres thing things think thinking though time
1      0    0          0      0     0      0     0        0      0    0
2      0    0          0      0     0      0     0        0      0    0
3      0    0          0      0     0      0     0        0      0    0
4      0    0          0      0     0      0     0        0      0    0
5      0    0          0      0     0      0     0        0      0    0
6      0    0          0      0     0      0     0        0      0    0
7      0    1          1      0     0      0     0        0      0    0
8      0    0          0      0     0      0     0        0      0    0
9      0    0          0      0     0      0     0        0      0    0
10     0    0          0      0     0      0     0        0      0    0
11     0    0          0      0     0      0     0        0      0    0
12     0    0          0      0     0      0     0        0      0    0
13     0    0          0      0     0      0     0        0      0    0
14     0    0          0      0     0      0     0        0      0    0
15     0    0          0      1     0      0     1        0      0    0
16     0    0          0      0     0      0     0        0      0    0
17     0    0          0      0     0      0     0        0      0    0
18     0    0          0      0     0      0     0        0      0    0
19     0    0          0      0     0      1     0        0      0    0
20     0    0          0      0     1      0     0        0      0    0
   tools top transparency transparent treated truly try unless use used
1      0   0            0           0       0     0   0      0   0    0
2      0   0            0           0       0     0   0      0   0    0
3      0   0            0           0       0     1   0      0   0    0
4      0   0            0           0       0     0   0      0   0    0
5      0   0            0           0       0     0   0      0   0    0
6      0   0            0           0       0     0   0      0   0    0
7      0   0            0           0       0     0   0      0   0    0
8      0   0            0           0       0     0   0      0   0    0
9      0   0            0           0       0     0   0      0   0    0
10     0   0            0           0       0     0   0      0   0    0
11     0   0            0           0       0     0   0      0   0    0
12     0   0            0           0       0     0   0      0   0    0
13     0   0            0           0       0     0   0      0   0    0
14     0   0            0           0       0     0   0      0   0    0
15     0   0            0           0       0     0   0      0   0    0
16     0   0            0           0       0     0   0      0   0    0
17     0   0            0           0       0     0   0      0   0    0
18     0   0            0           0       0     0   0      0   0    0
19     1   0            0           0       1     0   0      0   0    0
20     0   0            0           0       0     0   0      0   0    0
   values variety want way well whats will willing within without
1       0       0    0   0    0     0    0       1      0       0
2       0       0    0   0    0     0    0       0      0       0
3       0       1    0   0    0     0    0       0      0       0
4       0       0    1   0    0     0    0       0      0       0
5       0       0    1   0    0     0    0       0      0       0
6       0       0    0   0    0     0    0       0      0       0
7       0       0    0   0    0     0    0       0      0       0
8       0       0    0   0    1     0    0       0      0       0
9       0       0    0   0    0     0    0       0      0       0
10      0       0    0   0    1     0    0       0      0       0
11      0       0    0   0    0     0    0       0      0       0
12      0       0    0   0    1     0    0       0      0       0
13      0       0    0   1    0     0    0       0      0       0
14      0       0    0   0    0     0    0       0      0       0
15      0       0    0   0    0     0    0       0      0       0
16      0       0    0   0    1     0    0       0      0       0
17      0       0    0   0    0     0    0       0      0       0
18      0       0    0   0    0     0    0       0      0       0
19      0       0    1   0    1     0    0       0      0       0
20      0       0    0   0    0     0    0       0      0       0
   wonderful work worked working worklife works world year years yet youll
1          0    1      1       0        0     1     1    0     0   0     0
2          0    2      0       0        0     0     0    0     0   0     0
3          0    0      0       0        0     0     0    0     0   0     0
4          0    1      0       0        0     0     0    0     0   0     0
5          0    0      0       0        0     0     0    0     0   0     0
6          0    1      0       0        0     0     0    0     0   0     0
7          0    0      0       1        0     0     0    0     0   0     0
8          0    3      0       0        0     0     0    0     0   0     0
9          0    0      0       0        0     0     0    0     0   0     0
10         0    1      0       0        0     0     1    0     0   0     0
11         0    1      0       0        0     0     1    0     0   0     0
12         0    0      0       1        0     0     0    0     0   0     0
13         0    0      1       0        0     0     0    0     0   0     0
14         0    0      0       0        0     0     0    0     0   0     0
15         0    2      0       0        0     0     0    0     0   0     0
16         0    1      0       0        0     0     0    0     0   0     0
17         0    0      0       0        0     0     1    0     0   0     0
18         0    0      0       0        0     0     0    0     0   0     0
19         0    3      0       2        0     0     0    0     0   0     0
20         0    1      0       1        0     0     0    0     0   0     0
   young youre
1      0     0
2      0     0
3      0     0
4      0     0
5      0     0
6      0     0
7      0     0
8      0     0
9      0     0
10     0     0
11     0     0
12     0     0
13     0     0
14     0     0
15     0     0
16     0     0
17     0     0
18     0     0
19     0     0
20     0     0
```

Step 8 Sentiment analysis - model creation and validation
========================================================


```r
# form the data set

df_txt %<>% cbind(Attrition=df2$Attrition)
```

```r
# split data set into training and testing set.

train_index <- 
  createDataPartition(df_txt$Attrition,
                      times=1,
                      p=.7) %>%
  unlist()

df_txt_train <- df_txt[train_index, ]
df_txt_test <- df_txt[-train_index, ]
```

Step 8 Sentiment analysis - model creation and validation (Cont'd)
========================================================


```r
# model building

model_sent <- train(Attrition ~ .,
                    df_txt_train,
                    method="svmRadial",
                    trainControl=tc)
```

Step 8 Sentiment analysis - model creation and validation (Cont'd)
========================================================


```r
# model evaluation

prediction <- predict(model_sent, newdata=select(df_txt_test, -Attrition))

confusionMatrix(prediction,
                reference=df_txt_test$Attrition,
                positive="Yes")
```

```
Confusion Matrix and Statistics

          Reference
Prediction No Yes
       No  86  13
       Yes  4  47
                                          
               Accuracy : 0.8867          
                 95% CI : (0.8248, 0.9326)
    No Information Rate : 0.6             
    P-Value [Acc > NIR] : 7.124e-15       
                                          
                  Kappa : 0.7578          
 Mcnemar's Test P-Value : 0.05235         
                                          
            Sensitivity : 0.7833          
            Specificity : 0.9556          
         Pos Pred Value : 0.9216          
         Neg Pred Value : 0.8687          
             Prevalence : 0.4000          
         Detection Rate : 0.3133          
   Detection Prevalence : 0.3400          
      Balanced Accuracy : 0.8694          
                                          
       'Positive' Class : Yes             
                                          
```

Last slide
========================================================
- Employee retention is important.
- DS & ML helps!
- Feedbacks are welcome! 

Le Zhang zhle@microsoft.com
