terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
      version = var.provider_ver
    }
  }
}

resource "octopusdeploy_variable" "deploytype" {
     name      = "deploytype"
     type      = "String"
     owner_id = var.projectid
     prompt     {
         is_required  = "true"
     }
}
resource "octopusdeploy_variable" "imageversion" {
     name      = "imageversion"
     type      = "String"
     owner_id = var.projectid
     prompt     {
         is_required  = "true"
 #        ControlType  = "dropdown"
     }
}