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

variable "runtime" {
  type    = string
  default = "Containers"
}

variable "CWL_CONTAINER_SHAPE" {
  type    = string
  default = "CI.Standard.E4.Flex"
}
variable "N_CONTAINER_INSTANCES" {
  type    = number
  default = 1
}
variable "USE_WAF" {
  type    = bool
  default = false
}

# --- mongodb PROD
variable "PROD_MONGODBATLAS_DB_TYPE" {
  type = string
  default = ""
}

variable "PROD_MONGODBATLAS_REGION_CLUSTER" {
  type = string
  default = ""
}

variable "PROD_MONGODBATLAS_CLUSTER_SIZE" {
  type = string
  default = "M10"
}


# --- mongodb STAGE
variable "STAGE_MONGODBATLAS_DB_TYPE" {
  type = string
  default = ""
}

variable "STAGE_MONGODBATLAS_REGION_CLUSTER" {
  type = string
  default = ""
}

variable "STAGE_MONGODBATLAS_CLUSTER_SIZE" {
  type = string
  default = "M10"
}

# --- mongodb TEST
variable "TEST_MONGODBATLAS_DB_TYPE" {
  type = string
  default = ""
}

variable "TEST_MONGODBATLAS_REGION_CLUSTER" {
  type = string
  default = ""
}

variable "TEST_MONGODBATLAS_CLUSTER_SIZE" {
  type = string
  default = "M10"
}



variable "MONGODBATLAS_IP_ACCESS_LIST" {
  type = string
  default = ""
}

variable "SMTP_HOST"        { type = string }
variable "SMTP_PORT"        { type = number }
variable "SMTP_USER"        { type = string }
variable "SMTP_PASSWORD"    { type = string }

variable "GOOGLE_CLIENT_ID"  { type = string }

variable "WORKSPACE"                    { type = string }
variable "ENGINE_SLACK_ADMIN_CHANNEL"   { type = string }
variable "EDGE_SLACK_ADMIN_CHANNEL"     { type = string }


locals {
  env                   = lower (split (":", var.env_label)[0])
  ENV                   = upper (local.env)
  workspace             = lower (var.WORKSPACE)
  WORKSPACE             = upper (var.WORKSPACE)
  dacslabs_link         = base64decode (split (".", var.dacslabs_link_b64)[1])
  engine_dx_url         = chomp (split (",", local.dacslabs_link)[1])
  edge_dx_url           = chomp (split (",", local.dacslabs_link)[2])
  rockit_base_link      = base64decode (split (".", var.rockit_base_link_b64)[1])
  rockitplay_comp_ocid  = split (",", local.rockit_base_link)[0]
  vault_ocid            = split (",", local.rockit_base_link)[1]
  vault_key_ocid        = split (",", local.rockit_base_link)[2]
  baseenv_id            = split (",", local.rockit_base_link)[3]
  USE_CWL               = {
    prod  = var.show_advanced_settings ? (var.runtime == "containers") : true
    stage = var.show_advanced_settings ? (var.runtime == "containers") : true
    test  = var.show_advanced_settings ? (var.runtime == "containers") : false
  }
  mongodbatlas_region   = {
    prod  = split (":", var.PROD_MONGODBATLAS_REGION_CLUSTER)[0]
    stage = split (":", var.STAGE_MONGODBATLAS_REGION_CLUSTER)[0]
    test  = split (":", var.TEST_MONGODBATLAS_REGION_CLUSTER)[0]
  }
  mongodbatlas_advanced_cluster_size  = {
    prod  = var.PROD_MONGODBATLAS_CLUSTER_SIZE
    stage = var.STAGE_MONGODBATLAS_CLUSTER_SIZE
    test  = var.TEST_MONGODBATLAS_CLUSTER_SIZE
  }
  mongodbatlas_db_type                = {
    prod  = split (":", var.PROD_MONGODBATLAS_DB_TYPE)[0]
    stage = split (":", var.STAGE_MONGODBATLAS_DB_TYPE)[0]
    test  = split (":", var.TEST_MONGODBATLAS_DB_TYPE)[0]
  }
}
