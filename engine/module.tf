# --- Environment variables
// 'prod', 'stage', 'test'
variable "ENV"                         { type = string }
variable "WORKSPACE"                   { type = string }

variable "ENGINE_OCI_TENANCY_OCID"     { type = string }
variable "ENGINE_OCI_REGION"           { type = string }
variable "ENGINE_OCI_NAMESPACE"        { type = string }

variable "ENGINE_PARENT_COMP_OCID"     { type = string }
variable "ENGINE_BASEENV_ID"           { type = string }

variable "ENGINE_VAULT_OCID"           { type = string }
variable "ENGINE_VAULT_KEY_OCID"       { type = string }

variable "ENGINE_LOADER_IMG_OCID"      { type = string }

variable "ENGINE_N_CONTAINER_INSTANCES" { type = number }

variable "ENGINE_DB_ORGID"             {
   type      = string
   sensitive = true
}
variable "ENGINE_DB_TYPE"              { type = string }
variable "ENGINE_DB_PROVIDER"          { type = string }
variable "ENGINE_DB_SIZE"              { type = string }
variable "ENGINE_DB_REGION"            { type = string }

variable "ENGINE_SRC_HASH"             { type = string }
variable "ENGINE_SRC_ENV"              { type = string }
variable "ENGINE_FN_URL"               { type = string }
variable "ENGINE_CWL_URL"              { type = string }
variable "ENGINE_TASK_URL"             { type = string }
variable "ENGINE_TASK_SIG"             { type = string }
variable "ENGINE_TASK_HASH"            { type = string }
variable "EDGE_DX_URL"                 { type = string }

variable "ENGINE_SLACK_TOKEN"          { type = string }
variable "ENGINE_SLACK_ADMIN_CHANNEL"  { type = string }
variable "ENGINE_SLACK_ERROR_CHANNEL"  { type = string }
variable "ENGINE_SLACK_INFO_CHANNEL"   { type = string }

variable "ENGINE_WITH_CERT" {
   type = bool
}
variable "ENGINE_CERT_DOMAINNAME" {
   type    = string
   default = null
}
variable "ENGINE_CERT_OCID" {
   type    = string
   default = null
}

variable "ENGINE_APIGW_CONNECTION_TIMEOUT"  {
   type    = number
   default = 60
}
variable "ENGINE_APIGW_READ_TIMEOUT"  {
   type    = number
   default = 60
}
variable "ENGINE_APIGW_SEND_TIMEOUT"  {
   type    = number
   default = 60
}

variable "vcn_cidr" {
   type = string
   default = "10.10.0.0/16"
}
variable "vcn_pub_cidr" {
   type = string
   default = "10.10.0.0/20"
}
variable "vcn_priv_cidr" {
   type = string
   default = "10.10.16.0/20"
}
variable "vcn_adm_cidr" {
   type = string
   default = "10.10.32.0/20"
}

locals {
   env             = lower (var.ENV)
   ENV             = upper (var.ENV)
   workspace       = lower (var.WORKSPACE)
   WORKSPACE       = upper (var.WORKSPACE)
   registry_prefix = "${var.ENGINE_OCI_REGION}.ocir.io/${var.ENGINE_OCI_NAMESPACE}/"
   engine_registry = "${local.registry_prefix}engine-registry-${local.workspace}"
   use_cwl         = var.ENGINE_N_CONTAINER_INSTANCES > 0
}

