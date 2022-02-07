
resource "octopusdeploy_deployment_process" "example" {
  project_id = "Projects-4"
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
    start_trigger       = "StartWithPrevious"
    run_script_action {
      can_be_used_for_project_versioning = false
      condition                          = "Success"
      is_disabled                        = false
      is_required                        = true
      name                               = "Hello world ( Bash)"
      script_body                        = <<-EOT
          echo 'Hello world, using Bash'
          ls -ltr
          
        EOT
      run_on_server                      = "true"
      worker_pool_id                     = "WorkerPools-5"
    }
  }
}