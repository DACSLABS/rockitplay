locals {
   edge_pub_hostname = local.workspace == "prod" ? "edge" : "edge-${local.workspace}"
}


# production: edge.cloud.rockitplay.com
# stage:      edge-stage.cloud.rockitplay.com
# test:       edge-test.cloud.rockitplay.com
resource "oci_dns_rrset" "edge_pub_dns_record" {
   count           = var.EDGE_WITH_CERT ? 1 : 0
   depends_on      = [
      oci_apigateway_gateway.edge_pub_api_gw,
      oci_load_balancer_load_balancer.edge_lb
   ]

   zone_name_or_id = var.EDGE_DNS_ZONE_OCID
   rtype           = local.use_cwl ? "A" : "CNAME"
   domain = "${local.edge_pub_hostname}.${var.EDGE_CERT_DOMAINNAME}."

   items {
       domain = "${local.edge_pub_hostname}.${var.EDGE_CERT_DOMAINNAME}."
       rtype  = local.use_cwl ? "A" : "CNAME"
       rdata  = local.use_cwl ? "${local.lb_ipaddr}" : "${oci_apigateway_gateway.edge_pub_api_gw[0].hostname}."
       ttl    = (local.env != "prod" && local.env != "stage") ?  300 : 3600
   }
}
