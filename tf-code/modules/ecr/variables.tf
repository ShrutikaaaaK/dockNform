variable "repo_name" { type = string }
variable "scan_on_push" { type = bool }
variable "expire_untagged_after_days" { type = number default = 7 }
