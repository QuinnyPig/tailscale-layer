#!/bin/bash -e

source regions.sh


LAYER="tailscale"
MD5SUM=$(md5 -q "${LAYER}.zip")
S3KEY="${LAYER}/${MD5SUM}"

for region in "${REGIONS[@]}"; do
  bucket_name="tailscale-layers-${region}"

  echo "Uploading ${LAYER}.zip to s3://${bucket_name}/${S3KEY}"

  aws --region $region s3 cp ${LAYER}.zip "s3://${bucket_name}/${S3KEY}"
done
