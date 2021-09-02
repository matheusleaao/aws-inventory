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
    echo "Buscando elastic search em $region"

    for domain in $(aws es list-domain-names --region=$region --output text --query 'DomainNames[*].DomainName'); do

    instances=$(aws es describe-elasticsearch-domain --region=$region --domain-name $domain --output text --query 'DomainStatus.[DomainId,DomainName,Endpoint,ElasticsearchVersion]')

    if [ $? == 0 ] && [[ ! -z $instances ]]; then
        countInstances=$(echo -n "$instances" | wc -l)
        echo "    $countInstances elastic search encontrados"

        # @TODO: fix \t\t\t\t\...
        echo -e "$region\t\t\t\t\t\t\t\n" >> "$output"
        echo -e "ID\tDomainName\tEndpoint\tElasticsearchVersion" >> "$output"
        echo -e "$instances\n" >> "$output"
    else
        echo "    Nenhum elastic search encontrado!"
    fi
    done
done
