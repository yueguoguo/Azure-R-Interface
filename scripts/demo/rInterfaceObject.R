# ----------------------------------------------------------------------
# Azure Virtual Machine R Interface
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le
# CONTRIBUTORS:       Zhang Le
# DATE OF CREATION:   11-02-2016
# DEPARTMENT:         IMML & ADS Asia
# COMPANY:            Microsoft
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Main definition of the object.
# ----------------------------------------------------------------------
rInterface <- setClass(
  # Set the name of the class
  "rInterface",
  
  representation(
    remote = "character",
    user = "character",
    script = "character",
    config = "list"
  ),
  
  prototype(
    remote = character(0),
    user = character(0),
    script = character(0),
    config = NULL
  )
)

# ----------------------------------------------------------------------
# Assign the values to the rInterface object.
# ----------------------------------------------------------------------
setGeneric(name = "riSet",
           def = function(object,
                          remote,
                          user,
                          script,
                          config
                          ) {
             standardGeneric("riSet")
           }
)

setMethod(f = "riSet",
          signature = "rInterface",
          definition = function(object,
                                remote = "",
                                user = "",
                                script = "",
                                config = ""
                                ) {
            if(!missing(remote)) object@remote <- remote
            if(!missing(user)) object@user <- user
            if(!missing(script) && file.exists(script)) {
              object@script <- script
            }
            if(!missing(config)) object@config <- config
             
            return(object)
          }
)
 
# ----------------------------------------------------------------------
# Configure the rInterface object.
# ----------------------------------------------------------------------
setGeneric(name = "riConfig",
           def = function(object,
                          machine.list,
                          dns.list,
                          machine.user,
                          master,
                          slaves,
                          data,
                          context) {
             standardGeneric("riConfig")
           }
)

setMethod(f = "riConfig",
          signature = "rInterface",
          definition = function(object,
                                machine.list,
                                dns.list,
                                machine.user,
                                master,
                                slaves,
                                data,
                                context
          ) {
            # assign argument values to the config list.
            object@config <- list(
              RI_MACHINES = ifelse(!missing(machine.list), list(machine.list), ""),
              RI_DNS = ifelse(!missing(dns.list), list(dns.list), ""),
              RI_VMUSER = ifelse(!missing(machine.user), list(machine.user), ""),
              RI_MASTER = ifelse(!missing(master), list(master), ""),
              RI_SLAVES = ifelse(!missing(slaves), list(slaves), ""),
              RI_DATA = ifelse(!missing(data), list(data), ""),
              RI_CONTEXT = ifelse(!missing(context), list(context), "")
            )
            
            return(object)
          }
)

# ----------------------------------------------------------------------
# Dump out the content of the rInterface object.
# ----------------------------------------------------------------------
setGeneric(name = "riDump",
           def = function(object) {
             standardGeneric("riDump")
           }
)

setMethod(f = "riDump",
          signature = "rInterface",
          definition = function(object) {
            cat(
              sprintf("---------------------------------------------------------------------------"),
              sprintf("r Interface information"),
              sprintf("---------------------------------------------------------------------------"),
              sprintf("The R script to be executed:\t%s.", shQuote(object@script)),
              sprintf("The remote host:\t\t%s.", shQuote(object@remote)),
              sprintf("The login user name:\t\t%s.", shQuote(object@user)),
              sprintf("---------------------------------------------------------------------------"),
              sprintf("The configuration of the interface is:"),
              # sprintf("virtual machines: %s", ifelse(!is.na(object@config$RI_MACHINES), object@config$RI_MACHINES, "N/A")),
              sprintf("virtual machines\t\t %s", unlist(object@config$RI_MACHINES)),
              sprintf("dns list\t\t\t %s", unlist(object@config$RI_DNS)),
              sprintf("user to these machines\t\t %s", unlist(object@config$RI_VMUSER)),
              sprintf("the master node\t\t\t %s", unlist(object@config$RI_MASTER)),
              sprintf("the slave nodes\t\t\t %s", unlist(object@config$RI_SLAVES)),
              sprintf("the data source\t\t\t %s", unlist(object@config$RI_DATA)),
              sprintf("the computing context\t\t %s", unlist(object@config$RI_CONTEXT)),
              sprintf("---------------------------------------------------------------------------"),
              sprintf("# End of information session"),
              sprintf("---------------------------------------------------------------------------"),
              sep = "\n"
            )
          })

# ----------------------------------------------------------------------
# Initialize a new worker script.
# ----------------------------------------------------------------------
setGeneric(name = "riNewScript",
           def = function(path, title) {
             standardGeneric("riNewScript")
           }
)

