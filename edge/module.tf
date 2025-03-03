# --- Environment variables
// 'prod', 'stage', 'test'
variable "ENV"                        { type = string }
variable "WORKSPACE"                  { type = string }

variable "EDGE_OCI_TENANCY_OCID"      { type = string }
variable "EDGE_OCI_REGION"            { type = string }
variable "EDGE_OCI_NAMESPACE"         { type = string }

variable "EDGE_PARENT_COMP_OCID"      { type = string }
variable "EDGE_ROCKITPLAY_COMP_OCID"  { type = string }
variable "EDGE_BASEENV_ID"            { type = string }

variable "EDGE_VAULT_OCID"            { type = string }
variable "EDGE_VAULT_KEY_OCID"        { type = string }

variable "EDGE_LOADER_IMG_OCID"       { type = string }

variable "EDGE_N_CONTAINER_INSTANCES" { type = number }
variable "EDGE_LB_BANDWIDTH_MBPS"     { type = number }

variable "EDGE_DB_ORGID"              {
   type      = string
   sensitive = true
}
variable "EDGE_DB_TYPE"               { type = string }
variable "EDGE_DB_SIZE"               { type = string }
variable "EDGE_DB_REGION"             { type = string }

variable "EDGE_ENGINE_BASE_URL"       { type = string }
variable "EDGE_ENGINE_ADMIN_TOKEN"    { type = string }

variable "EDGE_SRC_HASH"              { type = string }
variable "EDGE_SRC_ENV"               { type = string }
variable "EDGE_FN_URL"                { type = string }
variable "EDGE_CWL_URL"               { type = string }
variable "EDGE_TASK_URL"              { type = string }
variable "EDGE_TASK_SIG"              { type = string }
variable "EDGE_TASK_HASH"             { type = string }

variable "EDGE_CWL_CONTAINER_SHAPE"   { type = string }

variable "EDGE_DX_URL"                { type = string }

variable "EDGE_SLACK_TOKEN"           { type = string }
variable "EDGE_SLACK_ADMIN_CHANNEL"   { type = string }
variable "EDGE_SLACK_ERROR_CHANNEL"   { type = string }
variable "EDGE_SLACK_INFO_CHANNEL"    { type = string }

variable "EDGE_WITH_CERT" {
   type = bool
}
variable "EDGE_CERT_DOMAINNAME" {
   type = string
   default = ""
}
variable "EDGE_CERT_OCID" {
   type = string
   default = ""
}

variable "EDGE_USE_S3_BACKEND" {
   type    = bool
   default = false
}

variable "EDGE_RSI_BASE_URL" {
   type    = string
   default = "https://public.cloud.rockitplay.com/rsi"
}

variable "EDGE_APIGW_CONNECTION_TIMEOUT"  {
   type    = number
   default = 60
}
variable "EDGE_APIGW_READ_TIMEOUT"  {
   type    = number
   default = 60
}
variable "EDGE_APIGW_SEND_TIMEOUT"  {
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
   registry_prefix = "${var.EDGE_OCI_REGION}.ocir.io/${var.EDGE_OCI_NAMESPACE}/"
   edge_registry   = "${local.registry_prefix}edge-registry-${local.workspace}"
   use_cwl         = var.EDGE_N_CONTAINER_INSTANCES > 0
   cwl_shapes = {
      "CI.Standard.A1.Flex" = {
         platform = "linux/arm64"
      }
      "CI.Standard.E4.Flex" = {
         platform = "linux/amd64"
      }
   }
}

