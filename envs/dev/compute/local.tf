locals {
  # VM Configuration
  vms = {
    controller = {
      name        = var.controller_vm_name
      description = "Kubernetes Master Controller Server"
      tags        = ["Controller", "Kubernetes"]
      username    = "${var.controller_vm_name}"
      password    = local.awsSecrets.CONTROLLER_PASSWORD
    },
    worker = {
      name        = var.worker_vm_name
      description = "Kubernetes worker server"
      tags        = ["Worker", "Kubernetes"]
      username    = "${var.worker_vm_name}"
      password    = local.awsSecrets.WORKER_PASSWORD
    },
    jenkins = {
      name        = var.jenkins_vm_name
      description = "Kubernetes jenkins server"
      tags        = ["Jenkins", "Kubernetes"]
      username    = "${var.jenkins_vm_name}"
      password    = local.awsSecrets.JENKINS_PASSWORD
    }
  }
  
  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Created     = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  }
  
  # SSH key paths
  ssh_key_paths = {
    controller = "${var.ssh_private_key_path}/${var.controller_vm_name}.pem"
    worker    = "${var.ssh_private_key_path}/${var.worker_vm_name}.pem"
    jenkins    = "${var.ssh_private_key_path}/${var.jenkins_vm_name}.pem"
  }
}