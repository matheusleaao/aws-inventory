# AWS Inventory

Gera um arquivo excel com inventário dos recursos do cliente.
Atualmente abrange os seguintes recursos:
- EC2 - Instances
- Load Balancers
    - Classic
    - Application
- VPC
- Elastic Beanstalk
- ECS
- EKS
- RDS
- Dynamo
- DocDB
- EFS
- Elasticache

## Atenção
O projeto ainda está em uma versão alfa, e muitas coisas ainda precisam ser refatoradas. Use com cautela!

## Execução

### Pré-requisitos
- Linux
- Bash
- AWS CLI
- [golint](https://github.com/golang/lint)
- [goimports](https://godoc.org/golang.org/x/tools/cmd/goimports)

### Comandos
```
export AWS_PROFILE="profile-da-conta"
chmod +x ./dist/*

# Gerar arquivos .csv
./dist/inventory
# Gerar arquivo aws-inventory.xlsx
./dist/excel
```

### Curiosidade
Para não ter que executar o ./dist/inventory e gerar todas as planilhas de uma vez, pode-se fazer gerando uma a uma de forma mais pratica:

**Exemplo**: Para gerar apenas a planilha do RDS:
```
./scripts/run.sh rds.sh ./scripts/csv/rds.csv
```
Assim a saída sera gravada dentro da pasta /csv.

## Contribuições

### Pré requisitos
Para contribuir com o projeto é necessário ter instalado e configurado:

- Golang 1.11+
- pre-commit

Antes de começar a trabalhar no projeto, execute:
```
pre-commit install
go mod download
```

## Melhorias
- Criar planilha inteira via código ✔️
- Ajustar alinhamento das colunas, tentar deixar automático
- Não criar uma sheet se o arquivo .csv estiver vazio ✔️
- Aplicar formatação na linha que indica a região
- Ajustar módulo de VPCS
    - Tentar pegar a tag name
    - Remover campo "estado"
    - Ignorar VPCs default
- Criar arquivo binário integrado para execução sem precisar do Go
- Implementar Cobra para melhorar interface CLI
    - Adicionar parâmetros ou modo interativo
- Converter scripts sh em Go
- Criar pipeline de build com release integrada
