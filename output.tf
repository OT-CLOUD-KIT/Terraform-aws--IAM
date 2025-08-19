##################################################
# USERS
##################################################
output "user_arns" {
  description = "ARNs of all IAM users created"
  value       = { for u, user in aws_iam_user.users : u => user.arn }
}

output "user_names" {
  description = "List of IAM user names"
  value       = keys(aws_iam_user.users)
}

output "user_access_keys" {
  description = "Access keys for users (if created)"
  value = {
    for u, ak in aws_iam_access_key.access_key :
    u => {
      id     = ak.id
      secret = ak.secret
      status = ak.status
    }
  }
}

output "user_login_profiles" {
  description = "Login profiles for users (if created)"
  value = {
    for u, lp in aws_iam_user_login_profile.login :
    u => {
      password_reset_required = lp.password_reset_required
      password_length         = lp.password_length
    }
  }
}

##################################################
# GROUPS
##################################################
output "group_arns" {
  description = "ARNs of all IAM groups created"
  value       = { for g, group in aws_iam_group.groups : g => group.arn }
}

output "group_members" {
  description = "Users in each IAM group"
  value = {
    for g, membership in aws_iam_group_membership.membership :
    g => membership.users
  }
}

##################################################
# POLICIES
##################################################
output "policy_arns" {
  description = "ARNs of all IAM policies created"
  value       = { for p, policy in aws_iam_policy.policies : p => policy.arn }
}

output "user_policy_attachments" {
  description = "Policies attached to users"
  value = {
    for k, attach in aws_iam_user_policy_attachment.custom_user_attach :
    k => {
      user       = attach.user
      policy_arn = attach.policy_arn
    }
  }
}

output "group_policy_attachments" {
  description = "Policies attached to groups"
  value = {
    for k, attach in aws_iam_group_policy_attachment.custom_group_attach :
    k => {
      group      = attach.group
      policy_arn = attach.policy_arn
    }
  }
}

##################################################
# CREDENTIAL FILES
##################################################
output "credentials_files" {
  description = "Generated credential files for users"
  value       = [for f in local_file.credentials : f.filename]
}
