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

variable "k8scluster" {
  type        = string
  default     = "https://akscluster-dns-7f2e4cbb.hcp.eastus.azmk8s.io:443"
  description = "Create k8s deployment target "
}