output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "acm_arn_frontend" {
  description = "Arn of generated certificate"
  value       = aws_acm_certificate_validation.default.certificate_arn
}

output "acm_arn_backend" {
  description = "Arn of generated certificate"
  value       = aws_acm_certificate_validation.default.certificate_arn
}

output "ssm_security_group_id" {
  value       = aws_security_group.ssm_instance.id
  description = "The ID of the SSM Agent Security Group."
}

output "ssm_role_id" {
  value       = aws_iam_role.ssm_instance.id
  description = "The ID of the SSM Agent Role."
}

output "security_group_lambda" {
  value = join("", aws_security_group.lambda_sg.*.id)
}
