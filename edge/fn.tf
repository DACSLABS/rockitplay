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
         docker tag  dacslabs/rockit-edge-fn:${var.EDGE_SRC_HASH} ${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}
         docker push ${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}

         docker rmi ${local.edge_registry}/rockit-edge-fn:${var.EDGE_SRC_HASH}
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
   subnet_ids     = [ oci_core_subnet.edge_pub_subnet.id ]
   config         = {
      "ENV"                       : local.env
      "WORKSPACE"                 : local.workspace
      "INSTANCE_ID"               : random_password.edge_instance_id.result
      "OCI_TENANCY"               : var.EDGE_OCI_TENANCY_OCID
      "DX_EDGE_BASE_URL"          : local.edge_base_url
      "DX_EDGE_COMP_OCID"         : oci_identity_compartment.edge_comp.id
      "DX_EDGE_VAULT_OCID"        : var.EDGE_VAULT_OCID
      "DX_EDGE_TASK_LOG_OCID"     : oci_logging_log.edge_task_log.id
      "DX_EDGE_TASK_SUBNET_OCID"  : oci_core_subnet.edge_pub_subnet.id
      "DX_EDGE_TASK_BOOTIMG_OCID" : var.EDGE_LOADER_IMG_OCID
      "DX_EDGE_TASK_URL"          : "${local.edge_tsk_bucket_readwrite_url}edge-task.tgz"
      "DX_EDGE_TASK_SIG"          : var.EDGE_TASK_SIG
      "DX_EDGE_RSI_BASE_URL"      : var.EDGE_RSI_BASE_URL
      "DX_EDGE_ROCKIT_MC_JS"      : local.edge_rockitmc_read_url
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
   provisioned_concurrency_config {
      count    = local.workspace == "prod" ? 20 : 0
      strategy = local.workspace == "prod" ? "CONSTANT" : "NONE"
   }
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