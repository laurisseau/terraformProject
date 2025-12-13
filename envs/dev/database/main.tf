terraform {
  backend "s3" {
    bucket = "dev-tf-state-bucket-ideeqrm7"
    key = "db-infra/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Data source to retrieve the secret
data "aws_secretsmanager_secret" "aws_secretname" {
  name = "sportsify-dev-secrets"
}

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = data.aws_secretsmanager_secret.aws_secretname.id
}

locals {
  awsSecrets = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
}

provider "proxmox" {
  endpoint   = "https://pve.ngrok.app/"
  api_token  = local.awsSecrets.PROXMOX_API_TOKEN
  insecure   = true  
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "dynamodb"
}

# Generate SSH key pair dynamically
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local Windows SSH directory
resource "local_file" "vm_private_key" {
  filename = "/home/reso/.ssh/${var.vm_name}.pem"
  content  = tls_private_key.vm_ssh.private_key_pem
  file_permission = "0600"
}


# Create a new VM by cloning from template
resource "proxmox_virtual_environment_vm" "dynamodb" {
  name        = var.vm_name
  description = "DynamoDB Cloned from template-vm"
  tags        = ["ubuntu", "dynamoDB", "terraform", "production"]
  node_name   = "pve"

  # Clone configuration
  clone {
    vm_id     = 9000    # Your template VM ID
    node_name = "pve"   # Same node as template
    retries   = 2       # Better to have 2-3 retries
  }

  # CPU configuration
  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  # Memory configuration
  memory {
    dedicated = 2048  # 2GB RAM
  }

  disk {
    interface    = "scsi0"
    datastore_id = "local-lvm"
    size         = 40
  }

  # Network interface
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Cloud-Init configuration
  initialization {
    datastore_id = "local-lvm"
    
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = var.vm_name
      password = local.awsSecrets.DYNAMODB_PASSWORD
      keys     = [tls_private_key.vm_ssh.public_key_openssh]
    }
  }

  # Add agent for better integration
  agent {
    enabled = true
    trim    = true
    type    = "virtio"
  }

  # Add lifecycle to ignore certain changes
  lifecycle {
    ignore_changes = [
      clone[0].vm_id,  # Don't recreate if template ID changes
      disk,  
      tags,
      initialization[0].user_account[0].keys          
    ]
  }

  provisioner "local-exec" {
  command = <<EOT
cat > ${path.module}/ansible/inventories/production.ini <<EOF
[all:vars]
ansible_connection=ssh
ansible_user=${var.vm_name}
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[production]
${self.ipv4_addresses[1][0]}

[dynamodb]
${self.ipv4_addresses[1][0]}
EOF

echo "Waiting for VM to boot..."
sleep 45

cd ${path.module}/ansible

ansible-playbook \
  -i inventories/production.ini \
  -u ${var.vm_name} \
  --private-key ~/.ssh/${var.vm_name}.pem \
  playbooks/setup-dynamodb.yml \
  --vault-password-file ./get-vault-pass.sh
"
EOT

  environment = {
    ANSIBLE_HOST_KEY_CHECKING = "False"
  }
  }

}

# Output the private key (store securely!)
output "ssh_private_key" {
  value     = tls_private_key.vm_ssh.private_key_pem
  sensitive = true
}

output "ssh_public_key" {
  value = tls_private_key.vm_ssh.public_key_openssh
}

output "ssh_connection" {
  value = "ssh -i ssh-keys/${var.vm_name}.pem ${var.vm_name}@${proxmox_virtual_environment_vm.dynamodb.ipv4_addresses[1][0]}"
}

# Output VM connection info
output "vm_info" {
  value = {
    name     = proxmox_virtual_environment_vm.dynamodb.name
    id       = proxmox_virtual_environment_vm.dynamodb.id
    node     = proxmox_virtual_environment_vm.dynamodb.node_name
    ip       = proxmox_virtual_environment_vm.dynamodb.ipv4_addresses[1][0]
  }
}