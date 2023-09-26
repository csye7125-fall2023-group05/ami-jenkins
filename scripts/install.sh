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
sudo apt update --quiet && sudo apt upgrade -y

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                               INSTALL JAVA 11                                                           |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Install Java for Jenkins
sudo sudo apt install openjdk-11-jdk -y

# Validate Java installation
JAVA=$?
if [ $JAVA -eq 0 ]; then
  echo "Successfully installed Java"
else
  echo "Unable to install Java"
fi

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                             CHECK JAVA VERSION                                                          |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Check Java version
echo "Java $(java -version)"

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                                INSTALL JENKINS                                                          |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Update local package index
sudo apt update --quiet

# Debian package repository of Jenkins to automate installation and upgrade.
# To use this repository, first add the key to the system:
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc >/dev/null

# Add a Jenkins apt repository entry:
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list >/dev/null

# Update local package index, then finally install Jenkins:
sudo apt update --quiet
sudo apt install jenkins -y

# Validate Jenkins installation
JENKINS=$?
if [ $JENKINS -eq 0 ]; then
  echo "Successfully installed Jenkins"
else
  echo "Unable to install Jenkins"
fi

# Check the status of Jenkins service
sudo systemctl status jenkins

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           CHECK JENKINS VERSION                                                         |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Check Jenkins version
echo "Jenkins $(jenkins --version)"

# Caddy Setup
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                               INSTALL CADDY                                                             |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Update local package index
sudo apt update --quiet

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo \
  gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee \
  /etc/apt/sources.list.d/caddy-stable.list

# Update local package index, then finally install caddy:
sudo apt update --quiet
sudo apt install caddy -y

# Validate caddy installation:
CADDY=$?
if [ $CADDY -eq 0 ]; then
  echo "Successfully installed the Caddy Service"
else
  echo "Unable to install the Caddy Service"
fi
