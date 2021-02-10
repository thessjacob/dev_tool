#!/bin/bash

echo "Do you want to roll back your current terraform config? 
This will unprovision your current environment! (yes/no): "
read decision

if [[ "$decision" == "yes" ]]; then
  cd terraform 
  terraform destroy -auto-approve
  rm terraform.tfstate
  rm terraform.tfstate.backup
  cd ..
  cp rollback/* terraform/
  rm terraform/inventory
fi
