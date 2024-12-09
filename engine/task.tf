resource "time_sleep" "wait_for_tsk_bucket" {
  depends_on = [ oci_objectstorage_bucket.tsk_bucket ]
  create_duration = "150s"
}

resource "null_resource" "engine_task_file" {
   depends_on = [
      oci_objectstorage_bucket.tsk_bucket,
      time_sleep.wait_for_tsk_bucket
   ]
   triggers = {
      always = timestamp ()
      # task_hash = var.ENGINE_TASK_HASH
      # --- store destruction time data in triggers
      bucket_name = "engine-tsk-bucket-${local.workspace}"
      namespace   = var.ENGINE_OCI_NAMESPACE
   }

   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         curl -o ./engine-task.tgz ${var.ENGINE_TASK_URL}
         oci os object put --bucket-name ${self.triggers.bucket_name} --name engine-task.tgz --file ./engine-task.tgz --namespace ${self.triggers.namespace}
      EOT
   }
   provisioner "local-exec" {
      when = destroy
      command = "oci os object delete --bucket-name ${self.triggers.bucket_name} --name engine-task.tgz --namespace ${self.triggers.namespace} --force || true"
   }
}