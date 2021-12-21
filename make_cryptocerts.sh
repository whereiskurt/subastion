#!/bin/bash
export ENVDIR=`pwd`/environment/cryptocerts/

mkdir log > /dev/null 2>&1

terraform -chdir=$ENVDIR init  | tee log/cryptocerts.tfinit.log 2>&1 
terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/cryptocerts.tfapply.log 2>&1
