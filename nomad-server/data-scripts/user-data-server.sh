#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/scripts/server.sh "aws" "${server_count}" "${retry_join}" "${nomad_binary}"

ACL_DIRECTORY="/ops/config"

sudo systemctl restart nomad

# Wait for nomad servers to come up
sleep 30

# Bootstrap nomad ACLs
# export NOMAD_BOOTSTRAP_TOKEN=$(nomad acl bootstrap | grep -i secret | awk -F '=' '{print $2}')
# nomad acl policy apply -token $NOMAD_BOOTSTRAP_TOKEN -description "Policy to allow reading of agents and nodes and listing and submitting jobs in all namespaces." node-read-job-submit $ACL_DIRECTORY/nomad-acl-user.hcl
# nomad acl token create -token $NOMAD_BOOTSTRAP_TOKEN -name "read-token" -policy node-read-job-submit | grep -i secret | awk -F "=" '{print $2}'
