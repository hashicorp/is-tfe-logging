#!/bin/bash

set -e -u -o pipefail

echo "[$(date +"%FT%T")]  Updating and Installing Software (docker and docker-compose)"
apt-get update
apt-get install -y docker.io
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
systemctl enable docker
systemctl start docker

echo "[$(date +"%FT%T")]  Checking out TFE ELK code"
mkdir -p /home/ubuntu/tfe-elk && cd /home/ubuntu/tfe-elk
git clone --single-branch --branch ${branch} ${repo} .

cd configure
echo "[$(date +"%FT%T")]  Start and Configure ELK"
./setup-elk.sh

echo "[$(date +"%FT%T")]  Create Kibana Objects"
./create-kibana-objects.sh