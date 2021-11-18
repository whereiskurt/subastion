resource "aws_iam_user" "vault_aws_root" {
  name = "vaultroot"
  force_destroy = true
  tags = var.aws_build_tags
}

resource "aws_iam_access_key" "vault_root_access_key" {
  user = aws_iam_user.vault_aws_root.name
}

resource "aws_iam_policy" "secret_root_policy" {
  name        = "KMSVaultKeyRoot"
  description = "Policy to encrypt/decrypt vault seal/unseal key."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:${var.aws_config["region"]}:*:alias/${var.aws_config["kms_key_alias"]}"
    }
  ]
}
EOF
  tags = var.aws_build_tags
}

resource "aws_iam_user_policy_attachment" "secret_root_group_attach" {
  user       = aws_iam_user.vault_aws_root.name
  policy_arn = aws_iam_policy.secret_root_policy.arn
}

resource "aws_iam_user" "vault_aws_user" {
  name = "vaultuser"
  force_destroy = true
  tags = var.aws_build_tags
}

resource "aws_iam_access_key" "vault_user_access_key" {
  user = aws_iam_user.vault_aws_user.name
}

resource "aws_iam_policy" "vault_aws_policy" {
  name        = "VaultUser"
  description = "Policy for root account for EC2 spinups."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": ["arn:aws:iam::*:user/vault-*"]
    }
  ]
}
EOF
  tags = var.aws_build_tags
}

resource "aws_iam_user_policy_attachment" "secret_vault_user_group_attach" {
  user       = aws_iam_user.vault_aws_user.name
  policy_arn = aws_iam_policy.vault_aws_policy.arn
}

resource "null_resource" "vault_enable_aws_secret" {
  depends_on = [null_resource.vault_login]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
      vault secrets enable aws &&
      vault policy write admin ../../docker/vault/admin_policy.hcl &&
      vault token create -format=json -policy="admin" | jq -r ".auth.client_token" > vaultadmin.token
    EOT
  }
}

resource "null_resource" "vault_aws_write_config" {
  depends_on = [null_resource.vault_enable_aws_secret]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
    vault write aws/config/root \
        access_key=${aws_iam_access_key.vault_user_access_key.id} \
        secret_key=${aws_iam_access_key.vault_user_access_key.secret} \
        region=${var.aws_config.region}
    EOT
  }
}

resource "aws_iam_policy" "ec2_admin_policy" {
  name        = "EC2Root"
  description = "Policy for root account for EC2 spinups."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOF
  tags = var.aws_build_tags
}

resource "null_resource" "vault_aws_ec2_admin_policy" {
  depends_on = [null_resource.vault_enable_aws_secret]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
      vault write aws/roles/ec2_admin_policy \
        policy_arns=${aws_iam_policy.ec2_admin_policy.arn} \
        credential_type=iam_user
    EOT
  }
}