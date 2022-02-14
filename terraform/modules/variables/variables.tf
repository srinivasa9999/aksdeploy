terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = "0.7.64"
    }
  }
}

resource "octopusdeploy_variable" "deploytype" {
     name      = "deploytype"
     type      = "String"
     project_id = var.projectid
     prompt     {
         is_required  = "true"
     }
     

}