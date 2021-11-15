terraform {
  required_providers {
      tls = {
        source = "hashicorp/tls"
        version = "3.1.0"
      }
      aws = {
        source = "hashicorp/aws"
        version = "3.64.2"
      }
      template = {
        source = "hashicorp/template"
        version = "2.2.0"
      }
      local = {
        source = "hashicorp/local"
        version = "2.1.0"
      }
      null = {
        source = "hashicorp/null"
        version = "3.1.0"
      }
  }
}

provider "aws" {
  region     = "${var.aws_config["region"]}"
  access_key = "${var.aws_config["access_key"]}"
  secret_key = "${var.aws_config["secret_key"]}"
}

provider "tls" { }