# Fetch all SSM parameters for the environment
data "aws_ssm_parameters_by_path" "env_vars" {
  path            = "/${var.project_name}/${var.environment}/"
  recursive       = true
  with_decryption = false # We just need the names, ECS will decrypt
}

# Local variable to transform SSM parameters into secrets array format
locals {
  # Convert SSM parameter names to secrets format for ECS
  ssm_secrets = [
    for param_name in data.aws_ssm_parameters_by_path.env_vars.names : {
      name      = replace(param_name, "/${var.project_name}/${var.environment}/", "")
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${param_name}"
    }
  ]
}
