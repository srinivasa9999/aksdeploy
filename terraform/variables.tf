variable "pgname" {
  type         = string
  default      = "ECommerce App"
  description  = "Project Group Name"
}

variable "pname" {
  type         = string
  default      = "Ecommerce Services"
  description  = "Project  Name"
}

variable "environments" {
  description = "Create Environments with these Names"
  type        = list(string)
  default     = ["development", "qa", "prod"]
}