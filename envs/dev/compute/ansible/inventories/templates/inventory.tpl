
# Ansible Inventory
# Environment: ${environment}

[all:vars]
ansible_connection=ssh
ansible_python_interpreter=/usr/bin/python3
environment=${environment}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[controller]
${controller_ip} ansible_user=${controller_user} ansible_ssh_private_key_file=${controller_ssh_key_path}

[worker] 
${worker_ip} ansible_user=${worker_user} ansible_ssh_private_key_file=${worker_ssh_key_path}
${jenkins_ip} ansible_user=${jenkins_user} ansible_ssh_private_key_file=${jenkins_ssh_key_path}

[jenkins]
${jenkins_ip} ansible_user=${jenkins_user} ansible_ssh_private_key_file=${jenkins_ssh_key_path}

[k8s_cluster:children]
controller
worker

