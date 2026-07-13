# --- Buckets
resource "oci_objectstorage_bucket" "edge_html_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-html-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = false
}


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

resource "oci_objectstorage_preauthrequest" "edge_html_bucket_read_par" {
   depends_on = [ oci_objectstorage_bucket.edge_html_bucket ]
   access_type  = "AnyObjectRead"
   bucket       = "edge-html-bucket-${local.workspace}"
   name         = "read"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

resource "oci_objectstorage_preauthrequest" "edge_html_bucket_dev_readwrite_par" {
   count        = local.env == "test" ? 1 : 0
   depends_on   = [ oci_objectstorage_bucket.edge_html_bucket ]
   access_type  = "AnyObjectReadWrite"
   bucket       = "edge-html-bucket-${local.workspace}"
   name         = "dev-read-write"
   namespace    = var.EDGE_OCI_NAMESPACE
   time_expires = "2030-01-01T10:00:00+02:00"
}

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

resource "oci_objectstorage_bucket" "edge_apps_bucket" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-apps-bucket-${local.workspace}"
   namespace      = var.EDGE_OCI_NAMESPACE
   object_events_enabled = true
}

resource "null_resource" "dl_rockitplay_html" {
  depends_on = [oci_objectstorage_bucket.edge_html_bucket]

  triggers = {
    namespace            = var.EDGE_OCI_NAMESPACE
    workspace            = local.workspace
    bucket_name          = "edge-html-bucket-${local.workspace}"
    rockitplay_html_hash = var.EDGE_ROCKITPLAY_HTML_HASH
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -e

      # Download and extract
      curl --fail -o rockitplay-html.tgz ${var.EDGE_ROCKITPLAY_HTML_URL}
      tar -xzf rockitplay-html.tgz

      # Clean previous uploads
      oci os object bulk-delete \
        --bucket-name ${self.triggers.bucket_name} \
        --prefix "" \
        --namespace ${self.triggers.namespace} \
        --force

      APPS="mc gc welcome signup resetpw pushworker"

      for app in $APPS; do
        if [ ! -d "$app" ]; then
          echo "Warning: $app not found, skipping..."
          continue
        fi

        if test -f "$app/index.html"; then
          echo "Replacing __GOOGLE_CLIENT_ID__ in $app/index.html"
          sed -i 's|__GOOGLE_CLIENT_ID__|${var.EDGE_GOOGLE_CLIENT_ID}|g' $app/index.html
        fi

        echo "Uploading app: $app"

        # 1. Assets (long cache - immutable since files are hashed)
        oci os object bulk-upload \
          --bucket-name ${self.triggers.bucket_name} \
          --src-dir "$app" \
          --object-prefix "$app/" \
          --include "assets/*.css" \
          --content-type text/css \
          --cache-control "public, max-age=31536000, immutable" \
          --overwrite

         oci os object bulk-upload \
          --bucket-name ${self.triggers.bucket_name} \
          --src-dir "$app" \
          --object-prefix "$app/" \
          --include "assets/*.js" \
          --content-type application/javascript \
          --cache-control "public, max-age=31536000, immutable" \
          --overwrite

         oci os object bulk-upload \
          --bucket-name ${self.triggers.bucket_name} \
          --src-dir "$app" \
          --object-prefix "$app/" \
          --include "assets/*.png" \
          --content-type image/png \
          --cache-control "public, max-age=31536000, immutable" \
          --overwrite

         oci os object bulk-upload \
          --bucket-name ${self.triggers.bucket_name} \
          --src-dir "$app" \
          --object-prefix "$app/" \
          --include "assets/*.jpg" \
          --content-type image/jpeg \
          --cache-control "public, max-age=31536000, immutable" \
          --overwrite

        # 2. HTML files (short cache / must revalidate)
        oci os object bulk-upload \
          --bucket-name ${self.triggers.bucket_name} \
          --src-dir "$app" \
          --object-prefix "$app/" \
          --include "*.html" \
          --content-type text/html \
          --cache-control "public, max-age=0, must-revalidate" \
          --overwrite

      done

      # cleanup
      rm -rf rockitplay-html rockitplay-html.tgz
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      oci os object bulk-delete \
        --bucket-name ${self.triggers.bucket_name} \
        --prefix "" \
        --namespace ${self.triggers.namespace} \
        --force
    EOT
  }
}

locals {
   dev_bucket_readwrite_par       = (local.env == "test") ? "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_dev_bucket_readwrite_par[0].access_uri}" : null
   dev_html_bucket_readwrite_par  = (local.env == "test") ? "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_html_bucket_dev_readwrite_par[0].access_uri}" : null
}

locals {
   edge_html_bucket_read_url       = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_html_bucket_read_par.access_uri}"
   edge_tsk_bucket_readwrite_url   = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_tsk_bucket_readwrite_par.access_uri}"
   edge_trc_bucket_readwrite_url   = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_trc_bucket_readwrite_par.access_uri}"
   edge_deps_bucket_readwrite_url  = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_deps_bucket_readwrite_par.access_uri}"
   edge_depot_bucket_read_url      = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_depot_bucket_read_par.access_uri}"
   edge_depot_bucket_readwrite_url = "https://objectstorage.${var.EDGE_OCI_REGION}.oraclecloud.com${oci_objectstorage_preauthrequest.edge_depot_bucket_readwrite_par.access_uri}"
}