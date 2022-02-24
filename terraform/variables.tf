variable "octopusaddress" {
  type         = string
  description  = "octopus URL"
}

variable "octopus_api_key" {
  type         = string
  description  = "API key to authenticate Octopus"
}

variable "pgname" {
  type         = string
  description  = "Project Group Name"
}

variable "pname" {
  type         = list
  description  = "Project  Name"
}

variable "environments" {
  description  = "Create Environments with these Names"
  type         = list(string)
}

variable "k8scluster" {
  type         = string
  description  = "Create k8s deployment target"
}

variable "akstoken" {
  type         = string
  description  = "Create k8s deployment target"
}

variable "ssh_username" {
  type        = string
  sensitive   = true
}


variable "ssh_password" {
  type        = string
  sensitive   = true
}

variable "ssh_host" {
  type        = string
  default     = "SSH Hostname or IP Addr"
}