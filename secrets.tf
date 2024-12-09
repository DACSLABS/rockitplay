# --- ROCKITPLAY_CERT_OCID
data "oci_vault_secrets" "cert_ocid_secret" {
    vault_id       = local.vault_ocid
    compartment_id = local.rockitplay_comp_ocid
    name           = "ROCKITPLAY_CERT_OCID.${local.baseenv_id}"
}
data "oci_secrets_secretbundle" "cert_ocid_secretbundle" { secret_id = data.oci_vault_secrets.cert_ocid_secret.secrets.0.id }

# --- ROCKITPLAY_CERT_DOMAINNAME
data "oci_vault_secrets" "cert_domainname_secret" {
    vault_id       = local.vault_ocid
    compartment_id = local.rockitplay_comp_ocid
    name           = "ROCKITPLAY_CERT_DOMAINNAME.${local.baseenv_id}"
}
data "oci_secrets_secretbundle" "cert_domainname_secretbundle" { secret_id = data.oci_vault_secrets.cert_domainname_secret.secrets.0.id }

# --- ROCKITPLAY_LOADER_IMAGE_OCID
data "oci_vault_secrets" "rockitplay_loader_img_ocid_secret" {
    vault_id       = local.vault_ocid
    compartment_id = local.rockitplay_comp_ocid
    name           = "ROCKITPLAY_LOADER_IMAGE_OCID.${local.baseenv_id}"
}
data "oci_secrets_secretbundle" "rockitplay_loader_img_ocid_secretbundle" { secret_id = data.oci_vault_secrets.rockitplay_loader_img_ocid_secret.secrets.0.id }

# --- ROCKITPLAY_MONGODBATLAS_ORGID
data "oci_vault_secrets" "mongodbatlas_orgid_secret" {
    vault_id       = local.vault_ocid
    compartment_id = local.rockitplay_comp_ocid
    name           = "ROCKITPLAY_MONGODBATLAS_ORGID.${local.baseenv_id}"
}
data "oci_secrets_secretbundle" "mongodbatlas_orgid_secretbundle" { secret_id = data.oci_vault_secrets.mongodbatlas_orgid_secret.secrets.0.id }

# --- ROCKITPLAY_MONGODBATLAS_ADMIN_PUBKEY
data "oci_vault_secrets" "mongodbatlas_admin_pubkey_secret" {
    vault_id       = local.vault_ocid
    compartment_id = local.rockitplay_comp_ocid
    name           = "ROCKITPLAY_MONGODBATLAS_ADMIN_PUBKEY.${local.baseenv_id}"
}
data "oci_secrets_secretbundle" "mongodbatlas_admin_pubkey_secretbundle" { secret_id = data.oci_vault_secrets.mongodbatlas_admin_pubkey_secret.secrets.0.id }

# --- ROCKITPLAY_MONGODBATLAS_ADMIN_PRIVKEY
data "oci_vault_secrets" "mongodbatlas_admin_privkey_secret" {
    vault_id       = local.vault_ocid
    compartment_id = local.rockitplay_comp_ocid
    name           = "ROCKITPLAY_MONGODBATLAS_ADMIN_PRIVKEY.${local.baseenv_id}"
}
data "oci_secrets_secretbundle" "mongodbatlas_admin_privkey_secretbundle" { secret_id = data.oci_vault_secrets.mongodbatlas_admin_privkey_secret.secrets.0.id }

# --- ROCKITPLAY_SLACK_TOKEN
data "oci_vault_secrets" "slack_token_secret" {
    vault_id       = local.vault_ocid
    compartment_id = local.rockitplay_comp_ocid
    name           = "ROCKITPLAY_SLACK_TOKEN.${local.baseenv_id}"
}
data "oci_secrets_secretbundle" "slack_token_secretbundle" { secret_id = data.oci_vault_secrets.slack_token_secret.secrets.0.id }


locals {
   with_cert                  = local.cert_ocid == "n/a" ? false : true
   cert_ocid                  = base64decode (data.oci_secrets_secretbundle.cert_ocid_secretbundle.secret_bundle_content.0.content)
   cert_domainname            = base64decode (data.oci_secrets_secretbundle.cert_domainname_secretbundle.secret_bundle_content.0.content)
   rockitplay_loader_img_ocid = base64decode (data.oci_secrets_secretbundle.rockitplay_loader_img_ocid_secretbundle.secret_bundle_content.0.content)
   mongodbatlas_orgid         = base64decode (data.oci_secrets_secretbundle.mongodbatlas_orgid_secretbundle.secret_bundle_content.0.content)
   mongodbatlas_admin_pubkey  = base64decode (data.oci_secrets_secretbundle.mongodbatlas_admin_pubkey_secretbundle.secret_bundle_content.0.content)
   mongodbatlas_admin_privkey = base64decode (data.oci_secrets_secretbundle.mongodbatlas_admin_privkey_secretbundle.secret_bundle_content.0.content)
   slack_token                = base64decode (data.oci_secrets_secretbundle.slack_token_secretbundle.secret_bundle_content.0.content)
}