terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Note that in the latest versions of LocalStack, all AWS services are exposed on port 4566, 
  # so the endpoint URLs for SQS, SNS, Lambda, etc., are all "http://localhost:4566"

  endpoints {
    sqs                        = "http://localhost:4566"
    sns                        = "http://localhost:4566"
    lambda                     = "http://localhost:4566"
    iam                        = "http://localhost:4566"
  }
}
