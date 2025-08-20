##################################################
# USERS
##################################################

resource "aws_iam_user" "users" {
  for_each = { for k, v in var.users : k => v if v.create }

  name          = each.key
  path          = each.value.path
  force_destroy = true
}

resource "aws_iam_user_login_profile" "login" {
  for_each = { for k, v in var.users : k => v if v.create && v.create_login_profile }

  user                    = each.key
  password_length         = each.value.password_length
  password_reset_required = each.value.password_reset_required
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_access_key" "access_key" {
  for_each = { for k, v in var.users : k => v if v.create && v.create_access_key }

  user   = each.key
  status = each.value.access_key_status
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_user_ssh_key" "ssh" {
  for_each = { for k, v in var.users : k => v if v.create && v.create_ssh_key }

  username   = each.key
  encoding   = each.value.ssh_key_encoding
  public_key = each.value.ssh_public_key
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_user_policy_attachment" "attached" {
  for_each = { for u, data in var.users : u => data if length(data.policies) > 0 }

  user       = each.key
  policy_arn = each.value.policies[0] # For multiple, can use nested for_each
  depends_on = [aws_iam_user.users]
}

resource "local_file" "credentials" {
  for_each = { for k, v in var.users : k => v if v.create_login_profile || v.create_access_key }

  filename = "${path.module}/credentials-${each.key}.txt"

  content = <<EOT
User Name:          ${each.key}
User ARN:           ${aws_iam_user.users[each.key].arn}
Access Key ID:      ${try(aws_iam_access_key.access_key[each.key].id, "N/A")}
Secret Access Key:  ${try(aws_iam_access_key.access_key[each.key].secret, "N/A")}
Console Password:   ${try(aws_iam_user_login_profile.login[each.key].password, "N/A")}
EOT

  depends_on = [aws_iam_user.users, aws_iam_access_key.access_key, aws_iam_user_login_profile.login]
}

##################################################
# GROUPS
##################################################

resource "aws_iam_group" "groups" {
  for_each = { for k, v in var.groups : k => v if v.create }

  name = each.key
  path = each.value.path
}

resource "aws_iam_group_membership" "membership" {
  for_each = { for g, data in var.groups : g => data if length(data.users) > 0 }

  name  = "${each.key}-membership"
  group = aws_iam_group.groups[each.key].name
  users = each.value.users
}

resource "aws_iam_group_policy_attachment" "managed" {
  for_each = { for g, data in var.groups : g => data if length(data.managed_policies) > 0 }

  group      = aws_iam_group.groups[each.key].name
  policy_arn = each.value.managed_policies[0]
}

resource "aws_iam_group_policy" "inline" {
  for_each = { for g, data in var.groups : g => data if data.inline_policy != "" }

  name   = "${each.key}-inline"
  group  = aws_iam_group.groups[each.key].name
  policy = each.value.inline_policy
}



resource "aws_iam_policy" "policies" {
  for_each = local.policies

  name        = each.key
  path        = lookup(each.value, "path", "/")
  description = lookup(each.value, "desc", "Managed by Terraform")

  # Use templatefile if provided, otherwise jsonencode policy_statement
   policy      = var.use_root_path_template ? lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) : templatefile(lookup(each.value, "policy_template_file"), lookup(each.value, "policy_template_vars")) : lookup(each.value, "policy_template_file") == null ? jsonencode(jsondecode(lookup(each.value, "policy_statement"))) : templatefile("${path.module}/policy_document/${lookup(each.value, "policy_template_file")}", lookup(each.value, "policy_template_vars"))



}


resource "aws_iam_user_policy_attachment" "custom_user_attach" {
  for_each = local.user_policy_map

  user       = each.value.user
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_policy.policies, aws_iam_user.users]
}

resource "aws_iam_group_policy_attachment" "custom_group_attach" {
  for_each = local.group_policy_map

  group      = each.value.group
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_policy.policies, aws_iam_group.groups]
}
locals {
  # Map policies by name
  policies = { for p in var.policies : p.name => p }

  # Users attached to policies
  user_policy_list = flatten([
    for policy_name, data in local.policies : [
      for user in data.attach_to_users : {
        key        = "${policy_name}-${user}"
        user       = user
        policy_arn = aws_iam_policy.policies[policy_name].arn
      }
    ]
  ])
  user_policy_map = { for item in local.user_policy_list : item.key => item }

  # Groups attached to policies
  group_policy_list = flatten([
    for policy_name, data in local.policies : [
      for group in data.attach_to_groups : {
        key        = "${policy_name}-${group}"
        group      = group
        policy_arn = aws_iam_policy.policies[policy_name].arn
      }
    ]
  ])
  group_policy_map = { for item in local.group_policy_list : item.key => item }
}

