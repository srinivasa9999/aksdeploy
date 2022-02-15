variable "pgname" {
  type         = string
  default      = "ECommerce App-1"
  description  = "Project Group Name"
}

variable "pname" {
  type         = string
  default      = "Ecommerce Services-1"
  description  = "Project  Name"
}

variable "environments" {
  description = "Create Environments with these Names"
  type        = list(string)
  default     = ["development", "qa", "prod"]
}