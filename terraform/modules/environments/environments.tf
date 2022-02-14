terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.64"
    }
  }
}

data "octopusdeploy_environments" "example" {
  skip         = 5
  take         = 100
}