# --- import fn Docker image
resource "null_resource" "import_fn_image" {
   depends_on = [
      oci_identity_auth_token.engine_registry_user_authtoken,
      time_sleep.engine_wait_for_registry_user,
      oci_artifacts_container_repository.engine_fn_container_repository
   ]
   triggers = {
      src_updated = var.ENGINE_SRC_HASH
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         workdir=/var/tmp/engine-${var.ENGINE_SRC_HASH}
         mkdir -p $workdir

         curl --fail -o $workdir/engine-fn.tgz ${var.ENGINE_FN_URL}
         docker load --input $workdir/engine-fn.tgz

         (echo '${local.engine_registry_user_pw}' | docker login ${var.ENGINE_OCI_REGION}.ocir.io -u ${var.ENGINE_OCI_NAMESPACE}/${oci_identity_user.engine_registry_user.name} --password-stdin)

         rm -rf $workdir
         docker tag  dacslabs/rockit-engine-fn:${var.ENGINE_SRC_HASH} ${local.engine_registry}/rockit-engine-fn:${var.ENGINE_SRC_HASH}
         docker push ${local.engine_registry}/rockit-engine-fn:${var.ENGINE_SRC_HASH}

         docker rmi ${local.engine_registry}/rockit-engine-fn:${var.ENGINE_SRC_HASH}
         docker rmi dacslabs/rockit-engine-fn:${var.ENGINE_SRC_HASH}
      EOT
   }
}

# ---------------------------------------------------------------------------

resource "oci_functions_application" "engine_app" {
   depends_on     = [
      null_resource.import_fn_image,
      oci_objectstorage_preauthrequest.tsk_bucket_readwrite_par,
      time_sleep.engine_wait_for_secrets
   ]
   compartment_id =  oci_identity_compartment.engine_comp.id
   display_name   = "engine-app-${local.workspace}"
   subnet_ids     = [ oci_core_subnet.engine_pub_subnet.id ]
   config         = {
      "ENV"                         : local.env
      "WORKSPACE"                   : local.workspace
      "INSTANCE_ID"                 : random_password.instance_id.result
      "OCI_TENANCY"                 : var.ENGINE_OCI_TENANCY_OCID
      "DX_ENGINE_COMP_OCID"         : oci_identity_compartment.engine_comp.id
      "DX_ENGINE_VAULT_OCID"        : var.ENGINE_VAULT_OCID
      "DX_ENGINE_TASK_LOG_OCID"     : oci_logging_log.engine_task_log.id
      "DX_ENGINE_TASK_SUBNET_OCID"  : oci_core_subnet.engine_pub_subnet.id
      "DX_ENGINE_TASK_BOOTIMG_OCID" : var.ENGINE_LOADER_IMG_OCID
      "DX_ENGINE_TASK_URL"          : "${local.tsk_bucket_readwrite_url}engine-task.tgz"
      "DX_ENGINE_TASK_SIG"          : var.ENGINE_TASK_SIG
   }
}

resource "oci_functions_function" "engine_fn" {
   depends_on         = [
      oci_functions_application.engine_app,
      oci_logging_log.engine_fn_log
   ]
   application_id     = oci_functions_application.engine_app.id
   display_name       = "engine-fn-${local.workspace}"
   image              = "${local.engine_registry}/rockit-engine-fn:${var.ENGINE_SRC_HASH}"
   memory_in_mbs      = 128
   timeout_in_seconds = 300
   defined_tags = {
      "ROCKITPLAY-Tags.instanceName" = "engine-${local.workspace}"
      "ROCKITPLAY-Tags.taskLoader"   = "rockit-loader-${var.ENGINE_BASEENV_ID}"
   }
   # provisioned_concurrency_config {
   #    count    = local.env == "prod" ? 40 : 0
   #    strategy = local.env == "prod" ? "CONSTANT" : "NONE"
   # }
}

# --- Logs
resource "oci_logging_log" "engine_fn_log" {
   display_name       = "engine-fn-log-${local.workspace}"
   log_group_id       = oci_logging_log_group.engine_log_group.id
   log_type           = "CUSTOM"
   is_enabled         = true
   retention_duration = 30
}