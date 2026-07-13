# --- import fn Docker image
resource "null_resource" "edge_import_fn_image" {
   depends_on = [
      oci_identity_auth_token.edge_registry_user_authtoken,
      time_sleep.edge_wait_for_registry_user,
      oci_artifacts_container_repository.edge_fn_container_repository
   ]
   triggers = {
      src_updated = var.EDGE_SRC_HASH
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         workdir=/var/tmp/edge-${var.EDGE_SRC_HASH}
         mkdir -p $workdir

         curl --fail -o $workdir/edge-fn.tgz ${var.EDGE_FN_URL}
         docker load --input $workdir/edge-fn.tgz

         (echo '${local.edge_registry_user_pw}' | docker login ${var.EDGE_OCI_REGION}.ocir.io -u ${var.EDGE_OCI_NAMESPACE}/default/${oci_identity_user.edge_registry_user.name} --password-stdin)

         rm -rf $workdir

         imageid=$(docker image ls --format "{{.ID}}" dacslabs/rockit-edge-fn:${var.EDGE_SRC_HASH})
         if test $(echo "$imageid" | wc -w) -ne 1; then
            echo "ERROR: received unexpected image id hashes from 'docker images'. Inspect content of edge-fn.tgz."
            exit 1
         fi

         docker tag  $imageid ${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}
         docker tag  $imageid ${local.edge_registry}/rockit-edge-fn:latest

         docker push ${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}
         docker push ${local.edge_registry}/rockit-edge-fn:latest


         docker rmi ${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}
         docker rmi ${local.edge_registry}/rockit-edge-fn:latest
         docker rmi dacslabs/rockit-edge-fn:${var.EDGE_SRC_HASH}
      EOT
   }
}

# ---------------------------------------------------------------------------


