########################################################################
# R-server Interface
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le
# CONTRIBUTORS:       Zhang Le
# DATE OF CREATION:   09-09-2016
# DEPARTMENT:         IMML & ADS Asia
# COMPANY:            Microsoft
########################################################################
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

setGeneric(name = "ri.set",
           def = function(object,
                          remote,
                          user,
                          script,
                          config
                          ) {
             standardGeneric("ri.set")
           }
)

setMethod(f = "ri.set",
          signature = "rInterface",
          definition = function(object,
                                remote,
                                user,
                                script,
                                config
                                ) {
            if(!missing(remote)) object@remote <- remote
            if(!missing(user)) object@user <- user
            if(!missing(script)) object@script <- script
            if(!missing(config)) object@config <- config
             
            return(object)
          }
)

setGeneric(name = "ri.config",
           def = function(object,
                          machine.list,
                          dns.list,
                          machine.user,
                          master,
                          slaves,
                          context) {
             standardGeneric("ri.config")
           }
)

setMethod(f = "ri.config",
          signature = "rInterface",
          definition = function(object,
                                machine.list,
                                dns.list,
                                machine.user,
                                master,
                                slaves,
                                context
          ) {
            # assign argument values to the config list.
            object@config <- list(
              MACHINES = ifelse(!missing(machine.list), list(machine.list), character(0)),
              DNS = ifelse(!missing(dns.list), list(dns.list), character(0)),
              VMUSER = ifelse(!missing(machine.user), list(machine.user), character(0)),
              MASTER = ifelse(!missing(master), list(master), character(0)),
              SLAVES = ifelse(!missing(slaves), list(slaves), character(0)),
              CONTEXT = ifelse(!missing(context), list(context), character(0))
            )
            
            return(object)
          }
)
setGeneric(name = "ri.dump",
           def = function(object) {
             standardGeneric("ri.dump")
           }
)

setMethod(f = "ri.dump",
          signature = "rInterface",
          definition = function(object) {
            cat(
              sprintf("#----------------------------------------------------------------------------------"),
              sprintf("# r Interface information"),
              sprintf("#----------------------------------------------------------------------------------"),
              sprintf("The R script to be executed:\t%s.", shQuote(object@script)),
              sprintf("The remote host:\t\t%s.", shQuote(object@remote)),
              sprintf("The login user name:\t\t%s.", shQuote(object@user)),
              sprintf("#----------------------------------------------------------------------------------"),
              sprintf("The configuration of the interface is:"),
              # sprintf("virtual machines: %s", ifelse(!is.na(object@config$MACHINES), object@config$MACHINES, "N/A")),
              sprintf("virtual machines\t\t %s", unlist(object@config$MACHINES)),
              sprintf("DNS list\t\t\t %s", unlist(object@config$DNS)),
              sprintf("user to these machines\t\t %s", unlist(object@config$VMUSER)),
              sprintf("the master node\t\t\t %s", unlist(object@config$MASTER)),
              sprintf("the slave nodes\t\t\t %s", unlist(object@config$SLAVES)),
              sprintf("the computing context\t\t %s", unlist(object@config$CONTEXT)),
              sprintf("#----------------------------------------------------------------------------------"),
              sprintf("# End of information session"),
              sprintf("#----------------------------------------------------------------------------------"),
              sep = "\n"
            )
          })
  
setGeneric(name = "ri.upload",
           def = function(object) {
             standardGeneric("ri.upload")
           }
)

setMethod(f = "ri.upload",
          signature = "rInterface",
          definition = function(object) {
            if (!file.exists(object@script)) stop("The script does not exist.")
            
            # apply config to the script.
            codes.body <- readLines(con = object@script)
            if (!identical(codes.body[2], "# THIS IS A HEADER ADDED BY R INTERFACE")) {
              codes.head <- paste(
                "# -------------------------------------------------------------------------------------------",
                "# THIS IS A HEADER ADDED BY R INTERFACE",
                "# -------------------------------------------------------------------------------------------",
                sep = "\n"
              )
              if (object@config$CONTEXT == "clusterParallel") {
                codes.head <- paste(
                  codes.head,
                  paste("VM <-", "c(", paste(shQuote(unlist(object@config$MACHINES)), collapse = ", "), ")"),
                  paste("DNS <-", "c(", paste(shQuote(unlist(object@config$DNS)), collapse = ", "), ")"),
                  paste("VMUSER <-", "c(", paste(shQuote(unlist(object@config$VMUSER)), collapse = ", "), ")"),
                  paste("MASTER <-", "c(", paste(shQuote(unlist(object@config$MASTER)), collapse = ", "), ")"),
                  paste("SLAVES <-", "c(", paste(shQuote(unlist(object@config$SLAVES)), collapse = ", "), ")"),
                  paste("CONTEXT <-", "c(", paste(shQuote(unlist(object@config$CONTEXT)), collapse = ", "), ")"),
                  "\nlibrary(RevoScaleR)",
                  "library(doParallel)\n",
                  "cl <- makePSOCKcluster(names = SLAVES, master = MASTER, user = VMUSER)",
                  "registerDoParallel(cl)",
                  "rxSetComputeContext(RxForeachDoPar())",
                  "# -------------------------------------------------------------------------------------------",
                  "# END OF THE HEADER ADDED BY R INTERFACE",
                  "# -------------------------------------------------------------------------------------------\n",
                  sep = "\n"
                )
              } else if (object@config$CONTEXT == "Hadoop") {
                codes.head <- paste(
                  codes.head,
                  "This is for Hadoop.",
                  "\n"
                )
              } else if (object@config$CONTEXT == "Spark") {
                codes.head <- paste(
                  codes.head,
                  "This is for Spark.",
                  "\n"
                )
              } else if (object@config$CONTEXT == "Teradata") {
                codes.head <- paste(
                  codes.head,
                  "This is for Teradata.",
                  "\n"
                )
              } else {
                stop("Specify a context from \"localParallel\", \"clusterParallel\", \"Hadoop\", \"Spark\", or \"Teradata\".")
              }
              
              cat(codes.head, "\n", file = object@script)
              cat(codes.body, "\n", file = object@script, sep = "\n", append = TRUE)
            }
            
            exe <- system(paste("scp ", object@script, " ", object@user, "@", object@remote, ":~/script.R", sep = ""), show.output.on.console = FALSE)
            if (is.null(attributes(exe))) {
              writeLines(sprintf("File %s is successfully uploaded on %s@%s.", object@script, object@user, object@remote))
            } else {
              writeLines("Something must be wrong....... See warning message.")
            }
          }
)

setGeneric(name = "ri.execute",
           def = function(object,
                          roptions,
                          verbose) {
             standardGeneric("ri.execute")
           }
)

setMethod(f = "ri.execute",
          signature = "rInterface",
          definition = function(object,
                                roptions,
                                verbose) {
            
            # Upload the script to the VM node.
            ri.upload(object)
            
            # Execution of the script.
            exe <- system(paste("ssh", paste(object@user, "@", object@remote, sep = ""), "Rscript", roptions, "script.R", sep = " "), intern = TRUE, show.output.on.console = TRUE)
            if (is.null(attributes(exe))) {
              writeLines(sprintf("File %s is successfully executed on %s@%s.", object@script, object@user, object@remote))
            } else {
              writeLines("Something must be wrong....... See warning message.")
            }
            
            if (!missing(verbose)) {
              if (verbose == TRUE) print(exe)
            }
          }
)

# TODO: method to fetch results?