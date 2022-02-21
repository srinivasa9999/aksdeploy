terraform {
  backend "azurerm" {
    storage_account_name = "terraformoctopus"
    container_name       = "terraform"
    key                  = "key1"

    # rather than defining this inline, the SAS Token can also be sourced
    # from an Environment Variable - more information is available below.
    sas_token = "sp=racwdli&st=2022-02-21T09:44:33Z&se=2022-02-26T17:44:33Z&sv=2020-08-04&sr=c&sig=eZCMFwtmYE8oTmXRPz2zq9jXL8RZE%2FNPyoSGlZdyhts%3D"
  }
}


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
  alias    = "spacesupport"
  address    = "https://srinivas.octopus.app/"   
  api_key    = "API-IUDLNTKGAKKJYU2A4PVVIX5L9LXR72WA"
}

resource "octopusdeploy_space" "spaces" {
  provider                    = octopusdeploy.spacesupport
  description                 = ""
  name                        = var.pgname
  is_default                  = "false"
  is_task_queue_stopped       = false
  space_managers_team_members = []
  space_managers_teams        = ["teams-everyone"]
}

provider "octopusdeploy" {
  address    = "https://srinivas.octopus.app/"   
  api_key    = "API-IUDLNTKGAKKJYU2A4PVVIX5L9LXR72WA"
  space_id   =  octopusdeploy_space.spaces.id
}


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

resource "octopusdeploy_token_account" "akstoken" {
  name  = "Token Account "
  space_id = octopusdeploy_space.spaces.id
  token = "e43a46946cb6e5f2652d2ab7b5189ebcfca5856f45b5656a5945869d00b21cc1e353493fa833f6f2bda390d470e720749089d4ddf9da2fe403c4323f1620e20f"
}

resource "octopusdeploy_kubernetes_cluster_deployment_target" "k8s-target" {
  cluster_url                       = var.k8scluster
  environments                      = [local.vardev,local.varqa,local.varprod]
  name                              = "Kubernetes Cluster "
  roles                             = ["Development"]
  tenanted_deployment_participation = "Untenanted"
  skip_tls_verification             = "true"

  authentication {
      account_id = octopusdeploy_token_account.akstoken.id

  }
}


## Create dynamic worker pool , Cannot create stic VMS
resource "octopusdeploy_dynamic_worker_pool" "dynamicworker" {
    name                          = "dynamicWorkerpool"
    worker_type                   = "UbuntuDefault"
    is_default                    = "true"
    description                   =  "workers will be loaded from Octopus cloud"
}

# resource "octopusdeploy_ssh_key_account" "sshaccount" {
#   name             = "SSH Key Pair Account"
#   private_key_file = ""
#   username         = "srinivas"
# }
# resource "octopusdeploy_ssh_connection_deployment_target" "vmtarget" {
#   name        = "vmtarget"
#   fingerprint = ""
#   host        = "34.125.179.254"
#   port        = 22
#   account_id  = "createmanually"
#   roles       = ["vmtarget"]
#   environments= [local.vardev,local.varqa,local.varprod]
# }

# Define deployment Process



resource "octopusdeploy_deployment_process" "deploymentProcess" {
  project_id = octopusdeploy_project.pcreate.id
  step {
    condition           = "Success"
    name                = "Deployment Summary"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    run_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = true
      is_required                        = true
      name                               = "Deployment Summary"
      script_syntax                      = "Bash"
      script_body                        = <<-EOT
          echo "Deployment summary"          
        EOT
      run_on_server                      = "true"
      worker_pool_id                     = octopusdeploy_dynamic_worker_pool.dynamicworker.id
    }
  }




  step {
    condition    = "Success"
    name         = "Manual intervention"
    manual_intervention_action {
      name                               = "Manual intervention"
      is_disabled                        = "true"
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
    name                = "Create change request"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    run_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = true
      is_required                        = true
      name                               = "Create change request"
      script_syntax                      = "Bash"
      script_body                        = <<-EOT
          echo "Create change request"          
        EOT
      run_on_server                      = "true"
      worker_pool_id                     = octopusdeploy_dynamic_worker_pool.dynamicworker.id
    }
  }

  step {
    condition           = "Success"
    name                = "Prepare to Deploy"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    run_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = false
      is_required                        = true
      name                               = "Prepare to Deploy"
      script_syntax                      = "Bash"
      script_body                        = <<-EOT
            cd /home/srinivas/
            rm -rf aksdeploy
            git clone https://github.com/srinivasa9999/aksdeploy.git
            cd aksdeploy
            cat vars.yaml
          
        EOT
      run_on_server                      = "true"
      worker_pool_id                     = octopusdeploy_dynamic_worker_pool.dynamicworker.id
    }
  }

  step {
    condition           = "Success"
    name                = "Deploy to K8s"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    run_script_action {
      features     = [  "Octopus.Features.JsonConfigurationVariables", ]
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = false
      is_required                        = true
      name                               = "Deploy to K8s"
      script_syntax                      = "Bash"
      properties        = {
         "Octopus.Action.EnabledFeatures" = "Octopus.Features.JsonConfigurationVariables"
         "Octopus.Action.Package.JsonConfigurationVariablesTargets" = "vars.yaml"
      }
      script_body                        = <<-EOT
            cd /home/srinivas/aksdeploy/
            cat vars.yaml
            ./deployment.sh $(get_octopusvariable "services")
          
        EOT
      run_on_server                      = "true"
      worker_pool_id                     = octopusdeploy_dynamic_worker_pool.dynamicworker.id
    }
  }

