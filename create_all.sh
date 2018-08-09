#!/usr/bin/env bash
set -euo pipefail

vagrant up
ansible-playbook create-certs-and-config.yml -i hosts
ansible-playbook configure-masters.yml -i hosts
ansible-playbook configure-workers.yml -i hosts
ansible-playbook configure-external-access.yml -i hosts
