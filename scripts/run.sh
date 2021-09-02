#!/usr/bin/env bash

ALL_REGIONS="us-east-1,sa-east-1,us-east-2,us-west-1,us-west-2,eu-north-1,eu-west-1,eu-west-2,eu-west-3,eu-central-1,ap-south-1,ap-northeast-1,ap-northeast-2,ap-southeast-1,ap-southeast-2,ca-central-1"

if [ ! -z "$1" ]; then
    if [ ! -z "$2" ]; then
        OUTPUT="$2"
    fi

    bash "$1"  --regions="$ALL_REGIONS" -o=${OUTPUT:-"/dev/stdout"}
    exit 0
fi

bash "ec2/instance.sh"  --regions="$ALL_REGIONS" --output=${OUTPUT:-"csv/ec2-instances.csv"}
bash "ec2/reserved.sh"  --regions="$ALL_REGIONS" --output=${OUTPUT:-"csv/ec2-reserved.csv"}

bash "lb/classic.sh"    --regions="$ALL_REGIONS" --output=${OUTPUT:-"csv/lb-classic.csv"}
bash "lb/elastic.sh"    --regions="$ALL_REGIONS" --output=${OUTPUT:-"csv/lb-elastic.csv"}
