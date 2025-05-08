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
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "admin_secret" {
    depends_on     = [ oci_vault_secret.admin_secret ]
    compartment_id = oci_identity_compartment.engine_comp.id
    vault_id       = var.ENGINE_VAULT_OCID
    name           = "ENGINE_ADMIN_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
}
data "oci_secrets_secretbundle" "admin_secret_secretbundle" { secret_id = data.oci_vault_secrets.admin_secret.secrets.0.id }
locals {
   engine_admin_secret_b64 = sensitive(data.oci_secrets_secretbundle.admin_secret_secretbundle.secret_bundle_content.0.content)
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
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "session_secret" {
    depends_on     = [ oci_vault_secret.session_secret ]
    compartment_id = oci_identity_compartment.engine_comp.id
    vault_id       = var.ENGINE_VAULT_OCID
    name           = "ENGINE_SESSION_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
}
data "oci_secrets_secretbundle" "session_secret_secretbundle" { secret_id = data.oci_vault_secrets.session_secret.secrets.0.id }
locals {
   engine_session_secret_b64 = sensitive(data.oci_secrets_secretbundle.session_secret_secretbundle.secret_bundle_content.0.content)
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
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "auth_secret" {
   depends_on     = [ oci_vault_secret.auth_secret ]
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   name           = "ENGINE_AUTH_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
}
data "oci_secrets_secretbundle" "auth_secret_secretbundle" { secret_id = data.oci_vault_secrets.auth_secret.secrets.0.id }
locals {
   engine_auth_secret_b64 = sensitive(data.oci_secrets_secretbundle.auth_secret_secretbundle.secret_bundle_content.0.content)
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
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "subscription_secret" {
   depends_on     = [ oci_vault_secret.subscription_secret ]
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   name           = "ENGINE_SUBSCRIPTION_SECRET_${local.WORKSPACE}.${random_password.instance_id.result}"
}
data "oci_secrets_secretbundle" "subscription_secret_secretbundle" { secret_id = data.oci_vault_secrets.subscription_secret.secrets.0.id }
locals {
   engine_subscription_secret_b64 = sensitive(data.oci_secrets_secretbundle.subscription_secret_secretbundle.secret_bundle_content.0.content)
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
   lifecycle { ignore_changes = all }
}

data "oci_secrets_secretbundle" "db_pw_secret" {
   depends_on = [ oci_vault_secret.db_pw_secret ]
   secret_id  = oci_vault_secret.db_pw_secret.id
}

# --- ENGINE_DB_CONNSTR
resource "oci_vault_secret" "db_connstr_secret" {
   depends_on = [
      mongodbatlas_advanced_cluster.engine_mongodb_cluster  # for $local.mongodb_connstr}
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
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "db_connstr_secret" {
   depends_on     = [ oci_vault_secret.db_connstr_secret ]
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   name           = "ENGINE_DB_CONNSTR_${local.WORKSPACE}.${random_password.instance_id.result}"
}
data "oci_secrets_secretbundle" "db_connstr_secret_secretbundle" { secret_id = data.oci_vault_secrets.db_connstr_secret.secrets.0.id }
locals {
   engine_db_connstr_secret_b64 = sensitive(data.oci_secrets_secretbundle.db_connstr_secret_secretbundle.secret_bundle_content.0.content)
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
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "slack_token_secret" {
   depends_on     = [ oci_vault_secret.slack_token_secret ]
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   name           = "SLACK_TOKEN_${local.WORKSPACE}.${random_password.instance_id.result}"
}
data "oci_secrets_secretbundle" "slack_token_secret_secretbundle" { secret_id = data.oci_vault_secrets.slack_token_secret.secrets.0.id }
locals {
   engine_slack_token_secret_b64 = sensitive(data.oci_secrets_secretbundle.slack_token_secret_secretbundle.secret_bundle_content.0.content)
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
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "slack_admin_channel_secret" {
   depends_on     = [ oci_vault_secret.slack_admin_channel_secret ]
   compartment_id = oci_identity_compartment.engine_comp.id
   vault_id       = var.ENGINE_VAULT_OCID
   name           = "SLACK_ADMIN_CHANNEL_${local.WORKSPACE}.${random_password.instance_id.result}"
}

data "oci_secrets_secretbundle" "slack_admin_channel_secret_secretbundle" { secret_id = data.oci_vault_secrets.slack_admin_channel_secret.secrets.0.id }
locals {
   engine_slack_admin_channel_secret_b64 = sensitive(data.oci_secrets_secretbundle.slack_admin_channel_secret_secretbundle.secret_bundle_content.0.content)
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
   # lifecycle { ignore_changes = all }
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
   # lifecycle { ignore_changes = all }
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
   # lifecycle { ignore_changes = all }
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
   # lifecycle { ignore_changes = all }
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
   # lifecycle { ignore_changes = all }
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
   # lifecycle { ignore_changes = all }
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
     oci_vault_secret.tar_bucket_rw_url_secret,
     oci_vault_secret.raw_bucket_rw_url_secret,
     oci_vault_secret.dxf_bucket_rw_url_secret,
     oci_vault_secret.seq_bucket_rw_url_secret,
     oci_vault_secret.trc_bucket_rw_url_secret,
     oci_vault_secret.pat_bucket_rw_url_secret,
  ]
  create_duration = "10s"
}
