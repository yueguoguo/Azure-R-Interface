# This is a function to customize the template of VM deployment
json_gen <- function(dns.label, user.name, public.key) {
  # Arguments:
  #   dns_label (string): DNS name label for the public IP address.
  #   public_key (string): public key for authentication purpose.
  #   user.name (string): user name for the VM.
  
  # Global vars.
  DNS_LABEL <- dns.label
  USER_NAME <- user.name
  PUB_KEY <- public.key
  KEY_PATH <- paste("/home/", USER_NAME, "/.ssh/authorized_keys", sep = "")
  
  # Load the default template json from the remote github repo.
  rj <- readLines("https://raw.githubusercontent.com/yueguoguo/azure_linuxdsvm/master/templates/template_ssh.json") # template url.
  # rj <- readLines("C:/Users/zhle/OneDrive - Microsoft/work/projects/data_science_virtual_machine/github/azure_linuxdsvm/temp.json") # template url.
  
  # Edit the DNS label.
  if(all(str_detect(rj, "\"dsvm_dns_label\"") == FALSE)) {
    stop("'dsvm_dns_label' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_dns_label\"", paste("\"", DNS_LABEL, "\"", sep = ""), rj)
  }
  
  # Edit the user name.
  if(all(str_detect(rj, "\"dsvm_username\"") == FALSE)) {
    stop("'dsvm_username' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_username\"", paste("\"", USER_NAME, "\"", sep = ""), rj)
  }
  
  # Edit the public key path.
  if(all(str_detect(rj, "\"dsvm_key_path\"") == FALSE)) {
    stop("'dsvm_key_path' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_key_path\"", paste("\"", KEY_PATH, "\"", sep = ""), rj)
  }
  
  # Edit the public key.
  if(all(str_detect(rj, "\"dsvm_public_key\"") == FALSE)) {
    stop("'dsvm_public_key' not found! Try to use a general template.")
  } else {
    rj <- gsub("\"dsvm_public_key\"", paste("\"", PUB_KEY, "\"", sep = ""), rj)
  }
  
  return(rj)
}
  
# Set up parameters for the json template.
DNS_LABEL <- "somedsvm"
USER_NAME <- "someuser"
PUB_KEY <- "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNueGaJyZRDOxJPdy307nK6lu1Sd8dpZirR7EIeUQVunsm6OhKRv3BTsPUV7nyCXTka40TzzjAGbV1xL0Sx92A8HZv3mQf+2lIY6sIYGfbvqZVTCktR/ax5k6EYW+PpjIo3x4eqBUtOQg6yHD/yCoNtnaq+8rhZBxG5ZMAC8P8o8E6oeTyoVMver+F3nG1Gq18/25H5O8DLW8HQpzoB/FD1ZSnkL0iiu5PvF5/FchVgYsPmmTihSltLoO2DWZudE6lPR0L0nkKoTUvEqZARHDxUylD+cZ44BXpIRLkmgnh7Jg+gjMLFQdI5IZ7NksY9ClNd8iqknXF3pVvB4sLw1VD"

# Output json file path and name.
PATH_JSON <- paste(getwd(), "/github/azure_linuxdsvm", sep = "") # to be my github local repo. 
NAME_JSON <- "some"
  
rj_new <- json_gen(DNS_LABEL, USER_NAME, PUB_KEY)
write(rj_new, paste(PATH_JSON, "/", NAME_JSON, ".json", sep = ""))

# Upload to somewhere as an accessible URL.
# Commit to a remote github repo.
# system(paste("cp", paste(PATH_JSON, NAME_JSON, sep = ""), PATH_GIT, sep = " "))
# system(paste("git -"))