#   step {
#     condition           = "Success"
#     name                = "Kubernetes Deploy"
#     start_trigger       = "StartAfterPrevious"
#     target_roles        = ["Development"]
#     run_kubectl_script_action {
#       can_be_used_for_project_versioning = true
#       condition                          = "Success"
#       environments                       = []
#       excluded_environments              = []
#       name                               = "Run a kubectl CLI Script"
#       is_disabled                        = false
#       is_required                        = false
#       properties                         = {
#           "Octopus.Action.Package.DownloadOnTentacle" = "True"
#           "Octopus.Action.Package.FeedId"             = "Feeds-1002"
#           "Octopus.Action.Package.PackageId"          = "srinivasa9999/aksdeploy"
#  #         "Octopus.Action.RunOnServer"                = "True"
#           "Octopus.Action.Script.ScriptFileName"      = "firsttime_deployment.sh"
#           "Octopus.Action.Script.ScriptSource"        = "Package"
#       }
#        run_on_server                      = "true"
#        script_file_name                   = "firsttime_deployment.sh"
#        package {
#           acquisition_location = "ExecutionTarget"
#           feed_id              = "Feeds-1002"
#           name                 = "k8stest"
#           extract_during_deployment = "true"
#           package_id           = "srinivasa9999/k8stest"

#       }
#    #   worker_pool_id                     = octopusdeploy_dynamic_worker_pool.dynamicworker.id 

#     }
#   }

step {
          condition           = "Success"
          name                = "Send an Email"
          package_requirement = "LetOctopusDecide"
          properties          = {} 
          start_trigger       = "StartAfterPrevious"
          action {
              action_type                        = "Octopus.Email" 
              can_be_used_for_project_versioning = false 
              condition                          = "Success"
              features                           = []
              is_disabled                        = false
              is_required                        = false
              name                               = "Send an Email"
              properties                         = {
                  "Octopus.Action.Email.Body"      = "deployment completed successfully"
                  "Octopus.Action.Email.Subject"   = "AVA Deployment"
                  "Octopus.Action.Email.To"        = "srinivasa.nallapati@gmail.com"
                  "Octopus.Action.Email.ToTeamIds" = "teams-everyone"
                }
              run_on_server                      = false

            }
}

  depends_on = [
     octopusdeploy_project.pcreate
       ]
}

locals {
  yamlvars = yamldecode(file("../vars.yaml"))
}
# output "namespace" {
#   value = local.yamlvars.productMgm.namespace
# }

locals {
  projectid = octopusdeploy_project.pcreate.id
}

resource "octopusdeploy_variable" "namespace" {
     name      = "productMgm:namespace"
     type      = "String"
     value     = local.yamlvars.productMgm.namespace
     owner_id = local.projectid
     prompt     {
         is_required  = "true"
     }
}
resource "octopusdeploy_variable" "deploy_action" {
     name      = "shoppingCart:deploy_action"
     type      = "String"
     value     = local.yamlvars.shoppingCart.deploy_action
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

resource "octopusdeploy_variable" "services" {
     name      = "services"
     type      = "String"
     value     = local.yamlvars.services
     owner_id = local.projectid
     prompt     {
         is_required  = "true"
 #        ControlType  = "dropdown"
     }
}