setMethod(f = "riNewScript",
          definition = function(path = ".", title = "worker_new.R") {
            notes <-
              sprintf(
                paste(
                  "\n# ---------------------------------------------------------------------------",
                  "# Your worker script starts from here ... ",
                  "# ---------------------------------------------------------------------------\n",
                  sep = "\n"
                )
              )
            if (missing(path) || missing(title)) {
              stop(sprintf("A default script named %s located at %s is created.", title, path))
            }
            
            cat(notes, file = file.path(path, title))
            writeLines(
              sprintf("Worker script %s is created at location %s.", title, ifelse(path == ".", "work directory", path))
            )
          }
)
  
# ----------------------------------------------------------------------
# Worker script.
# ----------------------------------------------------------------------
setGeneric(name = "riScript",
           def = function(object) {
             standardGeneric("riScript")
           }
)

setMethod(f = "riScript",
          signature = "rInterface",
          definition = function(object) {
            if (!file.exists(object@script) || length(object@script) == 0) {
              stop("The script does not exist or is not specified! Consider create a new one using riNewScript.")
            }
            
            codes.body <- readLines(con = object@script)
            # remove the header.
            if (codes.body[2] == "# THIS IS A HEADER ADDED BY R INTERFACE") {
            head.start <- which(codes.body == "# THIS IS A HEADER ADDED BY R INTERFACE")
            head.end <- which(codes.body == "# END OF THE HEADER ADDED BY R INTERFACE")
            codes.body <- codes.body[-((head.start - 1):(head.end + 1))]
            }
            
            # add context-specific info into header.
            codes.head <- paste(
              "# ---------------------------------------------------------------------------",
              "# THIS IS A HEADER ADDED BY R INTERFACE",
              "# ---------------------------------------------------------------------------",
              sep = "\n"
            )
            
            if (object@config$RI_CONTEXT == "clusterParallel") {
              codes.head <- paste(
                codes.head,
                paste("RI_MACHINES <-", "c(", paste(shQuote(unlist(object@config$RI_MACHINES)), collapse = ", "), ")"),
                paste("RI_DNS <-", "c(", paste(shQuote(unlist(object@config$RI_DNS)), collapse = ", "), ")"),
                paste("RI_VMUSER <-", "c(", paste(shQuote(unlist(object@config$RI_VMUSER)), collapse = ", "), ")"),
                paste("RI_MASTER <-", "c(", paste(shQuote(unlist(object@config$RI_MASTER)), collapse = ", "), ")"),
                paste("RI_SLAVES <-", "c(", paste(shQuote(unlist(object@config$RI_SLAVES)), collapse = ", "), ")"),
                paste("RI_DATA <-", paste(shQuote(unlist(object@config$RI_DATA)), collapse = ", ")),
                paste("RI_CONTEXT <-", paste(shQuote(unlist(object@config$RI_CONTEXT)), collapse = ", ")),
                "\nlibrary(RevoScaleR)",
                "# --------- Set compute context",
                "cl <- makePSOCKcluster(names = RI_SLAVES, master = RI_MASTER, user = RI_VMUSER)",
                "registerDoParallel(cl)",
                "rxSetComputeContext(RxForeachDoPar())",
                "# --------- Load data.",
                "download.file(url = RI_DATA, destfile = './data.csv')",
                "riData <- read.csv('./data.csv', header = T, sep = ',', stringAsFactor = F)",
                "# ---------------------------------------------------------------------------",
                "# END OF THE HEADER ADDED BY R INTERFACE",
              "# ---------------------------------------------------------------------------\n",
                sep = "\n"
              )
            } else if (object@config$RI_CONTEXT == "Hadoop") {
              codes.head <- paste(
                codes.head,
                "This is for Hadoop.",
                "\n"
              )
            } else if (object@config$RI_CONTEXT == "Spark") {
              codes.head <- paste(
                codes.head,
                paste("RI_DNS <-", "c(", paste(shQuote(unlist(object@config$RI_DNS)), collapse = ", "), ")"),
                paste("RI_VMUSER <-", "c(", paste(shQuote(unlist(object@config$RI_VMUSER)), collapse = ", "), ")"),
                paste("RI_MASTER <-", "c(", paste(shQuote(unlist(object@config$RI_MASTER)), collapse = ", "), ")"),
                paste("RI_SLAVES <-", "c(", paste(shQuote(unlist(object@config$RI_SLAVES)), collapse = ", "), ")"),
                paste("RI_DATA <-", paste(shQuote(unlist(object@config$RI_DATA)), collapse = ", ")),
                paste("RI_CONTEXT <-", paste(shQuote(unlist(object@config$RI_CONTEXT)), collapse = ", ")),
                "\nlibrary(RevoScaleR)",
                "# --------- Set compute context",
                "myHadoopCluster <- RxSpark(persistentRun = TRUE, idleTimeOut = 600)",
                "rxSetComputeContext(myHadoopCluster)",
                "# --------- Load data.",
                "download.file(url = RI_DATA, destfile = './data.csv')",
                "riData <- read.csv('./data.csv', header = T, sep = ',', stringAsFactor = F)",
                "bigDataDirRoot <- '/share'",
                "inputDir <- file.path(bigDataDirRoot, 'riBigData')",
                "rxHadoopMakeDir(inputDir)",
                "rxHadoopCopyFromLocal('./data.csv', inputDir)",
                "hdfsFS <- RxHdfsFileSystem()",
                "riTextData <- RxTextData(file = inputDir, fileSystem = hdfsFS)",
                "# ---------------------------------------------------------------------------",
                "# END OF THE HEADER ADDED BY R INTERFACE",
              "# ---------------------------------------------------------------------------\n",
                sep = "\n"
              )
            } else if (object@config$RI_CONTEXT == "Teradata") {
              codes.head <- paste(
                codes.head,
                "This is for Teradata.",
                "\n"
              )
            } else if (object@config$RI_CONTEXT == "localParallel") {
              codes.head <- paste(
                codes.head,
                paste("RI_MACHINES <-", "c(", paste(shQuote(unlist(object@config$RI_MACHINES)), collapse = ", "), ")"),
                paste("RI_DNS <-", "c(", paste(shQuote(unlist(object@config$RI_DNS)), collapse = ", "), ")"),
                paste("RI_VMUSER <-", "c(", paste(shQuote(unlist(object@config$RI_VMUSER)), collapse = ", "), ")"),
                paste("RI_MASTER <-", "c(", paste(shQuote(unlist(object@config$RI_MASTER)), collapse = ", "), ")"),
                paste("RI_SLAVES <-", "c(", paste(shQuote(unlist(object@config$RI_SLAVES)), collapse = ", "), ")"),
                paste("RI_DATA <-", paste(shQuote(unlist(object@config$RI_DATA)), collapse = ", ")),
                paste("RI_CONTEXT <-", paste(shQuote(unlist(object@config$RI_CONTEXT)), collapse = ", ")),
                "\nlibrary(RevoScaleR)",
                "library(doParallel)",
                "# --------- Set compute context",
                "rxSetComputeContext(RxLocalParallel())",
                "# --------- Load data.",
                "download.file(url = RI_DATA, destfile = './data.csv')",
                "riData <- read.csv('./data.csv', header = T, sep = ',', stringAsFactor = F)",
                "# ---------------------------------------------------------------------------",
                "# END OF THE HEADER ADDED BY R INTERFACE",
              "# ---------------------------------------------------------------------------\n",
                sep = "\n"
              )
            } else {
              stop("Specify a context from \"localParallel\", \"clusterParallel\", \"Hadoop\", \"Spark\", or \"Teradata\".")
            }
            
            cat(codes.head, file = object@script)
            cat(codes.body, file = object@script, sep = "\n", append = TRUE)
          }
)

