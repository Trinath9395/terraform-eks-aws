terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }

  backend "s3" {
  bucket = "82-remote-state-pr-dev"
  key = "sg-infra-eks-rds"
  region = "us-east-1"
  use_lockfile = false
 }

}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}