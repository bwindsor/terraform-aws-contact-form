terraform {
  required_version = ">= 1.0.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = ">= 2.2.0, < 3.0.0"
    }
  }
}
