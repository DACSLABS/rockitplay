terraform {
   required_providers {
      mongodbatlas = {
         source  = "mongodb/mongodbatlas"
         version = "1.37.0"
      }
      ably = {
         source  = "ably/ably"
         version = "0.11.1"
      }
      # oci = {
      #    source  = "oracle/oci"
      #    version = ">= 5.38.0"
      # }
   }
 }
