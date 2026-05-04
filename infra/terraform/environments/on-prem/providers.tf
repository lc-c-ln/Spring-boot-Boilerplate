terraform {
  required_version = ">= 1.6.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # 온프레미스도 AWS S3 백엔드 사용 가능 (AWS 계정이 있으므로)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "environments/on-prem/terraform.tfstate"
  #   region         = "ap-northeast-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}
