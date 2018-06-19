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

```