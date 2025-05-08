# --- Object Storage namespace
data "oci_objectstorage_namespace" "rockitplay_namespace" {
   compartment_id = var.compartment_ocid
}

locals {
   namespace = data.oci_objectstorage_namespace.rockitplay_namespace.namespace
}

# --- get engine-release.json and edge-release.json
locals {
   sys_bucket_name = "sys-bucket-${local.workspace}"
}
resource "oci_objectstorage_bucket" "sys_bucket" {
   compartment_id = var.compartment_ocid
   name           = local.sys_bucket_name
   namespace      = local.namespace
}

resource "oci_objectstorage_preauthrequest" "sys_bucket_readonly_par" {
   depends_on   = [ oci_objectstorage_bucket.sys_bucket ]
   access_type  = "AnyObjectRead"
   bucket       = local.sys_bucket_name
   name         = "read-only"
   namespace    = local.namespace
   time_expires = "2030-01-01T10:00:00+02:00"
}
locals {
   sys_bucket_readonly_par = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.sys_bucket_readonly_par.access_uri}"
}

resource "null_resource" "copy_json_to_sys_bucket" {
   count = var.APPLY_UPDATES ? 1 : 0
   triggers = {
      always      = timestamp()
      namespace   = local.namespace
      workspace   = local.workspace
      bucket_name = local.sys_bucket_name
   }

   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         curl --fail -o engine-release.json ${local.engine_dx_url}
         curl --fail -o edge-release.json   ${local.edge_dx_url}
         oci os object put --bucket-name ${self.triggers.bucket_name} --name engine-release.json --file ./engine-release.json --namespace ${self.triggers.namespace} --force
         oci os object put --bucket-name ${self.triggers.bucket_name} --name edge-release.json   --file ./edge-release.json   --namespace ${self.triggers.namespace} --force
      EOT
   }
   provisioner "local-exec" {
      when = destroy
      command = <<-EOT
         oci os object delete --bucket-name ${self.triggers.bucket_name} --name edge-release.tgz   --namespace ${self.triggers.namespace} --force 2>/dev/null || true
         oci os object delete --bucket-name ${self.triggers.bucket_name} --name engine-release.tgz --namespace ${self.triggers.namespace} --force 2>/dev/null || true
      EOT
   }
}

data "http" "engine_release_json" {
   depends_on = [ null_resource.copy_json_to_sys_bucket ]
   url        = "${local.sys_bucket_readonly_par}engine-release.json"
   request_headers = {
      Accept = "application/json"
   }
}
data "http" "edge_release_json" {
   depends_on = [ null_resource.copy_json_to_sys_bucket ]
   url        = "${local.sys_bucket_readonly_par}edge-release.json"
   request_headers = {
      Accept = "application/json"
   }
}
locals {
   engine_src_env   = jsondecode (data.http.engine_release_json.response_body).env
   engine_src_hash  = jsondecode (data.http.engine_release_json.response_body).srcHash
   engine_fn_url    = jsondecode (data.http.engine_release_json.response_body).fn
   engine_cwl_url   = jsondecode (data.http.engine_release_json.response_body).cwl
   engine_task_url  = jsondecode (data.http.engine_release_json.response_body).task
   engine_task_sig  = jsondecode (data.http.engine_release_json.response_body).taskSig
   engine_task_hash = jsondecode (data.http.engine_release_json.response_body).taskHash
}
locals {
   edge_src_env     = jsondecode (data.http.edge_release_json.response_body).env
   edge_src_hash    = jsondecode (data.http.edge_release_json.response_body).srcHash
   edge_mc_url      = jsondecode (data.http.edge_release_json.response_body).mc
   edge_fn_url      = jsondecode (data.http.edge_release_json.response_body).fn
   edge_cwl_url     = jsondecode (data.http.edge_release_json.response_body).cwl
   edge_task_url    = jsondecode (data.http.edge_release_json.response_body).task
   edge_task_sig    = jsondecode (data.http.edge_release_json.response_body).taskSig
   edge_task_hash   = jsondecode (data.http.edge_release_json.response_body).taskHash
}

