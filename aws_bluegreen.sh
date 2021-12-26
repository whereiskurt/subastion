#!/bin/bash
export ENVDIR=`pwd`/environment/aws/bluegreen

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
  echo "Destroying AWS infrastructure with terraform and destroying vault instance..."
  mkdir log > /dev/null 2>&1
  
  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/aws_bluegreen.tfdestroy.log 2>&1

  rm -fr $ENVDIR/terraform.tfstate*
  rm -fr $ENVDIR/.terraform.lock.hcl

  echo "Use 'build-prod-bluegreen' to rebuild..."  
  echo "Done!"

  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset SUBASTION_GREEN_KEYFILE
  unset SUBASTION_GREEN_IP
  unset SUBASTION_BLUE_KEYFILE
  unset SUBASTION_BLUE_IP
}


build-prod-bluegreen() {
  mkdir log > /dev/null 2>&1

  terraform -chdir=$ENVDIR init  | tee log/aws_bluegreen.tfinit.log 2>&1 
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/aws_bluegreen.tfapply.log 2>&1

  export VAULT_ADDR=https://vaultsubastion:8200
  export VAULT_TOKEN=`cat $ENVDIR/vaultadmin.token`
  export VAULT_CACERT=`pwd`/terraform/modules/dockervault/vault.cert.pem
  export SUBASTION_GREEN_KEYFILE=$HOME/.ssh/prod_green_subastion_ec2
  export SUBASTION_GREEN_IP=$(vault read -field=ip subastion/prod_green_subastion_ec2) 
  export SUBASTION_BLUE_KEYFILE=$HOME/.ssh/prod_blue_subastion_ec2
  export SUBASTION_BLUE_IP=$(vault read -field=ip subastion/prod_blue_subastion_ec2)

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

export -f build-prod-bluegreen
export -f destroy-prod-bluegreen

export -f ssh-prod-green-subastion
export -f openvpn-prod-green-subastion

export -f ssh-prod-blue-subastion
export -f openvpn-prod-blue-subastion