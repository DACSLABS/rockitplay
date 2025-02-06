# --- Buckets
resource "oci_objectstorage_bucket" "edge_trc_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-trc-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "edge_trc_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.edge_trc_bucket,
      oci_identity_policy.edge_workspace_depl_pol
   ]
   bucket    = "edge-trc-bucket-${local.workspace}"
   namespace = var.EDGE_OCI_NAMESPACE
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


resource "oci_objectstorage_bucket" "edge_assets_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-assets-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "edge_assets_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.edge_assets_bucket,
      oci_identity_policy.edge_workspace_depl_pol
   ]
   bucket    = "edge-assets-bucket-${local.workspace}"
   namespace = var.EDGE_OCI_NAMESPACE
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


resource "oci_objectstorage_bucket" "edge_deps_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-deps-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "edge_deps_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.edge_deps_bucket,
      oci_identity_policy.edge_workspace_depl_pol
   ]
   bucket    = "edge-deps-bucket-${local.workspace}"
   namespace = var.EDGE_OCI_NAMESPACE
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




# --- Preauthenticated Requests

resource "oci_objectstorage_preauthrequest" "edge_trc_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.edge_trc_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-trc-bucket-${local.workspace}"
   name         = "read-only"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "edge_assets_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.edge_assets_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-assets-bucket-${local.workspace}"
   name         = "read-only"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "edge_deps_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.edge_deps_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-deps-bucket-${local.workspace}"
   name         = "read-only"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_bucket" "edge_tsk_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-tsk-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_preauthrequest" "edge_tsk_bucket_readwrite_par" {
   depends_on   = [ oci_objectstorage_bucket.edge_tsk_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-tsk-bucket-${local.workspace}"
   name         = "read-wrte"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_bucket" "edge_dev_bucket" {
   count          = local.env == "test" ? 1 : 0
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-dev-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_preauthrequest" "edge_dev_bucket_readwrite_par" {
   count        = local.env == "test" ? 1 : 0
   depends_on   = [ oci_objectstorage_bucket.edge_dev_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-dev-bucket-${local.workspace}"
   name         = "read-wrte"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_bucket" "edge_mc_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-mc-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_preauthrequest" "edge_rockitmc_read_par" {
   depends_on   = [ oci_objectstorage_bucket.edge_mc_bucket ]
   access_type  = "ObjectRead"
   bucket       = "edge-mc-bucket-${local.workspace}"
   name         = "read-rockitmc-only"
   object_name  = "rockit-mc.js"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

locals {
   dev_bucket_readwrite_par = (local.env == "test") ? "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_dev_bucket_readwrite_par[0].access_uri}" : null
}

locals {
   edge_tsk_bucket_readwrite_url    = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_tsk_bucket_readwrite_par.access_uri}"
   edge_trc_bucket_readwrite_url    = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_trc_bucket_readwrite_par.access_uri}"
   edge_assets_bucket_readwrite_url = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_assets_bucket_readwrite_par.access_uri}"
   edge_deps_bucket_readwrite_url   = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_deps_bucket_readwrite_par.access_uri}"
   edge_rockitmc_read_url           = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_rockitmc_read_par.access_uri}"
}