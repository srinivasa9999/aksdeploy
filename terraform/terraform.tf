terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.68"
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
  is_default                  = "true"
  is_task_queue_stopped       = false
  space_managers_team_members = []
  space_managers_teams        = ["teams-everyone"]
}
# data "octopusdeploy_spaces" "spaces" {
#   take         = 100
# }
# output "spaceslist" {
#   value = data.octopusdeploy_spaces.spaces
# }



# ## Creating Environments (development, qa & Prod)
resource "octopusdeploy_environment" "environments" {
  for_each = toset(var.environments)
  allow_dynamic_infrastructure = false
  name                         = each.value
  use_guided_failure           = false
}

# output "envs" {
#   value = values(octopusdeploy_environment.environments)[*]
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
}

# data "octopusdeploy_project_groups" "groups" {
#   partial_name  = var.pgname
# }

# output "group" {
#   value = octopusdeploy_project_group.gcreate
# }
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


# module "deployProcess" {
#   source  = "./modules/deployProcess"
#   prname  = var.pname
#   depends_on = [
#      octopusdeploy_project.pcreate
#   ]
  
# }




resource "octopusdeploy_deployment_process" "deploymentProcess" {
  project_id = octopusdeploy_project.pcreate.id
  step {
    condition    = "Success"
    name         = "Manual intervention"
    manual_intervention_action {
      name                               = "Manual intervention"
      is_disabled                        = false
      is_required                        = true
      responsible_teams                  = "teams-everyone"
      instructions                       = "Approve"
#      can_be_used_for_project_versioning = "true"
      properties                         = {
            "Octopus.Action.Manual.BlockConcurrentDeployments" = "True"
            "Octopus.Action.Manual.Instructions"              = "Approve"
                }

    }
  }

  step {
    condition           = "Success"
    name                = "Hello world ( Bash)"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    run_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = false
      is_required                        = true
      name                               = "Hello world ( Bash)"
      script_syntax                      = "Bash"
      script_body                        = <<-EOT
          echo 'Hello world, using Bash'
          ls -ltr
          
        EOT
      run_on_server                      = "true"
      worker_pool_id                     = "WorkerPools-5"
    }
  }

  step {
    condition           = "Success"
    name                = "Kubernetes Deploy"
    start_trigger       = "StartAfterPrevious"
    target_roles        = ["test"]
    run_kubectl_script_action {
      can_be_used_for_project_versioning = true
      condition                          = "Success"
      environments                       = []
      excluded_environments              = []
      name                               = "Run a kubectl CLI Script"
      is_disabled                        = false
      is_required                        = false
      # properties                         = {
      #     "Octopus.Action.KubernetesContainers.Namespace" = "default"
      #     "Octopus.Action.RunOnServer"                    = "true"
      #     "Octopus.Action.Script.ScriptBody"              = "kubectl apply deploy.yml"
      #     "Octopus.Action.Script.ScriptSource"            = "Inline"
      #     "Octopus.Action.Script.Syntax"                  = "Bash"
      # }
      properties                         = {
          "Octopus.Action.Package.DownloadOnTentacle" = "True"
          "Octopus.Action.Package.FeedId"             = "Feeds-1002"
          "Octopus.Action.Package.PackageId"          = "srinivasa9999/aksdeploy"
 #         "Octopus.Action.RunOnServer"                = "True"
          "Octopus.Action.Script.ScriptFileName"      = "firsttime_deployment.sh"
          "Octopus.Action.Script.ScriptSource"        = "Package"
      }
                
#   #    script_source                      = "Inline"
       run_on_server                      = "true"
       script_file_name                   = "firsttime_deployment.sh"
       package {
          acquisition_location = "ExecutionTarget"
          feed_id              = "Feeds-1002"
#          id                   = "test"
          name                 = "k8stest"
          extract_during_deployment = "true"
          package_id           = "srinivasa9999/k8stest"
          # properties           = {
          #   "Octopus.Action.RunOnServer"                = "True"
          # }
      }
    }
  }

  depends_on = [
     octopusdeploy_project.pcreate
       ]
}



locals {
  projectid = octopusdeploy_project.pcreate.id
}

resource "octopusdeploy_variable" "deploytype" {
     name      = "deploytype"
     type      = "String"
     owner_id = local.projectid
     prompt     {
         is_required  = "true"
     }
}
resource "octopusdeploy_variable" "imageversion" {
     name      = "imageversion"
     type      = "String"
     owner_id = local.projectid
     prompt     {
         is_required  = "true"
 #        ControlType  = "dropdown"
     }
}
resource "octopusdeploy_variable" "environment" {
     name      = "environment"
     type      = "String"
     owner_id = local.projectid
     prompt     {
         is_required  = "true"
 #        ControlType  = "dropdown"
     }
}


data "octopusdeploy_spaces" "spaces" {
  take         = 100
  # spaces        {
  #   is_default  = "true"

  # }
}
output "defaultgroup" {
  value = data.octopusdeploy_spaces.spaces.spaceslist
}


