variable "pgname" {
  type         = string
 # default      = "CVS"
  description  = "Project Group Name"
}

variable "pname" {
  type         = list
#  default      = ["ABC","DEF"]
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
  description = "Create k8s deployment target"
}

variable "ssh_username" {
  type        = string
 # default     = ""
  sensitive   = true
}


variable "ssh_password" {
  type        = string
 # default     = ""
#  sensitive   = true
}

variable "ssh_host" {
  type        = string
  default     = "SSH Hostname or IP Addr"
}