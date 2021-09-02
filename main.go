package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

const allRegions = "sa-east-1,us-east-1,us-east-2,us-west-1,us-west-2,eu-north-1,eu-west-1,eu-west-2,eu-west-3,eu-central-1,ap-south-1,ap-northeast-1,ap-northeast-2,ap-southeast-1,ap-southeast-2,ca-central-1"

func main() {
	chmodScripts()
	CreateInventories()
}

func chmodScripts() {
	scripts, err := filepath.Glob(GetCurrentDir() + "/scripts/*.sh")
	if err != nil {
		log.Fatal("Erro", err)
	}

	chmodArgs := []string{"+x"}
	chmodArgs = append(chmodArgs, scripts...)

	RunCommand("chmod", chmodArgs...)
}

func GetCurrentDir() string {
	dir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	return dir
}

func RunCommand(command string, args ...string) {
	cmd := exec.Command(
		command,
		args...,
	)

	var out io.Reader
	{
		stdout, err := cmd.StdoutPipe()
		if err != nil {
			log.Fatal(err)
		}
		stderr, err := cmd.StderrPipe()
		if err != nil {
			log.Fatal(err)
		}
		out = io.MultiReader(stdout, stderr)
	}

	if err := cmd.Start(); err != nil {
		log.Fatal(err)
	}

	defer cmd.Process.Kill()

	s := bufio.NewScanner(out)
	for s.Scan() {
		fmt.Println(s.Text())
	}
}

func CreateInventories() {
	currDir := GetCurrentDir()

	CreateInventoryCsv(currDir+"/scripts/classic-lb.sh", "csv/classic-lb.csv")
	CreateInventoryCsv(currDir+"/scripts/elastic-lb.sh", "csv/elastic-lb.csv")
	CreateInventoryCsv(currDir+"/scripts/dynamodb.sh", "csv/dynamodb.csv")
	CreateInventoryCsv(currDir+"/scripts/ec2.sh", "csv/ec2.csv")
	CreateInventoryCsv(currDir+"/scripts/ecs.sh", "csv/ecs.csv")
	CreateInventoryCsv(currDir+"/scripts/efs.sh", "csv/efs.csv")
	CreateInventoryCsv(currDir+"/scripts/eks.sh", "csv/eks.csv")
	CreateInventoryCsv(currDir+"/scripts/elastic-beanstalk.sh", "csv/elastic-beanstalk.csv")
	CreateInventoryCsv(currDir+"/scripts/elasticache.sh", "csv/elasticache.csv")
	CreateInventoryCsv(currDir+"/scripts/rds.sh", "csv/rds.csv")
	CreateInventoryCsv(currDir+"/scripts/vpc.sh", "csv/vpc.csv")
	CreateInventoryCsv(currDir+"/scripts/directconnect.sh", "csv/directconnect.csv")
	CreateInventoryCsv(currDir+"/scripts/ec2-ebs.sh", "csv/ec2-ebs.csv")
	CreateInventoryCsv(currDir+"/scripts/ec2-snaps.sh", "csv/ec2-snaps.csv")
	CreateInventoryCsv(currDir+"/scripts/eip.sh", "csv/eip.csv")
	CreateInventoryCsv(currDir+"/scripts/es.sh", "csv/es.csv")
	CreateInventoryCsv(currDir+"/scripts/nat-gateway.sh", "csv/nat-gateway.csv")
}

func CreateInventoryCsv(script string, outFile string) {
	RunCommand(
		script,
		fmt.Sprintf("--regions=%s", allRegions),
		fmt.Sprintf("-o=%s", outFile),
	)
}
