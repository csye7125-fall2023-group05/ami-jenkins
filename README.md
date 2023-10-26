# Jenkins AMI w/ Hashicorp Packer

[![Build custom AMI using Packer](https://github.com/cyse7125-fall2023-group05/ami-jenkins/actions/workflows/packer-build.yml/badge.svg?branch=master)](https://github.com/cyse7125-fall2023-group05/ami-jenkins/actions/workflows/packer-build.yml)

## :package: [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli?in=packer/aws-get-started)

We will build custom AMI (Amazon Machine Image) using Packer from HashiCorp.

### :arrow_heading_down: Installing Packer

Install Packer using Homebrew (only on MacOS):

> For any other distros, please follow the [setup guide in the official docs](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli).

- First, install the HashiCorp tap, a repository of all our Homebrew packages:

```shell
brew tap hashicorp/tap
```

- Now, install Packer with `hashicorp/tap/packer`:

```shell
brew install hashicorp/tap/packer
```

- To update to the latest, run:

```shell
brew upgrade hashicorp/tap/packer
```

- After installing Packer, verify the installation worked by opening a new command prompt or console, and checking that `packer` is available:

```shell
packer
```

> NOTE: If you get an error that packer could not be found, then your PATH environment variable was not set up properly. Please go back and ensure that your PATH variable contains the directory which has Packer installed. Otherwise, Packer is installed and you're ready to go!

### :wrench: Building Custom AMI using Packer

Packer uses Hashicorp Configuration Language(HCL) to create a build template. We'll use the [Packer docs](https://www.packer.io/docs/templates/hcl_templates) to create the build template file.

> NOTE: The file should end with the `.pkr.hcl` extension to be parsed using the HCL2 format.

#### Create the `.pkr.hcl` template

The custom AMI should have the following features:

> NOTE: The builder to be used is `amazon-ebs`.

- **OS:** `Ubuntu 22.04 LTS`
- **Build:** built on the default VPC
- **Device Name:** `/dev/sda1/`
- **Volume Size:** `8GiB`
- **Volume Type:** `gp2`
- Have valid `provisioners`.
- Pre-installed dependencies using a shell script.
- Jenkins pre-installed on the AMI.

#### Shell Provisioners

This will automate the process of updating the OS packages and installing software on the AMI and will have our application in a running state whenever the custom AMI is used to launch an EC2 instance. It should also copy artifacts to the AMI in order to get the application running. It is important to bootstrap our application here, instead of manually SSH-ing into the AMI instance.

Install application prerequisites, middlewares and runtime dependencies here. Update the permission and file ownership on the copied application artifacts.

> NOTE: The file provisioners must copy the application artifacts and configuration to the right location.

#### Custom AMI creation

To create the custom AMI from the `.pkr.hcl` template created earlier, use the commands given below:

- If you're using Packer plugins , run the `init` command first:

```shell
# Installs all packer plugins mentioned in the config template
packer init .
```

- To format the template, use:

```shell
packer fmt .
```

- To validate the template, use:

```shell
# to validate syntax only
packer validate -syntax-only .
# to validate the template as a whole
packer validate -evaluate-datasources .
```

- To build the custom AMI using packer, use:

```shell
packer build <filename>.pkr.hcl
```

#### Packer HCL Variables

To prevent pushing sensitive details to your version control, we can have variables in the `<file-name>.pkr.hcl` file, and then declare the actual values for these variables in another HCL file with the extension `.pkrvars.hcl`.

If you want to validate your build configuration, you can use the following command:

```shell
packer validate -evaluate-datasources --var-file=<variables-file>.pkrvars.hcl <build-config>.pkr.hcl
```

> NOTE: To use the `-evaluate-datasources` parameter, you'll have to update packer to `v1.8.5` or greater. For more details, refer [this issue](https://github.com/hashicorp/packer/issues/12056).

To use this variables files when creating a golden image, use the build command as shown:

```shell
packer build --var-file=<variables-file>.pkrvars.hcl <build-config>.pkr.hcl
```

> NOTE: It is considered best practice to build a custom AMI with variables using HCP Packer!

## ⤵️ Install required software

In order for Jenkins to run it requires `Java`

### ☕️ Java Installation

```bash
# Installing Java
sudo apt update --quiet
sudo apt install openjdk-11-jdk -y
sudo apt update --quiet
# Validate installation
java -version
```

### 💁‍♂️ Jenkins Installation

```bash
# Installing Jenkins

sudo apt update --quiet
# Debian package repository of Jenkins to automate installation and upgrade.
# To use this repository, first add the key to the system:
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc >/dev/null

# Add a Jenkins apt repository entry:
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list >/dev/null

# update local package index and install Jenkins
sudo apt update --quiet
sudo apt install jenkins -y
# check the status of Jenkins
sudo systemctl status jenkins
```

### 📦 NodeJS Installation

```bash
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

# Check Node version:
echo "Node $(node --version)"
```

### 🐳 Docker Installation

```bash
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
```

## 🔒 Configure Caddy Service

```bash
# Install and configure keyring for caddy stable release:
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo \
  gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee \
  /etc/apt/sources.list.d/caddy-stable.list

# Install caddy:
sudo apt update # required to refresh apt with the newly installed keys
sudo apt install caddy -y
```

To configure reverse-proxy with Caddy, refer the [official documentation here](https://caddyserver.com/docs/quick-starts/reverse-proxy).
For details on configuring reverse-proxy, refer this [`userdata.sh`](https://github.com/cyse7125-fall2023-group05/infra-jenkins/blob/master/modules/ec2/userdata.sh) file.

> NOTE: To remove reverse proxy error on Jenkins server: Jenkins->Manage->Configure->Jenkins URL->set it to "caddy1".

## ⚙️ Configuring Jenkins

### ⬇️ Installing plugins

We will configure the Jenkins server using the `install.sh` script that configures and installs plugins for us in an automated fashion.
There are a couple of plugins that will help us setup the Jenkins server with `Jenkins Configuration as Code`:

- `job-dsl`: Configure seed jobs to setup multi-branch pipelines
- `configuration-as-code`: Configure Jenkins with a JCasC `yaml` file that installs required tools and creates users
- `configuration-as-code-groovy`: Configure Jenkins with a JCasC `yaml` file that runs the `Groovy` scripts defined in the seed jobs

In order to install the plugins on the EC2 instance, we need to download and run the `plugin-installation-manager-tool` from [GitHub](https://github.com/jenkinsci/plugin-installation-manager-tool/).

```bash
# Install Jenkins plugin manager tool:
wget --quiet \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar
```

Next, we need to install the list of plugins mentioned in the `plugins.txt` file:

> The `plugins.txt` file contains the names and the versions of the plugins that we would need to configure Jenkins and run CI/CD jobs.

```bash
# Install plugins with jenkins-plugin-manager tool:
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt
```

Remember that we need to update the user and group permissions to `jenkins` for these plugins:

```bash
# Update users and group permissions to `jenkins` for all installed plugins:
cd /var/lib/jenkins/plugins/ || exit
sudo chown jenkins:jenkins ./*
```

### 🧾 JCasC

In order to configure Jenkins with Configuration as Code, we need to define a `yaml` file with some basic fields:

```yaml
jobs:
  - file: ./<your_seed_job>.groovy
unclassified:
  location:
    url: https://<localhost>:8080

```

### 🧳 Seed jobs using Groovy scripts

To setup multi-branch pipelines, we'll use `Groovy` scripts:

```groovy
multibranchPipelineJob('job-name') {
  branchSources {
    github {
      id('unique-job-id')
      scanCredentialsId('github-webhook-app-credentials')
      repoOwner('repository-owner')
      repository('repository-name')
    }
  }

  orphanedItemStrategy {
    discardOldItems {
      numToKeep(-1)
      daysToKeep(-1)
    }
  }
}

```

We have to update the user and group permissions for the JCasC and groovy files:

```bash
# Update file ownership
cd /var/lib/jenkins/ref/ || exit
sudo chown jenkins:jenkins <your-jcasc>.yaml <your_seed_job>.groovy
```

### ⏫ Update jenkins service

To disable the initial Jenkins setup wizard and to configure the Jenkins server using the JCasC file, we'll need to update the `jenkins.service` systemd service file:

```bash
# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/ref/jcasc.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
```

Finally, restart your jenkins service:

```bash
# restart jenkins service
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins
```

## 🪝 Webhook

In order for GitHub to run the Jenkins pipeline jobs, we would need a webhook that would be trigger on code push to the `master` branch.
We need to install and configure a `GitHub app` in our organization, and also `webhooks` in the repositories that would be scanned in order to run the build pipeline jobs.

> IMPORTANT: The URL for the webhook should be of the format: `https://<your-jenkins-server-domain>.tld/github-webhook`.

Once you've created and installed the GitHub app at the organization level on GitHub, it is time to add the credentials of this app on the Jenkins server.

In order to do this, download the `pkcs1` private key that you need to generate manually from the GitHub app. We would need to convert this private key int `pkcs8` format for Jenkins to talk to the GitHub app.

```bash
# convert pkcs1 private key to pkcs8
openssl pkcs8 -topk8 -nocrypt -in <github-app-private-key.pem> -out <jenkins-private-key>.pem
```

Next, we would need to add this private key with a unique id on the Jenkins server in the credentials section. This should help the GitHub app and the Jenkins server talk to each other over webhooks. Also, we need to fill out the `App ID` in the credentials section with the GitHub app ID.

> As an additional step, remember to add your `DockerHub` or `Quay` container repository secrets in the credentials section within the Jenkins server, since we will need them in our build pipelines.
