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
      prefix = "/adm/v1"
      method = "GET",
      endpoints_exact = [
         "apps",
         "orgs",
         "tasks",
         "tenants",
         "users"
      ]
      endpoints_wildcard = [
         "apps",
         "orgs",
         "tasks",
         "tenants",
         "users",
      ]
   }, {
      prefix = "/adm/v1"
      method = "POST"
      endpoints_exact = [
         "commit",
         "login",
         "logout",
         "orgs",
         "refresh",
         "tenants",
         "users",
      ]
   }, {
      prefix = "/adm/v1"
      method = "PATCH"
      endpoints_exact = [
         "apps",
         "orgs",
         "tenants",
         "users",
      ]
   }, {
      prefix = "/adm/v1"
      method = "DELETE"
      endpoints_wildcard = [
         "orgs",
         "tenants",
         "users",
      ]
   }, {

      // --- /be/v1/*
      prefix = "/be/v1"
      method = "GET"
      endpoints_exact = [
         "activities",
         "apps",
         "deployments",
         "deps",
         "keys",
         "library",
         "messages",
         "notifications",
         "packages",
         "roles",
         "sources",
         "subscriptions",
         "tasks",
         "trainings",
         "users",
         "workbench",
      ]
      endpoints_wildcard = [
         "apps",
         "deployments",
         "deps",
         "keys",
         "library",
         "messages",
         "notifications",
         "packages",
         "roles",
         "sources",
         "subscriptions",
         "tasks",
         "trainings",
         "users",
         "workbench",
      ]
   }, {
      prefix = "/be/v1"
      method = "POST"
      endpoints_exact = [
         "apikeys",
         "apps",
         "builds",
         "commit",
         "deployments",
         "deps",
         "export",
         "import",
         "keys",
         "login",
         "logout",
         "notifications",
         "packages",
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
         "deployments",
         "deps",
         "keys",
         "orgs",
         "packages",
         "resetpw",
         "roles",
         "sources",
         "tasks",
         "trainings",
         "users",
         "workbench",
         "messages",
      ]
      endpoints_wildcard = [
         "messages",
      ]
   }, {
      prefix = "/be/v1"
      method = "DELETE"
      endpoints_exact = [
         "apikeys",
         "keys",
      ]
      endpoints_wildcard = [
         "apikeys",
         "apps",
         "deployments",
         "deps",
         "keys",
         "notifications",
         "orgs",
         "packages",
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
         "packages",
         "rsi",
      ]
      endpoints_wildcard = [
         "packages",
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
      path = "/apps/mc"
      id   = "mc"
   }, {
      path = "/apps/gc"
      id   = "gc"
   }, {
      path = "/apps/signup"
      id   = "signup"
   }, {
      path = "/apps/resetpw"
      id   = "resetpw"
   }, {
      path = "/"
      id   = "welcome"
   }, {
      path = "/apps/pushworker"
      id   = "pushworker"
   }]
}