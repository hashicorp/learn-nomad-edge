# !/bin/bash

set -e

CONFIGDIR=/ops/config
NOMADCONFIGDIR=/etc/nomad.d
HOME_DIR=ubuntu

# Wait for network
sleep 15

DOCKER_BRIDGE_IP_ADDRESS=($(ifconfig docker0 2>/dev/null | awk '/inet addr:/ {print $2}' | sed 's/addr://'))
CLOUD=$1
SERVER_COUNT=$2
RETRY_JOIN=$3
NOMAD_BINARY=$4
IP_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# Nomad
## Replace existing Nomad binary if remote file exists
if [[ $(wget -S --spider $NOMAD_BINARY 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then
  curl -L $NOMAD_BINARY >nomad.zip
  sudo unzip -o nomad.zip -d /usr/local/bin
  sudo chmod 0755 /usr/local/bin/nomad
  sudo chown root:root /usr/local/bin/nomad
fi

sudo cp $CONFIGDIR/nomad.hcl $NOMADCONFIGDIR
sudo cp $CONFIGDIR/nomad.service /etc/systemd/system/nomad.service
sed -i "s/SERVER_COUNT/$SERVER_COUNT/g" $NOMADCONFIGDIR/nomad.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $NOMADCONFIGDIR/nomad.hcl
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $NOMADCONFIGDIR/nomad.hcl

sudo systemctl enable nomad.service
sudo systemctl start nomad.service
sleep 10
export NOMAD_ADDR=http://$IP_ADDRESS:4646

# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# Add Docker bridge network IP to /etc/resolv.conf (at the top)
echo "nameserver $DOCKER_BRIDGE_IP_ADDRESS" | sudo tee /etc/resolv.conf.new
cat /etc/resolv.conf | sudo tee --append /etc/resolv.conf.new
sudo mv /etc/resolv.conf.new /etc/resolv.conf

# # Set env vars for tool CLIs
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /home/$HOME_DIR/.bashrc
