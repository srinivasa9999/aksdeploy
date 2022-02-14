terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.64"
    }
  }
}

resource "octopusdeploy_environment" "development" {
  allow_dynamic_infrastructure = false
  description                  = "An environment for the development team."
  name                         = "development"
  sort_order                   = 0
  use_guided_failure           = false
}

resource "octopusdeploy_environment" "qa" {
  allow_dynamic_infrastructure = false
  description                  = "An environment for the qa team."
  name                         = "qa"
  sort_order                   = 1
  use_guided_failure           = false
}

resource "octopusdeploy_environment" "prod" {
  allow_dynamic_infrastructure = false
  description                  = "An environment for the Production team."
  name                         = "prod"
  sort_order                   = 2
  use_guided_failure           = false
}

data "octopusdeploy_environments" "example" {
#  skip         = 5
  take         = 100
}
output "environments" {
    value = data.octopusdeploy_environments.example.environments[*].name
}

