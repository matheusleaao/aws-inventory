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

QUERY="sort_by(DBInstances, &Engine)[*].[DBInstanceIdentifier,Endpoint.Address,MasterUsername,Engine,EngineVersion,DBInstanceClass,StorageType,AllocatedStorage,Iops,BackupRetentionPeriod]"
FIELDS="Nome\tEndpoint\tUsuário Master\tEngine\tVersão\tTipo instância\tTipo Armaz.\tStorage (GB)\tIOPS Prov.\tRetenção Bkp (dias)"

for region in $regions; do
    echo "Buscando recursos em $region"

    instances=$(aws rds describe-db-instances --region=$region --output text --query "$QUERY")

    if [ $? == 0 ] && [[ ! -z $instances ]]; then
        countInstances=$(echo -n "$instances" | wc -l)
        echo "    $countInstances recursos encontrados"

        # @TODO: fix \t\t\t\t\...
        echo -e "$region\t\t\t\t\t\t\t\t\t\n" >> "$output"
        echo -e "$FIELDS" >> "$output"
        echo -e "$instances\n" >> "$output"
    else
        echo "    Nenhuma instância encontrada!"
    fi
done
