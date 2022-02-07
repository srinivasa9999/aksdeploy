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


resource "octopusdeploy_project_group" "gcreate" {
  description  = "AVA."
  name         = "AVA"
}

resource "octopusdeploy_project" "pcreate" {
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  description                          = "The development project."
  discrete_channel_release             = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = true
  lifecycle_id                         = "Lifecycles-2"   #variable
  name                                 = "AVAReport"      #variable
  project_group_id                     = "ProjectGroups-2" #variable
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
}

data "octopusdeploy_project_groups" "groups" {
  take                   = 2
}

output "groups" {
    value = data.octopusdeploy_project_groups.groups
}


resource "octopusdeploy_deployment_process" "example" {
  project_id = "Projects-4"
#   step {
#     condition    = "Success"
#     name         = "Manual intervention is needed"
# #    instructions = "Approve"
# #    can_be_used_for_project_versioning = "true"
#     manual_intervention_action {
#       name                               = "Manual intervention is needed"
#       is_disabled                        = false
#       is_required                        = true
#       responsible_teams                  = "Everyone"
#       instructions                       = "Approve"
#       can_be_used_for_project_versioning = "true"
# #      properties                         = "BlockConcurrentDeployments"
#     }
#   }





  step {
    condition           = "Success"
    name                = "Hello world (using PowerShell)"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    run_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = false
      is_required                        = true
      name                               = "Hello world (using PowerShell)"
      script_body                        = <<-EOT
          Write-Host 'Hello world, using PowerShell'
          #TODO: Experiment with steps of your own :)
          Write-Host '[Learn more about the types of steps available in Octopus](https://g.octopushq.com/OnboardingAddStepsLearnMore)'
        EOT
      run_on_server                      = true
    }
  }
  step {
    condition           = "Success"
    name                = "Hello world (using Bash)"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartWithPrevious"
    run_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = false
      is_required                        = true
      name                               = "Hello world (using Bash)"
      script_body                        = <<-EOT
          echo 'Hello world, using Bash'
          #TODO: Experiment with steps of your own :)
          echo '[Learn more about the types of steps available in Octopus](https://g.octopushq.com/OnboardingAddStepsLearnMore)'
        EOT
      run_on_server                      = true
    }
  }
}