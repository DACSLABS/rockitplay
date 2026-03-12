locals {
   apigw_maintenance_mode = (var.EDGE_MAINTENANCE_MODE || (var.EDGE_USE_CWL && var.EDGE_N_CONTAINER_INSTANCES==0))
}


# --- API Gateway
resource "oci_apigateway_gateway" "edge_pub_api_gw" {
   compartment_id = oci_identity_compartment.edge_comp.id
   display_name   = "edge-pub-gw-${local.workspace}"
   endpoint_type  = "PUBLIC"
   subnet_id      = oci_core_subnet.edge_pub_subnet.id
   certificate_id = var.EDGE_WITH_CERT ? var.EDGE_CERT_OCID : null
}


resource "oci_apigateway_deployment" "edge_api_deployment" {
   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-api-${local.workspace}"
   path_prefix    = "/"

   specification {

      // --- ROCKITPLAY Edge public endpoints: MAINTENANCE mode
      dynamic "routes" {
         for_each = local.apigw_maintenance_mode ? var.edge_api_routes : []
         content {
            path = "${routes.value.prefix}/{path*}"
            methods = [ routes.value.method ]
            backend {
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
      }

      // --- fn: ROCKITPLAY Edge public endpoints: OPERATION mode
      dynamic "routes" {
         for_each = (!local.apigw_maintenance_mode && !var.EDGE_USE_CWL) ? var.edge_api_routes : []
         content {
            path = "${routes.value.prefix}/{path*}"
            methods = [ routes.value.method ]
            backend {
               type = "DYNAMIC_ROUTING_BACKEND"
               selection_source {
                  type     = "SINGLE"
                  selector = "request.path[path]"   // "foo" or "foo/123"
               }

               // --- exact match routes, e.g. /foo
               dynamic "routing_backends" {
                  for_each = routes.value.endpoints_exact
                  content {
                     key {
                        type   = "ANY_OF"
                        name   = "exact_${trimprefix(routing_backends.value, "/")}"
                        values = [trimprefix(routing_backends.value, "/")]   // ["foo"], ["bar"], ...
                     }
                     backend {
                        type        = "ORACLE_FUNCTIONS_BACKEND"
                        function_id = try(oci_functions_function.edge_fn.id, null)
                     }
                  }
               }

               // --- wildcard match routes, e.g. /foo/*
               dynamic "routing_backends" {
                  for_each = routes.value.endpoints_wildcard
                  content {
                     key {
                        type       = "WILDCARD"
                        name       = "wildcard_${trimprefix(routing_backends.value, "/")}"
                        expression = "${trimprefix(routing_backends.value, "/")}/+"   // "foo/+", "bar/+", ...
                     }
                     backend {
                        type        = "ORACLE_FUNCTIONS_BACKEND"
                        function_id = try(oci_functions_function.edge_fn.id, null)
                        url         = null
                        connect_timeout_in_seconds = 60
                        read_timeout_in_seconds    = 60
                        is_ssl_verify_disabled     = false
                     }
                  }
               }
            }
         }
      }

      # --- cwl: ROCKITPLAY public endpoints: OPERATIONAL mode
      dynamic "routes" {
         for_each = (!local.apigw_maintenance_mode && var.EDGE_USE_CWL) ? var.edge_api_routes : []
         content {
            path = "${routes.value.prefix}/{path*}"
            methods = [ routes.value.method ]
            backend {
               type        = "HTTP_BACKEND"
               url         = "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}${routes.value.prefix}/$${request.path[path]}"
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      // --- fn: ROCKITPLAY Edge service endpoints
      dynamic "routes" {
         for_each = (!var.EDGE_USE_CWL) ? var.edge_api_srv_routes : []
         content {
            path = "${routes.value.prefix}/{path*}"
            methods = [ routes.value.method ]
            backend {
               type = "DYNAMIC_ROUTING_BACKEND"
               selection_source {
                  type     = "SINGLE"
                  selector = "request.path[path]"   // "foo" or "foo/123"
               }

               // --- exact match routes, e.g. /foo
               dynamic "routing_backends" {
                  for_each = routes.value.endpoints_exact
                  content {
                     key {
                        type   = "ANY_OF"
                        name   = "exact_${trimprefix(routing_backends.value, "/")}"
                        values = [trimprefix(routing_backends.value, "/")]   // ["foo"], ["bar"], ...
                     }
                     backend {
                        type        = "ORACLE_FUNCTIONS_BACKEND"
                        function_id = try(oci_functions_function.edge_fn.id, null)
                     }
                  }
               }

               // --- wildcard match routes, e.g. /foo/*
               dynamic "routing_backends" {
                  for_each = routes.value.endpoints_wildcard
                  content {
                     key {
                        type       = "WILDCARD"
                        name       = "wildcard_${trimprefix(routing_backends.value, "/")}"
                        expression = "${trimprefix(routing_backends.value, "/")}/+"   // "foo/+", "bar/+", ...
                     }
                     backend {
                        type        = "ORACLE_FUNCTIONS_BACKEND"
                        function_id = try(oci_functions_function.edge_fn.id, null)
                        url         = null
                        connect_timeout_in_seconds = 60
                        read_timeout_in_seconds    = 60
                        is_ssl_verify_disabled     = false
                     }
                  }
               }
            }
         }
      }



      # --- cwl: ROCKITPLAY service endpoints
      dynamic "routes" {
         for_each = (var.EDGE_USE_CWL) ? var.edge_api_srv_routes : []
         content {
            path = "${routes.value.prefix}/{path*}"
            methods = [ routes.value.method ]
            backend {
               type        = "HTTP_BACKEND"
               url         = "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}${routes.value.prefix}/$${request.path[path]}"
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }


      # / -> index.html, /apps/{id} -> {id}/index.html
      dynamic "routes" {
         for_each = var.edge_api_static
         content {
            path    = routes.value.path
            methods = ["GET", "HEAD"]

            backend {
               type = "HTTP_BACKEND"
               url  = "${local.edge_html_bucket_read_url}${routes.value.id}/index.html"
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds    = 60
               send_timeout_in_seconds    = 60
               is_ssl_verify_disabled     = false
            }
         }
      }
      # /assets/**/ -> assets/*, /apps/{id}/assets/* -> {id}/assets/*
      dynamic "routes" {
         for_each = var.edge_api_static
         content {
            path    = (routes.value.path == "/") ? "/{path*}" : "${routes.value.path}/{path*}"
            methods = ["GET", "HEAD"]

            backend {
               type = "DYNAMIC_ROUTING_BACKEND"
               selection_source {
                  type     = "SINGLE"
                  selector = "request.path[path]"
               }
               routing_backends {
                  key {
                     is_default = true
                     name       = "default"
                     type       = "ANY_OF"
                     values     = []
                  }
                  backend {
                     type = "HTTP_BACKEND"
                     url  = "${local.edge_html_bucket_read_url}${routes.value.id}/index.html"
                     connect_timeout_in_seconds = 60
                     read_timeout_in_seconds    = 60
                     is_ssl_verify_disabled     = false
                  }
               }
               routing_backends {
                  key {
                     name       = "assets"
                     type       = "WILDCARD"
                     expression = "assets/*"
                  }
                  backend {
                     type = "HTTP_BACKEND"
                     url  = "${local.edge_html_bucket_read_url}${routes.value.id}/$${request.path[path]}"
                     connect_timeout_in_seconds = 60
                     read_timeout_in_seconds    = 60
                     is_ssl_verify_disabled     = false
                  }
               }
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.EDGE_DB_TYPE == "free_cluster" ? 33 : 800
            rate_key = "TOTAL"
         }
      }
   }
}


locals {
   edge_apigw_ipaddr = oci_apigateway_gateway.edge_pub_api_gw.ip_addresses[0].ip_address
   edge_apigw_url    = "https://${oci_apigateway_gateway.edge_pub_api_gw.hostname}"
}