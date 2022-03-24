#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/scripts/client.sh "aws" "" "${nomad_binary}"

NOMAD_HCL_PATH="/etc/nomad.d/nomad.hcl"

sed -i 's/RETRY_JOIN/${servers}/g' $NOMAD_HCL_PATH

# Place the AWS instance name as metadata on the client for targetting workloads
AWS_SERVER_TAG_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/Name)
sed -i "s/SERVER_NAME/$AWS_SERVER_TAG_NAME/g" $NOMAD_HCL_PATH

# Put targeted nodes in a different datacenter and add service_client meta tag
if [[ $AWS_SERVER_TAG_NAME =~ "targeted" ]]; then
    sed -i "s/DATACENTER/${targeted_dc}/g" $NOMAD_HCL_PATH
    sed -i "s/SERVICE_CLIENT/payments/g" $NOMAD_HCL_PATH
else
    sed -i "s/DATACENTER/${dc}/g" $NOMAD_HCL_PATH
    sed -i "s/SERVICE_CLIENT/api/g" $NOMAD_HCL_PATH
fi

# Wait for nomad servers to come up
sleep 15
source ~/.bashrc
sudo systemctl restart nomad
