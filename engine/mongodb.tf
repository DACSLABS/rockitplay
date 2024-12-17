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

# --- MongoDB Cluster: eu-central-1 @ aws
resource "mongodbatlas_cluster" "engine_mongodb_cluster" {
   count      = var.ENGINE_DB_TYPE == "cluster" ? 1 : 0
   depends_on = [ mongodbatlas_project.engine_mongodb_proj ]
   name       = "eng-${local.workspace}-${local.db_region}"
   project_id = mongodbatlas_project.engine_mongodb_proj.id
   provider_name               = "TENANT"
   backing_provider_name       = var.ENGINE_DB_PROVIDER
   provider_instance_size_name = var.ENGINE_DB_SIZE
   provider_region_name        = var.ENGINE_DB_REGION
}

# --- MongoDB Atlas Serverless Instance @ aws
resource "mongodbatlas_serverless_instance" "engine_mongodb_instance" {
   count      = var.ENGINE_DB_TYPE == "serverless" ? 1 : 0
   project_id = mongodbatlas_project.engine_mongodb_proj.id
   name       = "eng-${local.workspace}-${local.db_region}"

   provider_settings_backing_provider_name = "AWS"
   provider_settings_provider_name         = "SERVERLESS"
   provider_settings_region_name           = var.ENGINE_DB_REGION
}

# --- Network Access
resource "mongodbatlas_project_ip_access_list" "engine_mongodb_global_acl" {
   project_id = mongodbatlas_project.engine_mongodb_proj.id
   cidr_block = "0.0.0.0/0"
   comment    = "global access"
}

# --- Retrieve connstr
locals {
   mongodb_connstr = replace (
      var.ENGINE_DB_TYPE == "serverless"  ? mongodbatlas_serverless_instance.engine_mongodb_instance[0].connection_strings_standard_srv
                                          : mongodbatlas_cluster.engine_mongodb_cluster[0].connection_strings[0].standard_srv,
      "mongodb+srv://",
      "mongodb+srv://engine-db-user-${local.workspace}:${urlencode(random_password.db_pw.result)}@"
   )
}

# --- Create DB Client User
resource "mongodbatlas_database_user" "db_user" {
   username           = "engine-db-user-${local.workspace}"
   depends_on         = [ mongodbatlas_cluster.engine_mongodb_cluster ]
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