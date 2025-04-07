# --- import cwl Docker image
resource "null_resource" "engine_import_cwl_image" {
   depends_on = [
      oci_identity_auth_token.engine_registry_user_authtoken,
      time_sleep.engine_wait_for_registry_user,
      oci_artifacts_container_repository.engine_cwl_container_repository
   ]
   triggers = {
      always = "${timestamp()}"
      # src_updated = var.ENGINE_SRC_HASH
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         (echo '${local.engine_registry_user_pw}' | docker login ${var.ENGINE_OCI_REGION}.ocir.io -u ${var.ENGINE_OCI_NAMESPACE}/default/${oci_identity_user.engine_registry_user.name} --password-stdin)

         #workdir=/var/tmp/engine-${var.ENGINE_SRC_HASH}
         workdir=cwl
         mkdir -p $workdir

         curl --fail -o $workdir/engine-cwl.tgz ${var.ENGINE_CWL_URL}
         pushd $workdir
            tar xvfz engine-cwl.tgz
            docker buildx create --name mybuilder
            docker buildx use mybuilder
            docker buildx build --platform linux/arm64,linux/amd64 -t ${local.engine_registry}/rockit-engine-cwl:latest --push .
         popd
      EOT
   }
}

# --- policies
resource "oci_identity_dynamic_group" "engine_cwl_dyngrp" {
   compartment_id = var.ENGINE_OCI_TENANCY_OCID
   description    = "ROCKIT Engine CWLs"
   matching_rule  = "ALL {resource.type='computecontainerinstance'}"
   name           = "engine-cwl-dyngrp-${local.workspace}"
}
resource "oci_identity_policy" "engine_cwl_pol" {
   compartment_id = var.ENGINE_PARENT_COMP_OCID
   description    = "Allow CWL to pull from container registry"
   name           = "engine-cwl-pol-${local.workspace}"
   depends_on     = [ oci_identity_dynamic_group.engine_cwl_dyngrp ]
   statements     = [
      "Allow dynamic-group engine-cwl-dyngrp-${local.workspace} to read repos in compartment engine-comp-${local.workspace}"
   ]
}

resource "oci_container_instances_container_instance" "engine_cwl" {
   count               = var.ENGINE_N_CONTAINER_INSTANCES
   depends_on          = [
      null_resource.engine_import_cwl_image,
      oci_objectstorage_preauthrequest.tsk_bucket_readwrite_par,
      time_sleep.engine_wait_for_secrets
   ]
   display_name        = "engine-cwl-${count.index+1}-${local.workspace}"
   state               = "ACTIVE"
	compartment_id      = oci_identity_compartment.engine_comp.id
	availability_domain = data.oci_identity_availability_domains.engine_availability_domains.availability_domains[0]["name"]

   defined_tags = {
      "ROCKITPLAY-Tags.instanceName" = "engine-${local.workspace}"
      "ROCKITPLAY-Tags.taskLoader"   = "rockit-loader-${var.ENGINE_BASEENV_ID}"
   }

   image_pull_secrets {
      registry_endpoint = "${local.engine_registry}/"
      secret_type       = "BASIC"
      username          = base64encode(oci_identity_user.engine_registry_user.name)
      password          = base64encode(local.engine_registry_user_pw)
      secret_id         = null
   }

   containers {
      display_name = "rockit-engine-cwl-container-${count.index+1}-${local.workspace}"
      image_url    = "${local.engine_registry}/rockit-engine-cwl:latest"
      environment_variables  = {
         "ENV"                               : local.env
         "WORKSPACE"                         : local.workspace
         "INSTANCE_ID"                       : random_password.instance_id.result
         "OCI_TENANCY"                       : var.ENGINE_OCI_TENANCY_OCID
         "DX_ENGINE_BASE_URL"                : "https://${local.engine_pub_hostname}.cloud.rockitplay.com"
         "DX_ENGINE_COMP_OCID"               : oci_identity_compartment.engine_comp.id
         "DX_ENGINE_VAULT_OCID"              : var.ENGINE_VAULT_OCID
         "DX_ENGINE_TASK_LOG_OCID"           : oci_logging_log.engine_task_log.id
         "DX_ENGINE_TASK_SUBNET_OCID"        : oci_core_subnet.engine_pub_subnet.id
         "DX_ENGINE_TASK_BOOTIMG_OCID"       : var.ENGINE_LOADER_IMG_OCID
         "DX_ENGINE_TASK_URL"                : "${local.tsk_bucket_readwrite_url}engine-task.tgz"
         "DX_ENGINE_TASK_SIG"                : var.ENGINE_TASK_SIG
         "DX_ENGINE_ADMIN_SECRET_B64"        : local.engine_admin_secret_b64
         "DX_ENGINE_SESSION_SECRET_B64"      : local.engine_session_secret_b64
         "DX_ENGINE_AUTH_SECRET_B64"         : local.engine_session_secret_b64
         "DX_ENGINE_SUBSCRIPTION_SECRET_B64" : local.engine_subscription_secret_b64
         "DX_ENGINE_DB_CONNSTR_B64"          : local.engine_db_connstr_secret_b64
         "DX_ENGINE_SLACK_TOKEN_B64"         : local.engine_slack_token_secret_b64
         "DX_ENGINE_SLACK_ADMIN_CHANNEL_B64" : local.engine_slack_admin_channel_secret_b64
         "DX_ENGINE_SLACK_ERROR_CHANNEL_B64" : local.engine_slack_error_channel_secret_b64
         "DX_ENGINE_SLACK_INFO_CHANNEL_B64"  : local.engine_slack_info_channel_secret_b64
      }
   }

    shape = var.ENGINE_CWL_CONTAINER_SHAPE

   shape_config {
      ocpus         = 1
      memory_in_gbs = 6
   }
   vnics {
      subnet_id = oci_core_subnet.engine_priv_subnet.id
      is_public_ip_assigned = false
   }
}

# --- enforce restart do reset inject.sh
resource "null_resource" "engine_cwl_restart" {
   count      = local.use_cwl && local.env == "test"  ? 1 : 0
   depends_on = [ oci_container_instances_container_instance.engine_cwl ]
   triggers = {
      always = "${timestamp()}"
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = "oci container-instances container-instance restart --container-instance-id ${oci_container_instances_container_instance.engine_cwl[0].id}"
   }
}

