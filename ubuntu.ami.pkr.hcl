packer {
  required_plugins {
    git = {
      version = ">= v0.4.3"
      source  = "github.com/ethanmdavidson/git"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "source_ami" {
  type        = string
  description = "Default Ubuntu AMI to build our custom AMI"
  default     = "ami-053b0d53c279acc90" #Ubuntu 22.04 LTS
}

variable "ami_prefix" {
  type        = string
  description = "AWS AMI name prefix"
  default     = "CSYE-7125"
}

variable "ssh_username" {
  type        = string
  description = "username to ssh into the AMI Instance"
  default     = "ubuntu"
}

variable "subnet_id" {
  type        = string
  description = "Subnet of the default VPC"
}

variable "OS" {
  type        = string
  description = "Base operating system version"
  default     = "Ubuntu"
}

variable "ubuntu_version" {
  type        = string
  description = "Version of the custom AMI"
  default     = "22.04 LTS"
}

variable "ami_users" {
  type        = list(string)
  description = "List of users who will access the custom AMI"
}

variable "instance_type" {
  type        = string
  description = "AWS AMI instance type"
  default     = "t2.micro"
}
variable "volume_type" {
  type        = string
  description = "EBS volume type"
  default     = "gp2"
}
variable "volume_size" {
  type        = string
  description = "EBS volume size"
  default     = "50"
}
variable "device_name" {
  type        = string
  description = "EBS device name"
  default     = "/dev/sda1"
}

locals {
  truncated_sha = substr(data.git-commit.cwd-head.hash, 0, 8)
  version       = data.git-repository.cwd.head == "master" && data.git-repository.cwd.is_clean ? var.ubuntu_version : "${var.ubuntu_version}-${local.truncated_sha}"
  timestamp     = substr(regex_replace(timestamp(), "[- TZ:]", ""), 8, 13)
}

data "git-repository" "cwd" {}
data "git-commit" "cwd-head" {}

source "amazon-ebs" "ubuntu" {
  region          = "${var.aws_region}"
  ami_name        = "${var.ami_prefix}-${local.truncated_sha} [${var.ubuntu_version}-${local.timestamp}]"
  ami_description = "Ubuntu AMI for CSYE 7125 built by ${data.git-commit.cwd-head.author}"
  tags = {
    Name         = "${var.ami_prefix}-${local.truncated_sha}"
    Base_AMI_ID  = "${var.source_ami}"
    TimeStamp_ID = "${local.timestamp}"
    OS_Version   = "${var.OS}"
    Release      = "${var.ubuntu_version}"
    Author       = "${data.git-commit.cwd-head.author}"
  }
  ami_regions = [
    "${var.aws_region}",
  ]

  aws_polling {
    delay_seconds = 120
    max_attempts  = 50
  }

  instance_type = "${var.instance_type}"
  source_ami    = "${var.source_ami}"
  ssh_username  = "${var.ssh_username}"
  subnet_id     = "${var.subnet_id}"
  ami_users     = "${var.ami_users}"

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "${var.device_name}"
    volume_size           = "${var.volume_size}"
    volume_type           = "${var.volume_type}"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  # https://www.packer.io/docs/provisioners/file#uploading-files-that-don-t-exist-before-packer-starts
  provisioner "file" {
    source      = "./jenkins/plugins.txt"
    destination = "/home/ubuntu/plugins.txt"
  }

  provisioner "file" {
    source      = "./configs.tgz"
    destination = "/home/ubuntu/configs.tgz"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "CHECKPOINT_DISABLE=1"
    ]
    scripts = [
      "./scripts/install.sh",
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
