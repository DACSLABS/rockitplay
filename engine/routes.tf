
variable "engine_adm_v1_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path      = "/hello"
      methods   = ["POST"]
   }, {
      path      = "/orgs"
      methods   = ["GET", "POST"]
   }, {
      path      = "/orgs/{var1}"
      methods   = ["GET", "DELETE"]
   }, {
      path      = "/ping"
      methods   = ["POST"]
   }, {
      path      = "/versions"
      methods   = ["GET"]
   }]
}

variable "engine_be_v1_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path      = "/apikeys"
      methods   = ["POST", "DELETE"]
   }, {
      path      = "/apps",
      methods   = ["GET", "POST", "PATCH"]
   }, {
      path      = "/apps/{var1}"
      methods   = ["GET", "DELETE"]
   }, {
      path      = "/auth"
      methods   = ["POST"]
   }, {
      path      = "/builds"
      methods   = ["POST"]
   }, {
      path      = "/commit"
      methods   = ["POST"]
   }, {
      path      = "/export"
      methods   = ["POST"]
   }, {
      path      = "/import"
      methods   = ["POST"]
   }, {
      path      = "/login"
      methods   = ["POST"]
   }, {
      path      = "/roles"
      methods   = ["GET", "POST", "PATCH"]
   }, {
      path      = "/roles/{var1}"
      methods   = ["GET", "DELETE"]
   }, {
      path      = "/subscriptions"
      methods   = ["POST"]
   }, {
      path      = "/subscriptions/{var1}/{var2}"
      methods   = ["DELETE"]
   }, {
      path      = "/tasks"
      methods   = ["GET", "PATCH"]
   }, {
      path      = "/tasks/{var1}"
      methods   = ["DELETE"]
   }, {
      path      = "/traces"
      methods   = ["POST"]
   }, {
      path      = "/trigger"
      methods   = ["POST"]
   }, {
      path      = "/users"
      methods   = ["GET", "POST", "PATCH"]
   }, {
      path      = "/users/{var1}"
      methods   = ["GET", "DELETE"]
   }]
}

variable "engine_srv_v1_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path      = "/initialize"
      methods   = ["POST"]
   }]
}
