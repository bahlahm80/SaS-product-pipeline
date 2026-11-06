resource "aws_ssm_parameter" "db_connection_string" {
  name        = "/sas/${var.environment}/database/connection_string"
  description = "Encrypted database connection string for tenant workloads"
  type        = "SecureString"
  value       = "postgres://placeholder-user:placeholder-pass@rds-cluster.internal:5432/sas_${var.environment}"

  lifecycle {
    ignore_changes = [value] # Prevents Terraform from overwriting manual or external secret updates
  }
}