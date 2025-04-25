locals {
   path_param1_key = "{var1}"
   path_param1_val = "$${request.path[var1]}"
   path_param2_key = "{var2}"
   path_param2_val = "$${request.path[var2]}"
}


# --- API Gateway
resource "oci_apigateway_gateway" "edge_pub_api_gw" {
   count          = local.use_cwl ? 0 : 1
   compartment_id = oci_identity_compartment.edge_comp.id
   display_name   = "edge-pub-gw-${local.workspace}"
   endpoint_type  = "PUBLIC"
   subnet_id      = oci_core_subnet.edge_pub_subnet.id
   certificate_id = var.EDGE_WITH_CERT ? var.EDGE_CERT_OCID : null
}

# --- API Deployments
resource "oci_apigateway_deployment" "edge_api_deployment" {
   count          = local.use_cwl ? 0 : 1
   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw[0].id
   display_name  = "edge-pub-api-v1-${local.workspace}"
   path_prefix    = "/"

   specification {
      dynamic "routes" {
         for_each = var.edge_endpoints
         content {
            path    = routes.value.path
            methods = routes.value.methods

            # --- static maintenance response (503 response)
            #     for all endpoints except /srv/*
            dynamic "backend" {
               for_each = (var.EDGE_MAINTENANCE_MODE && substr(routes.value.path, 0, 5) != "/srv/") ? [1] : []
               content {
                  type   = "STOCK_RESPONSE_BACKEND"
                  status = 503
                  body   = jsonencode({
                     "status"     = "failed"
                     "error"      = "maintenance"
                     "message"    = "The service is in maintenance mode. Please retry later."
                     "retryAfter" = "900"
                  })
                  headers {
                     name  = "Content-Type"
                     value = "application/json"
                  }
                  headers {
                     name  = "Retry-After"
                     value = "900"  # 15m
                  }
               }
            }

            dynamic "backend" {
               for_each = (var.EDGE_MAINTENANCE_MODE && substr(routes.value.path, 0, 5) != "/srv/") ? [] : (local.use_cwl ? [] : [1])
               content {
                  type        = "ORACLE_FUNCTIONS_BACKEND"
                  function_id = oci_functions_function.edge_fn.id
               }
            }
            # request_policies {
            #    body_validation {
            #       content {
            #          media_type      = "application/json"
            #          validation_type = "NONE"
            #       }
            #       required        = "true"
            #       validation_mode = "ENFORCING"
            #    }
				# }
         }
      }
   }
}


locals {
   edge_apigw_ipaddr = local.use_cwl ? "n/a" : oci_apigateway_gateway.edge_pub_api_gw[0].ip_addresses[0].ip_address
   edge_apigw_url    = local.use_cwl ? "n/a" : "https://${oci_apigateway_gateway.edge_pub_api_gw[0].hostname}"
}
