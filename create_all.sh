#!/usr/bin/env bash
set -euo pipefail

vagrant up
ansible-playbook install.yml -i hosts
ansible-playbook configure_masters.yml -i hosts
ansible-playbook configure_workers.yml -i hosts
ansible-playbook configure_clients.yml -i hosts