locals {
   orgTokenPubKeyB64 = {
      prod  = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQ0FnRUEzSEsrV1owNXQyb3Fic05mcFVIRgp1RStzeWVRTG5aWHR1a091clNYWUlsLzFZL0xQWjJYeDM2UmdIN1lkZW5adVVDYmNZM0NBNGFnWmdsK0dETG1oCnBHaDJ5My9WSk9uTjRBdkhvZHpOTkVjMFpNcEt3YUppM0RyTm9CMmE3a09vNWo4bEQ5MWR6MHJzMXR5SUpGT0EKbHlzOU8xTk5MeGFaaGV3OVlWU1RQY0NFZ2pMWnRScFpVTFBUdVBDd3RYRXVBL1JVR1c5WmFrU1hpVS9oRGNIUQpQTlh4bFdPUTFwNzdOMC92NXpPc1RQY3NabXlYdSsyajZETWQvVktNQzRVeDhxTXhoT21XT0pSZXI4TExqNG9rCkV6dGttdlovTURDeGtPY01SOHFNQ0dmYWVqUEZ4RnFSRm1QLyt3NWRaMk1SM3ZZYzkweWFtTUo1RUxkUUdJWi8KeDFBNjVFdnp1SE1Tb3J5cHVqVGMydHJBdEVDa0VJNHVEdU9mZjVXSTdnYm5ycXpkNFhEb0ZBVDRENTRZREJVNwo4eDBpS05pQm5iaE9qaXRiR0d4L1k0RFdlZlBHQUJTOFJ4NzNDSEVKQkgrTnQxbTg5bllTRHVsOGVuelA0Mm5jCm1lNk80Q0FMZFJhZEp2Snp4L0N0amE5Sm1sbEtKZ2oyU2Zrc2xCMlE3NFlNOFVRMjhQOGVtUm55b1YzVGMzMlcKK3JWSkgxR1JmVXlsSDJpcHRzM1AxcEpWKzlySUNNZEN5QWlJQXkwa3FCbWxBT3R6cm95N0RMSUloSVVZaHRvSwpTZUxCbFl5RWJPRFlkK3VwcW02clZBR3hpNG0yVktFVzMrOU04KytpQ3FraHV3QmRzNnlXeEN4TURheFVtd3dPCnQrVHlxRlRVQ0YvM3NwejJXRGpiL1pNQ0F3RUFBUT09Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQ=="
      stage = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQ0FnRUFzdVVyanhTSGxQS0NqVktsellMawpSdGk4WlJNWS96RkxKb2FnVHZORHIrOEQ3cXpqeVhCZWg0VjZmazAvaW93cTU4RFM0RWxmMjhXdGlRaUFKUDh3Cm82T2J5UXhnTlhmMmozc1FyTnNLY1ArZHJ2QzlZSXdURDVpU2ZJOWRQbmtPLythQ2dMM09uMTNIQXU1RWpJdmoKTDNSZG56S1FYTXhHWmd2Z3BVWnhoS3IxYjQ3RzlSalZ1cmxLa0tUa09XbHEyQkwxamZRMHNuRENXNlZzOWJKQgpSL3B5NjkzNm5qL1JNQVhlQUNSVkNQYVNPZW1BV1Q3V3FuM3BTZkkvVmdKaTRwczB5cnlGbzJRcHNBZ1BlYUxtClM3cFcweTRWOStscG54TDlMU2cyUFlrcDdoMG5iVjhGc2pKRDFJZWZSK0greFRLZ0F4VEIwTWt1ZGl3Vk4vMEwKVmRmeDV5QVYxdzZqY2VYMXRPaUZQaEs5UVVkOURJcUhLNXU2NHBna2VjYkR5cC9mc2VGSU1NQW5WaUthYUhacQo4UVpZaHFreW1ScWNiVFdRVzJOeVM4TUduandTbDlYMUQ0VmZ4aUgyZXFITFRtQ0RuK2tiZml2UTZFajBUdUJzCjloWi8rdXZKY1BNbkdoRlJadDdIbXBNTzVhMHRKMUt4bjI2UG50QWtBQ1BhczUrYnQ2MXMvSU50dzhBZzU1eXEKNzBMMWVCTEFWL2xuRFVTWU5qNmVYenYxaTZDY3RrVFdHNjlGa1ZKWmk3VjRqaitBdlVUQlg1Q0VuQUJNdXRDMgo2YzQveUpCUTkrSWg1U0gvMHd2eC9oUXpTREZOcXM3V0FaVFd6bFVEYm03bjJQY2ZzbWxjNkdDRWRBT3JiQnBkCmNrTkNNYmZTdVFwa1ZhODFrVGtzaXdNQ0F3RUFBUT09Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQ=="
      test  = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQ0FnRUF5S2prYlZmSHMvN0Vrb3JRRzQxYQo4RHhDWjRSQkZROXRFRHB6N1NXRzE1aGJobmd4ZTU3cmM4bE13U1lSOUJWdDM3VzFEUmNBT3YwRVMrK1FRQkZMCm91a01VMEU3Vk5vaXVWTWl3cG9PTTZmTmdERGtnNHI0RE1PRGhrQ3NSZGJrUXduSS85V1BZbXhFOXNSaXRzZmkKc2cxTWlUZVB6cUszVFl0SU1YQlNFOHN2WkJMU1dFalpmY3RpQmh3NXFidFo5eFZ5SEFwdnZTbVJPUjB6eldZeQowWmJ6RTV6bFV0V0lNcDl3cG1oL1FYbGU1dkhYTVN3SmZLYnlLWStoNldwSDV5RTJjYTlObUFFWWgrZ0QzZlljCjE3VmVkK01WM3dkYURUV0VzTjdBZS9HeEdEQUgvU0J6cnA5bFdId013SmhCbVUybldreXA1b0tTR2x5dFluRzYKV2x6M0NiZ3Y2aE9KT0ZnVmd2SXo0SXl4MUxhQlFycWR1amZ1Z1gyRStzRzMwWHdUbkpCVW4vS0E3aFZaZitCeApIZlovUWpnbGVqcUd3eG9YY2VnQ3JBenpuQ2dUSi96a3VjZ1RJYXErQ0E5K0s3NUo3WkVXd0h2YnFFMEtkSmJKCjZ0S24wVGxlcFNtRGdvZDRCeGZsSktmOEI3b2pmSVhYZ0RkbkJYYWc3VUVla09CQlhTcjBVV1NsZkwrM3Zuc1QKN3NPcEpMSWx5QWlLMEVuUDBHZDVjbXBNbElYQ0hsVDhpa20zLzkrK0FvZDRRK3pIZ2ZPMDdJSXMweWRpUTNiSgpnRlVpbXJzUEN6Qzk1emUxWnc3Q3VlZVc2eElKclpGOTkwMWNqS0dyMDNwV1QwaHlVREgyU0l6aEZLNVkvU1Z3Clk4T2l3UThZNTdBQnA3VGd4WDN5akJNQ0F3RUFBUT09Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQ=="
   }
}

