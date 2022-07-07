
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

/* source "virtualbox-iso" "proxmox-focal-jenkins" {
  boot_command            = ["<enter><enter><f6><esc><wait> ", "autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<enter><wait>"]
  boot_wait               = "5s"
  disk_size               = 15000
  guest_additions_mode    = "disable"  
  guest_os_type           = "Ubuntu_64"
  http_directory          = "subiquity/http"
  http_port_max           = 9200
  http_port_min           = 9001
  iso_checksum            = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
  iso_urls                = ["http://mirrors.kernel.org/ubuntu-releases/20.04.4/ubuntu-20.04.4-live-server-amd64.iso"]  
  shutdown_command        = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_wait_timeout        = "1200s"
  ssh_password            = "${var.SSHPW}"
  ssh_timeout             = "20m"
  ssh_username            = "vagrant"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--memory", "${var.memory_amount}"]]
  vm_name                 = "proxmox-focal-jenkins"
  headless                = "${var.headless_build}"
} */

################################################################
# This script will build Proxmox Templates for the Proxmox Cloud 
# Platform
# Template Documentation for Packer is here:
# https://www.packer.io/docs/builders/proxmox/iso
#################################################################

#################################################################
# Packer init command to get the latest proxmox plugin
# run the command:  packer init . 
# do this before you run the command: packer build .
#################################################################
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.5"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

#################################################################
# Build for Ubuntu Focal 20.04 Nginx LoadBalancer template
# https://www.packer.io/docs/builders/proxmox/iso
#################################################################

#################################################################
# Build for Ubuntu Focal 20.04 Database Server
# https://www.packer.io/docs/builders/proxmox/iso
#################################################################
source "proxmox-iso" "proxmox-focal-jenkins" {
  boot_command = ["<enter><enter><f6><esc><wait> ", "autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<enter><wait>"]
  boot_wait    = "5s"
  cores        = "${var.NUMBEROFCORES}"
  node         = "${var.NODENAME}"
  username     = "${var.USERNAME}"
  token        = "${var.PROXMOX_TOKEN}"
  cpu_type     = "host"
  disks {
    disk_size         = "${var.DISKSIZE}"
    storage_pool      = "${var.STORAGEPOOL}"
    storage_pool_type = "lvm"
    type              = "virtio"
  }
  http_directory   = "subiquity-proxmox/http"
  http_port_max    = 9200
  http_port_min    = 9001
  iso_checksum     = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
  iso_urls         = ["http://mirrors.kernel.org/ubuntu-releases/20.04.4/ubuntu-20.04.4-live-server-amd64.iso"]
  iso_storage_pool = "local"
  memory           = "${var.MEMORY}"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  network_adapters {
    bridge = "vmbr1"
    model  = "virtio"
  }
  network_adapters {
    bridge = "vmbr2"
    model  = "virtio"
  }
  os                       = "l26"
  proxmox_url              = "${var.URL}"
  insecure_skip_tls_verify = true
  unmount_iso              = true
  qemu_agent               = true
  cloud_init               = true
  cloud_init_storage_pool  = "local"
  ssh_password             = "vagrant"
  ssh_username             = "${var.SSHPW}"
  ssh_timeout              = "20m"
  ssh_wait_timeout         = "1200s"
  template_description     = "A Packer template to create a Focal database"
  vm_name                  = "${var.NAME}"
}

build {
  sources = ["source.proxmox-iso.proxmox-focal-jenkins"]


  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    script          = "../scripts/proxmox/post_install_prxmx_ubuntu_2004.sh"
  } 

  ########################################################################################################################
  # Add .hcl configuration file to register the systems DNS - base template
  ########################################################################################################################

  provisioner "file" {
    source      = "./system.hcl"
    destination = "/home/vagrant/"
  
  }

  ########################################################################################################################
  # Insert the Android SDK Tools
  ########################################################################################################################

  provisioner "file" {
    source      = "./commandlinetools-linux-8512546_latest.zip"
    destination = "/home/vagrant/"
  }

   provisioner "file" {
    source = "./id_ed25519_build_server_key"
    destination = "/home/vagrant/.ssh/"
  }

  ########################################################################################################################
  # Add a post_install_iptables-dns-adjustment.sh to the system for consul dns lookup adjustment to the iptables
  ########################################################################################################################

  provisioner "file" {
    source      = "../scripts/proxmox/post_install_iptables-dns-adjustment.sh"
    destination = "/home/vagrant/"
  
  }
  
  ########################################################################################################################
  # Command to move dns-adjustment script so the Consul DNS service will start on boot/reboot
  ########################################################################################################################

  provisioner "shell" {
    inline = [
      "sudo mv /home/vagrant/post_install_iptables-dns-adjustment.sh /etc",
      "sudo chmod u+x /etc/post_install_iptables-dns-adjustment.sh"
    ]
  }

  ########################################################################################################################
  # This is the script that will open the default firewall ports, all ports except 22, 8301, and 8500 are locked down
  # by default.  Edit this script if you want to open additional ports
  ########################################################################################################################

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    scripts         = ["../scripts/proxmox/post_install_prxmx-firewall-configuration.sh"]
    
  }

  ########################################################################################################################
  # Scripts needed to setup internal DNS -- do not edit
  ########################################################################################################################

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    scripts         = ["../scripts/proxmox/post_install_prxmx_start-cloud-init.sh", 
                       "../scripts/proxmox/post_install_prxmx-ssh-restrict-login.sh", 
                       "../scripts/proxmox/post_install_prxmx_install_hashicorp_consul.sh", 
                       "../scripts/proxmox/post_install_prxmx_update_dns_to_use_systemd_for_consul.sh"]
  
  }

  ########################################################################################################################
  # Script to change the bind_addr in Consul to the dynmaic Go lang call to
  # Interface ens18
  # https://www.consul.io/docs/troubleshoot/common-errors
  ########################################################################################################################
  
  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    scripts         = ["../scripts/proxmox/post_install_change_consul_bind_interface.sh"]
  
  }

  ############################################################################################
  # Script to give a dynamic message about the consul DNS upon login
  #
  # https://ownyourbits.com/2017/04/05/customize-your-motd-login-message-in-debian-and-ubuntu/
  #############################################################################################
  
  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    scripts         = ["../scripts/proxmox/post_install_update_dynamic_motd_message.sh"]
  }
   
}
