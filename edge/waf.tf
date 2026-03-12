resource "oci_waf_web_app_firewall_policy" "edge_waf_pol" {
   count          = (var.EDGE_USE_WAF && var.EDGE_USE_CWL) ? 1 : 0
   display_name   = "edge-waf-pol-${local.workspace}"
	compartment_id = oci_identity_compartment.edge_comp.id

   # --- actions
   actions {
      name = "allow"
      type = "ALLOW"
   }
   actions {
      name = "denied"
      type = "RETURN_HTTP_RESPONSE"
      code = "400"
      headers {
         name  = "Content-Type"
         value = "application/json"
      }
      body {
         text = jsonencode({
            "code"    = 400,
            "message" = "Bad Request"
         })
         type = "STATIC_TEXT"
      }
   }
   actions {
      name = "no-such-route"
      type = "RETURN_HTTP_RESPONSE"
      code = "404"
      headers {
         name  = "Content-Type"
         value = "application/json"
      }
      body {
         text = jsonencode({
            "code"    = 404,
            "message" = "Not Found"
         })
         type = "STATIC_TEXT"
      }
   }
   actions {
      name = "limit"
      type = "RETURN_HTTP_RESPONSE"
      code = "429"
      headers {
         name  = "Content-Type"
         value = "application/json"
      }
      headers {
         name  = "Retry-After"
         value = 60
      }
      body {
         text = jsonencode({
            "code"    = 429,
            "message" = "Too Many Requests"
         })
         type = "STATIC_TEXT"
      }
   }
   actions {
      name = "maintenance"
      type = "RETURN_HTTP_RESPONSE"
      code = "503"
      headers {
         name  = "Content-Type"
         value = "application/json"
      }
      headers {
         name  = "Retry-After"
         value = "900"  # 15m
      }
      body {
         text = jsonencode({
            "status"     = "failed"
            "error"      = "maintenance"
            "message"    = "The service is in maintenance mode. Please retry later."
            "retryAfter" = "900"
         })
         type = "STATIC_TEXT"
      }
   }

   request_access_control {
      default_action_name = "no-such-route"

      # --- ROCKITPLAY public endpoints
      dynamic "rules" {
         for_each = flatten([
         for route in var.edge_api_routes : concat(
            [for exact in route.endpoints_exact : {
               key         = "exact_${route.method}${replace(route.prefix, "/", "_")}_${exact}"
               method      = route.method
               full_path   = "${route.prefix}/${exact}"
               is_wildcard = false
            }],
            [for wc in route.endpoints_wildcard : {
               key         = "wildcard_${route.method}${replace(route.prefix, "/", "_")}_${wc}"
               method      = route.method
               full_path   = "${route.prefix}/${wc}"
               is_wildcard = true
            }]
         )
         ])
         content {
            name               = rules.value.key
            action_name        = "allow"
            type               = "ACCESS_CONTROL"
            condition_language = "JMESPATH"

            condition = (
               rules.value.is_wildcard
               ? "i_equals(http.request.method, '${rules.value.method}') && i_starts_with(http.request.url.path, '${rules.value.full_path}/')"
               : "i_equals(http.request.method, '${rules.value.method}') && i_equals(http.request.url.path, '${rules.value.full_path}')"
            )
         }
      }

      # --- ROCKITPLAY service endpoints
      dynamic "rules" {
         for_each = flatten([
         for route in var.edge_api_srv_routes : concat(
            [for exact in route.endpoints_exact : {
               key         = "exact_${route.method}${replace(route.prefix, "/", "_")}_${exact}"
               method      = route.method
               full_path   = "${route.prefix}/${exact}"
               is_wildcard = false
            }],
            [for wc in route.endpoints_wildcard : {
               key         = "wildcard_${route.method}${replace(route.prefix, "/", "_")}_${wc}"
               method      = route.method
               full_path   = "${route.prefix}/${wc}"
               is_wildcard = true
            }]
         )
         ])
         content {
            name               = rules.value.key
            action_name        = "allow"
            type               = "ACCESS_CONTROL"
            condition_language = "JMESPATH"

            condition = (
               rules.value.is_wildcard
               ? "i_equals(http.request.method, '${rules.value.method}') && i_starts_with(http.request.url.path, '${rules.value.full_path}/')"
               : "i_equals(http.request.method, '${rules.value.method}') && i_equals(http.request.url.path, '${rules.value.full_path}')"
            )
         }
      }
   }

   # --- security rules
   request_protection {
      body_inspection_size_limit_in_bytes = "8192"
      rules {
         action_name                = "denied"
         type                       = "PROTECTION"
         condition                  = "i_starts_with(http.request.url.path, '/')"
         condition_language         = "JMESPATH"
         is_body_inspection_enabled = "false"
         name                       = "waf-sec-rules"
         # protection_capabilities {
         #    key     = "9420000" # SQL Injection (SQLi) Collaborative Group - SQLi Filters Categories
         #    version = "1"
         # }
         protection_capabilities {
            key     = "941360" # Cross-Site Scripting (XSS) Attempt: Defend against JSFuck and Hieroglyphy obfuscation of Javascript code
            version = "1"
         }
         protection_capabilities {
            key     = "934131" # JavaScript Prototype Pollution
            version = "1"
         }
         protection_capabilities {
            key     = "934130" # JavaScript prototype pollution injection attempts
            version = "1"
         }
         protection_capabilities {
            key     = "934100" # Insecure unserialization Remote Code Execution
            version = "2"
         }
         protection_capabilities {
            key     = "9410000" # Cross-Site Scripting (XSS) Collaborative Group - XSS Filters Categories
            version = "3"
         }
         # protection_capabilities {
         #    key     = "9300000" # Local File Inclusion (LFI) Collaborative Group - LFI Filter Categories
         #    version = "2"
         # }
         # protection_capabilities {
         #    key     = "9330000" # PHP Injection Attacks Collaborative Group - PHP Filters Categories
         #    version = "2"
         # }
         # protection_capabilities {
         #    key     = "9320001" # Remote Code Execution (RCE) Collaborative Group - Windows RCE Filter Categories
         #    version = "2"
         # }
         # protection_capabilities {
         #    key     = "9320000" # Remote Code Execution (RCE) Collaborative Group - Unix RCE Filter Categories
         #    version = "2"
         # }
         protection_capabilities {
            key     = "920390" # Limit arguments total length
            version = "1"
         }
         protection_capabilities {
            key     = "920380" # Number of Arguments Limits
            version = "1"
         }
         protection_capabilities {
            key     = "920370" # Limit argument value length
            version = "1"
         }
         protection_capabilities {
            key     = "920300" # Missing Accept Header
            version = "2"
         }
         protection_capabilities {
            key     = "920280" # Missing/Empty Host Header
            version = "1"
         }
         protection_capabilities {
            key     = "911100" # Restrict HTTP Request Methods
            version = "1"
         }
         protection_capabilities {
            key     = "200003" # Restrict multipart/form-data
            version = "1"
         }
         protection_capabilities {
            key     = "200002" # Identify Request Body process failures
            version = "1"
         }
         protection_capabilities {
            key     = "200001" # Enable JSON request body parser
            version = "1"
         }
         protection_capability_settings {
            allowed_http_methods = ["GET", "POST", "PATCH", "DELETE"]
         }
      }
   }
}


resource "oci_waf_web_app_firewall" "edge_waf" {
   count                      = (var.EDGE_USE_WAF && var.EDGE_USE_CWL) ? 1 : 0
   display_name               = "edge-waf-${local.workspace}"
   backend_type               = "LOAD_BALANCER"
   compartment_id             = oci_identity_compartment.edge_comp.id
   load_balancer_id           = oci_load_balancer_load_balancer.edge_lb[0].id
   web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.edge_waf_pol[0].id
}