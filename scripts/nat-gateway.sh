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
    echo "Buscando nat gateways em $region"

    instances=$(aws ec2 describe-nat-gateways --region=$region --output text --query 'NatGateways[*].[Tags[?Key==`Name`].Value|[0],NatGatewayId,State,NatGatewayAddresses[0].PublicIp,NatGatewayAddresses[0].PrivateIp,NatGatewayAddresses[0].NetworkInterfaceId,VpcId,SubnetId,CreateTime]')

    if [ $? == 0 ] && [[ ! -z $instances ]]; then
        countInstances=$(echo -n "$instances" | wc -l)
        echo "    $countInstances nat gateways encontrados"

        # @TODO: fix \t\t\t\t\...
        echo -e "$region\t\t\t\t\t\t\t\n" >> "$output"
        echo -e "Nome\tNatGatewayId\tState\tPublicIp\tPrivateIp\tNetworkInterfaceId\tVpcId\tSubnetId\tCreateTime" >> "$output"
        echo -e "$instances\n" >> "$output"
    else
        echo "    Nenhuma nat gateways encontrado!"
    fi
done
