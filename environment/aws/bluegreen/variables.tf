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
  sensitive = true
}

##Leaving this false prevents private/manage networks for getting out the Internet via outbound NAT.
variable build_nat_gateway {
  type = bool
  default = true
}

variable "vault_env" {
  type = map
  default = {
    VAULT_ADDR = "https://localhost:8200"
    VAULT_CACERT = "../../../terraform/modules/openssl/ca.ica.pem"
    DOCKER_HOST_PORT=8200
    DOCKER_CONTAINER_PORT=8200
  }
}

variable "aws_build_tags" {
  type = map
  default = {
    "builder" = "subastion-built"
    "auto_remove_by" = "20220601"
  }
}