#!/bin/bash
export ENVDIR=`pwd`/environment/aws/bluegreen

aws-bluegreen-init() {
  terraform -chdir=$ENVDIR init  | tee subastion.tfinit.log 2>&1
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee aws_bluegreen.tf.log 2>&1

  export VAULT_ADDR=https://localhost:8200
  export VAULT_TOKEN=$(cat $ENVDIR/vaultadmin.token)

  export SUBASTION_GREEN_KEYFILE=$HOME/.ssh/prod_green_subastion_ec2
  export SUBASTION_GREEN_IP=$(vault read -field=ip subastion/prod_green_subastion_ec2)
  
  export SUBASTION_BLUE_KEYFILE=$HOME/.ssh/prod_blue_subastion_ec2
  export SUBASTION_BLUE_IP=$(vault read -field=ip subastion/prod_blue_subastion_ec2)
}

aws-bluegreen-destroy() {
  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee aws_bluegreen.tf.log 2>&1

  docker kill vault
  docker rm vault
  rm -fr $ENVDIR/../../../docker/vault/volumes/file/*
  rm -fr $ENVDIR/../../../docker/vault/volumes/log/*
  rm -fr $ENVDIR/../../../terraform/modules/openssl && git checkout $ENVDIR/../../../terraform/modules/openssl
  
  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset SUBASTION_GREEN_KEYFILE
  unset SUBASTION_GREEN_IP
  unset SUBASTION_BLUE_KEYFILE
  unset SUBASTION_BLUE_IP
}

ssh-aws-green-subastion () { 
  ssh -i $SUBASTION_GREEN_KEYFILE ubuntu@$SUBASTION_GREEN_IP
}

ssh-aws-blue-subastion () { 
  ssh -i $SUBASTION_BLUE_KEYFILE ubuntu@$SUBASTION_BLUE_IP
}

export -f aws-bluegreen-init
export -f aws-bluegreen-destroy
export -f ssh-aws-green-subastion
export -f ssh-aws-blue-subastion