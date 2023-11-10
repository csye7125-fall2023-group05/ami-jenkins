#!/bin/bash
############################################################################################
##                                    install.sh                                          ##
##                  This script installs all the dependencies on the AMI                  ##
## 1. Upgrade the OS packages.                                                            ##
## 2. Install all the application prerequisites, middleware, and runtime.                 ##
############################################################################################

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                           INSTALL SCRIPT v2.0                                                           |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Update packages and dependencies
sudo apt-get update --quiet && sudo apt-get upgrade -y

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                              INSTALL NODEJS                                                             |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# https://github.com/nodesource/distributions#installation-instructions
# Download and import the Nodesource GPG key
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo \
  gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Create a deb repository
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo \
  tee /etc/apt/sources.list.d/nodesource.list

# Run update and install
sudo apt-get update && sudo apt-get install nodejs -y

sleep 3

# Check Node version:
echo "Node $(node --version)"

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                               INSTALL JAVA 11                                                           |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Install Java for Jenkins: (https://adoptium.net/installation/linux/)
sudo apt-get install openjdk-11-jdk -y

sleep 3

# Ensure necessary packages are present:
# sudo apt-get install -y wget apt-transport-https

# Download the Eclipse Adoptium GPG key:
# sudo mkdir -p /etc/apt/keyrings
# wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee \
#   /etc/apt/keyrings/adoptium.asc

# # Configure the Eclipse Adoptium apt repository:
# # To check the full list of versions supported take a look at the list in the tree at https://packages.adoptium.net/ui/native/deb/dists/.
# # For Linux Mint (based on Ubuntu) you have to replace VERSION_CODENAME with UBUNTU_CODENAME.
# echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] \
# https://packages.adoptium.net/artifactory/deb \
# $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee \
#   /etc/apt/sources.list.d/adoptium.list

# # Install the Temurin version you require:
# sudo apt-get update # required to refresh apt with the newly installed keys
# sudo apt-get install temurin-21-jdk -y

# Check Java version:
echo "Java $(java -version)"

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                                INSTALL JENKINS                                                          |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Jenkins setup on Debian (stable): https://pkg.jenkins.io/debian-stable/

# Debian package repository of Jenkins to automate installation and upgrade.
# To use this repository, first add the key to the system:
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc >/dev/null

# Add a Jenkins apt repository entry:
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list >/dev/null

# Install Jenkins:
sudo apt-get update && sudo apt-get install jenkins -y

sleep 3

# Check the status of Jenkins service
sudo systemctl --full status jenkins

# Check Jenkins version
echo "Jenkins $(jenkins --version)"

# Caddy Setup
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                               INSTALL CADDY                                                             |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Caddy(stable) installation docs: https://caddyserver.com/docs/install#debian-ubuntu-raspbian

# Install and configure keyring for caddy stable release:
sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo \
  gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee \
  /etc/apt/sources.list.d/caddy-stable.list

# Install caddy:
sudo apt-get update && sudo apt-get install caddy -y

# Check the status of Caddy service
sudo systemctl --full status caddy

# Check Caddy version
echo "Caddy $(caddy --version)"

# Jenkins Configuration
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                          CONFIGURE JENKINS                                                              |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Install Jenkins plugin manager tool:
wget --quiet \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# Install plugins with jenkins-plugin-manager tool:
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt

# Update users and group permissions to `jenkins` for all installed plugins:
cd /var/lib/jenkins/plugins/ || exit
sudo chown jenkins:jenkins ./*

# Move Jenkins files to Jenkins home
cd /home/ubuntu/ || exit
sudo mv jcasc.yaml webapp_seed.groovy webapp_db_seed.groovy webapp_helm_chart_seed.groovy infra_helm_chart_seed.groovy /var/lib/jenkins/

# Update file ownership
cd /var/lib/jenkins/ || exit
sudo chown jenkins:jenkins jcasc.yaml webapp_seed.groovy webapp_db_seed.groovy webapp_helm_chart_seed.groovy infra_helm_chart_seed.groovy

# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jcasc.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

echo "Restarting Jenkins service with JCasC..."
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins

# Docker Setup
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                              INSTALL DOCKER                                                             |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker:
sudo apt-get update && sudo apt-get install docker-ce -y

# Provide relevant permissions
sudo chmod 666 /var/run/docker.sock
sudo usermod -a -G docker jenkins

# Check Docker version
echo "Docker $(docker --version)"
