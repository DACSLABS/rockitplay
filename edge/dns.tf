data "oci_dns_zones" "edge_zones" {
   compartment_id = var.EDGE_OCI_TENANCY_OCID
   name           = "cloud.rockitplay.com"
}

locals {
   edge_pub_hostname = local.workspace == "prod" ? "edge" : "edge-${local.workspace}"
}


# production: edge.cloud.rockitplay.com
# stage:      edge-stage.cloud.rockitplay.com
# test:       edge-test.cloud.rockitplay.com
resource "oci_dns_record" "edge_pub_dns_record" {
   count           = var.EDGE_WITH_CERT ? 1 : 0
   depends_on      = [ oci_apigateway_gateway.edge_pub_api_gw ]
   zone_name_or_id = data.oci_dns_zones.edge_zones.zones[0].id
   domain          = "${local.edge_pub_hostname}.cloud.rockitplay.com"
   rtype           = "CNAME"
   rdata           = "${oci_apigateway_gateway.edge_pub_api_gw.hostname}."
   ttl             = 3600
}