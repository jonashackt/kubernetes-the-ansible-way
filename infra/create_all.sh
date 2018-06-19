#!/usr/bin/env bash
set -euo pipefail

vagrant up
ansible-playbook install.yml -i hosts
