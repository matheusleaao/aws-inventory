#!/usr/bin/env bash

output="/dev/stdout"

while test $# -gt 0
do
    case "$1" in
        --regions=*) regions=${1/--regions=/}
            regions=${regions//,/ }
            ;;
        -o=*|--output=*) output=${1/--output=/}
            output=${output/-o=/}
            ;;
        -*|--*) echo "Opção $1 desconhecida"
            ;;
        *)
            ;;
    esac
    shift
done

if [ -z "$regions" ]; then
    echo "Utilização: $0 --regions=us-east-1,sa-east-1"
    return 1
fi

echo "Regiões: $regions"
echo "Canal de saída: $output"
echo ""

echo -n "" > $output

for region in $regions; do
    echo "Buscando ebs em $region"

    instances=$(aws ec2 describe-volumes --region=$region --output text --query 'Volumes[*].[Tags[?Key==`Name`].Value|[0],VolumeId,Size,VolumeType,Iops,SnapshotId,CreateTime,AvailabilityZone,State,Attachments[0].InstanceId,Encrypted,MultiAttachEnabled]')

    if [ $? == 0 ] && [[ ! -z $instances ]]; then
        countInstances=$(echo -n "$instances" | wc -l)
        echo "    $countInstances ebs encontrados"

        # @TODO: fix \t\t\t\t\...
        echo -e "$region\t\t\t\t\t\t\t\n" >> "$output"
        echo -e "Nome\tVolume ID\tSize\tVolume Type\tIOPS\tSnapshot\tCreated\tAvailability Zone\tState\tAttachment Information\tEncryption\tMultiAttachEnabled" >> "$output"
        echo -e "$instances\n" >> "$output"
    else
        echo "    Nenhum ebs encontrado!"
    fi
done
