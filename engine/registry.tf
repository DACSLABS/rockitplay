resource "oci_identity_user" "engine_registry_user" {
  compartment_id = var.ENGINE_OCI_TENANCY_OCID
  name           = "engine-registry-user-${local.workspace}"
  description    = "Registry Upload User for ROCKIT Engine [${local.workspace}]"
}
resource "oci_identity_group" "engine_registry_group" {
  compartment_id = var.ENGINE_OCI_TENANCY_OCID
  name           = "engine-registry-group-${local.workspace}"
  description    = "Registry Upload User Group for ROCKIT Engine [${local.workspace}]"
}

# --- avoid OCI bug (500 error when destroying oci_identity_user_group_membership)
# resource "oci_identity_user_group_membership" "engine_registry_user_group_membership" {
#   user_id  = oci_identity_user.engine_registry_user.id
#   group_id = oci_identity_group.engine_registry_group.id
# }
resource "null_resource" "engine_registry_user_group_membership" {
  provisioner "local-exec" {
    command = "oci iam group add-user --user-id ${oci_identity_user.engine_registry_user.id} --group-id ${oci_identity_group.engine_registry_group.id} || true"
  }
}


resource "oci_identity_auth_token" "engine_registry_user_authtoken" {
  depends_on  = [ null_resource.engine_registry_user_group_membership ]
  user_id     = oci_identity_user.engine_registry_user.id
  description = "Docker login auth token for ROCKIT Engine [${local.workspace}]"
}


locals {
   engine_registry_user_pw = oci_identity_auth_token.engine_registry_user_authtoken.token
}

resource "oci_artifacts_container_repository" "engine_fn_container_repository" {
  depends_on     = [ time_sleep.engine_wait_for_registry_user ]
  compartment_id = oci_identity_compartment.engine_comp.id
  display_name   = "engine-registry-${local.workspace}/rockit-engine-fn"
}

resource "oci_artifacts_container_repository" "engine_cwl_container_repository" {
  compartment_id = oci_identity_compartment.engine_comp.id
  display_name   = "engine-registry-${local.workspace}/rockit-engine-cwl"
}