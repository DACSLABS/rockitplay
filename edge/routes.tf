// --- endpoint definitions: /adm/v1
variable "edge_endpoints" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path       = "/mc"
      methods    = ["GET"]
    }, {
      path       = "/mc/{var1}"
      methods    = ["GET"]
    }, {
       // --- /adm/v1/*
      path       = "/adm/v1/hello"
      methods    = ["POST"]
   }, {
      path      = "/adm/v1/orgs"
      methods    = ["POST"]
   }, {
      path      = "/adm/v1/orgs/{var1}"
      methods    = ["DELETE"]
   }, {
      path      = "/adm/v1/ping"
      methods    = ["POST"]
   }, {

      // --- /be/v1/*
      path       = "/be/v1/apikeys"
      methods    = ["POST", "DELETE"]
   }, {
      path       = "/be/v1/apps"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/be/v1/apps/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/be/v1/auth"
      methods    = ["POST"]
   }, {
      path       = "/be/v1/builds"
      methods    = ["POST"]
   }, {
      path       = "/be/v1/bundles"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/be/v1/bundles/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/be/v1/commit"
      methods    = ["POST"]
   }, {
      path       = "/be/v1/deployments"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/be/v1/deployments/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/be/v1/deps"
      methods    = ["POST", "PATCH", "GET", "DELETE"]
   }, {
      path       = "/be/v1/deps/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/be/v1/export"
      methods    = ["POST"]
   }, {
      path       = "/be/v1/import"
      methods    = ["POST"]
   }, {
      path       = "/be/v1/keys"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/be/v1/keys/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/be/v1/login"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/orgs"
      methods    = ["POST"]
   }, {
      path      = "/be/v1/orgs/{var1}"
      methods    = ["DELETE"]
   }, {
      path       = "/be/v1/roles"
      methods    = ["POST", "PATCH", "GET"]
   }, {
      path       = "/be/v1/roles/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/be/v1/sources"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/be/v1/sources/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/be/v1/subscriptions"
      methods    = [ "GET", "POST" ]
   }, {
      path       = "/be/v1/subscriptions/{var1}"
      methods    = [ "GET", "DELETE" ]
   }, {
      path       = "/be/v1/tasks"
      methods    = ["GET", "PATCH"]
   }, {
      path       = "/be/v1/tasks/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/be/v1/trainings"
      methods    = ["GET", "PATCH"]
   }, {
      path       = "/be/v1/trainings/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/be/v1/trigger"
      methods    = ["POST"]
   }, {
      path       = "/be/v1/users"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/be/v1/users/{var1}"
      methods    = ["GET", "DELETE"]
   }, {

      // --- /client/v1/*
      path       = "/client/v1/auth"
      methods    = ["POST"]
   }, {
      path       = "/client/v1/bundles"
      methods    = ["GET"]
   }, {
      path       = "/client/v1/bundles/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/client/v1/client-items"
      methods    = ["POST"]
   }, {
      path       = "/client/v1/deps/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/client/v1/feedback"
      methods    = ["POST"]
   }, {
      path       = "/client/v1/ib-sessions"
      methods    = ["POST"]
   }, {
      path       = "/client/v1/login"
      methods    = ["POST"]
   }, {
      path       = "/client/v1/rsi"
      methods    = ["GET"]
   }, {
      path       = "/client/v1/rte-sessions"
      methods    = ["POST", "PATCH"]
   }, {
      path       = "/client/v1/traces"
      methods    = ["POST"]
   }, {

      // --- /srv/v1/*
      path      = "/srv/v1/initialize"
      methods    = ["POST"]
   }, {
      path       = "/srv/v1/progress"
      methods    = ["POST"]
   }, {
      path       = "/srv/v1/publish"
      methods    = ["POST"]
   }, {
      path       = "/srv/v1/release"
      methods    = ["POST"]
   }]
}