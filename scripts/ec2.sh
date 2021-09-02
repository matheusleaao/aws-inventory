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
    echo "Buscando instâncias em $region"

    instances=$(aws ec2 describe-instances --region=$region --output text --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress,ImageId,LaunchTime]'  --filter='Name=instance-state-name,Values=pending,running,stopping,stopped')

    if [ $? == 0 ] && [[ ! -z $instances ]]; then
        countInstances=$(echo -n "$instances" | wc -l)
        echo "    $countInstances instâncias encontradas"

        # @TODO: fix \t\t\t\t\...
        echo -e "$region\t\t\t\t\t\t\t\n" >> "$output"
        echo -e "Nome\tID\tEstado\tTipo de instância\tIP Privado\tIP Público\tAMI\tCriada em" >> "$output"
        echo -e "$instances\n" >> "$output"
    else
        echo "    Nenhuma instância encontrada!"
    fi
done
