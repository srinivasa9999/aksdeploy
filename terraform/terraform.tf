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

data "octopusdeploy_users" example {
  take = 10
}

output "users" {
    value = data.octopusdeploy_users "srinivasa.nallapati@gmail.com" 
    sensitive = true
}