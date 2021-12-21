#!/bin/bash
export ENVDIR=`pwd`/environment/dockervault/

mkdir log > /dev/null 2>&1

terraform -chdir=$ENVDIR init  | tee log/dockervault.tfinit.log 2>&1 
terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/dockervault.tfapply.log 2>&1
