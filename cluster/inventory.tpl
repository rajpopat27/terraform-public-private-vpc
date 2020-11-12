[${clusterName}Masters]
%{for index, ip in master_ips ~}
${clusterName}masterNode${index} ansible_host=${ip}
%{ endfor ~}

[${clusterName}Workers]
%{for index, ip in worker_ips ~}
${clusterName}workerNode${index} ansible_host=${ip}
%{ endfor ~}

%{~ if nfs>0 ~}
[${clusterName}nfsServer]
${clusterName}nfs ansible_host=${clusterName}.cboitistcs.com
%{ endif  }

[${clusterName}:children]
${clusterName}Masters
${clusterName}Workers
${clusterName}nfsServer

[${clusterName}:vars]
ansible_user= ubuntu
ansible_python_interpreter=/usr/bin/python3

[all:vars]
ansible_python_interpreter=/usr/bin/python3