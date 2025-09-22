terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.11.0"
    }
  }

  backend s3 {
  bucket = "82-remote-state-pr"
  key = "expense-dev-eks-vpc"
  region = "us-east-1"
  use_lockfile = true
 }

}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}