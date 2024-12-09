resource "oci_events_rule" "tar_event" {
   compartment_id =  oci_identity_compartment.engine_comp.id
   display_name   = "tar-event-${local.workspace}"
   description    = "object creation in engine-tar-bucket-${local.workspace}"
   condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\"],\"data\":{\"resourceName\":[\"*/*/*/native-build.tar\",\"*/*/*/trigger\"],\"additionalDetails\":{\"bucketName\":[\"engine-tar-bucket-${local.workspace}\"]}}}"
   is_enabled     = true
   actions {
      actions {
         action_type = "FAAS"
         is_enabled  = true
         function_id = oci_functions_function.engine_fn.id
      }
   }
}

resource "oci_events_rule" "raw_event" {
   compartment_id =  oci_identity_compartment.engine_comp.id
   display_name   = "raw-event-${local.workspace}"
   description    = "object creation in engine-raw-bucket-${local.workspace}"
   condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\"],\"data\":{\"resourceName\":[\"*/*/*/img.raw\",\"*/*/*/trigger\"],\"additionalDetails\":{\"bucketName\":[\"engine-raw-bucket-${local.workspace}\"]}}}"
   is_enabled     = true
   actions {
      actions {
         action_type = "FAAS"
         is_enabled  = true
         function_id = oci_functions_function.engine_fn.id
      }
   }
}

resource "oci_events_rule" "seq_event" {
   compartment_id =  oci_identity_compartment.engine_comp.id
   display_name   = "seq-event-${local.workspace}"
   description    = "object creation in engine-seq-bucket-${local.workspace}"
   condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\",\"com.oraclecloud.objectstorage.updateobject\"],\"data\":{\"resourceName\":[\"*/*/*/seq.latest\",\"*/*/*/trigger\"],\"additionalDetails\":{\"bucketName\":[\"engine-seq-bucket-${local.workspace}\"]}}}"
   is_enabled     = true
   actions {
      actions {
         action_type = "FAAS"
         is_enabled  = true
         function_id = oci_functions_function.engine_fn.id
      }
   }
}

resource "oci_events_rule" "trc_event" {
   compartment_id =  oci_identity_compartment.engine_comp.id
   display_name   = "trc-event-${local.workspace}"
   description    = "object creation in engine-trc-bucket-${local.workspace}"
   condition      = "{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\"],\"data\":{\"resourceName\":[\"*/*/*/traces.tar\"],\"additionalDetails\":{\"bucketName\":[\"engine-trc-bucket-${local.workspace}\"]}}}"
   is_enabled     = true
   actions {
      actions {
         action_type = "FAAS"
         is_enabled  = true
         function_id = oci_functions_function.engine_fn.id
      }
   }
}
