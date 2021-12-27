#!/bin/bash
export AWS_KMS_KEY_ID="edac385f-c393-4e9c-aab7-808e1bc3c899"
export AWS_KMS_KEY_ALIAS="orchestration"
export AWS_ACCESS_KEY_ID=`aws configure get default.aws_access_key_id`
export AWS_SECRET_ACCESS_KEY=`aws configure get default.aws_secret_access_key`

export TF_VAR_aws_kms_key_id=$AWS_KMS_KEY_ID
export TF_VAR_aws_kms_key_alias=$AWS_KMS_KEY_ALIAS
export TF_VAR_build_nat_gateway=false

export TF_VAR_vault_addr="https://localhost:8200"
export TF_VAR_vault_cacert="../../../terraform/modules/openssl/ca.ica.pem"

ssh-prod-green-subastion () { 
  ssh -i $SUBASTION_GREEN_KEYFILE ubuntu@$SUBASTION_GREEN_IP
}

openvpn-prod-green-subastion () { 
  scp -i $SUBASTION_GREEN_KEYFILE ubuntu@$SUBASTION_GREEN_IP:/home/ubuntu/openvpn/prod_green_subastion.ovpn ~/.ssh/ && \
  chmod 600 ~/.ssh/prod_green_subastion.ovpn && \
  OVPN=$HOME && \
  sudo sh -c "nohup openvpn --redirect-gateway autolocal --config $OVPN/.ssh/prod_green_subastion.ovpn > ~/nohup.green.out 2>&1 &"
}

ssh-prod-blue-subastion () { 
  ssh -i $SUBASTION_BLUE_KEYFILE ubuntu@$SUBASTION_BLUE_IP
}

openvpn-prod-blue-subastion () { 
  scp -i $SUBASTION_BLUE_KEYFILE ubuntu@$SUBASTION_BLUE_IP:/home/ubuntu/openvpn/prod_blue_subastion.ovpn ~/.ssh/ && \
  chmod 600 ~/.ssh/prod_blue_subastion.ovpn && \
  OVPN=$HOME && \
  sudo sh -c "nohup openvpn --redirect-gateway autolocal --config $OVPN/.ssh/prod_blue_subastion.ovpn > ~/nohup.blue.out 2>&1 &"
}

destroy-prod-bluegreen() {
  ENVDIR=`pwd`/environment/aws/bluegreen

  mkdir log > /dev/null 2>&1
  
  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/aws_bluegreen.tfdestroy.log 2>&1

  rm -fr $ENVDIR/terraform.tfstate*
  rm -fr $ENVDIR/.terraform.lock.hcl

  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset SUBASTION_GREEN_KEYFILE
  unset SUBASTION_GREEN_IP
  unset SUBASTION_BLUE_KEYFILE
  unset SUBASTION_BLUE_IP
}

build-prod-bluegreen() {
  ENVDIR=`pwd`/environment/aws/bluegreen
  
  mkdir log > /dev/null 2>&1

  terraform -chdir=$ENVDIR init  | tee log/aws_bluegreen.tfinit.log 2>&1 
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/aws_bluegreen.tfapply.log 2>&1

  export VAULT_ADDR=$TF_VAR_vault_addr
  export VAULT_TOKEN=`cat environment/dockervault/vaultadmin.token`
  export VAULT_CACERT=`pwd`/terraform/modules/dockervault/vault.cert.pem
  export SUBASTION_GREEN_KEYFILE=$HOME/.ssh/prod_green_subastion_ec2
  export SUBASTION_GREEN_IP=`vault read -field=ip subastion/prod_green_subastion_ec2`
  export SUBASTION_BLUE_KEYFILE=$HOME/.ssh/prod_blue_subastion_ec2
  export SUBASTION_BLUE_IP=`vault read -field=ip subastion/prod_blue_subastion_ec2`

  ##This file can be sourced later reset the environment variables from ssh-prod* openvpn-prod*
  cat << EOF > bluegreen.env
#!/bin/bash
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$VAULT_TOKEN
export VAULT_CACERT=$VAULT_CACERT
export SUBASTION_GREEN_KEYFILE=$SUBASTION_GREEN_KEYFILE
export SUBASTION_GREEN_IP=$SUBASTION_GREEN_IP
export SUBASTION_BLUE_KEYFILE=$SUBASTION_BLUE_KEYFILE
export SUBASTION_BLUE_IP=$SUBASTION_BLUE_IP
EOF
  source bluegreen.env
}


build-cryptocerts() {
  ENVDIR=`pwd`/environment/cryptocerts/

  mkdir log > /dev/null 2>&1

  terraform -chdir=$ENVDIR init  | tee log/cryptocerts.tfinit.log 2>&1 
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/cryptocerts.tfapply.log 2>&1
}

destroy-cryptocerts() {
  ENVDIR=`pwd`/environment/cryptocerts/

  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/dockervault.tfapply.log 2>&1

  rm -fr $ENVDIR/terraform.tfstate*
  rm -fr $ENVDIR/.terraform.lock.hcl

  rm -fr terraform/modules/openssl/ica/index*
  rm -fr terraform/modules/openssl/ica/serial*
  rm -fr terraform/modules/openssl/ica/*.pem
  rm -fr terraform/modules/openssl/ica/ica.openssl.conf

  rm -fr terraform/modules/openssl/ca/index*
  rm -fr terraform/modules/openssl/ca/serial*
  rm -fr terraform/modules/openssl/ca/*.pem
  rm -fr terraform/modules/openssl/ca/ca.openssl.conf

  ##TEMP: it's faster to leave this!
  ##rm -fr terraform/modules/openssl/dh.2048.pem
  rm -fr terraform/modules/openssl/ca.ica.pfx
  rm -fr terraform/modules/openssl/ca.ica.pem

  git checkout terraform/modules/openssl/ca > /dev/null 2>&1
  git checkout terraform/modules/openssl/ica > /dev/null 2>&1

}

build-dockervault() {
  ENVDIR=`pwd`/environment/dockervault/

  mkdir log > /dev/null 2>&1

  terraform -chdir=$ENVDIR init  | tee log/dockervault.tfinit.log 2>&1 
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/dockervault.tfapply.log 2>&1
}

destroy-dockervault() {
  ENVDIR=`pwd`/environment/dockervault/

  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/dockervault.tfapply.log 2>&1
  rm -fr $ENVDIR/terraform.tfstate*
  rm -fr $ENVDIR/.terraform.lock.hcl

  docker kill vaultsubastion > /dev/null 2>&1
  docker rm vaultsubastion > /dev/null 2>&1

  rm -fr terraform/modules/dockervault/*.pem
  rm -fr terraform/modules/dockervault/root.secret
  rm -fr environment/dockervault/vaultadmin.token
    
  ##NOTE: vault docker container runs as root and outputs files as root.
  sudo rm -fr docker/vault/volumes/file/*
  sudo rm -fr docker/vault/volumes/log/*

  rm -fr docker/*.pem
  rm -fr docker/*.pfx
  rm -fr docker/*.token 
}

export -f build-cryptocerts
export -f destroy-cryptocerts

export -f build-dockervault
export -f destroy-dockervault

export -f build-prod-bluegreen
export -f destroy-prod-bluegreen

export -f ssh-prod-green-subastion
export -f openvpn-prod-green-subastion
export -f ssh-prod-blue-subastion
export -f openvpn-prod-blue-subastion