resource "oci_functions_application" "edge_app" {
   depends_on     = [
      null_resource.edge_import_fn_image,
      time_sleep.edge_wait_for_secrets
   ]
   compartment_id =  oci_identity_compartment.edge_comp.id
   display_name   = "edge-app-${local.workspace}"
   subnet_ids     = [ oci_core_subnet.edge_priv_subnet.id ]
   config         = {
      "ENV"                                      : local.env
      "WORKSPACE"                                : local.workspace
      "INSTANCE_ID"                              : random_password.edge_instance_id.result
      "OCI_TENANCY"                              : var.EDGE_OCI_TENANCY_OCID
      "OCI_NAMESPACE"                            : var.EDGE_OCI_NAMESPACE
      "OCI_REGION"                               : var.EDGE_OCI_REGION
      "OCI_AV_DOMAINS"                           : local.avDomains
      "DX_EDGE_BASE_URL"                         : local.edge_base_url
      "DX_EDGE_COMP_OCID"                        : oci_identity_compartment.edge_comp.id
      "DX_EDGE_VAULT_OCID"                       : var.EDGE_VAULT_OCID
      "DX_EDGE_TASK_LOG_OCID"                    : oci_logging_log.edge_task_log.id
      "DX_EDGE_TASK_SUBNET_OCID"                 : oci_core_subnet.edge_priv_subnet.id
      "DX_EDGE_TASK_BOOTIMG_OCID"                : var.EDGE_LOADER_IMG_OCID
      "DX_EDGE_TASK_URL"                         : "${local.edge_tsk_bucket_readwrite_url}edge-task.tgz"
      "DX_EDGE_TASK_SIG"                         : var.EDGE_TASK_SIG
      "DX_EDGE_RSI_BASE_URL"                     : var.EDGE_RSI_BASE_URL
      "DX_EDGE_ADMIN_SECRET_B64"                 : local.edge_admin_secret_b64
      "DX_EDGE_ADM_REFRESH_SECRET_B64"           : local.edge_adm_refresh_secret_b64
      "DX_EDGE_ADM_ACCESS_SECRET_B64"            : local.edge_adm_access_secret_b64
      "DX_EDGE_SIGNUP_SECRET_B64"                : local.edge_signup_secret_b64
      "DX_EDGE_RESETPW_SECRET_B64"               : local.edge_signup_secret_b64  // use the same secret as signup
      "DX_EDGE_BE_ORGSEL_SECRET_B64"             : local.edge_be_orgsel_secret_b64
      "DX_EDGE_BE_REFRESH_SECRET_B64"            : local.edge_be_refresh_secret_b64
      "DX_EDGE_BE_ACCESS_SECRET_B64"             : local.edge_be_access_secret_b64
      "DX_EDGE_SESSION_SECRET_B64"               : local.edge_session_secret_b64
      "DX_EDGE_CLIENT_SECRET_B64"                : local.edge_client_secret_b64
      "DX_EDGE_DX_ORGTOKEN_PUBKEY_PEM_PROD_B64"  : local.orgTokenPubKeyB64.prod
      "DX_EDGE_DX_ORGTOKEN_PUBKEY_PEM_STAGE_B64" : local.orgTokenPubKeyB64.stage
      "DX_EDGE_DX_ORGTOKEN_PUBKEY_PEM_TEST_B64"  : local.orgTokenPubKeyB64.test
      "DX_EDGE_IB_SECRET_B64"                    : local.edge_ib_secret_b64
      "DX_EDGE_AUTH_SECRET_B64"                  : local.edge_auth_secret_b64
      "DX_EDGE_ORG_SECRET_B64"                   : local.edge_org_secret_b64
      "DX_EDGE_ENGINE_BASE_URL_B64"              : local.edge_engine_baseurl_secret_b64
      "DX_EDGE_ENGINE_ADMIN_TOKEN_B64"           : base64encode(var.EDGE_ENGINE_ADMIN_TOKEN)
      "DX_EDGE_ENGINE_SUBSCRIPTION_SECRET_B64"   : local.edge_engine_subscription_secret_b64
      "DX_EDGE_SUBSCRIPTION_SECRET_B64"          : local.edge_subscription_secret_b64
      "DX_EDGE_DEPLOYMENT_SECRET_B64"            : local.edge_deployment_secret_b64
      "DX_EDGE_SOURCE_SECRET_B64"                : local.edge_source_secret_b64
      "DX_EDGE_SMTP_HOST"                        : var.EDGE_SMTP_HOST
      "DX_EDGE_SMTP_PORT"                        : var.EDGE_SMTP_PORT
      "DX_EDGE_SMTP_USER"                        : var.EDGE_SMTP_USER
      "DX_EDGE_SMTP_PASSWORD_B64"                : base64encode(var.EDGE_SMTP_PASSWORD)
      "DX_EDGE_SLACK_TOKEN_B64"                  : base64encode(var.EDGE_SLACK_TOKEN)
      "DX_EDGE_SLACK_ADMIN_CHANNEL_B64"          : base64encode(var.EDGE_SLACK_ADMIN_CHANNEL)
      "DX_EDGE_GOOGLE_CLIENT_ID"                 : var.EDGE_GOOGLE_CLIENT_ID
      "DX_EDGE_ABLY_APIKEY"                      : local.edge_ably_apikey
      "DX_EDGE_DB_CONNSTR_B64"                   : local.edge_db_connstr_secret_b64
      "DX_EDGE_TRC_BUCKET_READWRITE_URL_B64"     : local.edge_trc_bucket_rw_url_secret_b64
      "DX_EDGE_DEPS_BUCKET_READWRITE_URL_B64"    : local.edge_deps_bucket_rw_url_secret_b64
      "DX_EDGE_DEPOT_BUCKET_READ_URL_B64"        : local.edge_depot_bucket_ro_url_secret_b64
      "DX_HAS_CWL_EVENT_QUEUE"                   : var.EDGE_USE_CWL ? "true" : "false"
   }
}

resource "oci_functions_function" "edge_fn" {
   depends_on         = [
      oci_functions_application.edge_app,
      oci_logging_log.edge_fn_log
   ]
   application_id     = oci_functions_application.edge_app.id
   display_name       = "edge-fn-${local.workspace}"
   image              = "${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}"
   memory_in_mbs      = 256
   timeout_in_seconds = 300
   defined_tags = {
      "ROCKITPLAY-Tags.instanceName" = "edge-${local.workspace}"
      "ROCKITPLAY-Tags.taskLoader"   = "rockit-loader-${var.EDGE_BASEENV_ID}"
   }
   # provisioned_concurrency_config {
   #    count    = local.env == "prod" ? 20 : 0
   #    strategy = local.env == "prod" ? "CONSTANT" : "NONE"
   # }
}

# --- Logs
resource "oci_logging_log" "edge_fn_log" {
   display_name       = "edge-fn-log-${local.workspace}"
   log_group_id       = oci_logging_log_group.edge_log_group.id
   log_type           = "CUSTOM"
   is_enabled         = true
   retention_duration = 30
}

# --- Output
# output "fn_image" {
#    value = "${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}"
# }