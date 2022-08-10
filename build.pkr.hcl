
variable "image_name" {
  type    = string
  default = "ADACS The Littlest JupyterHub (Ubuntu 20.04 LTS Focal)"
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
  source_image_name = "NeCTAR Ubuntu 20.04 LTS (Focal) amd64"
  ssh_username      = "${var.ssh_user}"
}

build {
  sources = ["source.openstack.tljh-build"]

  provisioner "ansible" {
    host_alias    = "tljh-build"
    only          = ["tljh-build"]
    playbook_file = "playbook.yml"
    user          = "${var.ssh_user}"
  }

}
