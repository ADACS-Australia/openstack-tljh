packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    openstack = {
      version = "~> 1"
      source  = "github.com/hashicorp/openstack"
    }
  }
}

variable "image_name" {
  type    = string
  default = "ADACS The Littlest JupyterHub (Ubuntu 22.04 LTS Jammy)"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

source "openstack" "tljh-build" {
  communicator      = "ssh"
  flavor            = "m3.small"
  image_name        = "${var.image_name}"
  instance_name     = "tljh-build"
  security_groups   = ["default", "SSH"]
  source_image_name = "NeCTAR Ubuntu 22.04 LTS (Jammy) amd64"
  ssh_username      = "${var.ssh_user}"
  image_visibility  = "community"
}

build {
  sources = ["source.openstack.tljh-build"]

  provisioner "ansible" {
    playbook_file = "ansible-jupyterhub/playbook.yml"
    user          = "${var.ssh_user}"
  }

}
