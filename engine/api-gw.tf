# --- API Gateway
resource "oci_apigateway_gateway" "engine_pub_api_gw" {
   compartment_id = oci_identity_compartment.engine_comp.id
   display_name   = "engine-pub-gw-${local.workspace}"
   endpoint_type  = "PUBLIC"
   subnet_id      = oci_core_subnet.engine_pub_subnet.id
   certificate_id = var.ENGINE_WITH_CERT ? var.ENGINE_CERT_OCID : null
}

# --- No CWLs Running Mode, serving no API at all
resource "oci_apigateway_deployment" "engine_nocwl_deployment" {
   count = (var.ENGINE_USE_CWL && var.ENGINE_N_CONTAINER_INSTANCES==0) ? 1 : 0

   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw.id
   display_name  = "engine-nocwl-${local.workspace}"
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
resource "oci_apigateway_deployment" "engine_maintenance_deployment" {
   count = var.ENGINE_MAINTENANCE_MODE ? 1 : 0

   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw.id
   display_name  = "engine-maintenance-${local.workspace}"
   path_prefix    = "/"

   specification {
      dynamic "routes" {
         for_each = var.engine_srv_v1_api

         content {
            path    = "/srv/v1${routes.value.path}"
            methods = routes.value.methods

            backend {
               type        = var.ENGINE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.ENGINE_USE_CWL ? null : try(oci_functions_function.engine_fn.id, null)
               url         = var.ENGINE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.engine_lb[0].ip_address_details[0].ip_address, "")}/srv/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
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
            rate_in_requests_per_second = var.ENGINE_DB_TYPE == "free_cluster" ? 5 : 20
            rate_key = "TOTAL"
         }
      }
    }
}


# --- ROCKIT-Engine API Deployments
resource "oci_apigateway_deployment" "engine_srv_v1_api_deployment" {
   count = (var.ENGINE_MAINTENANCE_MODE || (var.ENGINE_USE_CWL && var.ENGINE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw.id
   display_name  = "engine-srv-api-v1-${local.workspace}"
   path_prefix    = "/srv/v1"

   specification {
      dynamic "routes" {
         for_each = var.engine_srv_v1_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.ENGINE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.ENGINE_USE_CWL ? null : try(oci_functions_function.engine_fn.id, null)
               url         = var.ENGINE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.engine_lb[0].ip_address_details[0].ip_address, "")}/srv/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.ENGINE_DB_TYPE == "free_cluster" ? 10 : 20
            rate_key = "TOTAL"
         }
      }
   }
}

resource "oci_apigateway_deployment" "engine_adm_v1_api_deployment" {
   count = (var.ENGINE_MAINTENANCE_MODE || (var.ENGINE_USE_CWL && var.ENGINE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw.id
   display_name  = "engine-adm-api-v1-${local.workspace}"
   path_prefix    = "/adm/v1"

   specification {
      dynamic "routes" {
         for_each = var.engine_adm_v1_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.ENGINE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.ENGINE_USE_CWL ? null : try(oci_functions_function.engine_fn.id, null)
               url         = var.ENGINE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.engine_lb[0].ip_address_details[0].ip_address, "")}/adm/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.ENGINE_DB_TYPE == "free_cluster" ? 10 : 20
            rate_key = "TOTAL"
         }
      }
   }
}

resource "oci_apigateway_deployment" "engine_be_v1_api_deployment" {
   count = (var.ENGINE_MAINTENANCE_MODE || (var.ENGINE_USE_CWL && var.ENGINE_N_CONTAINER_INSTANCES==0)) ? 0 : 1

   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw.id
   display_name  = "engine-be-api-v1-${local.workspace}"
   path_prefix    = "/be/v1"

   specification {
      dynamic "routes" {
         for_each = var.engine_be_v1_api

         content {
            path    = routes.value.path
            methods = routes.value.methods

            backend {
               type        = var.ENGINE_USE_CWL ? "HTTP_BACKEND" : "ORACLE_FUNCTIONS_BACKEND"
               function_id = var.ENGINE_USE_CWL ? null : try(oci_functions_function.engine_fn.id, null)
               url         = var.ENGINE_USE_CWL ? (
                              "http://${try(oci_load_balancer_load_balancer.engine_lb[0].ip_address_details[0].ip_address, "")}/be/v1${ replace( replace(routes.value.path, "{everything*}", "$${request.path[everything]}"), "{var1}", "$${request.path[var1]}" ) }"
                           ) : null
               connect_timeout_in_seconds = 60
               read_timeout_in_seconds = 60
               send_timeout_in_seconds = 60
            }
         }
      }

      request_policies {
         rate_limiting {
            rate_in_requests_per_second = var.ENGINE_DB_TYPE == "free_cluster" ? 10 : 20
            rate_key = "TOTAL"
         }
      }
   }
}

locals {
   engine_apigw_ipaddr = oci_apigateway_gateway.engine_pub_api_gw.ip_addresses[0].ip_address
   engine_apigw_url    = "https://${oci_apigateway_gateway.engine_pub_api_gw.hostname}"
}
