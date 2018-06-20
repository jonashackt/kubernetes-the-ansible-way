#!/usr/bin/env bash
set -euo pipefail

vagrant up
ansible-playbook install.yml -i hosts
ansible-playbook start_controllers.yml -i hosts
ansible-playbook start_workers.yml -i hosts
