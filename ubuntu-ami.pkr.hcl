packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "AMI-BUILD"
}

variable "bldeploy" {
  type    = string
  default = "blue"
}

variable "grdeploy" {
  type    = string
  default = "green"
}

// locals {
//   timestamp = regex_replace(timestamp(), "[- TZ:]", "")
// }


source "amazon-ebs" "Blue" {
  ami_name      = "${var.ami_prefix}-Blue"
  instance_type = "t3.small"
  region        = "eu-west-1"
  vpc_id        = "vpc-0eeacc2d66b989dc1"
  subnet_id     = "subnet-068ab3fcbdaa5269b"
  security_group_id = "sg-04c950d4b41c1cda2"
 

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
    ssh_username = "ubuntu"
    tags = {
      "Name" = "Blue-Server"
    }
  deprecate_at = timeadd(timestamp(), "8766h")
  force_deregister  = "true"
  force_delete_snapshot = "true"
}

build {
  name = "  Blue-packer"
  sources = [
    "source.amazon-ebs.Blue",
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/webserver.yml"
    extra_arguments = ["--extra-vars", "color=${var.bldeploy}"]
  
  }
}

source "amazon-ebs" "Green" {
  ami_name      = "${var.ami_prefix}-Green"
  instance_type = "t3.small"
  region        = "eu-west-1"
  vpc_id        = "vpc-0eeacc2d66b989dc1"
  subnet_id     = "subnet-068ab3fcbdaa5269b"
  security_group_id = "sg-04c950d4b41c1cda2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name" = "Green-Server"
  }
  deprecate_at = timeadd(timestamp(), "8766h")
  force_deregister  = "true"
  force_delete_snapshot = "true"
}

build {
  name = " Green-packer"
  sources = [
    "source.amazon-ebs.Green"
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/webserver.yml"
    extra_arguments = ["--extra-vars", "color=${var.grdeploy}"]
  }
}