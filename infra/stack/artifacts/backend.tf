terraform {
  backend "s3" {
    bucket         = "tfstate-ml-sandbox"
    key            = "services/object-classifier/artifacts/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-ml-locks"
    encrypt        = true
  }
}
