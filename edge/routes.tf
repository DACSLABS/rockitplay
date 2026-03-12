# --- public endpoints
variable "edge_api_routes" {
   description = "List of endpoints"
   type = list(object({
      prefix = string
      method = string
      endpoints_exact    = optional(list(string), [])   # exact match, e.g. /users
      endpoints_wildcard = optional(list(string), [])   # wildcard match, e.g. /users/*
   }))
   validation {
      condition = length(setsubtract(
         [for r in var.edge_api_routes : r.method],
         ["HEAD", "GET", "POST", "PATCH", "DELETE"]
      )) == 0
      error_message = "Supported HTTP methods are: GET, POST, PATCH, DELETE"
   }

   default = [{
      // --- /adm/v1/*
   #  prefix = "/adm/v1"
   #  method = "GET"
   # }, {
      prefix = "/adm/v1"
      method = "POST"
      endpoints_exact = [
         "orgs",
      ]
   }, {
   #  prefix = "/adm/v1"
   #  method = "PATCH"
   # }, {
      prefix = "/adm/v1"
      method = "DELETE"
      endpoints_wildcard = [
         "orgs",
         "users",
      ]
   }, {

      // --- /be/v1/*
      prefix = "/be/v1"
      method = "GET"
      endpoints_exact = [
         "activities",
         "apps",
         "bundles",
         "deployments",
         "deps",
         "keys",
         "library",
         "roles",
         "sources",
         "subscriptions",
         "tasks",
         "trainings",
         "users",
      ]
      endpoints_wildcard = [
         "apps",
         "bundles",
         "deployments",
         "deps",
         "keys",
         "roles",
         "sources",
         "subscriptions",
         "tasks",
         "trainings",
         "users",
      ]
   }, {
      prefix = "/be/v1"
      method = "POST"
      endpoints_exact = [
         "apikeys",
         "apps",
         "builds",
         "bundles",
         "commit",
         "deployments",
         "deps",
         "export",
         "import",
         "keys",
         "login",
         "logout",
         "orgs",
         "refresh",
         "resetpw",
         "roles",
         "signup",
         "sources",
         "subscriptions",
         "tasks",
         "trainings",
         "trigger",
         "users",
      ]
   }, {
      prefix = "/be/v1"
      method = "PATCH"
      endpoints_exact = [
         "apps",
         "bundles",
         "deployments",
         "deps",
         "keys",
         "orgs",
         "resetpw",
         "roles",
         "sources",
         "tasks",
         "trainings",
         "users",
      ]
   }, {
      prefix = "/be/v1"
      method = "DELETE"
      endpoints_exact = [
         "apikeys",
      ]
      endpoints_wildcard = [
         "apikeys",
         "apps",
         "bundles",
         "deployments",
         "deps",
         "keys",
         "orgs",
         "roles",
         "sources",
         "subscriptions",
         "users",
      ]
   }, {

      // --- /client/v1/*
      prefix = "/client/v1"
      method = "GET"
      endpoints_exact = [
         "bundles",
         "rsi",
      ]
      endpoints_wildcard = [
         "bundles",
         "deps",
      ]
   }, {
      prefix = "/client/v1"
      method = "POST"
      endpoints_exact = [
         "auth",
         "client-items",
         "feedback",
         "ib-sessions",
         "login",
         "rte-sessions",
         "traces",
      ]
   }, {
      prefix = "/client/v1"
      method = "PATCH"
      endpoints_exact = [
         "client-items",
         "rte-sessions",
      ]
   }]
}

# --- internal /srv endpoints
variable "edge_api_srv_routes" {
   description = "List of endpoints"
   type = list(object({
      prefix    = string
      method    = string
      endpoints_exact    = optional(list(string), [])   # exact match, e.g. /users
      endpoints_wildcard = optional(list(string), [])   # wildcard match, e.g. /users/*
   }))
   validation {
      condition = length(setsubtract(
         [for r in var.edge_api_srv_routes : r.method],
         ["HEAD", "GET", "POST", "PATCH", "DELETE"]
      )) == 0
      error_message = "Supported HTTP methods are: GET, POST, PATCH, DELETE"
   }

   default = [{
      // --- /srv/v1/*
      prefix = "/srv/v1"
      method = "GET"
      endpoints_exact = [
         "versions"
      ]
   }, {
      prefix = "/srv/v1"
      method = "POST"
      endpoints_exact = [
         "hello",
         "initialize",
         "ping",
         "progress",
         "publish",
         "release"
      ]
   }]
}

# --- static routes to React SPAs: /* and /assets/*
variable "edge_api_static" {
   type = list(object({
      path = string
      id   = string
   }))
   default = [{
      path = "/"
      id   = "welcome"
   }, {
      path = "/apps/mc"
      id   = "mc"
   }, {
      path = "/apps/signup"
      id   = "signup"
   }, {
      path = "/apps/resetpw"
      id   = "resetpw"
   }]
}