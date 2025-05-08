# Invoke maintenance process periodically
# (see https://redthunder.blog/2022/05/03/a-better-mechanism-for-periodic-functions-invocation

resource "oci_ons_notification_topic" "maintenance_topic" {
   compartment_id = oci_identity_compartment.engine_comp.id
   name           = "engine-maintenance-topic-${local.workspace}"
}

resource "oci_ons_subscription" "maintenance_subscription" {
   compartment_id = oci_identity_compartment.engine_comp.id
   endpoint       = oci_functions_function.engine_fn.id
   protocol       = "ORACLE_FUNCTIONS"
   topic_id       = oci_ons_notification_topic.maintenance_topic.id
}

resource "oci_monitoring_alarm" "maintenance_trigger" {
   compartment_id        = oci_identity_compartment.engine_comp.id
   destinations          = [ oci_ons_notification_topic.maintenance_topic.id ]
   display_name          = "maintenance-trigger-${local.workspace} ${var.ENGINE_MAINTENANCE_MODE ? "OFF (maintenance)" : "ON"}"
   is_enabled            = !var.ENGINE_MAINTENANCE_MODE
   metric_compartment_id = oci_identity_compartment.engine_comp.id
   namespace             = "oci_internet_gateway"
   # any valid query which ALWAYS returns TRUE
   query                 = "BytesFromIgw[1m].count() >= 0"
   # 2m: PT2M, 2h: PT2H, 2d: PT2D
   repeat_notification_duration = "PT10M"
   severity              = "INFO"
   #defined_tags          = {"ROCKITPLAY-Tags.taskType"= "bgengine"}
}