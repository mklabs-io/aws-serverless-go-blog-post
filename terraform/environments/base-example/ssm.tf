locals {
  // internal user used for admin maintenance tasks
  ssm_instance_user  = "example"
  ssm_instance_group = "example"
}

/**
  * SSM instance security group
*/
resource "aws_security_group" "ssm_instance" {
  vpc_id      = var.vpc_id
  name        = "ssm-sg"
  description = "Allow egress from SSM Agent to Internet."
  tags = {
    "Name" = "ssm-sg"
  }
}

resource "aws_security_group_rule" "ssm_instance_allow_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssm_instance.id
}

resource "aws_security_group_rule" "ssm_instance_allow_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssm_instance.id
}

data "aws_iam_policy_document" "ssm_instance_default" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_instance" {
  name               = "ssm-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_instance_default.json
}

resource "aws_iam_role_policy_attachment" "ssm_instance_policy" {
  role       = aws_iam_role.ssm_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance" {
  name = "ssm-iam-instance-profile"
  role = aws_iam_role.ssm_instance.name
}

data "template_file" "install_ssm_instance" {
  template = file("install-ssm-instance.yaml")
  vars = {
    user  = local.ssm_instance_user
    group = local.ssm_instance_group
  }
}

/*
 * Ref: https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
 */
data "template_cloudinit_config" "ssm_instance_config" {
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.install_ssm_instance.rendered
  }
  // cloud-init has apparently a 8 year unresolved issue (face-palm) [1], and is unable
  // to create users before write_files directive . Thus, we use this hack.
  // [1] - https://bugs.launchpad.net/cloud-init/+bug/1486113
  part {
    content_type = "text/x-shellscript"
    content      = "/usr/bin/install-pg.sh"
  }
}

resource "aws_instance" "ec2" {
  ami                    = "ami-0d712b3e6e1f798ef"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ssm_instance.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance.name

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 20
  }
  user_data = data.template_file.install_ssm_instance.rendered
  tags = {
    "Name" = "ssm-ec2"
  }
}

