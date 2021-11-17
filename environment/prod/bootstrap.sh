#!/bin/bash

subastion-init() {
  terraform init | tee subastion.tfinit.log 2>&1
  terraform apply -no-color -auto-approve | tee subastion.tfrun.log 2>&1

  export VAULT_ADDR=https://localhost:8200
  export VAULT_TOKEN=$(cat admin.token)
  export SUBASTION_KEYFILE=$(pwd)/bastion.key
  export SUBASTION_IP=$(vault read -field=ip subastion/ec2host)

  sleep 5 ##Waiting for ssh'd to come-up
  ssh-keyscan -H $SUBASTION_IP >> ~/.ssh/known_hosts

}

subastion-destroy() {
  terraform destroy -no-color -auto-approve | tee subastion.tfrun.log 2>&1
  docker kill vault
  docker rm vault
  rm -fr ../../docker/vault/volumes/file/*
  rm -fr ../../docker/vault/volumes/log/*
  rm -fr ../../modules/openssl && git checkout ../../modules/openssl
  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset SUBASTION_KEYFILE
  unset SUBASTION_IP
}

subastion-ssh () {
  vault read -field=pem subastion/ec2host|base64 -d > $SUBASTION_KEYFILE
  chmod 400 $SUBASTION_KEYFILE
  ssh -i $SUBASTION_KEYFILE ubuntu@$SUBASTION_IP
  rm -f $SUBASTION_KEYFILE
}

export -f subastion-init
export -f subastion-destroy
export -f subastion-ssh

