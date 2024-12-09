# --- variables predefined by OCI Stacks
variable "tenancy_ocid" { }
variable "compartment_ocid" { }
variable "region" { }
variable "current_user_ocid" { }

# --- user-input by OCI
variable "dacslabs_link_b64"            { type = string }
variable "rockit_base_link_b64"         { type = string }
variable "env_label"                    { type = string }

variable "RSI_URL" {
  type = string
  default = "https://public.cloud.rockitplay.com/rsi"
}
variable "N_CONTAINER_INSTANCES" {
  type    = number
  default = 0
}

variable "MONGODBATLAS_REGION_SERVERLESS"  {
  type = string
  default = ""
}
variable "MONGODBATLAS_REGION_CLUSTER_M10" {
  type = string
  default = ""
}
variable "MONGODBATLAS_REGION_CLUSTER_M0" {
  type = string
  default = ""
}

variable "WORKSPACE"                    { type = string }
variable "ENGINE_SLACK_ADMIN_CHANNEL"   { type = string }
variable "ENGINE_SLACK_ERROR_CHANNEL"   { type = string }
variable "ENGINE_SLACK_INFO_CHANNEL"    { type = string }
variable "EDGE_SLACK_ADMIN_CHANNEL"     { type = string }
variable "EDGE_SLACK_ERROR_CHANNEL"     { type = string }
variable "EDGE_SLACK_INFO_CHANNEL"      { type = string }



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
  mongodbatlas = {
    prod = {
      type   = "serverless"
      size   = ""
      region = split (":", var.MONGODBATLAS_REGION_SERVERLESS)[0]
    }
    stage = {
      type   = "serverless"
      size   = ""
      region = split (":", var.MONGODBATLAS_REGION_SERVERLESS)[0]
    }
    test = {
      type   = "cluster"
      size   = "M0"
      region = split (":", var.MONGODBATLAS_REGION_CLUSTER_M0)[0]
    }
  }
}