// --- endpoint definitions: /adm/v1
variable "engine_endpoints" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      // --- /adm/v1/*
      path       = "/adm/v1/hello"
      methods    = ["POST"]
   }, {
      path      = "/adm/v1/initialize"
      methods    = ["POST"]
   }, {
      path      = "/adm/v1/orgs"
      methods    = ["GET", "POST"]
   }, {
      path      = "/adm/v1/orgs/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path      = "/adm/v1/ping"
      methods    = ["POST"]
   }, {

     // --- /be/v1/*
      path       = "/be/v1/apikeys"
      methods    = ["POST", "DELETE"]
   }, {
      path      = "/be/v1/apps",
      methods   = ["GET", "POST", "PATCH"]
   }, {
      path      = "/be/v1/apps/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path      = "/be/v1/auth"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/builds"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/commit"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/export"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/import"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/login"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/roles"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path      = "/be/v1/roles/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path      = "/be/v1/subscriptions"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/subscriptions/{var1}/{var2}"
      methods    = ["DELETE"]
   }, {
      path      = "/be/v1/tasks"
      methods    = ["GET"]
   }, {
      path      = "/be/v1/tasks/{var1}"
      methods    = ["DELETE"]
   }, {
      path      = "/be/v1/traces"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/trigger"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/users"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path      = "/be/v1/users/{var1}"
      methods    = ["GET", "DELETE"]
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
   count          = local.use_cwl ? 0 : 1
   compartment_id = oci_identity_compartment.engine_comp.id
   display_name   = "engine-pub-gw-${local.workspace}"
   endpoint_type  = "PUBLIC"
   subnet_id      = oci_core_subnet.engine_pub_subnet.id
   certificate_id = var.ENGINE_WITH_CERT ? var.ENGINE_CERT_OCID : null
}

# --- API Deployments
resource "oci_apigateway_deployment" "engine_api_deployment" {
   count          = local.use_cwl ? 0 : 1
   compartment_id = oci_identity_compartment.engine_comp.id
   gateway_id     = oci_apigateway_gateway.engine_pub_api_gw[0].id
   display_name  = "engine-pub-api-v1-${local.workspace}"
   path_prefix    = "/"

   specification {
      dynamic "routes" {
         for_each = var.engine_endpoints
         content {
            path    = routes.value.path
            methods = routes.value.methods
            dynamic "backend" {
               for_each = local.use_cwl ? [1] : []
               content {
                  type = "HTTP_BACKEND"
                  url  = "${local.nlb_url}${replace(replace (routes.value.path, local.path_param1_key, local.path_param1_val), local.path_param2_key, local.path_param2_val)}"
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
   engine_apigw_ipaddr = local.use_cwl ? "n/a" : oci_apigateway_gateway.engine_pub_api_gw[0].ip_addresses[0].ip_address
   engine_apigw_url    = local.use_cwl ? "n/a" : "https://${oci_apigateway_gateway.engine_pub_api_gw[0].hostname}"
}