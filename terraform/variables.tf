variable "pgname" {
  type         = string
  default      = "group"
  description  = "Project Group Name"
}

variable "pname" {
  type         = string
  default      = "project"
  description  = "Project  Name"
}

variable "environments" {
  description = "Create Environments with these names"
  type        = list(string)
  default     = ["development", "qa", "prod"]
}