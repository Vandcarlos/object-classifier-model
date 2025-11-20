terraform {
  backend "s3" {
    bucket         = "tfstate-ml-sandbox"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-ml-locks"
    encrypt        = true
  }
}