# --- instance / rollout identifier
resource "random_password" "edge_instance_id" {
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
data "oci_identity_availability_domains" "edge_availability_domains" {
   compartment_id = oci_identity_compartment.edge_comp.id
}

# --- Compartments
resource "oci_identity_compartment" "edge_comp" {
    compartment_id = var.EDGE_PARENT_COMP_OCID
    description    = "ROCKIT Edge"
    name           = "edge-comp-${local.workspace}"
    enable_delete  = true
}

# --- Log group
resource "oci_logging_log_group" "edge_log_group" {
   compartment_id = oci_identity_compartment.edge_comp.id
   display_name   = "edge-log-${local.workspace}"
   description    = "Combined logs of ROCKIT Edge"
}

# --- Logs
resource "oci_logging_log" "edge_task_log" {
   display_name       = "edge-task-log-${local.workspace}"
   log_group_id       = oci_logging_log_group.edge_log_group.id
   log_type           = "CUSTOM"
   is_enabled         = true
   retention_duration = 30
}

# --- Policies
resource "oci_identity_policy" "edge_workspace_depl_pol" {
   depends_on     = [
      oci_identity_compartment.edge_comp,
      oci_identity_group.edge_registry_group,
   ]
   compartment_id = var.EDGE_PARENT_COMP_OCID
   description    = "ROCKIT Edge [${local.workspace}] Deployment Workspace Policy"
   name           = "edge-workspace-depl-pol-${local.workspace}"
   statements     = [
      "Allow group edge-registry-group-${local.workspace} to manage repos in compartment edge-comp-${local.workspace}",
      "Allow service objectstorage-${var.EDGE_OCI_REGION} to manage object-family in compartment edge-comp-${local.workspace}"
   ]
}

# --- wait for user IAM policy
resource "time_sleep" "edge_wait_for_registry_user" {
  depends_on = [
    oci_identity_policy.edge_workspace_depl_pol,
    oci_identity_auth_token.edge_registry_user_authtoken
  ]
  create_duration = "120s"
}

# --- Update database after deployment
data "oci_vault_secrets" "edge_admin_secret" {
   depends_on     = [ oci_vault_secret.edge_admin_secret ]
   vault_id       = var.EDGE_VAULT_OCID
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "EDGE_ADMIN_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}"
}
data "oci_secrets_secretbundle" "edge_admin_secretbundle" { secret_id = data.oci_vault_secrets.edge_admin_secret.secrets.0.id }
locals {
   edge_admin_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_admin_secretbundle.secret_bundle_content.0.content)
}

# --- inject.sh link
locals {
   inject_link_args = [
      local.workspace,
      var.EDGE_OCI_REGION,
      var.EDGE_OCI_NAMESPACE,
      local.edge_apigw_url,
      local.edge_admin_secret_b64,
      oci_functions_function.edge_fn.id,
      "x64",
      local.cwl_shapes[var.EDGE_CWL_CONTAINER_SHAPE].platform,
      (local.env == "test") ? local.dev_bucket_readwrite_par : "",
      (local.env == "test" && local.use_cwl) ? oci_container_instances_container_instance.edge_cwl[0].id : ""
   ]
   inject_link_data = base64encode(join (",", local.inject_link_args))
}

locals {
   edge_base_url = var.EDGE_WITH_CERT ? "https://${local.edge_pub_hostname}.${var.EDGE_CERT_DOMAINNAME}" : "https://local.edge_ipaddr"
}

# --- Output
output "edge_instance_id" {
  value = nonsensitive (random_password.edge_instance_id.result)
}

output "inject_link" {
   value = local.env == "test" ? "dxinjectlnk3.edge.${nonsensitive(local.inject_link_data)}" : null
}

output "apigw_url" {
   value = local.edge_apigw_url
}

output "edge_admin_secret_b64" {
   value = nonsensitive (local.edge_admin_secret_b64)
}

output "edge_db_conn_str" {
   value = nonsensitive (local.mongodb_connstr)
}

output "edge_ipaddr" {
   value = local.use_cwl ? local.lb_ipaddr : local.edge_apigw_ipaddr
}

output "edge_base_url" {
   value = local.edge_base_url
}
