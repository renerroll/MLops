# backend.tf placeholder for root config (S3/remote state configuration)
# terraform {
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "path/to/state.tfstate"
#     region = "us-east-1"
#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}