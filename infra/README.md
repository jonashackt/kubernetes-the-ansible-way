# Infrastructure

Based on Vagrant

## Prerequisites


```bash
bash prepare.mac.bash
#or
bash prepare.arch.bash
#and
vagrant up
```


## Commands

````bash

ansible --private-key=$(pwd)/.vagrant/machines/client-0/virtualbox/private_key client -i hosts -u vagrant -m setup

# kube api server health checks
curl --cacert certificates/ca.pem --key certificates/admin-key.pem --cert certificates/admin.pem https://client-0.k8s:6443/healthz

```