module engine {
   source = "./engine"
   ENV                              = local.ENV
   WORKSPACE                        = local.WORKSPACE
   ENGINE_OCI_TENANCY_OCID          = var.tenancy_ocid
   ENGINE_OCI_REGION                = var.region
   ENGINE_OCI_NAMESPACE             = local.namespace
   ENGINE_PARENT_COMP_OCID          = var.compartment_ocid
   ENGINE_BASEENV_ID                = local.baseenv_id
   ENGINE_WITH_CERT                 = local.with_cert
   ENGINE_CERT_DOMAINNAME           = local.cert_domainname
   ENGINE_CERT_OCID                 = local.cert_ocid
   ENGINE_DNS_ZONE_OCID             = local.dns_zone_ocid
   ENGINE_LOADER_IMG_OCID           = local.rockitplay_loader_img_ocid
   ENGINE_N_CONTAINER_INSTANCES     = local.N_CONTAINER_INSTANCES[local.env]
   ENGINE_SRC_HASH                  = local.engine_src_hash
   ENGINE_SRC_ENV                   = local.engine_src_env
   ENGINE_FN_URL                    = local.engine_fn_url
   ENGINE_CWL_URL                   = local.engine_cwl_url
   ENGINE_TASK_URL                  = local.engine_task_url
   ENGINE_TASK_SIG                  = local.engine_task_sig
   ENGINE_TASK_HASH                 = local.engine_task_hash
   ENGINE_CWL_CONTAINER_SHAPE       = var.CWL_CONTAINER_SHAPE
   ENGINE_LB_BANDWIDTH_MBPS         = var.ENGINE_LB_BANDWIDTH_MBPS
   ENGINE_VAULT_OCID                = local.vault_ocid
   ENGINE_VAULT_KEY_OCID            = local.vault_key_ocid
   ENGINE_DB_ORGID                  = local.mongodbatlas_orgid
   ENGINE_DB_TYPE                   = local.engine_mongodbatlas_db_type
   ENGINE_DB_SIZE                   = local.engine_mongodbatlas_advanced_cluster_size
   ENGINE_DB_REGION                 = local.engine_mongodbatlas_region
   ENGINE_SLACK_TOKEN               = local.slack_token
   ENGINE_SLACK_ADMIN_CHANNEL       = var.ENGINE_SLACK_ADMIN_CHANNEL
   ENGINE_MAINTENANCE_MODE          = var.MAINTENANCE_MODE
   ENGINE_APPLY_UPDATES             = var.APPLY_UPDATES
   EDGE_DX_URL                      = local.edge_dx_url
}

locals {
   engine_edge_link       = base64decode (split (".", module.engine.rockit_edge_link)[1])
   engine_workspace       = split (",", local.engine_edge_link)[0]
   engine_oci_region      = split (",", local.engine_edge_link)[1]
   engine_base_url        = split (",", local.engine_edge_link)[2]
   engine_admin_token_b64 = split (",", local.engine_edge_link)[3]
   engine_edge_dx_url     = split (",", local.engine_edge_link)[4]
   engine_admin_token     = base64decode (local.engine_admin_token_b64)
}

