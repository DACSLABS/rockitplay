resource "time_sleep" "edge_wait_for_tsk_bucket" {
  depends_on = [ oci_objectstorage_bucket.edge_tsk_bucket ]
  create_duration = "150s"
}

resource "null_resource" "edge_task_file" {
   depends_on = [
      oci_objectstorage_bucket.edge_tsk_bucket,
      time_sleep.edge_wait_for_tsk_bucket
   ]
   triggers = {
      always = timestamp ()
      # task_hash = var.EDGE_TASK_HASH
      # --- store destruction time data in triggers
      bucket_name = "edge-tsk-bucket-${local.workspace}"
      namespace   = var.EDGE_OCI_NAMESPACE
   }

   provisioner "local-exec" {
      interpreter = [ "/bin/bash", "-c" ]
      command = <<-EOT
         set -e
         curl -o ./edge-task.tgz ${var.EDGE_TASK_URL}
         oci os object put --bucket-name ${self.triggers.bucket_name} --name edge-task.tgz --file ./edge-task.tgz --namespace ${self.triggers.namespace}
      EOT
   }
   provisioner "local-exec" {
      when = destroy
      command = "oci os object delete --bucket-name ${self.triggers.bucket_name} --name edge-task.tgz --namespace ${self.triggers.namespace} --force || true"
   }
}