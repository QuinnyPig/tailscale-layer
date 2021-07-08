#!/bin/bash -e

source regions.sh

for region in "${REGIONS[@]}"; do
  bucket_name="tailscale-layers-demo-${region}"

  echo "Creating bucket ${bucket_name}..."

  aws s3 mb s3://$bucket_name --region $region
done
