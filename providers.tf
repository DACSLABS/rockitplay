terraform {
   required_providers {
      mongodbatlas = {
         source  = "mongodb/mongodbatlas"
         version = "1.37.0"
      }
      # oci = {
      #    source  = "oracle/oci"
      #    version = ">= 5.38.0"
      # }
   }
}

provider "mongodbatlas" {
   public_key  = local.mongodbatlas_admin_pubkey
   private_key = local.mongodbatlas_admin_privkey
}
