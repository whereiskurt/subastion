#!/bin/bash

export ENVDIR=`pwd`/environment/prod

subastion-init() {
  terraform -chdir=$ENVDIR init  | tee subastion.tfinit.log 2>&1
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee subastion.tfrun.log 2>&1

  export VAULT_ADDR=https://localhost:8200
  export VAULT_TOKEN=$(cat $ENVDIR/vaultadmin.token)
  export SUBASTION_KEYFILE=$HOME/.ssh/bastion.key
  export SUBASTION_IP=$(vault read -field=ip subastion/ec2host)
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
  unset SUBASTION_KEYFILE
  unset SUBASTION_IP
}

subastion-ssh () { 
  #Looked at various ways to pipe in ssh avoiding the file
  #but wasn't able to. Even the fifo wasn't working for me.
  vault read -field=pem subastion/ec2host|base64 -d > $SUBASTION_KEYFILE
  chmod 400 $SUBASTION_KEYFILE
  ssh -i $SUBASTION_KEYFILE ubuntu@$SUBASTION_IP
  rm -f $SUBASTION_KEYFILE
}

export -f subastion-init
export -f subastion-destroy
export -f subastion-ssh
