variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}
# variables.tf

variable "users" {
  description = "Map of IAM users to create"
  type = map(object({
    create                  = bool
    path                   = string
    create_login_profile   = bool
    password_length        = number
    password_reset_required = bool
    create_access_key      = bool
    access_key_status      = string
    create_ssh_key         = bool
    ssh_key_encoding       = optional(string)
    ssh_public_key         = optional(string)
    policies               = list(string)
  }))
  default = {}
}

variable "groups" {
  description = "Map of IAM groups to create"
  type = map(object({
    create          = bool
    path           = string
    users          = list(string)
    managed_policies = list(string)
    inline_policy   = string
  }))
  default = {}
}

variable "policies" {
  description = "List of custom IAM policies to create"
  type = list(object({
    name                = string
    path                = string
    desc                = string
    policy_statement    = optional(string)
    policy_template_file = optional(string)
    policy_template_vars = optional(map(any))
    attach_to_users     = list(string)
    attach_to_groups    = list(string)
  }))
  default = []
}

variable "use_root_path_template" {
  description = "Whether to look for policy templates in root path"
  type        = bool
  default     = false
}