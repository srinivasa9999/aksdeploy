terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.64"
    }
  }
}

##  Octopus Login 
provider "octopusdeploy" {
  address    = "https://srinivas.octopus.app/"   
  api_key    = "API-IUDLNTKGAKKJYU2A4PVVIX5L9LXR72WA"             
}

## Creating Environments (development, qa & Prod)
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

variable "vardev" {
 type    = string
 default = octopusdeploy_environment.development.id
}
variable "varqa" {
 type    = string
 default = octopusdeploy_environment.qa.id
}
variable "varprod" {
 type    = string
 default = octopusdeploy_environment.prod.id
}


## Creating lifecycle between Environments

resource "octopusdeploy_lifecycle" "lifecycle" {
  description = "This is the default lifecycle."
  name        = "LifeCycle"

  release_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = true
    unit                = "Days"
  }
  tentacle_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = false
    unit                = "Items"
  }

  phase {
    automatic_deployment_targets = [var.vardev,var.varqa,var.varprod]
    name                         = "Phase"
    minimum_environments_before_promotion = 1
  }
}



resource "octopusdeploy_project_group" "gcreate" {
  name         = var.pgname
}

data "octopusdeploy_project_groups" "groups" {
  partial_name  = var.pgname
}

output "group" {
  value = octopusdeploy_project_group.gcreate.id
}

# output "groups" {
#   value = data.octopusdeploy_project_groups.groups.project_groups[0].id
# }
# locals {
#   projectID = "data.octopusdeploy_project_groups.groups.project_groups[0].id"

# }


resource "octopusdeploy_project" "pcreate" {
  space_id                             =  "Spaces-1"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  description                          = "The development project."
  discrete_channel_release             = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = false
  lifecycle_id                         = "Lifecycles-23"   #variable
  name                                 = var.pname      #variable
  project_group_id                     = octopusdeploy_project_group.gcreate.id
  tenanted_deployment_participation    = "Untenanted"


  
  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }
#   git_persistence_settings  "git" {
#     url  = "https://github.com/srinivasa9999/aksdeploy.git"
#   }
#   git_persistence_settings.credentials {
#     username = "srinivasa9999"
#     password = "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"
#   }

  template {
    default_value = "example-default-value"
    help_text     = "example-help-test"
    label         = "example-label"
    name          = "example-template-value"
    display_settings = {
      "Octopus.ControlType" : "SingleLineText"
    }
  }
  depends_on  = [octopusdeploy_project_group.gcreate]
}


module "deployProcess" {
  source  = "./modules/deployProcess"
  prname  = var.pname
  depends_on = [
     octopusdeploy_project.pcreate
  ]
  
}




module "projectvariables" {
  source    = "./modules/variables"
  projectid = octopusdeploy_project.pcreate.id
}




