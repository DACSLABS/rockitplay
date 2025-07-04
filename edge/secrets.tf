# --- EDGE_ADMIN_SECRET
resource "random_password" "initial_edge_admin_secret" {
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

resource "oci_vault_secret" "edge_admin_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_ADMIN_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign admin tokens"
   secret_content {
      content_type = "BASE64"
      content      = nonsensitive (base64encode(random_password.initial_edge_admin_secret.result))
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_admin_secret" {
    depends_on     = [ oci_vault_secret.edge_admin_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_ADMIN_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_admin_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_admin_secret.secrets.0.id }
locals {
   edge_admin_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_admin_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_BE_SESSION_SECRET
resource "random_password" "initial_edge_be_session_secret" {
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

resource "oci_vault_secret" "edge_be_session_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_BE_SESSION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign backend session tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_be_session_secret.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_be_session_secret" {
    depends_on     = [ oci_vault_secret.edge_be_session_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_BE_SESSION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_be_session_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_be_session_secret.secrets.0.id }
locals {
   edge_be_session_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_be_session_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_BE_AUTH_SECRET
resource "random_password" "initial_edge_be_auth_secret" {
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

resource "oci_vault_secret" "edge_be_auth_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_BE_AUTH_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign backend auth tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_be_auth_secret.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_be_auth_secret" {
    depends_on     = [ oci_vault_secret.edge_be_auth_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_BE_AUTH_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_be_auth_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_be_auth_secret.secrets.0.id }
locals {
   edge_be_auth_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_be_auth_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_SESSION_SECRET
resource "random_password" "initial_edge_session_secret" {
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

resource "oci_vault_secret" "session_edge_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_SESSION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign session tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_session_secret.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "session_edge_secret" {
    depends_on     = [ oci_vault_secret.session_edge_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_SESSION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "session_edge_secret_secretbundle" { secret_id = data.oci_vault_secrets.session_edge_secret.secrets.0.id }
locals {
   edge_session_secret_b64 = sensitive(data.oci_secrets_secretbundle.session_edge_secret_secretbundle.secret_bundle_content.0.content)
}


# --- EDGE_IB_SECRET
resource "random_password" "initial_edge_ib_secret" {
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

resource "oci_vault_secret" "edge_ib_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_IB_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign ib session tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_ib_secret.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_ib_secret" {
    depends_on     = [ oci_vault_secret.edge_ib_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_IB_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_ib_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_ib_secret.secrets.0.id }
locals {
   edge_ib_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_ib_secret_secretbundle.secret_bundle_content.0.content)
}


# --- EDGE_AUTH_SECRET
resource "random_password" "initial_edge_auth_secret" {
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

resource "oci_vault_secret" "edge_auth_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_AUTH_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign auth tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_auth_secret.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_auth_secret" {
    depends_on     = [ oci_vault_secret.edge_auth_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_AUTH_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_auth_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_auth_secret.secrets.0.id }
locals {
   edge_auth_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_auth_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_ORG_SECRET
#     (aes-256-cbc algorithm: fixed key length: 32 bytes)
resource "random_password" "initial_edge_org_secret" {
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

resource "oci_vault_secret" "edge_org_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_ORG_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encrypt/decrypt organization passphrases"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_org_secret.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_org_secret" {
    depends_on     = [ oci_vault_secret.edge_org_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_ORG_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_org_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_org_secret.secrets.0.id }
locals {
   edge_org_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_org_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_ENGINE_BASE_URL
resource "oci_vault_secret" "edge_engine_baseurl_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_ENGINE_BASE_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "URL to access the ROCKIT Engine"
   secret_content {
      content_type = "BASE64"
      content      = base64encode (var.EDGE_ENGINE_BASE_URL)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_engine_baseurl_secret" {
    depends_on     = [ oci_vault_secret.edge_engine_baseurl_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_ENGINE_BASE_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_engine_baseurl_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_engine_baseurl_secret.secrets.0.id }
locals {
   edge_engine_baseurl_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_engine_baseurl_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_ENGINE_SUBSCRIPTION_SECRET
resource "random_password" "initial_edge_engine_subscription_secret" {
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

resource "oci_vault_secret" "edge_engine_subscription_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_ENGINE_SUBSCRIPTION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign engine subscription tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_engine_subscription_secret.result)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_engine_subscription_secret" {
    depends_on     = [ oci_vault_secret.edge_engine_subscription_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_ENGINE_SUBSCRIPTION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_engine_subscription_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_engine_subscription_secret.secrets.0.id }
locals {
   edge_engine_subscription_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_engine_subscription_secret_secretbundle.secret_bundle_content.0.content)
}


# --- EDGE_SUBSCRIPTION_SECRET
#     (aes-256-cbc algorithm: fixed key length: 32 bytes)
resource "random_password" "initial_edge_subscription_secret" {
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

resource "oci_vault_secret" "edge_subscription_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = "EDGE_SUBSCRIPTION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}"
   description    = "Secret to encode/sign subscription tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_subscription_secret.result)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_subscription_secret" {
    depends_on     = [ oci_vault_secret.edge_subscription_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_SUBSCRIPTION_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_subscription_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_subscription_secret.secrets.0.id }
locals {
   edge_subscription_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_subscription_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_DEPLOYMENTS_SECRET
#     (aes-256-cbc algorithm: fixed key length: 32 bytes)
resource "random_password" "initial_edge_deployment_secret" {
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

resource "oci_vault_secret" "edge_deployment_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_DEPLOYMENT_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode deployments"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_deployment_secret.result)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_deployment_secret" {
    depends_on     = [ oci_vault_secret.edge_deployment_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_DEPLOYMENT_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_deployment_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_deployment_secret.secrets.0.id }
locals {
   edge_deployment_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_deployment_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_DB_PW
resource "random_password" "edge_db_pw" {
  length           = 20
  special          = false
  upper            = true
  lower            = true
  numeric          = true
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

resource "oci_vault_secret" "edge_db_pw_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_DB_PW_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "MongoDB password"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.edge_db_pw.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_secrets_secretbundle" "edge_db_pw_secret" {
   secret_id = oci_vault_secret.edge_db_pw_secret.id
}

# --- EDGE_DB_CONNSTR
resource "oci_vault_secret" "edge_db_connstr_secret" {
   depends_on = [
      mongodbatlas_advanced_cluster.edge_mongodb_cluster  # for $local.mongodb_connstr}
   ]
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_DB_CONNSTR_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "MongoDB connection string"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.mongodb_connstr)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_db_connstr_secret" {
    depends_on     = [ oci_vault_secret.edge_db_connstr_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_DB_CONNSTR_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_db_connstr_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_db_connstr_secret.secrets.0.id }
locals {
   edge_db_connstr_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_db_connstr_secret_secretbundle.secret_bundle_content.0.content)
}

# --- TRC_BUCKET_READWRITE_URL_
resource "oci_vault_secret" "edge_trc_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_TRC_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Download/upload URL to access the trc bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.edge_trc_bucket_readwrite_url)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_trc_bucket_rw_url_secret" {
    depends_on     = [ oci_vault_secret.edge_trc_bucket_rw_url_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_TRC_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_trc_bucket_rw_url_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_trc_bucket_rw_url_secret.secrets.0.id }
locals {
   edge_trc_bucket_rw_url_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_trc_bucket_rw_url_secret_secretbundle.secret_bundle_content.0.content)
}

# --- DEPS_BUCKET_READWRITE_URL_
resource "oci_vault_secret" "edge_deps_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_DEPS_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Download/upload URL to access the deps bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.edge_deps_bucket_readwrite_url)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_deps_bucket_rw_url_secret" {
    depends_on     = [ oci_vault_secret.edge_deps_bucket_rw_url_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_DEPS_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_deps_bucket_rw_url_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_deps_bucket_rw_url_secret.secrets.0.id }
locals {
   edge_deps_bucket_rw_url_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_deps_bucket_rw_url_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_DEPOT_BUCKET_READ_URL
resource "oci_vault_secret" "edge_depot_bucket_ro_url_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_DEPOT_BUCKET_READ_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Download URL to access the depot bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.edge_depot_bucket_read_url)
   }
   # lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_depot_bucket_ro_url_secret" {
    depends_on     = [ oci_vault_secret.edge_depot_bucket_ro_url_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_DEPOT_BUCKET_READ_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_depot_bucket_ro_url_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_depot_bucket_ro_url_secret.secrets.0.id }
locals {
   edge_depot_bucket_ro_url_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_depot_bucket_ro_url_secret_secretbundle.secret_bundle_content.0.content)
}

# --- EDGE_DEPOT_BUCKET_READWRITE_URL
resource "oci_vault_secret" "edge_depot_bucket_rw_url_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_DEPOT_BUCKET_READWRITE_URL_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Download/upload URL to access the depot bucket"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(local.edge_depot_bucket_readwrite_url)
   }
   # lifecycle { ignore_changes = all }
}


# --- EDGE_CLIENT_SECRET
resource "random_password" "initial_edge_client_secret" {
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

resource "oci_vault_secret" "edge_client_secret" {
   compartment_id = oci_identity_compartment.edge_comp.id
   vault_id       = var.EDGE_VAULT_OCID
   key_id         = var.EDGE_VAULT_KEY_OCID
   secret_name    = nonsensitive ("EDGE_CLIENT_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
   description    = "Secret to encode/sign ROCKIT Client tokens"
   secret_content {
      content_type = "BASE64"
      content      = base64encode(random_password.initial_edge_client_secret.result)
   }
   lifecycle { ignore_changes = all }
}

data "oci_vault_secrets" "edge_client_secret" {
    depends_on     = [ oci_vault_secret.edge_client_secret ]
    compartment_id = oci_identity_compartment.edge_comp.id
    vault_id       = var.EDGE_VAULT_OCID
    name           = nonsensitive ("EDGE_CLIENT_SECRET_${local.WORKSPACE}.${random_password.edge_instance_id.result}")
}
data "oci_secrets_secretbundle" "edge_client_secret_secretbundle" { secret_id = data.oci_vault_secrets.edge_client_secret.secrets.0.id }
locals {
   edge_client_secret_b64 = sensitive(data.oci_secrets_secretbundle.edge_client_secret_secretbundle.secret_bundle_content.0.content)
}

resource "time_sleep" "edge_wait_for_secrets" {
  depends_on = [
     oci_vault_secret.edge_admin_secret,
     oci_vault_secret.edge_be_session_secret,
     oci_vault_secret.edge_be_auth_secret,
     oci_vault_secret.session_edge_secret,
     oci_vault_secret.edge_ib_secret,
     oci_vault_secret.edge_auth_secret,
     oci_vault_secret.edge_org_secret,
     oci_vault_secret.edge_engine_baseurl_secret,
     oci_vault_secret.edge_engine_subscription_secret,
     oci_vault_secret.edge_deployment_secret,
     oci_vault_secret.edge_db_pw_secret,
     oci_vault_secret.edge_db_connstr_secret,
     oci_vault_secret.edge_trc_bucket_rw_url_secret,
     oci_vault_secret.edge_deps_bucket_rw_url_secret,
     oci_vault_secret.edge_client_secret
  ]
  create_duration = "10s"
}
