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


---

## Requirements

What does this module do?

1. Create **IAM Users** with login profiles, passwords, access keys, and optional SSH keys.  
2. Create **IAM Groups** with managed and inline policies.  
3. Create **Custom IAM Policies** using inline JSON or template files.  
4. Attach policies to both users and groups.  

---

## Modules

**Design Considerations:**

1. Define **users** with required attributes.  
2. Create **groups** and assign users to them.  
3. Create **policies** (inline JSON or from templates).  
4. Attach policies to users and groups.  

---



## Usage

```hcl
module "iam_setup" {
  source = "git@github.com:your-org/terraform-aws-iam-user-group-policy.git?ref=main"

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

| Name                                                                                                   | Description                                                                                                                         | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Default | Required |
| ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_users"></a> [users](#input_users)                                                       | Map of IAM users to create. Each user supports options for login profile, access key, ssh key, and attached policies.               | <pre>map(object({<br>  create                   = bool<br>  path                     = string<br>  create\_login\_profile     = bool<br>  password\_length          = number<br>  password\_reset\_required  = bool<br>  create\_access\_key        = bool<br>  access\_key\_status        = string<br>  create\_ssh\_key           = bool<br>  ssh\_key\_encoding         = string<br>  ssh\_public\_key           = string<br>  policies                 = list(string)<br>}))</pre> | `{}`    |    no    |
| <a name="input_groups"></a> [groups](#input_groups)                                                    | Map of IAM groups to create. Each group supports users, managed policies, and an inline policy.                                     | <pre>map(object({<br>  create            = bool<br>  path              = string<br>  users             = list(string)<br>  managed\_policies  = list(string)<br>  inline\_policy     = string<br>}))</pre>                                                                                                                                                                                                                                                                             | `{}`    |    no    |
| <a name="input_policies"></a> [policies](#input_policies)                                              | List of custom IAM policies. Each policy supports statement or template-based definitions and optional attachments to users/groups. | <pre>list(object({<br>  name                 = string<br>  path                 = string<br>  desc                 = string<br>  policy\_statement     = string<br>  policy\_template\_file = string<br>  policy\_template\_vars = map(string)<br>  attach\_to\_users      = list(string)<br>  attach\_to\_groups     = list(string)<br>}))</pre>                                                                                                                                      | `[]`    |    no    |
| <a name="input_use_root_path_template"></a> [use\_root\_path\_template](#input_use_root_path_template) | Whether to resolve policy templates relative to the root path instead of the module path.                                           | `bool`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `false` |    no    |

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
