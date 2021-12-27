# Overview
This collection of `terraform` modules provide the **"Infrastructure as Code"** for a secure blue/green infrastructure template in AWS - usually builds in under 2minutes. Changing a few configuration variables results in a complete AWS Virtual Private Cloud with security controls and bastion host connectivity.
## Quick Start
These steps are fully explained in the next section, but the quick start is here. :-)
You MUST create the AWS KMS CMK manually in the AWS console. The key needs to be in the region you are building (e.g. ca-central-1)

To manage the AWS infrastructure using `terraform` you can either:
- **Option A)** use the local machine which needs to have `terraform`, `vault`, `openssl` and `jq` installed, or 
- **Option B)** run subastion inside a Docker image using `docker-compose` to create an Alpine Linux image with the binaries and subastion installed:
### Option A: Build using local host terraform
```shell 
  ##Get latest code
  git clone https://github.com/whereiskurt/subastion
  cd subastion
  
  ##Load bash functions and environment variables
  source environments.sh
  
  ##Build certs/dockervault and create AWS Blue/Green from local terraform install
  build-cryptocerts
  build-dockervault
  build-prod-bluegreen

  ## Now the environment is built, we can connect over `ssh`:
  ssh-prod-green-subastion
  ssh-prod-blue-subastion
  ## OR! We can extend our network through blue/green using `openvpn`:
  openvpn-prod-blue-subastion
  openvpn-prod-green-subastion 
```
### Option B: Build with Subastion in Docker
```shell 
  ##Get latest code
  git clone https://github.com/whereiskurt/subastion
  cd subastion
  ##Load bash functions and environment variables
  source environments.sh

  ##Build certs/dockervault
  build-cryptocerts
  build-dockervault
  ## Build / run docker image for subastion
  cd docker && docker-compose run subastion
  ## From with-in Docker load bash functions and environment variables
  source environments.sh
  ## From with-in Docker create AWS Blue/Green using terraform
  build-prod-bluegreen

  ## Now the environment is built, we can connect over `ssh`:
  ssh-prod-green-subastion
  ssh-prod-blue-subastion
  ## OR! We can extend our network through blue/green using `openvpn`:
  openvpn-prod-blue-subastion
  openvpn-prod-green-subastion 

```
- With the build complete access bastion hosts over `ssh`:

| <b>Run `ssh-prod-blue-subastion` and `ssh-prod-green-subastion` </b>|
|:--:|
| ![ssh into bastion hosts](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/ssh.bluegreen.gif) |


## Detailed Steps
### 1. AWS KMS CMK Setup
The only requirement is using the AWS KMS to create a customer managed key (CMK) with an alias 'orchestration':
| <b>AWS console showing `orchestration` alias and key id</b>|
|:--:|
| ![aws kms alias and key](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/kms.alias.orchestration.with.keyid.png) |

This allows the `vault` to automatically unseal using a configuration tied to AWS CMK:
<p align="center">
<img src="https://github.com/whereiskurt/subastion/blob/main/docs/gifs/vaultseal.png" />
</p>

### 2. Clone the Repository
With the AWS KMS customer managed key aliased 'orchestration' in-place and get the latest version of subastion:
| <b>Using `git clone https://github.com/whereiskurt/subastion` to retrieve latest subastion and set default environment varaibles with `source environments.sh`.</b>|
|:--:|
|![git clone and sourcing environment](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/gitclone.gif)|

### 3. Create Local Self-signed CA/ICA Certs
Build self-signed certificate authority and intermediate certificate authority:
| <b>Execute bash function `source environments.sh && build-cryptocerts`</b>|
|:--:|
|![build-cryptocerts](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/buildcerts.gif)|

### 4. Start Hashicorp Vault in Docker
Build/run a docker container to host the Hashicorp vault: 
| <b>Execute bash function `source environments.sh && build-dockervault`</b>|
|:--:|
|![build-dockervault](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/builddocker.gif)|

Run `docker ps` to see the official Hashicorp vault image labeled 'vaultsubastion' is started with mapped local host ports onto the container port running vault:
<p align="center">
<img src="https://github.com/whereiskurt/subastion/blob/main/docs/gifs/dockerrunning.png" />
</p>

### 5. Run Terraform Locally or Run Terraform in Docker
#### 5a. Run Terraform Locally 
This setup will run `terraform` from your local system and store the state locally:
| <b>Execute bash function `source environments.sh && build-prod-bluegreen`</b>|
|:--:|
|![build terraform locally](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/buildprodgreenblue.local.gif)|

After approximately 2-3mins the build should complete:
<p align="center">
<img src="https://github.com/whereiskurt/subastion/blob/main/docs/gifs/buildcomplete.local.png" />
</p>

This is indicating you have two bastion hosts setup:
```go
subastion_blue_public_ip = "35.183.231.248"
subastion_green_public_ip = "3.97.186.194"
```

#### 5b. Run Terraform in Docker
To run `terraform` with-in a docker container:


![ssh-prod-green-subastion demo](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/ssh.gif)

After `build-aws-bluegreen` completes you have access to 2x EC2 bastion hosts straddling public/manage/private portions of their blue/green networks. Executing `openvpn-prod-blue-subastion` will extend your local network and tunnel your outbound traffic through AWS. Executing `ssh-prod-green-subastion` will land you on the green bastion host, straddling the subnets.

Destroying the environment is as easy as running `destroy-prod-bluegreen` (this does not delete the KMS key):
![destroy-aws-bluegreen demo](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/destroy.gif)

