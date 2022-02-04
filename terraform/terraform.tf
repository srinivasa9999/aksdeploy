terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.64"
    }
  }
}

provider "octopusdeploy" {
  # Configuration options
  address    = "https://srinivas.octopus.app/"   
  api_key    = "API-IUDLNTKGAKKJYU2A4PVVIX5L9LXR72WA"             
}

data "octopusdeploy_project_groups" "groups" {
  take                   = 2
  skip                   =5
}

output "projects" {
    value = data.octopusdeploy_project_groups.groups
}
