# --- Load Balancer

# - see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_load_balancer.html
#
# on bandwidth:
# - min and max are set according to benchmark results
# - 10 mbps is Free Tier at OCI, more then that makes no sense with a
#   "free_cluster" database
# - any "advanced_cluster" database is greatly limited by a 10mbps
#   configuration -> this combination makes no sense either
resource "oci_load_balancer_load_balancer" "edge_lb" {
   count          = var.EDGE_USE_CWL ? 1 : 0

   compartment_id = oci_identity_compartment.edge_comp.id
   display_name   = "edge-lb-${local.workspace}"
   subnet_ids     = [ oci_core_subnet.edge_priv_subnet.id ]

	shape = "flexible"
	shape_details {
		minimum_bandwidth_in_mbps = (var.EDGE_DB_TYPE=="free_cluster" ? 10 : 70)
		maximum_bandwidth_in_mbps = (var.EDGE_DB_TYPE=="free_cluster" ? 10 : var.EDGE_N_CONTAINER_INSTANCES * 70)
	}

   defined_tags = {
      "ROCKITPLAY-Tags.instanceName" = "edge-${local.workspace}"
   }
	is_private = true  # API-GW provides the public address
}

locals {
   lb_ipaddr = var.EDGE_USE_CWL ? oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address : "n/a"
}


# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_backend_set.html
resource "oci_load_balancer_backend_set" "edge_lb_beset" {
   count          = var.EDGE_USE_CWL ? 1 : 0

   name             = "edge-lb-beset-${local.workspace}"
	load_balancer_id = oci_load_balancer_load_balancer.edge_lb[0].id

	policy = "LEAST_CONNECTIONS"

	health_checker {
		protocol = "HTTP"
		interval_ms = 10000
		port = 3000
		retries = 3
		return_code = 200
		timeout_in_millis = 3000
		url_path = "/"
	}
}

# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_listener.html
resource "oci_load_balancer_listener" "edge_http" {
   count          = var.EDGE_USE_CWL ? 1 : 0

	name = "edge_${local.workspace}_http"
	load_balancer_id = oci_load_balancer_load_balancer.edge_lb[0].id
	default_backend_set_name = oci_load_balancer_backend_set.edge_lb_beset[0].name
	port = 80
	protocol = "HTTP"
}

# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_backend.html
resource "oci_load_balancer_backend" "edge_cwl_container" {
   count          = var.EDGE_USE_CWL ? var.EDGE_N_CONTAINER_INSTANCES : 0

	backendset_name = oci_load_balancer_backend_set.edge_lb_beset[0].name
	ip_address = oci_container_instances_container_instance.edge_cwl[count.index].vnics[0].private_ip
	load_balancer_id = oci_load_balancer_load_balancer.edge_lb[0].id
	port = 3000
}
