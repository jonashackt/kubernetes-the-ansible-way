#!/usr/bin/env bash
set -euo pipefail

vagrant up
ansible-playbook k8s-certs-and-config.yml -i hosts
ansible-playbook k8s-master-nodes.yml -i hosts
ansible-playbook k8s-worker-nodes.yml -i hosts
ansible-playbook k8s-external-access.yml -i hosts
# or use the master playbook:
#ansible-playbook k8s.yml -i hosts