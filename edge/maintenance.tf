# Invoke maintenance process periodically
# (see https://redthunder.blog/2022/05/03/a-better-mechanism-for-periodic-functions-invocation

resource "oci_ons_notification_topic" "edge_maintenance_topic" {
   compartment_id = oci_identity_compartment.edge_comp.id
   name           = "edge-maintenance-topic-${local.workspace}"
}

resource "oci_ons_subscription" "edge_maintenance_subscription" {
   compartment_id = oci_identity_compartment.edge_comp.id
   endpoint       = oci_functions_function.edge_fn.id
   protocol       = "ORACLE_FUNCTIONS"
   topic_id       = oci_ons_notification_topic.edge_maintenance_topic.id
}

resource "oci_monitoring_alarm" "edge_maintenance_trigger" {
   compartment_id        = oci_identity_compartment.edge_comp.id
   destinations          = [ oci_ons_notification_topic.edge_maintenance_topic.id ]
   display_name          = "maintenance-trigger-${local.workspace}"
   is_enabled            = true
   metric_compartment_id = oci_identity_compartment.edge_comp.id
   namespace             = "oci_internet_gateway"
   # any valid query which ALWAYS returns TRUE
   query                 = "BytesFromIgw[1m].count() >= 0"
   # 2m: PT2M, 2h: PT2H, 2d: PT2D
   repeat_notification_duration = "PT10M"
   severity              = "INFO"
   defined_tags          = {"ROCKITPLAY-Tags.taskType"= "bgedge"}
}