# --- API Gateway
resource "oci_apigateway_gateway" "edge_pub_api_gw" {
   compartment_id = oci_identity_compartment.edge_comp.id
   display_name   = "edge-pub-gw-${local.workspace}"
   endpoint_type  = "PUBLIC"
   subnet_id      = oci_core_subnet.edge_pub_subnet.id
   certificate_id = var.EDGE_WITH_CERT ? var.EDGE_CERT_OCID : null
}

# --- No CWLs Running Mode, serving no API at all
resource "oci_apigateway_deployment" "edge_nocwl_deployment" {
   count = (var.EDGE_USE_CWL && var.EDGE_N_CONTAINER_INSTANCES==0) ? 1 : 0

   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-nocwl-${local.workspace}"
   path_prefix    = "/"

   specification {
      routes {
         path   = "/{anything*}"
         methods = ["ANY"]

         backend {
            type   = "STOCK_RESPONSE_BACKEND"

            status = 503
            body   = jsonencode({
               "status"     = "failed"
               "error"      = "offline"
               "message"    = "The service is offline. Please retry later and/or contact an administrator."
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

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = 5
            rate_key = "TOTAL"
         }
      }
    }
}

# --- Maintenance Mode with /srv API only
resource "oci_apigateway_deployment" "edge_maintenance_deployment" {
   count = var.EDGE_MAINTENANCE_MODE ? 1 : 0

   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-maintenance-${local.workspace}"
   path_prefix    = "/"

   specification {
      dynamic "routes" {
         for_each = var.edge_srv_v1_api

         content {
            path    = "/srv/v1${routes.value.path}"
            methods = routes.value.methods

            backend {
               type        = var.EDGE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.EDGE_USE_CWL ? null : try(oci_functions_function.edge_fn.id, null)
               url         = var.EDGE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}/srv/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      routes {
         path   = "/{anything*}"
         methods = ["ANY"]

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

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.EDGE_DB_TYPE == "free_cluster" ? 5 : 20
            rate_key = "TOTAL"
         }
      }
    }
}


# --- ROCKITPLAY API Deployments
resource "oci_apigateway_deployment" "edge_srv_v1_api_deployment" {
   count = (var.EDGE_MAINTENANCE_MODE || (var.EDGE_USE_CWL && var.EDGE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-srv-api-v1-${local.workspace}"
   path_prefix    = "/srv/v1"

   specification {
      dynamic "routes" {
         for_each = var.edge_srv_v1_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.EDGE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.EDGE_USE_CWL ? null : try(oci_functions_function.edge_fn.id, null)
               url         = var.EDGE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}/srv/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.EDGE_DB_TYPE == "free_cluster" ? 5 : 20
            rate_key = "TOTAL"
         }
      }
   }
}

resource "oci_apigateway_deployment" "edge_apps_api_deployment" {
   count = (var.EDGE_MAINTENANCE_MODE || (var.EDGE_USE_CWL && var.EDGE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-apps-api-${local.workspace}"
   path_prefix    = "/apps"

   specification {
      dynamic "routes" {
         for_each = var.edge_apps_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.EDGE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.EDGE_USE_CWL ? null : try(oci_functions_function.edge_fn.id, null)
               url         = var.EDGE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}/apps${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.EDGE_DB_TYPE == "free_cluster" ? 5 : 20
            rate_key = "TOTAL"
         }
      }
   }
}

resource "oci_apigateway_deployment" "edge_adm_v1_api_deployment" {
   count = (var.EDGE_MAINTENANCE_MODE || (var.EDGE_USE_CWL && var.EDGE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-adm-api-v1-${local.workspace}"
   path_prefix    = "/adm/v1"

   specification {
      dynamic "routes" {
         for_each = var.edge_adm_v1_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.EDGE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.EDGE_USE_CWL ? null : try(oci_functions_function.edge_fn.id, null)
               url         = var.EDGE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}/adm/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.EDGE_DB_TYPE == "free_cluster" ? 5 : 20
            rate_key = "TOTAL"
         }
      }
   }
}

resource "oci_apigateway_deployment" "edge_be_v1_api_deployment" {
   count = (var.EDGE_MAINTENANCE_MODE || (var.EDGE_USE_CWL && var.EDGE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-be-api-v1-${local.workspace}"
   path_prefix    = "/be/v1"

   specification {
      dynamic "routes" {
         for_each = var.edge_be_v1_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.EDGE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.EDGE_USE_CWL ? null : try(oci_functions_function.edge_fn.id, null)
               url         = var.EDGE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}/be/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.EDGE_DB_TYPE == "free_cluster" ? 5 : 20
            rate_key = "TOTAL"
         }
      }
   }
}

resource "oci_apigateway_deployment" "edge_client_v1_api_deployment" {
   count = (var.EDGE_MAINTENANCE_MODE || (var.EDGE_USE_CWL && var.EDGE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-client-api-v1-${local.workspace}"
   path_prefix    = "/client/v1"

   specification {
      dynamic "routes" {
         for_each = var.edge_client_v1_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.EDGE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.EDGE_USE_CWL ? null : try(oci_functions_function.edge_fn.id, null)
               url         = var.EDGE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.edge_lb[0].ip_address_details[0].ip_address, "")}/client/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            # Requests/Sec for non-free_cluster DBs taken from benchmarks; re-benchmark any changes
            rate_in_requests_per_second = var.EDGE_DB_TYPE == "free_cluster" ? 20 : 800
            rate_key = "TOTAL"
         }
      }
   }
}

locals {
   edge_apigw_ipaddr = oci_apigateway_gateway.edge_pub_api_gw.ip_addresses[0].ip_address
   edge_apigw_url    = "https://${oci_apigateway_gateway.edge_pub_api_gw.hostname}"
}
