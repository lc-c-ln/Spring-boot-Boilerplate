terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 백엔드 설정 – 실제 bucket/region으로 교체 후 주석 해제
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "environments/aws/terraform.tfstate"
  #   region         = "ap-northeast-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "aws"
      ManagedBy   = "terraform"
    }
  }
}
