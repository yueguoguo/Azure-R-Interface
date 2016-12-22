########################################################################
# Seetings for Managing Azure Resorces
# ----------------------------------------------------------------------
# AUTHORS:            Le Zhang, Graham Williams.
# CONTRIBUTORS:       Le Zhang, Graham Williams.
# DATE OF CREATION:   20161222
# DEPARTMENT:         ADS Asia
# COMPANY:            Microsoft
########################################################################

VM_PUBKEY <- "ssh-rsa AAAAB3NzaC1yc2E...1FD" # OpenSSH compatible public key.
RG        <- "my_dsvm_rg_sea" # Resource group as manually created in Azure.
LOC       <- "southeastasia"  # Data centre location for new resource group.
TID       <- "88bf...011d"    # Tenant ID from app creation in Active Directory.
CID       <- "10e3....d3d1"   # Client ID from app creation in Active Directory.
KEY       <- "u/cc....53hg"   # User key from app creation in Active Directory.
