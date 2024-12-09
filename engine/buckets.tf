# --- Buckets
resource "oci_objectstorage_bucket" "tar_bucket" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-tar-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "tar_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.tar_bucket,
      oci_identity_policy.engine_workspace_depl_pol
   ]
   bucket    = "engine-tar-bucket-${local.workspace}"
   namespace = var.ENGINE_OCI_NAMESPACE
   rules {
      target = "multipart-uploads"
      action = "ABORT"
      is_enabled = true
      name = "delete uncommitted multipart uploads"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*.invalid" ] }
      name = "delete *.invalid"
      time_amount = 1
      time_unit = "DAYS"
   }
}


resource "oci_objectstorage_bucket" "raw_bucket" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-raw-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "raw_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.raw_bucket,
      oci_identity_policy.engine_workspace_depl_pol
   ]
   bucket     = "engine-raw-bucket-${local.workspace}"
   namespace  = var.ENGINE_OCI_NAMESPACE
   rules {
      target = "multipart-uploads"
      action = "ABORT"
      is_enabled = true
      name = "delete uncommitted multipart uploads"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*.invalid" ] }
      name = "delete *.invalid"
      time_amount = 1
      time_unit = "DAYS"
   }
}

resource "oci_objectstorage_bucket" "seq_bucket" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-seq-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "seq_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.seq_bucket,
      oci_identity_policy.engine_workspace_depl_pol
   ]
   bucket     = "engine-seq-bucket-${local.workspace}"
   namespace  = var.ENGINE_OCI_NAMESPACE
   rules {
      target = "multipart-uploads"
      action = "ABORT"
      is_enabled = true
      name = "delete uncommitted multipart uploads"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*.invalid" ] }
      name = "delete *.invalid"
      time_amount = 1
      time_unit = "DAYS"
   }
}

resource "oci_objectstorage_bucket" "dxf_bucket" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-dxf-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "dxf_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.dxf_bucket,
      oci_identity_policy.engine_workspace_depl_pol
   ]
   bucket     = "engine-dxf-bucket-${local.workspace}"
   namespace  = var.ENGINE_OCI_NAMESPACE
   rules {
      target = "multipart-uploads"
      action = "ABORT"
      is_enabled = true
      name = "delete uncommitted multipart uploads"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*.invalid" ] }
      name = "delete *.invalid"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*" ] }
      name = "delete *"
      time_amount = 2
      time_unit = "DAYS"
   }
}

resource "oci_objectstorage_bucket" "pat_bucket" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-pat-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "pat_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.pat_bucket,
      oci_identity_policy.engine_workspace_depl_pol
   ]
   bucket     = "engine-pat-bucket-${local.workspace}"
   namespace  = var.ENGINE_OCI_NAMESPACE
   rules {
      target = "multipart-uploads"
      action = "ABORT"
      is_enabled = true
      name = "delete uncommitted multipart uploads"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*.invalid" ] }
      name = "delete *.invalid"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*" ] }
      name = "delete *"
      time_amount = 2
      time_unit = "DAYS"
   }
}

resource "oci_objectstorage_bucket" "trc_bucket" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-trc-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "trc_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.trc_bucket,
      oci_identity_policy.engine_workspace_depl_pol
   ]
   bucket     = "engine-trc-bucket-${local.workspace}"
   namespace  = var.ENGINE_OCI_NAMESPACE
   rules {
      target = "multipart-uploads"
      action = "ABORT"
      is_enabled = true
      name = "delete uncommitted multipart uploads"
      time_amount = 1
      time_unit = "DAYS"
   }
   rules {
      target = "objects"
      action = "DELETE"
      is_enabled = true
      object_name_filter { inclusion_patterns = [ "*.invalid" ] }
      name = "delete *.invalid"
      time_amount = 1
      time_unit = "DAYS"
   }
}


resource "oci_objectstorage_bucket" "tsk_bucket" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-tsk-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_bucket" "dev_bucket" {
   count          = local.env == "test" ? 1 : 0
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-dev-bucket-${local.workspace}"
   namespace      = var.ENGINE_OCI_NAMESPACE
   object_events_enabled = true
}


# --- Preauthenticated Requests

resource "oci_objectstorage_preauthrequest" "tar_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.tar_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-tar-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "raw_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.raw_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-raw-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "dxf_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.dxf_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-dxf-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "seq_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.seq_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-seq-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "trc_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.trc_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-trc-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "pat_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.pat_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-pat-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "tsk_bucket_readwrite_par" {
   depends_on   = [ oci_objectstorage_bucket.tsk_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-tsk-bucket-${local.workspace}"
   name         = "read-wrte"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "dev_bucket_readwrite_par" {
   count        = local.env == "test" ? 1 : 0
   depends_on   = [ oci_objectstorage_bucket.dev_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "engine-dev-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.ENGINE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

locals {
   dev_bucket_readwrite_par = (local.env == "test") ? "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.dev_bucket_readwrite_par[0].access_uri}" : null
}

locals {
   tsk_bucket_readwrite_url = "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.tsk_bucket_readwrite_par.access_uri}"
   tar_bucket_readwrite_url = "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.tar_bucket_readwrite_par.access_uri}"
   raw_bucket_readwrite_url = "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.raw_bucket_readwrite_par.access_uri}"
   dxf_bucket_readwrite_url = "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.dxf_bucket_readwrite_par.access_uri}"
   seq_bucket_readwrite_url = "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.seq_bucket_readwrite_par.access_uri}"
   trc_bucket_readwrite_url = "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.trc_bucket_readwrite_par.access_uri}"
   pat_bucket_readwrite_url = "https://objectstorage.${var.ENGINE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.pat_bucket_readwrite_par.access_uri}"
}