#!/bin/bash
export ENVDIR=`pwd`/environment/prod

subastion-init() {
  terraform -chdir=$ENVDIR init  | tee subastion.tfinit.log 2>&1
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee subastion.tfrun.log 2>&1

  export VAULT_ADDR=https://localhost:8200
  export VAULT_TOKEN=$(cat $ENVDIR/vaultadmin.token)

  export SUBASTION_GREEN_KEYFILE=$HOME/.ssh/subastion.green.key
  export SUBASTION_GREEN_IP=$(vault read -field=ip subastion/prod_green_subastion_ec2)
  
  export SUBASTION_BLUE_KEYFILE=$HOME/.ssh/subastion.blue.key
  export SUBASTION_BLUE_IP=$(vault read -field=ip subastion/prod_blue_subastion_ec2)
}

subastion-destroy() {
  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee subastion.tfrun.log 2>&1

  docker kill vault
  docker rm vault
  rm -fr $ENVDIR/../../docker/vault/volumes/file/*
  rm -fr $ENVDIR/../../docker/vault/volumes/log/*
  rm -fr $ENVDIR/../../terraform/modules/openssl && git checkout $ENVDIR/../../terraform/modules/openssl
  
  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset SUBASTION_GREEN_KEYFILE
  unset SUBASTION_GREEN_IP
  unset SUBASTION_BLUE_KEYFILE
  unset SUBASTION_BLUE_IP
}

subastion-green-ssh () { 
  vault read -field=pem subastion/prod_green_subastion_ec2 | base64 -d > $SUBASTION_GREEN_KEYFILE
  chmod 400 $SUBASTION_GREEN_KEYFILE
  ssh -i $SUBASTION_GREEN_KEYFILE ubuntu@$SUBASTION_GREEN_IP
  rm -f $SUBASTION_GREEN_KEYFILE
}

subastion-blue-ssh () { 
  vault read -field=pem subastion/prod_blue_subastion_ec2 | base64 -d > $SUBASTION_BLUE_KEYFILE
  chmod 400 $SUBASTION_BLUE_KEYFILE
  ssh -i $SUBASTION_BLUE_KEYFILE ubuntu@$SUBASTION_BLUE_IP
  rm -f $SUBASTION_BLUE_KEYFILE
}


export -f subastion-init
export -f subastion-green-ssh
export -f subastion-blue-ssh
export -f subastion-destroy
