# These are just example variables
# Actual variables will be created via GitHub organization secrets during the
# CI/CD pipeline execution
ami_prefix     = "CSYE7125"
OS             = "Ubuntu"
ubuntu_version = "22.04 LTS"
ssh_username   = "ubuntu"
source_ami     = "ami-053b0d53c279acc90"
subnet_id      = "subnet-0d3ed39036353594g"
aws_region     = "us-east-1"
instance_type  = "t2.micro"
volume_size    = "8"
volume_type    = "gp2"
device_name    = "/dev/sda1"
ami_users      = ["555431999881", "897161821908"]