# --- instance / rollout identifier
resource "random_password" "instance_id" {
  length           = 10
  special          = false
  upper            = true
  lower            = true
  numeric          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

# --- Public IP address
data "http" "public_ip" {
   url = "http://ipv4.icanhazip.com"
}

# --- Availability domains
data "oci_identity_availability_domains" "engine_availability_domains" {
   compartment_id = oci_identity_compartment.engine_comp.id
}

# --- Compartments
resource "oci_identity_compartment" "engine_comp" {
    compartment_id = var.ENGINE_PARENT_COMP_OCID
    description    = "ROCKIT Engine"
    name           = "engine-comp-${local.workspace}"
    enable_delete  = true
}

# --- Log group
resource "oci_logging_log_group" "engine_log_group" {
   compartment_id = oci_identity_compartment.engine_comp.id
   display_name   = "engine-log-${local.workspace}"
   description    = "Combined logs of ROCKIT Engine"
}

# --- Logs
resource "oci_logging_log" "engine_task_log" {
   display_name       = "engine-task-log-${local.workspace}"
   log_group_id       = oci_logging_log_group.engine_log_group.id
   log_type           = "CUSTOM"
   is_enabled         = true
   retention_duration = 30
}

# --- Policies
resource "oci_identity_policy" "engine_workspace_depl_pol" {
   depends_on     = [
      oci_identity_compartment.engine_comp,
      oci_identity_group.engine_registry_group,
   ]
   compartment_id = var.ENGINE_PARENT_COMP_OCID
   description    = "ROCKIT Engine [${local.workspace}] Deployment Workspace Policy"
   name           = "engine-workspace-depl-pol-${local.workspace}"
   statements     = [
      "Allow group engine-registry-group-${local.workspace} to manage repos in compartment engine-comp-${local.workspace}",
      "Allow service objectstorage-${var.ENGINE_OCI_REGION} to manage object-family in compartment engine-comp-${local.workspace}"
   ]
}

# --- wait for user IAM policy
resource "time_sleep" "engine_wait_for_registry_user" {
  depends_on = [
    oci_identity_policy.engine_workspace_depl_pol,
    oci_identity_auth_token.engine_registry_user_authtoken
  ]
  create_duration = "120s"
}

# --- inject.sh link
locals {
   inject_link_args = [
      local.workspace,
      var.ENGINE_OCI_REGION,
      var.ENGINE_OCI_NAMESPACE,
      local.engine_apigw_url,
      local.engine_admin_secret_b64,
      oci_functions_function.engine_fn.id,
      "x64",
      (local.env == "test") ? local.dev_bucket_readwrite_par : "",
      (local.env == "test" && local.use_cwl) ? oci_container_instances_container_instance.engine_cwl[0].id : ""
   ]
   inject_link_data = base64encode(join (",", local.inject_link_args))
}

# --- Update database after deployment
data "oci_vault_secrets" "engine_admin_secret" {
   depends_on     = [ oci_vault_secret.admin_secret ]
   vault_id       = var.ENGINE_VAULT_OCID
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "ENGINE_ADMIN_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
}
data "oci_secrets_secretbundle" "engine_admin_secretbundle" { secret_id = data.oci_vault_secrets.engine_admin_secret.secrets.0.id }
locals {
   engine_admin_secret_b64 = sensitive(data.oci_secrets_secretbundle.engine_admin_secretbundle.secret_bundle_content.0.content)
}

resource "null_resource" "curl_post_initialize" {
   depends_on = [
      oci_apigateway_deployment.engine_adm_api_deployment,
      oci_functions_function.engine_fn
   ]
   triggers = {
      # always = "${timestamp()}"
      src_updated  = var.ENGINE_SRC_HASH
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         ENGINE_BASE_URL="${local.engine_apigw_url}"
         chmod +x ./engine/gen-admin-token.sh
         token=$(./engine/gen-admin-token.sh '${local.engine_admin_secret_b64}' 'engine-stack')
         curl --insecure -H "x-rockit-engine-admin-token: $token" -H "Content-Type: application/json" -X POST $ENGINE_BASE_URL/adm/v1/initialize || true
      EOT
   }
}

# --- prepare ROCKIT Engine link to ROCKIT Edge instance(s)
resource "null_resource" "edge_admin_token" {
   triggers = {
      always = "${timestamp()}"
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         chmod +x ./engine/gen-admin-token.sh
         token=$(./engine/gen-admin-token.sh '${local.engine_admin_secret_b64}' 'ROCKIT Edge Service')
         echo -n $token > ${path.module}/edge_admin_token
      EOT
   }
}
data "local_file" "edge_admin_token_file" {
   depends_on = [ null_resource.edge_admin_token ]
   filename   = "${path.module}/edge_admin_token"
}
locals {
   edge_link_args = [
      local.workspace,
      var.ENGINE_OCI_REGION,
      local.engine_base_url,
      data.local_file.edge_admin_token_file.content_base64,
      var.EDGE_DX_URL,
   ]
   edge_link_data = base64encode(join (",", local.edge_link_args))
}

# --- Output
output "instance_id_output" {
   value = nonsensitive(random_password.instance_id.result)
}

output "rockit_edge_link" {
   value = "dxedgelnk1.${local.edge_link_data}"
}

output "inject_link" {
   value = local.env == "test" ? "dxinjectlnk2.engine.${nonsensitive(local.inject_link_data)}" : null
}

output "apigw_url" {
   value = local.engine_apigw_url
}

output "admin_secret_b64" {
   value = nonsensitive (local.engine_admin_secret_b64)
}

output "engine_db_conn_str" {
   value = nonsensitive (local.mongodb_connstr)
}