#!/bin/bash
export ENVDIR=`pwd`/environment/aws/bluegreen

build-prod-bluegreen() {
  mkdir log > /dev/null 2>&1

  terraform -chdir=$ENVDIR init  | tee log/subastion.tfinit.log 2>&1 
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/aws_bluegreen.tf.log 2>&1

  export VAULT_ADDR=https://localhost:8200
  export VAULT_TOKEN=$(cat $ENVDIR/vaultadmin.token)

  export SUBASTION_GREEN_KEYFILE=$HOME/.ssh/prod_green_subastion_ec2
  export SUBASTION_GREEN_IP=$(vault read -field=ip subastion/prod_green_subastion_ec2)
  
  export SUBASTION_BLUE_KEYFILE=$HOME/.ssh/prod_blue_subastion_ec2
  export SUBASTION_BLUE_IP=$(vault read -field=ip subastion/prod_blue_subastion_ec2)
}

destroy-prod-bluegreen() {
  mkdir log > /dev/null 2>&1
  
  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/aws_bluegreen.tf.log 2>&1

  docker kill vault
  docker rm vault
  rm -fr $ENVDIR/../../../docker/vault/volumes/file/*
  rm -fr $ENVDIR/../../../docker/vault/volumes/log/*
  rm -fr $ENVDIR/../../../terraform/modules/openssl && git checkout $ENVDIR/../../../terraform/modules/openssl
  rm -fr $ENVDIR/../../../terraform/modules/aws && git checkout $ENVDIR/../../../terraform/modules/aws
  
  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset SUBASTION_GREEN_KEYFILE
  unset SUBASTION_GREEN_IP
  unset SUBASTION_BLUE_KEYFILE
  unset SUBASTION_BLUE_IP

  unset ssh-prod-green-subastion
  unset openvpn-prod-green-subastion
  unset ssh-prod-blue-subastion
  unset openvpn-prod-blue-subastion
}

ssh-prod-green-subastion () { 
  ssh -i $SUBASTION_GREEN_KEYFILE ubuntu@$SUBASTION_GREEN_IP
}

openvpn-prod-green-subastion () { 
  scp -i $SUBASTION_GREEN_KEYFILE ubuntu@$SUBASTION_GREEN_IP:/home/ubuntu/openvpn/prod_green_subastion.ovpn ~/.ssh/.
  chmod 600 ~/.ssh/prod_green_subastion.ovpn
  nohup openvpn ~/.ssh/prod_green_subastion.ovpn > ~/nohup.green.out &
}

ssh-prod-blue-subastion () { 
  ssh -i $SUBASTION_BLUE_KEYFILE ubuntu@$SUBASTION_BLUE_IP
}

openvpn-prod-blue-subastion () { 
  scp -i $SUBASTION_BLUE_KEYFILE ubuntu@$SUBASTION_BLUE_IP:/home/ubuntu/openvpn/prod_blue_subastion.ovpn ~/.ssh/
  chmod 600 ~/.ssh/prod_blue_subastion.ovpn
  nohup openvpn ~/.ssh/prod_blue_subastion.ovpn > ~/nohup.blue.out &
}

export -f build-prod-bluegreen
export -f destroy-prod-bluegreen

export -f ssh-prod-green-subastion
export -f openvpn-prod-green-subastion

export -f ssh-prod-blue-subastion
export -f openvpn-prod-blue-subastion
