resource "oci_identity_dynamic_group" "engine_dyngrp" {
    compartment_id = var.ENGINE_OCI_TENANCY_OCID
    description    = "ROCKIT Engine [${local.workspace}]"
    matching_rule  = "tag.ROCKITPLAY-Tags.instanceName.value = 'engine-${local.workspace}'"
    name           = "engine-dyngrp-${local.workspace}"
}



resource "oci_identity_policy" "engine_tenancy_rt_pol" {
   compartment_id = var.ENGINE_OCI_TENANCY_OCID
   description    = "ROCKIT Engine [${local.workspace}] Runtime Tenancy Policy"
   name           = "engine-tenancy-rt-pol-${local.workspace}"
   depends_on     = [ oci_identity_dynamic_group.engine_dyngrp ]
   statements     = [
      "Allow dynamic-group engine-dyngrp-${local.workspace} to manage tag-namespaces in tenancy where any { target.tag-namespace.name='ROCKITPLAY-Tags', target.tag-namespace.name='Oracle-Tags' }",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to use vaults in tenancy",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to use keys in tenancy"
   ]
}
resource "oci_identity_policy" "engine_workspace_rt_pol" {
   compartment_id = var.ENGINE_PARENT_COMP_OCID
   description    = "ROCKIT Engine [${local.workspace}] Runtime Workspace Policy"
   name           = "engine-workspace-rt-pol-${local.workspace}"
   depends_on = [
      oci_identity_compartment.engine_comp,
      oci_identity_dynamic_group.engine_dyngrp
   ]
   statements     = [
      "Allow dynamic-group engine-dyngrp-${local.workspace} to use secret-family in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to manage instance-family in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to use virtual-network-family in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to manage volume-family in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to read app-catalog-listing in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to manage block-volumes in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to read buckets in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to manage objects-family in compartment engine-comp-${local.workspace}",
      "Allow dynamic-group engine-dyngrp-${local.workspace} to use log-content in compartment engine-comp-${local.workspace}",
      "Allow service objectstorage-${var.ENGINE_OCI_REGION} to manage object-family in compartment engine-comp-${local.workspace}",
      "Allow any-user to use functions-family in compartment engine-comp-${local.workspace} where All {request.principal.type= 'ApiGateway', request.resource.compartment.id = '${oci_identity_compartment.engine_comp.id}'}",
   ]
}
