resource "oci_events_rule" "edge_depot_event" {
   compartment_id =  oci_identity_compartment.edge_comp.id
   display_name   = "edge-depot-event-${local.workspace}"
   description    = "object creation in edge-depot-bucket-${local.workspace}"
   condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\",\"com.oraclecloud.objectstorage.updateobject\"],\"data\":{\"resourceName\":[\"*/*/*/deploy.json\",\"*/*/*/trigger\"],\"additionalDetails\":{\"bucketName\":[\"edge-depot-bucket-${local.workspace}\"]}}}"
   is_enabled     = true
   actions {
      actions {
         action_type = "FAAS"
         is_enabled  = true
         function_id = oci_functions_function.edge_fn.id
      }
   }
}

resource "oci_events_rule" "edge_assets_event" {
   compartment_id =  oci_identity_compartment.edge_comp.id
   display_name   = "edge-assets-event-${local.workspace}"
   description    = "object creation in edge-assets-bucket-${local.workspace}"
   condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\"],\"data\":{\"resourceName\":[\"*/*/*.png\",\"*/*/*.jpg\"],\"additionalDetails\":{\"bucketName\":[\"edge-assets-bucket-${local.workspace}\"]}}}"
   is_enabled     = true
   actions {
      actions {
         action_type = "FAAS"
         is_enabled  = true
         function_id = oci_functions_function.edge_fn.id
      }
   }
}

resource "oci_events_rule" "edge_deps_event" {
   compartment_id =  oci_identity_compartment.edge_comp.id
   display_name   = "edge-deps-event-${local.workspace}"
   description    = "object creation in edge-deps-bucket-${local.workspace}"
   condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\"],\"data\":{\"resourceName\":[\"*/*/*.exe\"],\"additionalDetails\":{\"bucketName\":[\"edge-deps-bucket-${local.workspace}\"]}}}"
   is_enabled     = true
   actions {
      actions {
         action_type = "FAAS"
         is_enabled  = true
         function_id = oci_functions_function.edge_fn.id
      }
   }
}