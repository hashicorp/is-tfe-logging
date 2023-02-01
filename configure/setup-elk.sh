#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# This script will wait for Kibana to be ready then do the initial boostrapping
# to get Elastic Search to use our TFE Pipeline

echo "[$(date +"%FT%T")]  Starting ELK Stack"
docker-compose -f ../files/docker-compose.yml up -d
echo

echo "[$(date +"%FT%T")]  Start Polling for Kibana to become healthy"
while ! curl -ksfS --connect-timeout 5 http://localhost:5601; do
  sleep 5
done
echo "[$(date +"%FT%T")]  Kibana is now healthy and reachable"
echo

echo "[$(date +"%FT%T")]  Create TFE pipeline in Elastic Search"
curl -XPUT "http://localhost:9200/_ingest/pipeline/tfe_pipeline" \
  -H 'Content-Type: application/json' \
  -d @tfe-pipeline.json
echo

echo "[$(date +"%FT%T")]  Assign TFE pipeline to index in Elastic Search"
curl -XPUT "http://localhost:9200/fluentd-tfe/_settings" \
  -H 'Content-Type: application/json' \
  -d'{ "index": { "default_pipeline": "tfe_pipeline" } }'
echo

cd ..
