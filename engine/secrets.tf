# --- ENGINE_ADMIN_SECRET
resource "random_password" "initial_admin_secret" {
  length           = 100
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  min_special      = 1
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!@#$%^&*()_+-=[]{}:;<>/?"
}

resource "oci_vault_secret" "admin_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "ENGINE_ADMIN_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Secret to encode/sign admin tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_admin_secret.result)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- ENGINE_SESSION_SECRET
resource "random_password" "initial_session_secret" {
  length           = 100
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  min_special      = 1
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!@#$%^&*()_+-=[]{}:;<>/?"
}

resource "oci_vault_secret" "session_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "ENGINE_SESSION_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Secret to encode/sign user session tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_session_secret.result)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- ENGINE_AUTH_SECRET
resource "random_password" "initial_auth_secret" {
  length           = 100
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  min_special      = 1
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!@#$%^&*()_+-=[]{}:;<>/?"
}

resource "oci_vault_secret" "auth_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "ENGINE_AUTH_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Secret to encode/sign user auth tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_auth_secret.result)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- ENGINE_SUBSCRIPTION_SECRET
#     (aes-256-cbc algorithm: fixed key length: 32 bytes)
resource "random_password" "initial_subscription_secret" {
  length           = 32
  special          = false
  upper            = true
  lower            = true
  numeric          = true
  min_special      = 0
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!@#$%^&*()_+-=[]{}:;<>/?"
}

resource "oci_vault_secret" "subscription_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "ENGINE_SUBSCRIPTION_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Secret to encode/sign subscription tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_subscription_secret.result)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- ENGINE_DB_PW
resource "random_password" "db_pw" {
  length           = 20
  special          = false
  upper            = true
  lower            = true
  numeric          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

resource "oci_vault_secret" "db_pw_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "ENGINE_DB_PW_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "MongoDB password"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.db_pw.result)
   }
   lifecycle {
      ignore_changes = all
   }
}

data "oci_secrets_secretbundle" "db_pw_secret" {
   secret_id = oci_vault_secret.db_pw_secret.id
}

# --- ENGINE_DB_CONNSTR
resource "oci_vault_secret" "db_connstr_secret" {
   depends_on = [
      mongodbatlas_cluster.engine_mongodb_cluster  # for $local.mongodb_connstr}
   ]
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "ENGINE_DB_CONNSTR_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "MongoDB connection string"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.mongodb_connstr)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- SLACK_TOKEN
resource "oci_vault_secret" "slack_token_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "SLACK_TOKEN_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Slack token to authenticate slack notification posts"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(var.ENGINE_SLACK_TOKEN)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- SLACK_ADMIN_CHANNEL
resource "oci_vault_secret" "slack_admin_channel_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "SLACK_ADMIN_CHANNEL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Slack channel id to receive site-admin notifications"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(var.ENGINE_SLACK_ADMIN_CHANNEL)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- SLACK_ERROR_CHANNEL
resource "oci_vault_secret" "slack_error_channel_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "SLACK_ERROR_CHANNEL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Slack channel id to receive error notifications"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(var.ENGINE_SLACK_ERROR_CHANNEL)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- SLACK_INFO_CHANNEL
resource "oci_vault_secret" "slack_info_channel_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "SLACK_INFO_CHANNEL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Slack channel id to receive info notifications"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(var.ENGINE_SLACK_INFO_CHANNEL)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- TAR_BUCKET_READWRITE_URL
resource "oci_vault_secret" "tar_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "TAR_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Download/upload URL to access the TAR bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.tar_bucket_readwrite_url)
   }
   lifecycle {
      ignore_changes = all
   }
}


# --- RAW_BUCKET_READWRITE_URL
resource "oci_vault_secret" "raw_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "RAW_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Download/upload URL to access the RAW bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.raw_bucket_readwrite_url)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- DXF_BUCKET_READWRITE_URL
resource "oci_vault_secret" "dxf_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "DXF_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Download/upload URL to access the DXF bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.dxf_bucket_readwrite_url)
   }
   lifecycle {
      ignore_changes = all
   }
}


# --- SEQ_BUCKET_READWRITE_URL
resource "oci_vault_secret" "seq_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "SEQ_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Download/upload URL to access the SEQ bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.seq_bucket_readwrite_url)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- TRC_BUCKET_READWRITE_URL
resource "oci_vault_secret" "trc_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "TRC_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Download/upload URL to access the TRC bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.trc_bucket_readwrite_url)
   }
   lifecycle {
      ignore_changes = all
   }
}

# --- PAT_BUCKET_READWRITE_URL
resource "oci_vault_secret" "pat_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   key_id         = var.ENGINE_VAULT_KEY_OCID
   secret_name    = "PAT_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.instance_id.result}"
   description    = "Download/upload URL to access the PAT bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.pat_bucket_readwrite_url)
   }
   lifecycle {
      ignore_changes = all
   }
}

resource "time_sleep" "engine_wait_for_secrets" {
  depends_on = [
     oci_vault_secret.admin_secret,
     oci_vault_secret.session_secret,
     oci_vault_secret.auth_secret,
     oci_vault_secret.subscription_secret,
     oci_vault_secret.db_pw_secret,
     oci_vault_secret.db_connstr_secret,
     oci_vault_secret.slack_token_secret,
     oci_vault_secret.slack_error_channel_secret,
     oci_vault_secret.slack_info_channel_secret,
     oci_vault_secret.tar_bucket_rw_url_secret,
     oci_vault_secret.raw_bucket_rw_url_secret,
     oci_vault_secret.dxf_bucket_rw_url_secret,
     oci_vault_secret.seq_bucket_rw_url_secret,
     oci_vault_secret.trc_bucket_rw_url_secret,
     oci_vault_secret.pat_bucket_rw_url_secret,
  ]
  create_duration = "10s"
}
