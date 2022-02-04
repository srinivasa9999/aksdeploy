terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.68"
    }
  }
}

provider "octopusdeploy" {
  # Configuration options
  address    = "https://srinivas.octopus.app/"   
  api_key    = "API-IUDLNTKGAKKJYU2A4PVVIX5L9LXR72WA"             
}

data "octopusdeploy_users" "example" {
  take = 10
}

output "users" {
    value = data.octopusdeploy_users.example
    sensitive = true
}

data "octopusdeploy_projects" "example" {
  take                   = 2
}

output "projects" {
    value = data.octopusdeploy_projects.example
}