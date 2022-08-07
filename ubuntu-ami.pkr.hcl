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

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "Blue" {
  ami_name      = "${var.ami_prefix}-Blue-${local.timestamp}"
  instance_type = "t3.small"
  region        = "eu-west-1"
  vpc_id        = "vpc-08116affe7705c0e5"
  subnet_id     = "subnet-0f7f747af8de118ac"
  security_group_id = "sg-06f7049bbea8acb3c"
 

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
  ami_name      = "${var.ami_prefix}-Green-${local.timestamp}"
  instance_type = "t3.small"
  region        = "eu-west-1"
  vpc_id        = "vpc-08116affe7705c0e5"
  subnet_id     = "subnet-0f7f747af8de118ac"
  security_group_id = "sg-06f7049bbea8acb3c"
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