output "iam_user_arns" {
  description = "ARNs of all IAM users from module"
  value       = module.iam_setup.user_arns
}

output "iam_group_arns" {
  description = "ARNs of all IAM groups from module"
  value       = module.iam_setup.group_arns
}

output "iam_policy_arns" {
  description = "ARNs of all IAM policies from module"
  value       = module.iam_setup.policy_arns
}

output "iam_user_policy_attachments" {
  description = "Policies attached to users"
  value       = module.iam_setup.user_policy_attachments
}

output "iam_group_policy_attachments" {
  description = "Policies attached to groups"
  value       = module.iam_setup.group_policy_attachments
}

output "iam_credentials_files" {
  description = "Generated credential files for users"
  value       = module.iam_setup.credentials_files
}
