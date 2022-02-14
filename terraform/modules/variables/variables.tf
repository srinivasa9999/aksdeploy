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