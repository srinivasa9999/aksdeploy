terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.64"
    }
  }
}

resource "octopusdeploy_deployment_process" "example" {
  project_id = var.prname
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
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"
    target_roles        = ["test"]
    run_kubectl_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      environments                       = []
      excluded_environments              = []
      name                               = "Run a kubectl CLI Script"
      is_disabled                        = false
      is_required                        = true
      properties                         = {
          "Octopus.Action.KubernetesContainers.Namespace" = "default"
          "Octopus.Action.RunOnServer"                    = "true"
          "Octopus.Action.Script.ScriptBody"              = "kubectl apply deploy.yml"
          "Octopus.Action.Script.ScriptSource"            = "Inline"
          "Octopus.Action.Script.Syntax"                  = "Bash"
      }
      run_on_server                      = "true"
    }
  }



  # depends_on = [
  #    octopusdeploy_project.pcreate
  #      ]
}


