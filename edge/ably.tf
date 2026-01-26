resource "ably_app" "edge_ably_app" {
   count    = var.EDGE_USE_ABLY ? 1 : 0
   name     = "rockit-edge-app-${local.workspace}"
   status   = "enabled"
   tls_only = true
}

resource "ably_api_key" "edge_ably_apikey" {
   count  = var.EDGE_USE_ABLY ? 1 : 0
   app_id = ably_app.edge_ably_app[0].id
   name   = "rockitplay-publish-apikey"
   capabilities = {
      "rockitplay" = [ "publish", "presence", "subscribe" ],
   }
}
locals {
   edge_ably_apikey = var.EDGE_USE_ABLY ? ably_api_key.edge_ably_apikey[0].key : ""
}