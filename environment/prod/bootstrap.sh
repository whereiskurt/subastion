#!/bin/bash

bastion-build() {
  terraform init | tee tfinit.txt 2>&1
  terraform apply -no-color -auto-approve | tee tfrun.txt 2>&1

  export VAULT_ADDR=https://localhost:8200
  export VAULT_TOKEN=$(cat admin.token)
  vault status

  export SUBASTION_KEYFILE=$(pwd)/bastion.key
  export SUBASTION_IP=$(vault read -field=ip subastion/ec2host)
  ssh-keyscan -H $SUBASTION_IP >> ~/.ssh/known_hosts
}

bastion-reset() {
  terraform destroy -no-color -auto-approve | tee tfrun.txt 2>&1
  docker kill vault
  docker rm vault
  cd ../../modules/ && rm -fr openssl && git checkout openssl
  cd -
}

bastion-ssh () {
  vault read -field=pem subastion/ec2host|base64 -d > $SUBASTION_KEYFILE
  chmod 400 $SUBASTION_KEYFILE
  ssh -i $SUBASTION_KEYFILE ubuntu@$SUBASTION_IP
  rm -f $SUBASTION_KEYFILE
}

export -f bastion-build
export -f bastion-ssh
export -f bastion-reset

