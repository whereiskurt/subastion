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
  profile="bootstrap"
  region=var.aws_region
}

provider "tls" { }