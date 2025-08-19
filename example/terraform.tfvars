users = {
  "john.doe" = {
    create                  = true
    path                   = "/developers/"
    create_login_profile   = true
    password_length        = 20
    password_reset_required = true
    create_access_key      = true
    access_key_status      = "Active"
    create_ssh_key         = false
    ssh_key_encoding      = null
    ssh_public_key        = null
    policies               = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  },
  "jane.smith" = {
    create                 = true
    path                  = "/managers/"
    create_login_profile  = true
    password_length       = 20
    password_reset_required = true
    create_access_key     = true
    access_key_status     = "Active"
    create_ssh_key        = false
    ssh_key_encoding      = "SSH"
    ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
    policies              = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }
}

# Groups Configuration
groups = {
  "developers" = {
    create          = true
    path           = "/"
    users          = ["john.doe"]
    managed_policies = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
    inline_policy   = <<EOT
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
    create          = true
    path           = "/"
    users          = ["jane.smith"]
    managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    inline_policy   = ""
  }
}

# Custom Policies Configuration
policies = [
  {
    name        = "EC2RestrictedAccess"
    path        = "/custom/"
    desc        = "Custom policy for restricted EC2 access"
    policy_statement = <<EOT
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
    attach_to_users  = ["john.doe"]
    attach_to_groups = ["developers"]
  },
  {
    name                = "S3BucketSpecificAccess"
    path                = "/custom/"
    desc                = "Custom policy for S3 bucket access"
    policy_statement    = null
    policy_template_file = "s3_policy.json.tpl"
    policy_template_vars = {
      bucket_name = "my-example-bucket"
    }
    attach_to_users    = []
    attach_to_groups   = ["developers"]
  }
]

# Module Configuration
use_root_path_template = false