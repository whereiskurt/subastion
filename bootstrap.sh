#!/bin/bash

export ENVDIR=`pwd`/environment/golden

subastion-init() {
  cd $ENVDIR
  terraform init | tee subastion.tfinit.log 2>&1
  terraform apply -no-color -auto-approve | tee subastion.tfrun.log 2>&1

  export VAULT_ADDR=https://localhost:8200
  export VAULT_TOKEN=$(cat vaultadmin.token)
  export SUBASTION_KEYFILE=$(pwd)/bastion.key
  export SUBASTION_IP=$(vault read -field=ip subastion/ec2host)
  cd - 
}

subastion-destroy() {
  cd $ENVDIR
  terraform destroy -no-color -auto-approve | tee subastion.tfrun.log 2>&1

  docker kill vault
  docker rm vault
  rm -fr ../../docker/vault/volumes/file/*
  rm -fr ../../docker/vault/volumes/log/*
  rm -fr ../../terraform/modules/openssl && git checkout ../../terraform/modules/openssl
  
  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset SUBASTION_KEYFILE
  unset SUBASTION_IP
  cd -
}

subastion-ssh () {
  cd $ENVDIR
  #Looked at various ways to pipe in ssh avoiding the file
  #but wasn't able to. Even the fifo wasn't working for me.
  vault read -field=pem subastion/ec2host|base64 -d > $SUBASTION_KEYFILE
  chmod 400 $SUBASTION_KEYFILE
  ssh -i $SUBASTION_KEYFILE ubuntu@$SUBASTION_IP
  rm -f $SUBASTION_KEYFILE
  cd -
}

export -f subastion-init
export -f subastion-destroy
export -f subastion-ssh