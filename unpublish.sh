#!/bin/bash -e

LAYER_VERSION="${1}"

source regions.sh

LAYER="tailscale"
MD5SUM=$(md5 -q "${LAYER}.zip")
S3KEY="${LAYER}/${MD5SUM}"

for region in "${REGIONS[@]}"; do
  bucket_name="tailscale-layers-${region}"

  echo "Deleting Lambda Layer ${LAYER} version ${VERSION} in region ${region}..."
  aws --region $region lambda delete-layer-version --layer-name ${LAYER} --version-number $VERSION > /dev/null
  echo "Deleted Lambda Layer ${LAYER} version ${VERSION} in region ${region}"
done
