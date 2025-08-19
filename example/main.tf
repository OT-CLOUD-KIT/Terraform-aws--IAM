provider "aws" {
  region = var.aws_region
}

module "iam_setup" {
  source = "../"  

  users                  = var.users
  groups                 = var.groups
  policies               = var.policies
  use_root_path_template = var.use_root_path_template
}
