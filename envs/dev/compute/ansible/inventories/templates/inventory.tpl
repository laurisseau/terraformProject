
# Ansible Inventory
# Environment: ${environment}

[all:vars]
ansible_connection=ssh
ansible_python_interpreter=/usr/bin/python3
environment=${environment}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[controller]
${controller_ip} ansible_user=${controller_user}

[worker] 
${worker_ip} ansible_user=${worker_user}

[k8s_cluster:children]
controller
worker

