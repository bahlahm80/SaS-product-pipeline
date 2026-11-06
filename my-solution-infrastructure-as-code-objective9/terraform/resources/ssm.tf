# placeholder for secrets for application to run
resource "aws_ssm_parameter" "sas_app_auth_token" {
  name        = "/sas/${var.environment}/app/api_key"
  description = "api key secret for authenticating with backend api services"
  type        = "SecureString"
  value       = "CHANGE_ME_IN_SSM"

  lifecycle {
    ignore_changes = [value] # Prevents Terraform from overwriting manual or external secret updates
  }
}