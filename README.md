# Jenkins AMI w/ Hashicorp Packer

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
- **Volume Size:** `50GiB`
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
