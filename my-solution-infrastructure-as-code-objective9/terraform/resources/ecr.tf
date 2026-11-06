resource "aws_ecr_repository" "app_repo" {
  name                 = "sas-product-${var.environment}"
  image_tag_mutability = "MUTABLE" # Allows tagging promoted artifacts

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}