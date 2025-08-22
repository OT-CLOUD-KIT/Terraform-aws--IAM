# AWS IAM 

Terraform module for managing **IAM users, groups, and policies**. This module allows you to define users with login profiles, access keys, and optional SSH keys, assign them to groups, and attach AWS-managed or custom policies. It provides a reusable structure for IAM resource management in AWS.

---

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.82.2 |
| <a name="terraform_module"></a> [Terraform](Terraform\module) | >= 1.12.1 |

---

## Diagram

![SNS](https://github.com/user-attachments/assets/ff3a1fc2-1c54-4674-a04c-abba0da21803)

---

## Requirements

What does this module do?

1. Create **IAM Users** with login profiles, passwords, access keys, and optional SSH keys.  
2. Create **IAM Groups** with managed and inline policies.  
3. Create **Custom IAM Policies** using inline JSON or template files.  
4. Attach policies to both users and groups.  

---



## Usage

```hcl
module "iam_setup" {
  source = "OT-CLOUD-KIT/Terraform-aws--IAM"

  use_root_path_template = false

  users = {
    "john.doe" = {
      create                  = true
      path                    = "/developers/"
      create_login_profile    = true
      password_length         = 20
      password_reset_required = true
      create_access_key       = true
      access_key_status       = "Active"
      create_ssh_key          = false
      ssh_key_encoding        = null
      ssh_public_key          = null
      policies                = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
    }

  groups = {
    "developers" = {
      create           = true
      path             = "/"
      users            = ["john.doe"]
      managed_policies = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
      inline_policy    = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::example-bucket"]
    }
  ]
}
EOT
    },
    "admins" = {
      create           = true
      path             = "/"
      users            = ["jane.smith"]
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      inline_policy    = ""
    }
  }

  policies = [
    {
      name                = "EC2RestrictedAccess"
      path                = "/custom/"
      desc                = "Custom policy for restricted EC2 access"
      policy_statement    = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:Describe*"],
      "Resource": "*"
    }
  ]
}
EOT
      policy_template_file = null
      policy_template_vars = null
      attach_to_users      = ["john.doe"]
      attach_to_groups     = ["developers"]
    },
    {
      name                 = "S3BucketSpecificAccess"
      path                 = "/custom/"
      desc                 = "Custom policy for S3 bucket access"
      policy_statement     = null
      policy_template_file = "s3_policy.json.tpl"
      policy_template_vars = {
        bucket_name = "my-example-bucket"
      }
      attach_to_users      = []
      attach_to_groups     = ["developers"]
    }
  ]
}
}
```

## Resources

| Name                                                                                                                                                                 | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws\_iam\_user.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)                                                         | resource |
| [aws\_iam\_user\_login\_profile.login](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile)                           | resource |
| [aws\_iam\_access\_key.access\_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key)                                      | resource |
| [aws\_iam\_user\_ssh\_key.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_ssh_key)                                         | resource |
| [aws\_iam\_user\_policy\_attachment.attached](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment)                | resource |
| [local\_file.credentials](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)                                                        | resource |
| [aws\_iam\_group.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group)                                                      | resource |
| [aws\_iam\_group\_membership.membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership)                           | resource |
| [aws\_iam\_group\_policy\_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment)               | resource |
| [aws\_iam\_group\_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy)                                       | resource |
| [aws\_iam\_policy.policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                  | resource |
| [aws\_iam\_user\_policy\_attachment.custom\_user\_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment)    | resource |
| [aws\_iam\_group\_policy\_attachment.custom\_group\_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |

___


## Input

| Name                                                                                                                       | Description                                       | Type           | Default       | Required |
| -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- | -------------- | ------------- | :------: |
| <a name="input_users"></a> [users](#input_users)                                                                           | Map of IAM users to create                        | `map(object)`  | `{}`          |    no    |
| <a name="input_users_create"></a> [users.create](#input_users_create)                                                      | Whether to create this IAM user                   | `bool`         | n/a           |    no    |
| <a name="input_users_path"></a> [users.path](#input_users_path)                                                            | Path for the IAM user                             | `string`       | n/a           |    no    |
| <a name="input_users_create_login_profile"></a> [users.create\_login\_profile](#input_users_create_login_profile)          | Whether to create a login profile for the user    | `bool`         | n/a           |    no    |
| <a name="input_users_password_length"></a> [users.password\_length](#input_users_password_length)                          | Length of the generated password                  | `number`       | n/a           |    no    |
| <a name="input_users_password_reset_required"></a> [users.password\_reset\_required](#input_users_password_reset_required) | Whether user must reset password on first login   | `bool`         | n/a           |    no    |
| <a name="input_users_create_access_key"></a> [users.create\_access\_key](#input_users_create_access_key)                   | Whether to create an access key for the user      | `bool`         | n/a           |    no    |
| <a name="input_users_access_key_status"></a> [users.access\_key\_status](#input_users_access_key_status)                   | Status of the access key                          | `string`       | n/a           |    no    |
| <a name="input_users_create_ssh_key"></a> [users.create\_ssh\_key](#input_users_create_ssh_key)                            | Whether to create an SSH public key               | `bool`         | n/a           |    no    |
| <a name="input_users_ssh_key_encoding"></a> [users.ssh\_key\_encoding](#input_users_ssh_key_encoding)                      | SSH key encoding type                             | `string`       | n/a           |    no    |
| <a name="input_users_ssh_public_key"></a> [users.ssh\_public\_key](#input_users_ssh_public_key)                            | SSH public key                                    | `string`       | n/a           |    no    |
| <a name="input_users_policies"></a> [users.policies](#input_users_policies)                                                | List of policies to attach to this user           | `list(string)` | `[]`          |    no    |
| <a name="input_groups"></a> [groups](#input_groups)                                                                        | Map of IAM groups to create                       | `map(object)`  | `{}`          |    no    |
| <a name="input_groups_create"></a> [groups.create](#input_groups_create)                                                   | Whether to create this group                      | `bool`         | n/a           |    no    |
| <a name="input_groups_path"></a> [groups.path](#input_groups_path)                                                         | Path for the IAM group                            | `string`       | n/a           |    no    |
| <a name="input_groups_users"></a> [groups.users](#input_groups_users)                                                      | List of user names to add to this group           | `list(string)` | `[]`          |    no    |
| <a name="input_groups_managed_policies"></a> [groups.managed\_policies](#input_groups_managed_policies)                    | List of managed policies to attach to this group  | `list(string)` | `[]`          |    no    |
| <a name="input_groups_inline_policy"></a> [groups.inline\_policy](#input_groups_inline_policy)                             | Inline policy for this group                      | `string`       | `""`          |    no    |
| <a name="input_policies"></a> [policies](#input_policies)                                                                  | List of custom IAM policies to create             | `list(object)` | `[]`          |    no    |
| <a name="input_policies_name"></a> [policies.name](#input_policies_name)                                                   | Name of the policy                                | `string`       | n/a           |    no    |
| <a name="input_policies_path"></a> [policies.path](#input_policies_path)                                                   | Path for the policy                               | `string`       | n/a           |    no    |
| <a name="input_policies_desc"></a> [policies.desc](#input_policies_desc)                                                   | Description of the policy                         | `string`       | n/a           |    no    |
| <a name="input_policies_policy_statement"></a> [policies.policy\_statement](#input_policies_policy_statement)              | JSON policy statement                             | `string`       | n/a           |    no    |
| <a name="input_policies_policy_template_file"></a> [policies.policy\_template\_file](#input_policies_policy_template_file) | Path to a policy template file                    | `string`       | n/a           |    no    |
| <a name="input_policies_policy_template_vars"></a> [policies.policy\_template\_vars](#input_policies_policy_template_vars) | Variables for policy template                     | `map(any)`     | `{}`          |    no    |
| <a name="input_policies_attach_to_users"></a> [policies.attach\_to\_users](#input_policies_attach_to_users)                | Users to attach this policy to                    | `list(string)` | `[]`          |    no    |
| <a name="input_policies_attach_to_groups"></a> [policies.attach\_to\_groups](#input_policies_attach_to_groups)             | Groups to attach this policy to                   | `list(string)` | `[]`          |    no    |
| <a name="input_use_root_path_template"></a> [use\_root\_path\_template](#input_use_root_path_template)                     | Whether to look for policy templates in root path | `bool`         | `false`       |    no    |

___

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_user_arns"></a> [iam_user_arns](#output_iam_user_arns) | ARNs of all IAM users from module |
| <a name="output_iam_group_arns"></a> [iam_group_arns](#output_iam_group_arns) | ARNs of all IAM groups from module |
| <a name="output_iam_policy_arns"></a> [iam_policy_arns](#output_iam_policy_arns) | ARNs of all IAM policies from module |
| <a name="output_iam_user_policy_attachments"></a> [iam_user_policy_attachments](#output_iam_user_policy_attachments) | Policies attached to users |
| <a name="output_iam_group_policy_attachments"></a> [iam_group_policy_attachments](#output_iam_group_policy_attachments) | Policies attached to groups |
| <a name="output_iam_credentials_files"></a> [iam_credentials_files](#output_iam_credentials_files) | Generated credential files for users |


## Contributors

- [Piyush Upadhyay](https://github.com/piiiyuushh)
- [Nikita Joshi](https://github.com/jnikita19)
