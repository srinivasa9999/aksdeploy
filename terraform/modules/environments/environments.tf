terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.64"
    }
  }
}

resource "octopusdeploy_environment" "example" {
  allow_dynamic_infrastructure = false
  description                  = "An environment for the development team."
  name                         = "development"
  use_guided_failure           = false
}

