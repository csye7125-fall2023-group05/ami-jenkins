#!/bin/bash
############################################################################################
##                                    install.sh                                          ##
##                  This script installs all the dependencies on the AMI                  ##
## 1. Upgrade the OS packages.                                                            ##
## 2. Install all the application prerequisites, middleware, and runtime.                 ##
############################################################################################

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           INSTALL SCRIPT v1.0                                                           |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Update packages and dependencies
sudo apt update && sudo apt upgrade -y


echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           INSTALL JAVA 11                                                        |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Installing Java 
sudo sudo apt install openjdk-11-jdk -y

sleep 3


echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           VALIDATING JAVA 11                                                        |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Validating java version
java -version

sudo apt update

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee   /usr/share/keyrings/jenkins-keyring.asc > /dev/null	

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update 

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           INSTALL JENKINS                                                        |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

sudo apt install jenkins -y

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           VALIDATING JENKINS                                                        |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

jenkins --version

# Caddy Setup
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           INSTALL CADDY                                                        |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

sudo apt-get update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
sleep 3
CADDY=$?  
if [ $CADDY -eq 0 ]; then  #checking if exit code is 0 or not
  echo "Successfully installed the Caddy Service"
else
  echo "Unable to install the Caddy Service"
fi
