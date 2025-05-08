// --- Network
resource "oci_core_vcn" "engine_vcn" {
    compartment_id = oci_identity_compartment.engine_comp.id
    cidr_block     = var.vcn_cidr
    display_name   = "vcn-${local.workspace}"
}

resource "oci_core_default_security_list" "default-security-list" {
   manage_default_resource_id = oci_core_vcn.engine_vcn.default_security_list_id
   compartment_id = oci_identity_compartment.engine_comp.id
   display_name = "default-seclist"
   egress_security_rules {
      stateless = false
      destination = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      protocol = "all"
   }
   ingress_security_rules {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "ssh remote login"
      protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      tcp_options {
         min = 22
         max = 22
      }
   }
   ingress_security_rules {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol = "1" # 1=ICMP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      icmp_options {
         type = 3
         code = 4
      }
   }
   ingress_security_rules {
      stateless = false
      source = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol = "1" # 1=ICMP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      icmp_options {
         type = 3 # (https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml)
      }
   }
   ingress_security_rules {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "https"
      protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      tcp_options {
         min = 443
         max = 443
      }
   }
   ingress_security_rules {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Container Instance"
      protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      tcp_options {
         min = 3000
         max = 3000
      }
   }
}

resource "oci_core_security_list" "adm_security_list" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "adm-seclist"
   egress_security_rules {
      stateless = false
      destination = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      protocol = "all"
   }
   ingress_security_rules {
      stateless = false
      source = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol = "1" # 1=ICMP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      icmp_options {
         type = 3
         code = 4
      }
   }
   ingress_security_rules {
      stateless = false
      source = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol = "1" # 1=ICMP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      icmp_options {
         type = 3 # (https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml)
      }
   }
   ingress_security_rules {
      stateless = false
      source = "185.212.53.227/32"
      source_type = "CIDR_BLOCK"
      description = "https from dx-erkrath"
      protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      tcp_options {
         min = 443
         max = 443
      }
   }
   ingress_security_rules {
      stateless = false
      source = "${chomp(data.http.public_ip.response_body)}/32"
      source_type = "CIDR_BLOCK"
      description = "https from current IP"
      protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
      tcp_options {
         min = 443
         max = 443
      }
   }
   # # --- Bitbucket CI Pipeline outpound IP addresses
   # #     https://support.atlassian.com/bitbucket-cloud/docs/what-are-the-bitbucket-cloud-ip-addresses-i-should-use-to-configure-my-corporate-firewall/
   # ingress_security_rules {
   #    stateless = false
   #    source = "34.199.54.113/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "34.232.25.90/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "34.232.119.183/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   #    ingress_security_rules {
   #    stateless = false
   #    source = "34.236.25.177/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "35.171.175.212/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "52.54.90.98/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "52.202.195.162/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "52.203.14.55/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "52.204.96.37/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "34.218.156.209/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "34.218.168.212/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "52.41.219.63/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "35.155.178.254/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "35.160.177.10/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "34.216.18.129/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "3.216.235.48/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "34.231.96.243/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "44.199.3.254/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "174.129.205.191/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "44.199.127.226/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "44.199.45.64/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "3.221.151.112/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "52.205.184.192/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
   # ingress_security_rules {
   #    stateless = false
   #    source = "52.72.137.240/32"
   #    source_type = "CIDR_BLOCK"
   #    description = "CI Pipelines"
   #    protocol = "6" # 6=TCP (https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)
   #    tcp_options {
   #       min = 443
   #       max = 443
   #    }
   # }
}

resource "oci_core_default_route_table" "default-routing-table" {
   # empty default routing table
   manage_default_resource_id = oci_core_vcn.engine_vcn.default_route_table_id
   compartment_id = oci_identity_compartment.engine_comp.id
   display_name = "default-routing-table"
}

resource "oci_core_internet_gateway" "internet_gw" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "internet-gw-${local.workspace}"
}

resource "oci_core_nat_gateway" "nat_gw" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "nat-gw-${local.workspace}"
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
  count = 1
}

resource "oci_core_service_gateway" "service_gw" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "service-gw-${local.workspace}"
   services {
      service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
   }
}

resource "oci_core_route_table" "pub_subnet_rt" {
   #depends_on = [  data.dns_a_record_set.mongodb_dns_records ]
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "pub-subnet-rt-${local.workspace}"
   route_rules {
      network_entity_id = oci_core_internet_gateway.internet_gw.id
      description = "all destinations"
      destination = "0.0.0.0/0"
   }
}

resource "oci_core_route_table" "priv_subnet_rt" {
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "priv-subnet-rt-${local.workspace}"
   route_rules {
      network_entity_id = oci_core_nat_gateway.nat_gw.id
      description = "all destinations"
      destination = "0.0.0.0/0"
   }
   route_rules {
      network_entity_id = oci_core_service_gateway.service_gw.id
      description = "traffic to OCI services"
      destination =  lookup (data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type = "SERVICE_CIDR_BLOCK"
   }
}

resource "oci_core_subnet" "engine_adm_subnet" {
   cidr_block     = var.vcn_adm_cidr
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "adm-subnet-${local.workspace}"
   route_table_id = oci_core_route_table.pub_subnet_rt.id
   security_list_ids = [ oci_core_security_list.adm_security_list.id ]
}

resource "oci_core_subnet" "engine_pub_subnet" {
   cidr_block     = var.vcn_pub_cidr
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "pub-subnet-${local.workspace}"
   route_table_id = oci_core_route_table.pub_subnet_rt.id
}

resource "oci_core_subnet" "engine_priv_subnet" {
   cidr_block     = var.vcn_priv_cidr
   compartment_id = oci_identity_compartment.engine_comp.id
   vcn_id         = oci_core_vcn.engine_vcn.id
   display_name   = "priv-subnet-${local.workspace}"
   route_table_id = oci_core_route_table.priv_subnet_rt.id
}


# --- Outputs
output "engine_nat_gw_ip" {
   value = oci_core_nat_gateway.nat_gw.nat_ip
}

