// --- endpoint definitions: /adm/v1
variable "edge_adm_v1_endpoints" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
     path       = "/hello"
     methods    = ["POST"]
   }, {
      path      = "/initialize"
      methods    = ["POST"]
   }, {
      path      = "/orgs"
      methods    = ["POST", "DELETE"]
   }, {
      path      = "/ping"
      methods    = ["POST"]
   }]
}

// --- endpoint definitions: /be/v1
variable "edge_be_v1_endpoints" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
     path       = "/apikeys"
     methods    = ["POST", "DELETE"]
   }, {
     path       = "/apps"
     methods    = ["GET", "POST", "PATCH", "DELETE"]
   }, {
     path       = "/apps/{var1}"
     methods    = ["GET"]
   }, {
     path       = "/assets"
     methods    = ["POST"]
   }, {
     path       = "/auth"
     methods    = ["POST"]
   }, {
     path       = "/builds"
     methods    = ["POST"]
   }, {
     path       = "/commit"
     methods    = ["POST"]
   }, {
     path       = "/deployments"
     methods    = ["POST", "PATCH", "DELETE"]
   }, {
     path       = "/deps"
     methods    = ["POST", "PATCH", "DELETE"]
   }, {
     path       = "/export"
     methods    = ["POST"]
   }, {
     path       = "/import"
     methods    = ["POST"]
   }, {
     path       = "/keys"
     methods    = ["POST", "DELETE"]
   }, {
     path       = "/login"
     methods    = ["POST"]
   }, {
     path       = "/progress"
     methods    = ["POST"]
   }, {
     path       = "/publish"
     methods    = ["POST"]
   }, {
     path       = "/release"
     methods    = ["POST"]
   }, {
     path       = "/roles"
     methods    = ["POST", "PATCH", "GET", "DELETE"]
   }, {
     path       = "/sources"
     methods    = ["GET", "POST", "PATCH", "DELETE"]
   }, {
     path       = "/tasks"
     methods    = ["GET"]
   }, {
     path       = "/tasks/{var1}"
     methods    = ["GET"]
   }, {
     path       = "/trigger"
     methods    = ["POST"]
   }, {
     path       = "/users"
     methods    = ["GET", "POST", "PATCH", "DELETE"]
   }]
}

// --- endpoint definitions: /client/v1
variable "edge_client_v1_endpoints" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
     path       = "/apps"
     methods    = ["GET"]
   }, {
      path       = "/apps/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/auth"
      methods    = ["POST"]
   }, {
      path       = "/client-items"
      methods    = ["POST"]
   }, {
      path       = "/deps/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/feedback"
      methods    = ["POST"]
   }, {
      path       = "/ib-sessions"
      methods    = ["POST"]
   }, {
      path       = "/login"
      methods    = ["POST"]
   }, {
      path       = "/rsi"
      methods    = ["GET"]
   }, {
      path       = "/rte-sessions"
      methods    = ["POST", "PATCH"]
   }, {
      path       = "/traces"
      methods    = ["POST"]
   }]
}


locals {
   path_param1_key = "{var1}"
   path_param1_val = "$${request.path[var1]}"
   path_param2_key = "{var2}"
   path_param2_val = "$${request.path[var2]}"
}


# --- API Gateway
resource "oci_apigateway_gateway" "edge_pub_api_gw" {
   compartment_id = oci_identity_compartment.edge_comp.id
   display_name   = "edge-pub-gw-${local.workspace}"
   endpoint_type  = "PUBLIC"
   subnet_id      = oci_core_subnet.edge_pub_subnet.id
   certificate_id = var.EDGE_WITH_CERT ? var.EDGE_CERT_OCID : null
}

