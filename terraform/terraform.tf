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
  space_id   = data.octopusdeploy_space.space.id
}

data "octopusdeploy_users" example {
  take = 100
}
data "users" {
    value = data octopusdeploy_users example
}