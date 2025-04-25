resource "oci_waf_web_app_firewall_policy" "edge_waf_pol" {
   count          = local.use_cwl ? 1 : 0
   display_name   = "edge-waf-pol-${local.workspace}"
	compartment_id = oci_identity_compartment.edge_comp.id

   # --- actions: allow, block, maintenance
   actions {
      name = "allow"
      type = "ALLOW"
   }
   actions {
      name = "block"
      type = "RETURN_HTTP_RESPONSE"
      code = "405"
      headers {
         name  = "Content-Type"
         value = "application/json"
      }
      body {
         text = jsonencode({
            "code"    = 405,
            "message" = "Method Not Allowed"
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

   # --- endpoints (normal mode)
   dynamic "request_access_control" {
      for_each = (var.EDGE_MAINTENANCE_MODE) ? [0] : [1]
      content {
         # TODO: revert default to "block" as part of RE-277, rate-limits still active with allow
         default_action_name = "allow"
         dynamic "rules" {
            for_each = var.edge_endpoints
            content {
               name               = "route${replace(replace(replace(rules.value.path, "/", "-"), "{", ""), "}", "")}_${join("-", rules.value.methods)}"
               action_name        = (var.EDGE_MAINTENANCE_MODE && substr(rules.value.path, 0, 5) != "/srv/") ? "maintenance" : "allow"
               condition          = "i_starts_with(http.request.url.path, '${rules.value.path}')\n&& i_contains(['${join("','", rules.value.methods)}'], http.request.method)"
               condition_language = "JMESPATH"
               type               = "ACCESS_CONTROL"
            }
         }
      }
   }

   # --- rate limits
   request_rate_limiting {

      // --- /client/*
      rules {
         name = "client-route-rate-limit"
         type = "REQUEST_RATE_LIMITING"
         action_name = "limit"
         condition_language = "JMESPATH"
         configurations {
            action_duration_in_seconds = "0"
            period_in_seconds          = "1"
            requests_limit             = "1000"
         }
      }

      // --- /srv/*
      rules {
         name = "srv-route-rate-limit"
         type = "REQUEST_RATE_LIMITING"
         action_name        = "limit"
         condition          = "i_starts_with(http.request.url.path, '/srv')"
         condition_language = "JMESPATH"
         configurations {
            action_duration_in_seconds = "0"
            period_in_seconds          = "1"
            requests_limit             = "100"
         }
      }

      // --- /be/*
      rules {
         name = "be-route-limit"
         type = "REQUEST_RATE_LIMITING"
         action_name        = "limit"
         condition          = "i_starts_with(http.request.url.path, '/be')"
         condition_language = "JMESPATH"
         configurations {
            action_duration_in_seconds = "0"
            period_in_seconds          = "1"
            requests_limit             = "10"
         }
      }

      // --- /adm/*
      rules {
         name = "adm-route-rate-limit"
         type = "REQUEST_RATE_LIMITING"
         action_name        = "limit"
         condition          = "i_starts_with(http.request.url.path, '/adm')"
         condition_language = "JMESPATH"
         configurations {
            action_duration_in_seconds = "0"
            period_in_seconds          = "1"
            requests_limit             = "10"
         }
      }
   }

   # --- security rules
#   request_protection {
#      body_inspection_size_limit_in_bytes = "8192"
#      rules {
#         action_name                = "block"
#         condition                  = "i_starts_with(http.request.url.path, '/')"
#         condition_language         = "JMESPATH"
#         is_body_inspection_enabled = "false"
#         name                       = "waf-sec-rules"
#         protection_capabilities {
#            key     = "941140"  # Cross-Site Scripting (XSS) Attempt: XSS Filters - Category 4
#            version = "3"
#         }
#         protection_capabilities {
#            key     = "9410000" # Cross-Site Scripting (XSS) Collaborative Group - XSS Filters Categories
#            version = "3"
#         }
#         protection_capabilities {
#            key     = "930120" # Local File Inclusion (LFI) - OS File Access
#            version = "2"
#         }
#         protection_capabilities {
#            key     = "9300000" # Local File Inclusion (LFI) Collaborative Group - LFI Filter Categories
#            version = "2"
#         }
#         protection_capabilities {
#            key     = "942270" # SQL Injection (SQLi) Common SQLi attacks for various dbs
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "9420000" # SQL Injection (SQLi) Collaborative Group - SQLi Filters Categories
#            version = "2"
#         }
#         protection_capabilities {
#            key     = "9330000" # PHP Injection Attacks Collaborative Group - PHP Filters Categories
#            version = "2"
#         }
#         protection_capabilities {
#            key     = "9320001" # Remote Code Execution (RCE) Collaborative Group - Windows RCE Filter Categories
#            version = "2"
#         }
#         protection_capabilities {
#            key     = "9320000" # Remote Code Execution (RCE) Collaborative Group - Unix RCE Filter Categories
#            version = "2"
#         }
#         protection_capabilities {
#            key     = "920390" # Limit arguments total length
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "920380" # Number of Arguments Limits
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "920370" # Limit argument value length
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "920320" # Missing User-Agent header
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "920300" # Missing Accept Header
#            version = "2"
#         }
#         protection_capabilities {
#            key     = "920280" # Missing/Empty Host Header
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "911100" # Restrict HTTP Request Methods
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "200003" # Restrict multipart/form-data
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "200002" # Identify Request Body process failures
#            version = "1"
#         }
#         protection_capabilities {
#            key     = "200001" # Enable JSON request body parser
#            version = "1"
#         }
#         type = "PROTECTION"
#      }
#   }
}


resource "oci_waf_web_app_firewall" "edge_waf" {
   count                      = local.use_cwl ? 1 : 0
   display_name               = "edge-waf-${local.workspace}"
   backend_type               = "LOAD_BALANCER"
   compartment_id             = oci_identity_compartment.edge_comp.id
   load_balancer_id           = oci_load_balancer_load_balancer.edge_lb[0].id
   web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.edge_waf_pol[0].id
}
