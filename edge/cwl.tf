# --- import cwl Docker image
resource "null_resource" "edge_import_cwl_image" {
   depends_on = [
      oci_identity_auth_token.edge_registry_user_authtoken,
      time_sleep.edge_wait_for_registry_user,
      oci_artifacts_container_repository.edge_cwl_container_repository
   ]
   triggers = {
      # always = "${timestamp()}"
      src_updated = var.EDGE_SRC_HASH
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         (echo '${local.edge_registry_user_pw}' | docker login ${var.EDGE_OCI_REGION}.ocir.io -u ${var.EDGE_OCI_NAMESPACE}/default/${oci_identity_user.edge_registry_user.name} --password-stdin)

         #workdir=/var/tmp/edge-${var.EDGE_SRC_HASH}
         workdir=cwl
         mkdir -p $workdir

         curl --fail -o $workdir/edge-cwl.tgz ${var.EDGE_CWL_URL}
         pushd $workdir
            tar xvfz edge-cwl.tgz
            docker build --platform linux/amd64 -t ${local.edge_registry}/rockit-edge-cwl:latest .
            docker push ${local.edge_registry}/rockit-edge-cwl:latest
            #docker buildx create --name edge_builder
            #docker buildx use edge_builder
            #docker buildx build --platform linux/arm64 -t ${local.edge_registry}/rockit-edge-cwl:latest --push .
            #docker buildx build --platform linux/amd64 -t ${local.edge_registry}/rockit-edge-cwl:latest --push .
         popd
      EOT
   }
}

# --- policies
resource "oci_identity_dynamic_group" "edge_cwl_dyngrp" {
   compartment_id = var.EDGE_OCI_TENANCY_OCID
   description    = "ROCKIT Edge CWLs"
   matching_rule  = "ALL {resource.type='computecontainerinstance'}"
   name           = "edge-cwl-dyngrp-${local.workspace}"
}
resource "oci_identity_policy" "edge_cwl_pol" {
   compartment_id = var.EDGE_PARENT_COMP_OCID
   description    = "Allow CWL to pull from container registry"
   name           = "edge-cwl-pol-${local.workspace}"
   depends_on     = [ oci_identity_dynamic_group.edge_cwl_dyngrp ]
   statements     = [
      "Allow dynamic-group edge-cwl-dyngrp-${local.workspace} to read repos in compartment edge-comp-${local.workspace}"
   ]
}

resource "oci_container_instances_container_instance" "edge_cwl" {
   count               = var.EDGE_N_CONTAINER_INSTANCES
   depends_on          = [
      null_resource.edge_import_cwl_image,
      time_sleep.edge_wait_for_secrets
   ]
   display_name        = "edge-cwl-${count.index+1}-${local.workspace}"
   state               = "ACTIVE"
	compartment_id      = oci_identity_compartment.edge_comp.id
	availability_domain = data.oci_identity_availability_domains.edge_availability_domains.availability_domains[0]["name"]

   defined_tags = {
      "ROCKITPLAY-Tags.instanceName" = "edge-${local.workspace}"
      "ROCKITPLAY-Tags.taskLoader"   = "rockit-loader-${var.EDGE_BASEENV_ID}"
   }

   image_pull_secrets {
      registry_endpoint = "${local.edge_registry}/"
      secret_type       = "BASIC"
      username          = base64encode(oci_identity_user.edge_registry_user.name)
      password          = base64encode(local.edge_registry_user_pw)
      secret_id         = null
   }

   containers {
      display_name = "rockit-edge-cwl-container-${count.index+1}-${local.workspace}"
      image_url    = "${local.edge_registry}/rockit-edge-cwl:latest"
      environment_variables  = {
         "ENV"                                      : local.env
         "WORKSPACE"                                : local.workspace
         "INSTANCE_ID"                              : random_password.edge_instance_id.result
         "OCI_TENANCY"                              : var.EDGE_OCI_TENANCY_OCID
         "DX_EDGE_BASE_URL"                         : local.edge_base_url
         "DX_EDGE_COMP_OCID"                        : oci_identity_compartment.edge_comp.id
         "DX_EDGE_VAULT_OCID"                       : var.EDGE_VAULT_OCID
         "DX_EDGE_TASK_LOG_OCID"                    : oci_logging_log.edge_task_log.id
         "DX_EDGE_TASK_SUBNET_OCID"                 : oci_core_subnet.edge_priv_subnet.id
         "DX_EDGE_TASK_BOOTIMG_OCID"                : var.EDGE_LOADER_IMG_OCID
         "DX_EDGE_TASK_URL"                         : "${local.edge_tsk_bucket_readwrite_url}edge-task.tgz"
         "DX_EDGE_TASK_SIG"                         : var.EDGE_TASK_SIG
         "DX_EDGE_RSI_BASE_URL"                     : var.EDGE_RSI_BASE_URL
         "DX_EDGE_ROCKIT_MC_JS"                     : local.edge_rockitmc_read_url
         "DX_EDGE_ROCKIT_MC_HASH"                   : var.EDGE_MC_HASH
         "DX_EDGE_ADMIN_SECRET_B64"                 : local.edge_admin_secret_b64
         "DX_EDGE_BE_SESSION_SECRET_B64"            : local.edge_be_session_secret_b64
         "DX_EDGE_BE_AUTH_SECRET_B64"               : local.edge_be_auth_secret_b64
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
         "DX_EDGE_SLACK_TOKEN_B64"                  : base64encode(var.EDGE_SLACK_TOKEN)
         "DX_EDGE_SLACK_ADMIN_CHANNEL_B64"          : base64encode(var.EDGE_SLACK_ADMIN_CHANNEL)
         "DX_EDGE_DB_CONNSTR_B64"                   : local.edge_db_connstr_secret_b64
         "DX_EDGE_TRC_BUCKET_READWRITE_URL_B64"     : local.edge_trc_bucket_rw_url_secret_b64
         "DX_EDGE_DEPS_BUCKET_READWRITE_URL_B64"    : local.edge_deps_bucket_rw_url_secret_b64
         "DX_EDGE_DEPOT_BUCKET_READ_URL_B64"        : local.edge_depot_bucket_ro_url_secret_b64
      }
   }

   shape = var.EDGE_CWL_CONTAINER_SHAPE

   shape_config {
      ocpus         = 1
      memory_in_gbs = 6
   }
   vnics {
      subnet_id = oci_core_subnet.edge_priv_subnet.id
      is_public_ip_assigned = false
   }
}

# --- enforce restart do reset inject.sh
resource "null_resource" "edge_cwl_restart" {
   count      = local.use_cwl && local.env == "test"  ? 1 : 0
   depends_on = [ oci_container_instances_container_instance.edge_cwl ]
   triggers = {
      always = "${timestamp()}"
   }
   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = "oci container-instances container-instance restart --container-instance-id ${oci_container_instances_container_instance.edge_cwl[0].id}"
   }
}

