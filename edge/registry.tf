resource "oci_identity_user" "edge_registry_user" {
  compartment_id = var.EDGE_OCI_TENANCY_OCID
  name           = "edge-registry-user-${local.workspace}"
  description    = "Registry Upload User for ROCKIT Edge [${local.workspace}]"
}
resource "oci_identity_group" "edge_registry_group" {
  compartment_id = var.EDGE_OCI_TENANCY_OCID
  name           = "edge-registry-group-${local.workspace}"
  description    = "Registry Upload User Group for ROCKIT Edge [${local.workspace}]"
}
# --- avoid OCI bug (error 500 when destroying oci_identity_user_group_membership)
# resource "oci_identity_user_group_membership" "edge_registry_group" {
#   user_id  = oci_identity_user.edge_registry_user.id
#   group_id = oci_identity_group.edge_registry_group.id
# }
resource "null_resource" "edge_registry_user_group_membership" {
  provisioner "local-exec" {
    command = "oci iam group add-user --user-id ${oci_identity_user.edge_registry_user.id} --group-id ${oci_identity_group.edge_registry_group.id} || true"
  }
}

resource "oci_identity_auth_token" "edge_registry_user_authtoken" {
  depends_on  = [ null_resource.edge_registry_user_group_membership ]
  user_id     = oci_identity_user.edge_registry_user.id
  description = "Docker login auth token for ROCKIT Edge [${local.workspace}]"
}

locals {
  edge_registry_user_pw = oci_identity_auth_token.edge_registry_user_authtoken.token
}

resource "oci_artifacts_container_repository" "edge_fn_container_repository" {
  depends_on     = [ time_sleep.edge_wait_for_registry_user ]
  compartment_id = oci_identity_compartment.edge_comp.id
  display_name   = "edge-registry-${local.workspace}/rockit-edge-fn"
}

resource "oci_artifacts_container_repository" "edge_cwl_container_repository" {
  compartment_id = oci_identity_compartment.edge_comp.id
  display_name   = "edge-registry-${local.workspace}/rockit-edge-cwl"
}