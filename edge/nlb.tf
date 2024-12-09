# --- Network Load Balancer
resource "oci_network_load_balancer_network_load_balancer" "edge_nlb" {
   count                          = local.use_cwl ? 1 : 0
   compartment_id                 = oci_identity_compartment.edge_comp.id
   display_name                   = "edge-nlb-${local.workspace}"
   subnet_id                      = oci_core_subnet.edge_priv_subnet.id
   is_preserve_source_destination = false
   is_private                     = true
}

locals {
   nlb_ipaddr = local.use_cwl ? oci_network_load_balancer_network_load_balancer.edge_nlb[0].ip_addresses[0].ip_address : "n/a"
   nlb_url    = local.use_cwl ? "http://${local.nlb_ipaddr}:3000" : ""
}

resource oci_network_load_balancer_backend_set edge_nlb_backends {
   count = local.use_cwl ? 1 : 0
   health_checker {
      interval_in_millis = "10000"
      port               = "3000"
      protocol           = "HTTP"
      retries           = "3"
      return_code       = "200"
      timeout_in_millis = "3000"
      url_path          = "/"
   }
   ip_version                  = "IPV4"
   is_fail_open                = "false"
   is_instant_failover_enabled = "false"
   is_preserve_source          = "false"
   name                        = "edge-nlb-backends-${local.workspace}"
   network_load_balancer_id    = oci_network_load_balancer_network_load_balancer.edge_nlb[0].id
   policy                      = "FIVE_TUPLE"
}

resource "oci_network_load_balancer_listener" "edge_tcp_3000" {
   count = local.use_cwl ? 1 : 0
   default_backend_set_name = oci_network_load_balancer_backend_set.edge_nlb_backends[0].name
   name                     = "edge-tcp-3000-listener-${local.workspace}"
   network_load_balancer_id = oci_network_load_balancer_network_load_balancer.edge_nlb[0].id
   port                     = 3000
   protocol                 = "TCP"
}

resource oci_network_load_balancer_backend edge_cwl_container {
   count                    = var.EDGE_N_CONTAINER_INSTANCES
   name                     = "${oci_container_instances_container_instance.edge_cwl[count.index].display_name}:3000"
   backend_set_name         = oci_network_load_balancer_backend_set.edge_nlb_backends[0].name
   ip_address               = oci_container_instances_container_instance.edge_cwl[count.index].vnics[0].private_ip
   is_backup                = "false"
   is_drain                 = "false"
   is_offline               = "false"
   network_load_balancer_id = oci_network_load_balancer_network_load_balancer.edge_nlb[0].id
   port                     = "3000"
   weight                   = "1"
}