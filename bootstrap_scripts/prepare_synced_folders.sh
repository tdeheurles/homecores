#!/bin/bash

. ./config.sh

cat <<EOF  > auto_generated/vagrant_synced_folders.yaml
- name: default
  source: $current_project_folder
  destination: $project_folder
  nfs: true
  mount_options: 'nolock,vers=3,udp,noatime'
  disabled: false
EOF
