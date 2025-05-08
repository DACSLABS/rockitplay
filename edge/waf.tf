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
      name = "bad"
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
   # note:
   #  - M0 database handles 30 RPS max
   #  - M10 database showed 600 RPS in benchmark with 2 CWLs
   #  - current config of a single WAF "firewall" object peaks at ~900 RPS
   #  - LoadBalancer needs manual adjustment, rule of thumb:  100mbps per core of the CWLs
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
            requests_limit             = var.EDGE_DB_TYPE == "free_cluster" ? 30 : 600
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
            requests_limit             = var.EDGE_DB_TYPE == "free_cluster" ? 30 : 600
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
            requests_limit             = var.EDGE_DB_TYPE == "free_cluster" ? 30 : 600
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
            requests_limit             = var.EDGE_DB_TYPE == "free_cluster" ? 30 : 600
         }
      }
   }

   # --- security rules
   request_protection {
      body_inspection_size_limit_in_bytes = "8192"
      rules {
         action_name                = "bad"
         type                       = "PROTECTION"
         condition                  = "i_starts_with(http.request.url.path, '/')"
         condition_language         = "JMESPATH"
         is_body_inspection_enabled = "false"
         name                       = "waf-sec-rules"
         protection_capabilities {
            key     = "9420000" # SQL Injection (SQLi) Collaborative Group - SQLi Filters Categories
            version = "1"
         }
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
         protection_capabilities {
            key     = "9300000" # Local File Inclusion (LFI) Collaborative Group - LFI Filter Categories
            version = "2"
         }
         protection_capabilities {
            key     = "9330000" # PHP Injection Attacks Collaborative Group - PHP Filters Categories
            version = "2"
         }
         protection_capabilities {
            key     = "9320001" # Remote Code Execution (RCE) Collaborative Group - Windows RCE Filter Categories
            version = "2"
         }
         protection_capabilities {
            key     = "9320000" # Remote Code Execution (RCE) Collaborative Group - Unix RCE Filter Categories
            version = "2"
         }
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
   count                      = local.use_cwl ? 1 : 0
   display_name               = "edge-waf-${local.workspace}"
   backend_type               = "LOAD_BALANCER"
   compartment_id             = oci_identity_compartment.edge_comp.id
   load_balancer_id           = oci_load_balancer_load_balancer.edge_lb[0].id
   web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.edge_waf_pol[0].id
}
