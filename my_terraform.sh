#!/bin/bash

ansible=$(ansible --version 2>/dev/null| wc -l)
if (( $ansible == 0 )); then
  echo "Please ensure that ansible is installed!"
  exit 1
fi

aws=$(aws --version 2>/dev/null| wc -l)
if (( $aws == 0)); then
  echo "Please ensure that the aws-cli is installed and you have run through initial configuration!"
  exit 1
fi

if [ ! -d .ssh ]; then
  mkdir .ssh
fi

if [ ! -f .ssh/id_rsa_dev_tool.pub ]; then
  ssh-keygen -q -t rsa -N '' -f .ssh/id_rsa_dev_tool <<<y 2>&1 >/dev/null
  key=$(cat .ssh/id_rsa_dev_tool.pub)
  echo "my_key_value = \"$key\"" >> terraform/terraform.tfvars
  cp terraform/terraform.tfvars rollback/
fi

tag1=$1
tag2=$2
tag3=$3
tag4=$4
tag5=$5
tag6=$6

state=$(terraform --version | grep "Terraform")
if [[ -z $state ]]; then

  sudo yum install yum-utils -y
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  sudo yum install terraform -y
fi

cd terraform/
state=$(terraform show | wc -l)
if [[ $state -ge 2 ]]; then
  terraform apply -auto-approve
else
  terraform init
  terraform apply -auto-approve
fi

ip1=$(terraform output instance1_ip | sed 's/"//g')
ip2=$(terraform output instance2_ip | sed 's/"//g')

cd ..
cp -f rollback/inventory inventory
sed -i "/\[public\]/a $ip1" inventory
sed -i "/\[private\]/a $ip2" inventory

echo "Waiting 30 seconds to allow intances to come up before configuring"
sleep 30
ansible-playbook playbook.yml -i inventory --tags "$1,$2,$3,$4,$5,$6"

cd terraform 
terraform apply -auto-approve