[${terraform.workspace}Masters]
%{for index, ip in master_ips ~}
${terraform.workspace}masterNode${index} ansible_host=${ip}
%{ endfor ~}

[${terraform.workspace}Workers]
%{for index, ip in worker_ips ~}
${terraform.workspace}workerNode${index} ansible_host=${ip}
%{ endfor ~}

${~ if var.nfs>0 ~}
[${terraform.workspace}nfsServer]
${terraform.workspace}nfs ansible_host=${terraform.workspace}.cboitistcs.com

[${terraform.workspace}:children]
${terraform.workspace}Masters
${terraform.workspace}Workers
${terraform.workspace}nfsServer

[${terraform.workspace}:vars]
ansible_user= ubuntu
ansible_python_interpreter=/usr/bin/python3

[all:vars]
ansible_python_interpreter=/usr/bin/python3