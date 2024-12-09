// --- endpoint definitions: /adm/v1
variable "engine_adm_v1_endpoints" {
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
      methods    = ["GET", "POST", "DELETE"]
   }, {
      path      = "/orgs/{var1}"
      methods    = ["GET"]
   }, {
      path      = "/ping"
      methods    = ["POST"]
   }]
}

// --- endpoint definitions: /be/v1
variable "engine_be_v1_endpoints" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
     path       = "/apikeys"
     methods    = ["POST", "DELETE"]
   }, {
      path      = "/apps",
      methods   = ["GET", "POST", "PATCH", "DELETE"]
   }, {
      path      = "/apps/{var1}"
      methods    = ["GET"]
   }, {
      path      = "/auth"
      methods    = ["POST"]
   }, {
      path      = "/builds"
      methods    = ["POST"]
   }, {
      path      = "/commit"
      methods    = ["POST"]
   }, {
      path      = "/export"
      methods    = ["POST"]
   }, {
      path      = "/import"
      methods    = ["POST"]
   }, {
      path      = "/login"
      methods    = ["POST"]
   }, {
      path      = "/roles"
      methods    = ["GET", "POST", "PATCH", "DELETE"]
   }, {
      path      = "/roles/{var1}"
      methods    = ["GET"]
   }, {
      path      = "/subscriptions"
      methods    = ["POST", "DELETE"]
   }, {
      path      = "/tasks"
      methods    = ["GET", "DELETE"]
   }, {
      path      = "/traces"
      methods    = ["POST"]
   }, {
      path      = "/trigger"
      methods    = ["POST"]
   }, {
      path      = "/users"
      methods    = ["GET", "POST", "PATCH", "DELETE"]
   }, {
      path      = "/users/{var1}"
      methods    = ["GET"]
   }]
}


locals {
   path_param1_key = "{var1}"
   path_param1_val = "$${request.path[var1]}"
   path_param2_key = "{var2}"
   path_param2_val = "$${request.path[var2]}"
}


# --- API Gateway
resource "oci_apigateway_gateway" "engine_pub_api_gw" {
   compartment_id = oci_identity_compartment.engine_comp.id
   display_name   = "engine-pub-gw-${local.workspace}"
   endpoint_type  = "PUBLIC"
   subnet_id      = oci_core_subnet.engine_pub_subnet.id
   certificate_id = var.ENGINE_WITH_CERT ? var.ENGINE_CERT_OCID : null
}

# --- API Deployment: Site-Administrator Endpoint definitions: /adm/v1
resource "oci_apigateway_deployment" "engine_adm_api_deployment" {
   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw.id
   display_name  = "engine-adm-api-${local.workspace}"
   path_prefix    = "/adm/v1"

   specification {
     dynamic "routes" {
         for_each = var.engine_adm_v1_endpoints
         content {
            path    = routes.value.path
            methods = routes.value.methods
            dynamic "backend" {
               for_each = local.use_cwl ? [1] : []
               content {
                  type = "HTTP_BACKEND"
                  url  = "${local.nlb_url}/adm/v1${replace(replace (routes.value.path, local.path_param1_key, local.path_param1_val), local.path_param2_key, local.path_param2_val)}"
                  connect_timeout_in_seconds = var.ENGINE_APIGW_CONNECTION_TIMEOUT
                  read_timeout_in_seconds    = var.ENGINE_APIGW_READ_TIMEOUT
                  send_timeout_in_seconds    = var.ENGINE_APIGW_SEND_TIMEOUT
               }
            }
            dynamic "backend" {
               for_each = local.use_cwl ? [] : [1]
               content {
                  type        = "ORACLE_FUNCTIONS_BACKEND"
                  function_id = oci_functions_function.engine_fn.id
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
resource "oci_apigateway_deployment" "engine_pub_api_be_deployment_v1" {
   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw.id
   display_name  = "engine-pub-api-v1-${local.workspace}"
   path_prefix    = "/be/v1"

   specification {
      dynamic "routes" {
         for_each = var.engine_be_v1_endpoints
         content {
            path    = routes.value.path
            methods = routes.value.methods
            dynamic "backend" {
               for_each = local.use_cwl ? [1] : []
               content {
                  type = "HTTP_BACKEND"
                  url  = "${local.nlb_url}/be/v1${replace(replace (routes.value.path, local.path_param1_key, local.path_param1_val), local.path_param2_key, local.path_param2_val)}"
                  connect_timeout_in_seconds = var.ENGINE_APIGW_CONNECTION_TIMEOUT
                  read_timeout_in_seconds    = var.ENGINE_APIGW_READ_TIMEOUT
                  send_timeout_in_seconds    = var.ENGINE_APIGW_SEND_TIMEOUT
               }
            }
            dynamic "backend" {
               for_each = local.use_cwl ? [] : [1]
               content {
                  type        = "ORACLE_FUNCTIONS_BACKEND"
                  function_id = oci_functions_function.engine_fn.id
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
   engine_apigw_ipaddr = oci_apigateway_gateway.engine_pub_api_gw.ip_addresses[0].ip_address
   engine_apigw_url = "https://${oci_apigateway_gateway.engine_pub_api_gw.hostname}"
   engine_base_url  = var.ENGINE_WITH_CERT ? "https://${local.engine_pub_hostname}.${var.ENGINE_CERT_DOMAINNAME}" : local.engine_apigw_url
}

output "baseurl" {
   value = local.engine_base_url
}

output "apigw_ip" {
   value = local.engine_apigw_ipaddr
}