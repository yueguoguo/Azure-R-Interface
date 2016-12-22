########################################################################
# Customise a template based on a general one.
# ----------------------------------------------------------------------
# AUTHORS:            Zhang Le, Graham Williams.
# CONTRIBUTORS:       Zhang Le, Graham Williams.
# DATE OF CREATION:   20160926
# DEPARTMENT:         ADS Asia Pacific
# COMPANY:            Microsoft
########################################################################

jsonGen <- function(rj, dns_label, user_name, public_key)
{
  # Description:
  #   This is a function to customize the template of VM deployment based
  #   on the base template from github.
  #
  # Arguments:
  #   rj:                   readLines output of template.json from URL.
  #   dns_label (string):   DNS name label for the public IP address.
  #   public_key (string):  public key for authentication purpose.
  #   user_name (string):   user name for the VM.
  
  # Global vars.

  DNS_LABEL <- dns_label
  USER_NAME <- user_name
  PUB_KEY   <- public_key
  KEY_PATH  <- paste0("/home/", user_name, "/.ssh/authorized_keys")

  TEMPLATES <- paste0("https://raw.githubusercontent.com/",
                      "yueguoguo/azure_linuxdsvm/master/templates/")

  
  # Load the default template json from the remote github repo.
  
  if(missing(rj)) {
    rj <- readLines(paste0(TEMPLATES, "template_ssh.json"))
  }
  
  # Edit the DNS label.
                  
  if(all(stringr::str_detect(rj, "\"dsvm_dns_label\"") == FALSE))
  {
    stop("'dsvm_dns_label' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_dns_label\"", paste0("\"", DNS_LABEL, "\""), rj)
  }
  
  # Edit the user name.
  
  if(all(stringr::str_detect(rj, "\"dsvm_username\"") == FALSE))
  {
    stop("'dsvm_username' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_username\"", paste0("\"", user_name, "\""), rj)
  }
  
  # Edit the public key path.
  
  if(all(stringr::str_detect(rj, "\"dsvm_key_path\"") == FALSE))
  {
    stop("'dsvm_key_path' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_key_path\"", paste0("\"", KEY_PATH, "\""), rj)
  }
  
  # Edit the public key.
  
  if(all(stringr::str_detect(rj, "\"dsvm_public_key\"") == FALSE))
  {
    stop("'dsvm_public_key' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_public_key\"", paste0("\"", PUB_KEY, "\""), rj)
  }
  
  return(rj)
}
