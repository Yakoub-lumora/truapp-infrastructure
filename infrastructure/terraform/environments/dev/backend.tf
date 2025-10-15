# Backend configuration for Terraform state
# Uncomment and configure when ready to use remote state

# terraform {
#   backend "s3" {
#     bucket         = "trushot-terraform-state-dev"
#     key            = "dev/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "trushot-terraform-locks-dev"
#   }
# }
