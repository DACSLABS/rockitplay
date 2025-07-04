# --- MongoDB Atlas Project
resource "mongodbatlas_project" "engine_mongodb_proj" {
   name   = "engine-proj-${local.workspace}"
   org_id = var.ENGINE_DB_ORGID

   is_collect_database_specifics_statistics_enabled = true
   is_data_explorer_enabled                         = true
   is_performance_advisor_enabled                   = true
   is_realtime_performance_panel_enabled            = true
   is_schema_advisor_enabled                        = true
}

locals {
   db_region = replace (lower (var.ENGINE_DB_REGION), "_", "")
}


# --- MongoDB Cluster: M0, Free Tier
resource "mongodbatlas_cluster" "engine_mongodb_cluster" {
   count      = var.ENGINE_DB_TYPE == "free_cluster" ? 1 : 0
   depends_on = [ mongodbatlas_project.engine_mongodb_proj ]
   name       = "eng-${local.workspace}-${local.db_region}"
   project_id = mongodbatlas_project.engine_mongodb_proj.id
   provider_name               = "TENANT"
   backing_provider_name       = "AWS"
   provider_instance_size_name = "M0"
   provider_region_name        = var.ENGINE_DB_REGION
}

# --- MongoDB Cluster: M10, minimal
resource "mongodbatlas_advanced_cluster" "engine_mongodb_cluster" {
   count      = var.ENGINE_DB_TYPE == "advanced_cluster" ? 1 : 0
   depends_on = [ mongodbatlas_project.engine_mongodb_proj ]
   name       = "eng-${local.workspace}-${local.db_region}"
   project_id = mongodbatlas_project.engine_mongodb_proj.id
   cluster_type = "REPLICASET"
   bi_connector_config {
      enabled         = false
   }
   replication_specs {
     region_configs {
       auto_scaling {
          disk_gb_enabled = false
          compute_enabled = false
       }
       electable_specs {
          instance_size = var.ENGINE_DB_SIZE
          node_count    = 3
       }
       provider_name = "AWS"
       priority      = 7
       region_name   = var.ENGINE_DB_REGION
     }
   }
}

# --- Network Access
resource "mongodbatlas_project_ip_access_list" "engine_mongodb_natgw_access_list" {
   depends_on = [ oci_core_nat_gateway.nat_gw ]
   project_id = mongodbatlas_project.engine_mongodb_proj.id
   ip_address = oci_core_nat_gateway.nat_gw.nat_ip
   comment    = "Engine NAT Gateway"
}

locals {
  mongodb_ip_access_list = [for ip in split(",", var.ENGINE_DB_IP_ACCESS_LIST) : ip if length(trimspace(ip)) > 0]
}

resource "mongodbatlas_project_ip_access_list" "engine_mongodb_ip_access_list" {
   for_each   = toset(local.mongodb_ip_access_list)

   project_id = mongodbatlas_project.engine_mongodb_proj.id
   cidr_block = each.value
   comment    = "List of permitted IP addresses"
}

# --- Retrieve connstr
locals {
   mongodb_connstr = replace (
      var.ENGINE_DB_TYPE == "free_cluster" ? mongodbatlas_cluster.engine_mongodb_cluster[0].connection_strings[0].standard_srv
                                           : mongodbatlas_advanced_cluster.engine_mongodb_cluster[0].connection_strings[0].standard_srv,
      "mongodb+srv://",
      "mongodb+srv://engine-db-user-${local.workspace}:${urlencode(random_password.db_pw.result)}@"
   )
}

# --- Create DB User
resource "mongodbatlas_database_user" "db_user" {
   username           = "engine-db-user-${local.workspace}"
   depends_on         = [ mongodbatlas_advanced_cluster.engine_mongodb_cluster ]
   password           = random_password.db_pw.result
   project_id         = mongodbatlas_project.engine_mongodb_proj.id
   auth_database_name = "admin"

   roles {
      //role_name     = "readWriteAnyDatabase"
      role_name = "atlasAdmin"
      database_name = "admin"
   }
}

# --- Outputs
# output "mongodb_connstr" {
#    value = local.mongodb_connstr
# }
