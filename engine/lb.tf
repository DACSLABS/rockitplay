# --- Load Balancer

# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_load_balancer.html
resource "oci_load_balancer_load_balancer" "engine_lb" {
   count          = local.use_cwl ? 1 : 0

   compartment_id = oci_identity_compartment.engine_comp.id
   display_name   = "engine-lb-${local.workspace}"
   subnet_ids     = [ oci_core_subnet.engine_pub_subnet.id ]

	shape = "flexible"
	shape_details {
		maximum_bandwidth_in_mbps = var.ENGINE_LB_BANDWIDTH_MBPS
		minimum_bandwidth_in_mbps = var.ENGINE_LB_BANDWIDTH_MBPS
	}

   defined_tags = {
      "ROCKITPLAY-Tags.instanceName" = "engine-${local.workspace}"
   }
	is_private = false   # obtain a Public IP
}

locals {
   lb_ipaddr = local.use_cwl ? oci_load_balancer_load_balancer.engine_lb[0].ip_address_details[0].ip_address : "n/a"
}


# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_backend_set.html
resource "oci_load_balancer_backend_set" "engine_lb_backends" {
   count          = local.use_cwl ? 1 : 0

   name             = "engine-lb-backends-${local.workspace}"
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
resource "oci_load_balancer_listener" "engine_https" {
   count          = local.use_cwl ? 1 : 0

	name = "engine_${local.workspace}_https"
	load_balancer_id = oci_load_balancer_load_balancer.engine_lb[0].id
	default_backend_set_name = oci_load_balancer_backend_set.engine_lb_backends[0].name
	port = 443
	protocol = "HTTP"

	ssl_configuration {
		certificate_ids = [ var.ENGINE_WITH_CERT ? var.ENGINE_CERT_OCID : null ]
      verify_peer_certificate = false  # TODO: correct?
	}
}

# see https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/6.27.0/docs/r/load_balancer_backend.html
resource "oci_load_balancer_backend" "engine_cwl_container" {
   count          = local.use_cwl ? var.ENGINE_N_CONTAINER_INSTANCES : 0

	backendset_name = oci_load_balancer_backend_set.engine_lb_backends[0].name
	ip_address = oci_container_instances_container_instance.engine_cwl[count.index].vnics[0].private_ip
	load_balancer_id = oci_load_balancer_load_balancer.engine_lb[0].id
	port = 3000
}