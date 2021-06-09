locals {
  template   = "../../../backend/template.yml"
  packaged   = "../../../backend/packaged.yml"
  stack_name = "dev-sample"
}

resource "aws_acm_certificate" "backend" {
  domain_name       = "${var.subdomain_name_backend}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}

resource "cloudflare_record" "validation_domain_backend" {
  name       = aws_acm_certificate.backend.domain_validation_options[0]["resource_record_name"]
  value      = trimsuffix(aws_acm_certificate.backend.domain_validation_options[0]["resource_record_value"], ".")
  type       = aws_acm_certificate.backend.domain_validation_options[0]["resource_record_type"]
  zone_id    = lookup(data.cloudflare_zones.default.zones[0], "id")
  depends_on = [aws_acm_certificate.backend]
}

resource "aws_acm_certificate_validation" "backend" {
  certificate_arn         = aws_acm_certificate.backend.arn
  validation_record_fqdns = cloudflare_record.validation_domain_backend.*.hostname
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security Group for lambda"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "lambda_to_https" {
  protocol          = "TCP"
  type              = "egress"
  security_group_id = aws_security_group.lambda_sg.id
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound traffic from lambdas to Internet"
}

resource "null_resource" "build_deploy_sam_resource" {
  triggers = {
    s3_bucket     = var.s3_bucket_artifacts
    template      = sha1(file("../../../backend/template.yaml"))
    stack_name    = local.stack_name
    sec_group_ids = join(",", aws_security_group.lambda_sg.*.id)
    subnet_ids    = join(",", var.private_subnet_ids)
    domain_name   = "${var.subdomain_name_backend}.${var.domain_name}"
    target_stage  = "dev"
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      sam package --template-file ${local.template} --s3-bucket ${self.triggers.s3_bucket} --output-template-file ${local.packaged}
      sam deploy --stack-name ${self.triggers.stack_name} --template-file ${local.packaged} --capabilities CAPABILITY_IAM --parameter-overrides TargetStage=${self.triggers.target_stage} DomainName=${self.triggers.domain_name} VPCSecurityGroupIDs=${self.triggers.sec_group_ids} VPCSubnetIDs=${self.triggers.subnet_ids} AcmCertificateArn=${aws_acm_certificate_validation.backend.certificate_arn}
    EOT
  }
  depends_on = [aws_security_group.lambda_sg, aws_acm_certificate_validation.backend]
}

resource "null_resource" "get_api_gateway_endpoint" {
  triggers = {
    template   = sha1(file("../../../backend/template.yaml"))
    stack_name = local.stack_name
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "aws cloudformation describe-stacks --stack-name ${self.triggers.stack_name} | jq '.Stacks[0].Outputs[0].OutputValue'| sed 's/\"//g' > ${path.module}/gateway_endpoint.txt"
  }
  depends_on = [null_resource.build_deploy_sam_resource]
}

data "local_file" "api_gateway_endpoint" {
  filename   = "${path.module}/gateway_endpoint.txt"
  depends_on = [null_resource.get_api_gateway_endpoint]
}

resource "cloudflare_record" "api_gateway_endpoint" {
  depends_on = [data.local_file.api_gateway_endpoint]
  name       = var.subdomain_name_backend
  value      = data.local_file.api_gateway_endpoint.content
  type       = "CNAME"
  proxied    = true
  zone_id    = lookup(data.cloudflare_zones.default.zones[0], "id")
}
