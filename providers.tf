terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # profile = "abayomi"
  access_key = "AKIAYG35YAJRLQQYWCEA"
  secret_key = "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"
}