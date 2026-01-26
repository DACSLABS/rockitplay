# --- Load Balancer

# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_load_balancer.html
#
# on bandwidth:
# - 10 mbps is Free Tier at OCI, more then that makes no sense with a
#   "free_cluster" database
# - any "advanced_cluster" database is greatly limited by a 10mbps
#   configuration -> this combination makes no sense either
# - min is the Free Tier, therefore, and dynamic increase to max is allowed as needed
# - max is taken from benchmark results, guestimated for Engine
resource "oci_load_balancer_load_balancer" "engine_lb" {
   count          = var.ENGINE_USE_CWL ? 1 : 0

   compartment_id = oci_identity_compartment.engine_comp.id
   display_name   = "engine-lb-${local.workspace}"
   subnet_ids     = [ oci_core_subnet.engine_priv_subnet.id ]

	shape = "flexible"
	shape_details {
		minimum_bandwidth_in_mbps = 10
		maximum_bandwidth_in_mbps = (var.ENGINE_DB_TYPE=="free_cluster" ? 10 : var.ENGINE_N_CONTAINER_INSTANCES * 20)
	}

   defined_tags = {
      "ROCKITPLAY-Tags.instanceName" = "engine-${local.workspace}"
   }
	is_private = true  # API-GW provides the public address
}

locals {
   lb_ipaddr = var.ENGINE_USE_CWL ? oci_load_balancer_load_balancer.engine_lb[0].ip_address_details[0].ip_address : "n/a"
}


# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_backend_set.html
resource "oci_load_balancer_backend_set" "engine_lb_beset" {
   count          = var.ENGINE_USE_CWL ? 1 : 0

   name             = "engine-lb-beset-${local.workspace}"
	load_balancer_id = oci_load_balancer_load_balancer.engine_lb[0].id

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
resource "oci_load_balancer_listener" "engine_http" {
   count          = var.ENGINE_USE_CWL ? 1 : 0

  name = "engine-http-${local.workspace}"
	load_balancer_id = oci_load_balancer_load_balancer.engine_lb[0].id
	default_backend_set_name = oci_load_balancer_backend_set.engine_lb_beset[0].name
	port = 80
	protocol = "HTTP"
}

# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_backend.html
resource "oci_load_balancer_backend" "engine_cwl_container" {
   count           = var.ENGINE_USE_CWL ? var.ENGINE_N_CONTAINER_INSTANCES : 0

	backendset_name = oci_load_balancer_backend_set.engine_lb_beset[0].name
	ip_address = oci_container_instances_container_instance.engine_cwl[count.index].vnics[0].private_ip
	load_balancer_id = oci_load_balancer_load_balancer.engine_lb[0].id
	port = 3000
}
