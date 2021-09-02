#!/usr/bin/env bash

output="/dev/stdout"

while test $# -gt 0
do
    case "$1" in
        --regions=*) regions=${1/--regions=/}
            regions=${regions//,/ }
            ;;
        -o=*|--output=*) output=${1/--output=/}
            output=${1/-o=/}
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
    exit 1
fi

echo "Regiões: $regions"
echo "Canal de saída: $output"
echo ""

echo -n "" > $output

QUERY="cluster.[name,version,endpoint,createdAt]"
FIELDS="Nome\tVersão K8S\tEndpoint\tCriado em"

for region in $regions; do
    echo "Buscando recursos em $region"

    clusters=$(aws eks list-clusters --region=$region --query='clusters[*]' --output text)

    if [ $? == 0 ] && [[ ! -z $clusters ]]; then
        countInstances=$(echo -n "$clusters" | wc -l)
        echo "    $countInstances recursos encontrados"

        clusterInfo=""
        for cluster in $clusters; do
            clusterInfo=$(echo -e "$clusterInfo" && aws eks describe-cluster --region=$region --name="$cluster" --query="$QUERY" --output text)
        done

        # @TODO: fix \t\t\t\t\...
        echo -e "$region\t\t\t\n" >> "$output"
        echo -e "$FIELDS" >> "$output"
        echo -e "$clusterInfo\n" >> "$output"
    else
        echo "    Nenhuma instância encontrada!"
    fi
done
