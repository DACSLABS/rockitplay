# --- Buckets
resource "oci_objectstorage_bucket" "edge_trc_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-trc-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = false
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

resource "oci_objectstorage_bucket" "edge_depot_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-depot-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "oci_objectstorage_object_lifecycle_policy" "edge_depot_bucket_lifecycle" {
   depends_on = [
      oci_objectstorage_bucket.edge_depot_bucket,
      oci_identity_policy.edge_workspace_depl_pol
   ]
   bucket    = "edge-depot-bucket-${local.workspace}"
   namespace = var.EDGE_OCI_NAMESPACE
   rules {
      target = "multipart-uploads"
      action = "ABORT"
      is_enabled = true
      name = "delete uncommitted multipart uploads"
      time_amount = 1
      time_unit = "DAYS"
   }
}


# --- Preauthenticated Requests

resource "oci_objectstorage_preauthrequest" "edge_trc_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.edge_trc_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-trc-bucket-${local.workspace}"
   name         = "read-write"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "edge_deps_bucket_readwrite_par" {
   depends_on = [ oci_objectstorage_bucket.edge_deps_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-deps-bucket-${local.workspace}"
   name         = "read-write"
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
   name         = "read-write"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "edge_depot_bucket_read_par" {
   depends_on   = [ oci_objectstorage_bucket.edge_depot_bucket ]
   access_type  = "AnyObjectRead"
   bucket       = "edge-depot-bucket-${local.workspace}"
   name         = "read-only"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "edge_depot_bucket_readwrite_par" {
   depends_on   = [ oci_objectstorage_bucket.edge_depot_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-depot-bucket-${local.workspace}"
   name         = "read-write"
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
   name         = "read-write"
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


resource "null_resource" "dl_mc" {
   depends_on   = [ oci_objectstorage_bucket.edge_mc_bucket ]
   triggers = {
   #  always      = timestamp ()
      mc_hash     = var.EDGE_MC_HASH
      namespace   = var.EDGE_OCI_NAMESPACE
      workspace   = local.workspace
      bucket_name = "edge-mc-bucket-${local.workspace}"
   }

   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         curl --fail -o rockit-mc.js ${var.EDGE_MC_URL}
         oci os object put --bucket-name ${self.triggers.bucket_name} --name rockit-mc.js --file ./rockit-mc.js --content-type application/javascript --namespace ${self.triggers.namespace} --force
      EOT
   }
   provisioner "local-exec" {
      when = destroy
      command = <<-EOT
         oci os object delete --bucket-name ${self.triggers.bucket_name} --name rockit-mc.js --namespace ${self.triggers.namespace} --force 2>/dev/null || true
      EOT
   }
}


locals {
   dev_bucket_readwrite_par = (local.env == "test") ? "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_dev_bucket_readwrite_par[0].access_uri}" : null
}

locals {
   edge_tsk_bucket_readwrite_url     = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_tsk_bucket_readwrite_par.access_uri}"
   edge_trc_bucket_readwrite_url     = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_trc_bucket_readwrite_par.access_uri}"
   edge_deps_bucket_readwrite_url    = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_deps_bucket_readwrite_par.access_uri}"
   edge_depot_bucket_read_url        = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_depot_bucket_read_par.access_uri}"
   edge_depot_bucket_readwrite_url   = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_depot_bucket_readwrite_par.access_uri}"
   edge_rockitmc_read_url            = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_rockitmc_read_par.access_uri}"
}