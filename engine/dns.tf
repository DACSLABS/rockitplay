data "oci_dns_zones" "engine_zones" {
   count          = var.ENGINE_WITH_CERT ? 1 : 0
   compartment_id = var.ENGINE_OCI_TENANCY_OCID
   name           = var.ENGINE_CERT_DOMAINNAME
}

locals {
   engine_pub_hostname = local.env == "prod" ? "engine" : "engine-${local.workspace}"
}


# production: engine.{ENGINE_CERT_DOMAINNAME}
# stage:      engine-stage.{ENGINE_CERT_DOMAINNAME}
# test:       engine-test.{ENGINE_CERT_DOMAINNAME}
resource "oci_dns_record" "engine_pub_dns_record" {
   count           = var.ENGINE_WITH_CERT ? 1 : 0
      depends_on      = [
      oci_apigateway_gateway.engine_pub_api_gw,
      oci_load_balancer_load_balancer.engine_lb
   ]
   zone_name_or_id = data.oci_dns_zones.engine_zones[0].zones[0].id
   domain          = "${local.engine_pub_hostname}.${var.ENGINE_CERT_DOMAINNAME}"
   rtype           = local.use_cwl ? "A" : "CNAME"
   rdata           = local.use_cwl ? "${local.lb_ipaddr}" : "${oci_apigateway_gateway.engine_pub_api_gw[0].hostname}."
   ttl             = 3600
}