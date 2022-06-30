###############################################################################
# These are your proxmox API token credentials (not username and password)
# That will be provided to you
###############################################################################
pm_api_url          = "https://192.168.172.41:8006/api2/json"                             # URL of your Proxmox cluster
pm_api_token_id     = ""                             # This is an API token you have previously created for a specific user
pm_api_token_secret = ""                             # This is a uuid that is only available when initially creating the token 
target_node         = "proxmonster3"                 # Promox node to provision VMs
keypath             = "id_ed25519_proxmox_terraform_deploy_key"     # The path to the private key you need to communicate with your instances
###############################################################################
# Debugging information settings
# No need to change these values
###############################################################################
pm_log_enable       = true                           # Optional; defaults to false) Enable debug logging, see the section below for logging details
pm_parallel         = 4                              # (Optional; defaults to 4) Allowed simultaneous Proxmox processes (e.g. creating resources).
pm_timeout          = 600                            # (Optional; defaults to 300) Timeout value (seconds) for proxmox API calls.
pm_log_file         = "terraform-plugin-proxmox.log" # (Optional; defaults to terraform-plugin-proxmox.log) If logging is enabled, the log file the provider will write logs to.
###############################################################################
# This is a variable to append to your cloud instances so they have a unique
# FQDN -- this is needed for the gossip based DNS to work
###############################################################################
yourinitials = "androidbuildpipeline-ds" # Your team number with leading zeros to add to the vms so they have a unique name
numberofvms        = 1   # quantity of that template to launch
desc       = "Created by Drew Snarski"                    # What is the purpose of the TF template
###############################################################################
# Name the template your created via Packer for Terraform to use to deploy
# instances from
###############################################################################
template_to_clone = "proxmox-focal-jenkins-template"                    # The name of the template to clone
###############################################################################
# Customize instance hardware settings
###############################################################################
memory             = 4096                  # Memory size of a VM
cores              = 1                     # vCPU = cores * sockets
sockets            = 1                     # vCPU = cores * sockets
disk_size          = "35G"                 # Disk size of a VM - min size must equal to the disk size of your clone image
###############################################################################
# This is the consul dns master -- no need to edit this
###############################################################################
consulip           = "192.168.172.33"      # IP address of consul master server