# ----------------------------------------------------------------------
# Execute the R script.
# ----------------------------------------------------------------------
setGeneric(name = "riExecute",
           def = function(object,
                          roptions,
                          verbose) {
             standardGeneric("riExecute")
           }
)

setMethod(f = "riExecute",
          signature = "rInterface",
          definition = function(object,
                                roptions,
                                verbose) {
            
            # add header.
            riScript(object)
            
            # upload the script to the VM node.
            exe <- system(paste("scp ", object@script, " ", object@user, "@", object@remote, ":~/script.R", sep = ""), show.output.on.console = FALSE)
            if (is.null(attributes(exe))) {
              writeLines(sprintf("File %s is successfully uploaded on %s@%s.", object@script, object@user, object@remote))
            } else {
              writeLines("Something must be wrong....... See warning message.")
            }
            
            # Execution of the script.
            exe <- system(paste("ssh", paste(object@user, "@", object@remote, sep = ""), "Rscript", roptions, "script.R", sep = " "), intern = TRUE, show.output.on.console = TRUE)
            if (is.null(attributes(exe))) {
              writeLines(sprintf("File %s is successfully executed on %s@%s.", object@script, object@user, object@remote))
            } else {
              writeLines("Something must be wrong....... See warning message.")
            }
            
            if (!missing(verbose)) {
              if (verbose == TRUE) writeLines(exe)
            }
          }
)