# --- API Deployment: Site-Administrator Endpoint definitions: /adm/v1
resource "oci_apigateway_deployment" "edge_adm_api_deployment" {
   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-adm-api-${local.workspace}"
   path_prefix    = "/adm/v1"

   specification {
     dynamic "routes" {
         for_each = var.edge_adm_v1_endpoints
         content {
            path    = routes.value.path
            methods = routes.value.methods
            dynamic "backend" {
               for_each = local.use_cwl ? [1] : []
               content {
                  type = "HTTP_BACKEND"
                  url  = "${local.nlb_url}/adm/v1${replace(replace (routes.value.path, local.path_param1_key, local.path_param1_val), local.path_param2_key, local.path_param2_val)}"
                  connect_timeout_in_seconds = var.EDGE_APIGW_CONNECTION_TIMEOUT
                  read_timeout_in_seconds    = var.EDGE_APIGW_READ_TIMEOUT
                  send_timeout_in_seconds    = var.EDGE_APIGW_SEND_TIMEOUT
               }
            }
            dynamic "backend" {
               for_each = local.use_cwl ? [] : [1]
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


# --- API Deployment: Backend-API, Public Endpoint definitions /be/v1
resource "oci_apigateway_deployment" "edge_pub_api_be_deployment_v1" {
   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-pub-api-v1-${local.workspace}"
   path_prefix    = "/be/v1"

   specification {
      dynamic "routes" {
         for_each = var.edge_be_v1_endpoints
         content {
            path    = routes.value.path
            methods = routes.value.methods
            dynamic "backend" {
               for_each = local.use_cwl ? [1] : []
               content {
                  type = "HTTP_BACKEND"
                  url  = "${local.nlb_url}/be/v1${replace(replace (routes.value.path, local.path_param1_key, local.path_param1_val), local.path_param2_key, local.path_param2_val)}"
                  connect_timeout_in_seconds = var.EDGE_APIGW_CONNECTION_TIMEOUT
                  read_timeout_in_seconds    = var.EDGE_APIGW_READ_TIMEOUT
                  send_timeout_in_seconds    = var.EDGE_APIGW_SEND_TIMEOUT
               }
            }
            dynamic "backend" {
               for_each = local.use_cwl ? [] : [1]
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

# --- API Deployment: ROCKIT Client API: Public Endpoint definitions /client/v1
resource "oci_apigateway_deployment" "edge_pub_api_launcher_deployment_v1" {
   compartment_id = oci_identity_compartment.edge_comp.id
   gateway_id     = oci_apigateway_gateway.edge_pub_api_gw.id
   display_name  = "edge-pub-api-v1-${local.workspace}"
   path_prefix    = "/client/v1"

   specification {
      dynamic "routes" {
         for_each = var.edge_client_v1_endpoints
         content {
            path    = routes.value.path
            methods = routes.value.methods
            dynamic "backend" {
               for_each = local.use_cwl ? [1] : []
               content {
                  type = "HTTP_BACKEND"
                  url  = "${local.nlb_url}/client/v1${replace(replace (routes.value.path, local.path_param1_key, local.path_param1_val), local.path_param2_key, local.path_param2_val)}"
                  connect_timeout_in_seconds = var.EDGE_APIGW_CONNECTION_TIMEOUT
                  read_timeout_in_seconds    = var.EDGE_APIGW_READ_TIMEOUT
                  send_timeout_in_seconds    = var.EDGE_APIGW_SEND_TIMEOUT
               }
            }
            dynamic "backend" {
               for_each = local.use_cwl ? [] : [1]
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
   edge_apigw_ipaddr = oci_apigateway_gateway.edge_pub_api_gw.ip_addresses[0].ip_address
   edge_apigw_url    = "https://${oci_apigateway_gateway.edge_pub_api_gw.hostname}"
   edge_base_url     = var.EDGE_WITH_CERT ? "https://${local.edge_pub_hostname}.${var.EDGE_CERT_DOMAINNAME}" : local.edge_apigw_url
}

output "baseurl" {
   value = local.edge_base_url
}

output "apigw_ip" {
   value = local.edge_apigw_ipaddr
}