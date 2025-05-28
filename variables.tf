# --- variables predefined by OCI Stacks
variable "tenancy_ocid" { }
variable "compartment_ocid" { }
variable "region" { }
variable "current_user_ocid" { }

# --- user-input by OCI
variable "dacslabs_link_b64"            { type = string }
variable "rockit_base_link_b64"         { type = string }
variable "env_label"                    { type = string }
variable "show_advanced_settings" {
  type = bool
  default = false
}

variable "MAINTENANCE_MODE" {
  type = bool
}

variable "RSI_URL" {
  type = string
  default = "https://public.cloud.rockitplay.com/rsi"
}
variable "CWL_CONTAINER_SHAPE" {
  type    = string
  default = "CI.Standard.A1.Flex"
}
variable "N_CONTAINER_INSTANCES" {
  type    = number
  default = 0
}

variable "EDGE_LB_BANDWIDTH_MBPS" {
  type    = number
  default = 10
}
variable "ENGINE_LB_BANDWIDTH_MBPS" {
  type    = number
  default = 10
}

variable "EDGE_MONGODBATLAS_DB_TYPE" {
  type = string
}

variable "EDGE_MONGODBATLAS_REGION_CLUSTER" {
  type = string
}

variable "EDGE_MONGODBATLAS_CLUSTER_SIZE" {
  type = string
  default = "M10"
}

variable "ENGINE_MONGODBATLAS_DB_TYPE" {
  type = string
}

variable "ENGINE_MONGODBATLAS_REGION_CLUSTER" {
  type = string
}

variable "ENGINE_MONGODBATLAS_CLUSTER_SIZE" {
  type = string
  default = "M10"
}

variable "WORKSPACE"                    { type = string }
variable "ENGINE_SLACK_ADMIN_CHANNEL"   { type = string }
variable "EDGE_SLACK_ADMIN_CHANNEL"     { type = string }


locals {
  env                  = lower (split (":", var.env_label)[0])
  ENV                  = upper (local.env)
  workspace            = lower (var.WORKSPACE)
  WORKSPACE            = upper (var.WORKSPACE)
  dacslabs_link        = base64decode (split (".", var.dacslabs_link_b64)[1])
  engine_dx_url        = chomp (split (",", local.dacslabs_link)[1])
  edge_dx_url          = chomp (split (",", local.dacslabs_link)[2])
  rockit_base_link     = base64decode (split (".", var.rockit_base_link_b64)[1])
  rockitplay_comp_ocid = split (",", local.rockit_base_link)[0]
  vault_ocid           = split (",", local.rockit_base_link)[1]
  vault_key_ocid       = split (",", local.rockit_base_link)[2]
  baseenv_id           = split (",", local.rockit_base_link)[3]
  N_CONTAINER_INSTANCES = {
    prod  = max (1, var.N_CONTAINER_INSTANCES)
    stage = max (1, var.N_CONTAINER_INSTANCES)
    test  = var.N_CONTAINER_INSTANCES
  }
  edge_mongodbatlas_region                  = split (":", var.EDGE_MONGODBATLAS_REGION_CLUSTER)[0]
  edge_mongodbatlas_advanced_cluster_size   = var.EDGE_MONGODBATLAS_CLUSTER_SIZE
  edge_mongodbatlas_db_type                 = split (":", var.EDGE_MONGODBATLAS_DB_TYPE)[0]
  engine_mongodbatlas_region                = split (":", var.ENGINE_MONGODBATLAS_REGION_CLUSTER)[0]
  engine_mongodbatlas_advanced_cluster_size = var.ENGINE_MONGODBATLAS_CLUSTER_SIZE
  engine_mongodbatlas_db_type               = split (":", var.ENGINE_MONGODBATLAS_DB_TYPE)[0]
}