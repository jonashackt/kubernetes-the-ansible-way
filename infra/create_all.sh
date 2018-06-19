#!/usr/bin/env bash
set -euo pipefail

vagrant up
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook install.yml -i hosts
