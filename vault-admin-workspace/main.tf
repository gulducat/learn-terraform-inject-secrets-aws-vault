variable "name" { default = "dynamic-aws-creds-vault-admin" }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2_manager" {
  name = var.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${data.aws_caller_identity.current.arn}"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_manager" {
  name = "allow_iam"
  role = aws_iam_role.ec2_manager.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": "*"
    }
  ]
}
EOF
}

provider "vault" {}

resource "vault_aws_secret_backend" "aws" {
  path = "${var.name}-path"

  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds     = "240"
}

resource "vault_aws_secret_backend_role" "admin" {
  backend = vault_aws_secret_backend.aws.path
  name    = "${var.name}-role"

  credential_type = "assumed_role"
  role_arns       = [aws_iam_role.ec2_manager.arn]
  default_sts_ttl = 60 * 30 # 30 min
  max_sts_ttl     = 60 * 60 # 1 hour
}

output "backend" {
  value = vault_aws_secret_backend.aws.path
}

output "role" {
  value = vault_aws_secret_backend_role.admin.name
}
