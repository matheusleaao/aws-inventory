package main

import (
	"encoding/csv"
	"fmt"
	"io/ioutil"
	"log"
	"strings"

	"github.com/360EntSecGroup-Skylar/excelize"
)

func main() {
	f := excelize.NewFile()

	createSheet("EC2", "csv/ec2.csv", f)
	createSheet("Classic Load Balancer", "csv/classic-lb.csv", f)
	createSheet("Elastic LoadBalancer", "csv/elastic-lb.csv", f)
	createSheet("RDS & DocumentDB", "csv/rds.csv", f)
	createSheet("DynamoDB", "csv/dynamodb.csv", f)
	createSheet("ECS", "csv/ecs.csv", f)
	createSheet("EFS", "csv/efs.csv", f)
	createSheet("EKS", "csv/eks.csv", f)
	createSheet("Elastic BeanStalk", "csv/elastic-beanstalk.csv", f)
	createSheet("ElastiCache", "csv/elasticache.csv", f)
	createSheet("VPC", "csv/vpc.csv", f)

	f.DeleteSheet("Sheet1")

	if err := f.SaveAs("aws-inventory.xlsx"); err != nil {
		fmt.Println(err)
	}
}

func createSheet(sheetName string, csvFile string, f *excelize.File) {
	records := readCsvFile(csvFile)

	// Não executar se o arquivo .csv estiver vazio
	if len(records) == 0 {
		return
	}

	_ = f.NewSheet(sheetName)

	for i, row := range records {
		f.SetSheetRow(sheetName, fmt.Sprintf("A%d", i+1), &row)
	}
}

func readCsvFile(filename string) [][]string {
	in, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatal("Error reading file ", err)
	}

	r := csv.NewReader(strings.NewReader(string(in)))
	r.Comma = '\t'

	records, err := r.ReadAll()
	if err != nil {
		log.Fatalf("Error reading csv file %s: %s", filename, err)
	}

	return records
}