module edge {
   source = "./edge"
   depends_on = [ module.engine ]
   ENV                            = local.ENV
   WORKSPACE                      = local.WORKSPACE
   EDGE_OCI_TENANCY_OCID          = var.tenancy_ocid
   EDGE_OCI_REGION                = var.region
   EDGE_OCI_NAMESPACE             = local.namespace
   EDGE_PARENT_COMP_OCID          = var.compartment_ocid
   EDGE_ROCKITPLAY_COMP_OCID      = local.rockitplay_comp_ocid
   EDGE_BASEENV_ID                = local.baseenv_id
   EDGE_CERT_DOMAINNAME           = local.cert_domainname
   EDGE_CERT_OCID                 = local.cert_ocid
   EDGE_DNS_ZONE_OCID             = local.dns_zone_ocid
   EDGE_N_CONTAINER_INSTANCES     = local.N_CONTAINER_INSTANCES[local.env]
   EDGE_LOADER_IMG_OCID           = local.rockitplay_loader_img_ocid
   EDGE_SRC_HASH                  = local.edge_src_hash
   EDGE_SRC_ENV                   = local.edge_src_env
   EDGE_MC_URL                    = local.edge_mc_url
   EDGE_FN_URL                    = local.edge_fn_url
   EDGE_CWL_URL                   = local.edge_cwl_url
   EDGE_TASK_URL                  = local.edge_task_url
   EDGE_TASK_SIG                  = local.edge_task_sig
   EDGE_TASK_HASH                 = local.edge_task_hash
   EDGE_CWL_CONTAINER_SHAPE       = var.CWL_CONTAINER_SHAPE
   EDGE_LB_BANDWIDTH_MBPS         = var.EDGE_LB_BANDWIDTH_MBPS
   EDGE_DX_URL                    = local.edge_dx_url
   EDGE_RSI_BASE_URL              = var.RSI_URL
   EDGE_WITH_CERT                 = local.with_cert
   EDGE_VAULT_OCID                = local.vault_ocid
   EDGE_VAULT_KEY_OCID            = local.vault_key_ocid
   EDGE_ENGINE_ADMIN_TOKEN        = local.engine_admin_token
   EDGE_ENGINE_BASE_URL           = module.engine.engine_base_url
   EDGE_DB_ORGID                  = local.mongodbatlas_orgid
   EDGE_DB_TYPE                   = local.edge_mongodbatlas_db_type
   EDGE_DB_SIZE                   = local.edge_mongodbatlas_advanced_cluster_size
   EDGE_DB_REGION                 = local.edge_mongodbatlas_region
   EDGE_MAINTENANCE_MODE          = var.MAINTENANCE_MODE
   EDGE_APPLY_UPDATES             = var.APPLY_UPDATES
   EDGE_SLACK_TOKEN               = local.slack_token
   EDGE_SLACK_ADMIN_CHANNEL       = var.EDGE_SLACK_ADMIN_CHANNEL
}

resource "null_resource" "engine_curl_post_initialize" {
   count      = var.APPLY_UPDATES ? 1 : 0
   depends_on = [ module.engine ]
   triggers   = { always = "${timestamp()}" }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         ENGINE_BASE_URL="https://${module.engine.engine_ipaddr}"
         chmod +x ./engine/gen-admin-token.sh
         token=$(./engine/gen-admin-token.sh '${module.engine.admin_secret_b64}' 'engine-stack')
         nRetries=0
         until [ $nRetries -ge 10 ]; do
            if curl --insecure --fail -H "x-rockit-engine-admin-token: $token" -X POST $ENGINE_BASE_URL/srv/v1/initialize; then
               break
            fi
            nRetries=$((nRetries+1))
            sleep 60
         done
      EOT
   }
}

resource "null_resource" "edge_curl_post_initialize" {
   count      = var.APPLY_UPDATES ? 1 : 0
   depends_on = [ module.edge ]
   triggers   = { always = "${timestamp()}" }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         EDGE_BASE_URL="https://${module.edge.edge_ipaddr}"
         chmod +x ./edge/gen-admin-token.sh
         token=$(./edge/gen-admin-token.sh '${module.edge.edge_admin_secret_b64}' 'edge-stack')
         nRetries=0
         until [ $nRetries -ge 10 ]; do
         if curl --insecure --fail -H "x-rockit-admin-token: $token" -X POST $EDGE_BASE_URL/srv/v1/initialize; then
            break
         fi
         nRetries=$((nRetries+1))
         sleep 60
         done
      EOT
   }
}

output "admin_secret_b64"   { value = module.edge.edge_admin_secret_b64 }
output "version"            { value = var.VERSION }
output "inject_link_edge"   { value = module.edge.inject_link }
output "inject_link_engine" { value = module.engine.inject_link }
# output "instance_id"      { value = module.edge.instance_id_output }
output "baseurl"            { value = module.edge.edge_base_url }
output "db_conn_edge"       { value = module.edge.edge_db_conn_str }
output "db_conn_engine"     { value = module.engine.engine_db_conn_str }
output "nat_gw_ip"          { value = module.edge.edge_nat_gw_ip }

