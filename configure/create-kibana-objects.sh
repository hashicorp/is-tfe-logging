#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# This will create the Index Pattern, Searches, Visuals, and Dashaboards for Kibana

echo "[$(date +"%FT%T")]  Create All the things in Kibana"
curl -XPOST "http://localhost:5601/api/saved_objects/_import?overwrite=true" \
  -H "kbn-xsrf: true" \
  --form file=@all-actions.ndjson
echo