
# Ansible Inventory
# Environment: ${environment}

[all:vars]
ansible_connection=ssh
ansible_python_interpreter=/usr/bin/python3
environment=${environment}
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[dynamodb]
${dynamodb_ip} ansible_user=${dynamodb_user}

[mysql] 
${mysql_ip} ansible_user=${mysql_user}

[database:children]
dynamodb
mysql

