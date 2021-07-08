#!/bin/bash -e
REGIONS=$(aws ec2 describe-regions \
    --all-regions \
    --query "Regions[].{Name:RegionName}" \
    --output text)
    
cat << EOF > ./regions.sh
REGIONS=(
$REGIONS
)
EOF
chmod +x regions.sh