## What is a Blue/Green Deployment strategy?
>A [blue/green deployment](https://docs.aws.amazon.com/whitepapers/latest/overview-deployment-options/bluegreen-deployments.html) is a deployment strategy in which you create two separate, but identical environments. One environment (blue) is running the current application version and one environment (green) is running the new application version. 

# Requirements
## Packages
The following packages are required to use this project:
1) Linux :) and potentially `sudo` access if you want to create openvpn connections
1) HashiCorp `terraform` to build `vault`, `openssl` and AWS environment
2) HashiCorp `vault` client+server to put/get secrets from the `vault` 
5) `jq` to manipulate JSON outpus from `terraform`
4) `openssl` to create .x509 certs
3) `docker` and `docker-compose` to run

**NOTE**: TODO: Make this a Dockerfile!

## Configuration
To `build-aws-bluegreen` you need to provide these minimum details in `environment/aws/bluegreen/variables.tf`:
```go
variable "aws_region" {
  type = string
  default = "ca-central-1"
}

variable "aws_zones" {
  type = list(string)
  default = ["ca-central-1a", "ca-central-1b"]
}

variable "aws_profile" {
  type = string
  default = "default"
}

variable "aws_kms_key_alias" {
  type = string
  default = "orchestration"
}

variable "aws_kms_key_id" {
  type = string
  default = "aaaaaa-bbbb-dddd-eeee-ffffffffffff"
  sensitive = true
}
```
The `aws_kms_key_id` above must be set to a AWS KMS that has already been created. The project creates a new IAM user `vaultroot` that has access to USE this key. An separate `vaultuser` is also created with *different permissions* from `vaultroot` and performs IAM actions onbehalf of `vault` (create/delete/manage IAM users.) 

This project currently does not create/delete the AWS KMS key. Create an AWS KMS key with the alias 'orchestration' in the same `aws_region` as above:

**TODO**: INSERT GIF of key creation

The default configuration uses an `aws_profile` named 'default' from the `$HOME/.aws/credentials` (this could be changed to word 'bootstrap' instead). This is what a `$HOME/.aws/credentials` file looks like with 'bootstrap' profile added:

```shell
[default]
aws_access_key_id = AKIAAAABBBCCCDDD
aws_secret_access_key = amazonprovidedsecretABCD

[bootstrap]
aws_access_key_id = AKIAZZZYYYXXXWWW
aws_secret_access_key = amazonprovidedsecretZYXW

```

## Technical Details
### Terraform
The `terraform` resources in this project are structured into modules. The code inside of `/terraform/modules/aws/subnet` is called twice from the `main.tf`. Here is a simplified example from the project code:

```go
module "vpc" {
  name="prod"
  vpc_cidr = "10.50.0.0/16"
  openvpn_port = "11194"
  ...
}

module "subnet_green" {
  vpc_id=module.vpc.id
  source = "terraform/modules/aws/subnet"
  aws_availability_zone = "ca-central-1a"
  public_subnets="10.50.0.0/20"
  manage_subnets = "10.50.16.0/20"
  private_subnets ="10.50.32.0/20"
  ...
}

module "subnet_blue" {
  vpc_id=module.vpc.id
  source = "terraform/modules/aws/subnet"
  aws_availability_zone="ca-central-1b"
  public_subnets="10.50.64.0/20"
  manage_subnets = "10.50.80.0/20"
  private_subnets ="10.50.96.0/20"
  ...
}
```
Structuring `terraform` resources into modules and variables demonstrates how to reduce the amount of code needed and increase the robustness/reusability of the code you do write.

The project code includes custom `subnet`, `natgateway` and `bastion` modules are used to create unique green/blue infrastructure within the AWS VPC. 

```go
module "ec2_subastion_green" {
  name="${module.vpc.name}_green_subastion"
  
  subastion_vpc_id = module.vpc.id
  public_subnet_id = module.subnet_green.public_subnet_id
  manage_subnet_id = module.subnet_green.manage_subnet_id
  private_subnet_id = module.subnet_green.private_subnet_id
  
  subastion_public_ip = "10.50.0.50"
  subastion_manage_ip = "10.50.16.50"
  subastion_private_ip = "10.50.32.50"
  ...
}

module "ec2_subastion_blue" {
  name="${module.vpc.name}_blue_subastion"
  
  subastion_vpc_id = module.vpc.id
  public_subnet_id = module.subnet_blue.public_subnet_id
  manage_subnet_id = module.subnet_blue.manage_subnet_id
  private_subnet_id = module.subnet_blue.private_subnet_id

  subastion_public_ip = "10.50.64.50"
  subastion_manage_ip = "10.50.80.50"
  subastion_private_ip = "10.50.96.50"
  ...
}
```
### Description
1. Create a new Virtual Private Cloud (VPC) called `prod` in the AWS Region `ca-central-1`.  This VPC will be referenced by other modules - for example the 
2. Re-using the AWS subnet module:
  1. Create subnets `green-public`, `green-manage` and `green-private`, residing in an Availability Zone `ca-central-1a` (as per subnets)
  2. Create subnets `blue-public` , `blue-manage` and `blue-private`, residing in an Availability Zone `ca-central-1b` (as per subnets)

### Certificates and Vault
* `openssl` cert generation with self-signed Certificate Authority (CA) and Intermediate Certificate Authoriy (ICA) signing chain
* The offiical HashiCorp `vault` image running inside of `Docker` container, unsealed using AWS KMS and IAM user `vaultroot` with privileges seal/unsealing. A separate IAM user `vaultuser` is also created to managed the 'aws secrets' and IAM users creation/delete/group assignments.
* `openvpn` connectivity to bastion host - just run `openvpn-prod-blue-subastion` or `openvpn-prod-green-subastion` 

### TODO - Quick List

- Move module outputs of PEM files from terraform/modules to the environment/ area
- All module outputs to the environment folder!
- In the destroy from aws_bluegreen remove the green/blue subastion keys from vault
- Add a environment/aws/kms