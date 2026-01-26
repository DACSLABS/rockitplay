
variable "edge_apps_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path       = "/apps"
      methods    = ["GET"]
    }, {
      path       = "/{everything*}"
      methods    = ["GET"]
   }]
}

variable "edge_adm_v1_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path       = "/orgs"
      methods    = ["POST"]
   }, {
      path       = "/orgs/{var1}"
      methods    = ["DELETE"]
   }, {
      path       = "/users/{var1}"
      methods    = ["DELETE"]
   }]
}

variable "edge_be_v1_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path       = "/activities"
      methods    = ["GET"]
   }, {
      path       = "/apikeys"
      methods    = ["POST", "DELETE"]
   }, {
      path       = "/apps"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/apps/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/builds"
      methods    = ["POST"]
   }, {
      path       = "/bundles"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/bundles/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/commit"
      methods    = ["POST"]
   }, {
      path       = "/deployments"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/deployments/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/deps"
      methods    = ["POST", "PATCH", "GET", "DELETE"]
   }, {
      path       = "/deps/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/export"
      methods    = ["POST"]
   }, {
      path       = "/import"
      methods    = ["POST"]
   }, {
      path       = "/keys"
      methods    = ["GET", "POST", "PATCH", "DELETE"]
   }, {
      path       = "/keys/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/library"
      methods    = ["GET"]
   }, {
      path       = "/login"
      methods    = ["POST"]
   }, {
      path       = "/logout"
      methods    = ["POST"]
   }, {
      path       = "/orgs"
      methods    = ["POST"]
   }, {
      path       = "/orgs/{var1}"
      methods    = ["DELETE"]
   }, {
      path       = "/refresh"
      methods    = ["POST"]
   }, {
      path       = "/resetpw"
      methods    = ["POST", "PATCH", "GET"]
   }, {
      path       = "/roles"
      methods    = ["POST", "PATCH", "GET"]
   }, {
      path       = "/roles/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/signup"
      methods    = ["POST", "GET"]
   }, {
      path       = "/sources"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/sources/{var1}"
      methods    = ["GET", "DELETE"]
   }, {
      path       = "/subscriptions"
      methods    = [ "GET", "POST" ]
   }, {
      path       = "/subscriptions/{var1}"
      methods    = [ "GET", "DELETE" ]
   }, {
      path       = "/tasks"
      methods    = ["GET", "PATCH"]
   }, {
      path       = "/tasks/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/trainings"
      methods    = ["GET", "PATCH"]
   }, {
      path       = "/trainings/{var1}"
      methods    = ["GET"]
   }, {
      path       = "/trigger"
      methods    = ["POST"]
   }, {
      path       = "/users"
      methods    = ["GET", "POST", "PATCH"]
   }, {
      path       = "/users/{var1}"
      methods    = ["GET", "DELETE"]
   }]
}

variable "edge_client_v1_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
         path       = "/auth"
         methods    = ["POST"]
      }, {
         path       = "/bundles"
         methods    = ["GET"]
      }, {
         path       = "/bundles/{var1}"
         methods    = ["GET"]
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

variable "edge_srv_v1_api" {
   type = list (object ({
      path      = string
      methods   = list(string)
   }))
   default = [{
      path       = "/hello"
      methods    = ["POST"]
   }, {
      path       = "/initialize"
      methods    = ["POST"]
   }, {
      path       = "/ping"
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
      path       = "/versions"
      methods    = ["GET"]
   }]
}
