resource "oci_identity_dynamic_group" "edge_dyngrp" {
    compartment_id = var.EDGE_OCI_TENANCY_OCID
    description    = "ROCKIT Edge [${local.workspace}]"
    matching_rule  = "tag.ROCKITPLAY-Tags.instanceName.value = 'edge-${local.workspace}'"
    name           = "edge-dyngrp-${local.workspace}"
}


resource "oci_identity_policy" "edge_tenancy_rt_pol" {
   compartment_id = var.EDGE_OCI_TENANCY_OCID
   description    = "ROCKIT Edge [${local.workspace}] Runtime Tenancy Policy"
   name           = "edge-tenancy-rt-pol-${local.workspace}"
   depends_on     = [ oci_identity_dynamic_group.edge_dyngrp ]
   statements     = [
      "Allow dynamic-group edge-dyngrp-${local.workspace} to manage tag-namespaces in tenancy where any { target.tag-namespace.name='ROCKITPLAY-Tags', target.tag-namespace.name='Oracle-Tags' }",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to use vaults in tenancy",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to use keys in tenancy"
   ]
}
resource "oci_identity_policy" "edge_workspace_rt_pol" {
   compartment_id = var.EDGE_PARENT_COMP_OCID
   description    = "ROCKIT Edge [${local.workspace}] Runtime Workspace Policy"
   name           = "edge-workspace-rt-pol-${local.workspace}"
   depends_on = [
      oci_identity_compartment.edge_comp,
      oci_identity_dynamic_group.edge_dyngrp
   ]
   statements     = [
      "Allow dynamic-group edge-dyngrp-${local.workspace} to use secret-family in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to manage instance-family in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to use virtual-network-family in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to manage volume-family in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to read app-catalog-listing in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to manage block-volumes in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to read buckets in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to manage objects-family in compartment edge-comp-${local.workspace}",
      "Allow dynamic-group edge-dyngrp-${local.workspace} to use log-content in compartment edge-comp-${local.workspace}",
      "Allow service objectstorage-${var.EDGE_OCI_REGION} to manage object-family in compartment edge-comp-${local.workspace}",
      "Allow any-user to use functions-family in compartment edge-comp-${local.workspace} where All {request.principal.type= 'ApiGateway', request.resource.compartment.id = '${oci_identity_compartment.edge_comp.id}'}",
   ]
}
