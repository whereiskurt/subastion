# Overview
DOCUMENTATION UPDATE UNDER WAY! :-) This is changing!

This collection of `terraform` modules provide the **"Infrastructure as Code"** for a secure blue/green infrastructure template in AWS - usually builds in under 2minutes. Changing a few configuration variables results in a complete AWS Virtual Private Cloud with security controls and bastion host connectivity.

The only requirement is using the AWS KMS to create a customer managed key (CMK) with an alias 'orchestration':
| ![aws kms alias and key](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/kms.alias.orchestration.with.keyid.png) |
|:--:|
| <b>AWS console showing `orchestration` alias and key id</b>|

With the AWS KMS customer managed key aliased 'orchestration' in-place, execute `git clone https://github.com/subastion` and prepare to build your own AWS environment:
|![git clone and sourcing environment](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/gitclone.gif)|
|:--:|
| <b>Using `git clone` to retrieve latest subastion and set default environment varaibles with `environments.sh`.</b>|

Build self-signed certificate authority and intermediate certificate authority:
|![build-cryptocerts](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/buildcerts.gif)|
|:--:|
| <b>Executing bash function `build-cryptocerts` creates CA/ICA artifacts</b>|

Build/run a docker container to host the Hashicorp vault: 
|![build-dockervault](https://github.com/whereiskurt/subastion/blob/main/docs/gifs/builddocker.gif)|
|:--:|
| <b>Use the official Hashicorp Docker vault image to store secrets.</b>|


Calling `build-aws-bluegreen` (shown above) will begin to 1) securely configures a local HashiCorp `vault` instance with `systemd --user` unsealed by an AWS KMS Customer Key and 2) create an AWS VPC with restricted network ACL, security groups, NAT gateways for private subnets, and bastion hosts with openvpn/ssh connectivity.

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