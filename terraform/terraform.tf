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

resource "octopusdeploy_space" "spaces" {
  description                 = ""
  name                        = var.pgname
  is_default                  = false
  is_task_queue_stopped       = false
  space_managers_team_members = []
  space_managers_teams        = ["teams-everyone"]
}
data "octopusdeploy_spaces" "spaces" {
  take         = 100
}
output "spaceslist" {
  value = data.octopusdeploy_spaces.spaces
}

# ## Creating Environments (development, qa & Prod)
resource "octopusdeploy_environment" "environments" {
  for_each = toset(var.environments)
  allow_dynamic_infrastructure = false
  name                         = each.value
  use_guided_failure           = false
  lifecycle {
        ignore_changes = [name]
  }
}

output "envs" {
  value = values(octopusdeploy_environment.environments)[*]
}

# resource "octopusdeploy_environment" "development" {
#   allow_dynamic_infrastructure = false
#   description                  = "An environment for the development team."
#   name                         = "development"
#   sort_order                   = 0
#   use_guided_failure           = false
# }

locals {
  vardev = octopusdeploy_environment.environments["development"].id
}

locals {
  varqa = octopusdeploy_environment.environments["qa"].id
}
locals {
  varprod = octopusdeploy_environment.environments["prod"].id
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
    automatic_deployment_targets = [local.vardev,local.varqa,local.varprod]
    name                         = "Phase"
    minimum_environments_before_promotion = 1
  }
}

## Create Project Group

resource "octopusdeploy_project_group" "gcreate" {
  name         = var.pgname
  space_id     = octopusdeploy_space.spaces.id
}

data "octopusdeploy_project_groups" "groups" {
  partial_name  = var.pgname
}

output "group" {
  value = octopusdeploy_project_group.gcreate.id
}

## Create Project 


resource "octopusdeploy_project" "pcreate" {
  space_id                             = octopusdeploy_space.spaces.id
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  description                          = "The development project."
  discrete_channel_release             = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = false
  lifecycle_id                         = octopusdeploy_lifecycle.lifecycle.id
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




