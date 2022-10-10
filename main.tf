
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

}


provider "aws" {
  region = var.aws_region
#  assume_role {
#    role_arn    = var.assume_role_name
#    external_id = "my_external_id"
#  }
}


terraform {
  backend "s3" {
    bucket  = "calibo-test-domain"
    region  = "us-east-1"
    encrypt = true
    key     = "tf-awss3-bucket-demo/terraform.tfstate"
  }
}

resource "aws_s3_bucket" "demos3" {
  bucket = "${var.bucket_name}"
  acl = "${var.acl_value}"
}

###### Variables #######

variable "aws_region" {
  default = "us-east-1"
}

variable "assume_role_name" {
  default = "arn:aws:iam::628740878687:role/tf-assume-role"
}

variable "acl_value" {
  default = "private"
}

variable "bucket_name" {
  default = "tf-assume-role-check"
}

output "bucket_details" {
  value = aws_s3_bucket.demos3
}