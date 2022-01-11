#!/bin/bash
export AWS_KMS_KEY_ALIAS=${AWS_KMS_KEY_ALIAS:-orchestration}
export CONFIG_MAKE_NATGATEWAY=${CONFIG_MAKE_NATGATEWAY:-false}

export VAULT_ADDR=${VAULT_ADDR:-https://localhost:8200}
export AWS_KMS_KEY_ID=${AWS_KMS_KEY_ID:-`aws kms list-aliases |jq -r '.Aliases| .[] | select (.AliasName == "alias/'$AWS_KMS_KEY_ALIAS'") |.TargetKeyId'`}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-`aws configure get default.aws_access_key_id`}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-`aws configure get default.aws_secret_access_key`}

ssh-juicebox-subastion () { 
  ssh -i $JUICESHOP_KEYFILE ubuntu@$JUICESHOP_IP
}

openvpn-juicebox-subastion () { 
  scp -i $JUICESHOP_KEYFILE ubuntu@$JUICESHOP_IP:/home/ubuntu/openvpn/juiceapplication.ovpn ~/.ssh/ && \
  chmod 600 ~/.ssh/juiceapplication.ovpn && \
  OVPN=$HOME && \
  sudo sh -c "nohup openvpn --redirect-gateway autolocal --config $OVPN/.ssh/juiceapplication.ovpn > ~/nohup.juice.out 2>&1 &"
}

build-juiceshop() {
  export TF_VAR_aws_kms_key_id=$AWS_KMS_KEY_ID
  export TF_VAR_aws_kms_key_alias=$AWS_KMS_KEY_ALIAS
  export TF_VAR_build_nat_gateway=$CONFIG_MAKE_NATGATEWAY
  export TF_VAR_vault_addr=$VAULT_ADDR

  ENVDIR=`pwd`/environment/aws/juiceshop/

  mkdir log > /dev/null 2>&1

  terraform -chdir=$ENVDIR init  | tee log/juiceshop.tfinit.log 2>&1 
  terraform -chdir=$ENVDIR apply -no-color -auto-approve | tee log/juiceshop.tfapply.log 2>&1

  export VAULT_ADDR=$TF_VAR_vault_addr
  export VAULT_TOKEN=`cat environment/dockervault/vaultadmin.token`
  export VAULT_CACERT=`pwd`/terraform/modules/dockervault/vault.cert.pem
  export JUICESHOP_KEYFILE=$HOME/.ssh/juice_application_ec2
  export JUICESHOP_IP=`vault read -field=ip subastion/juice_application_ec2`
  cat << EOF > juiceshop.env
#!/bin/bash
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$VAULT_TOKEN
export VAULT_CACERT=$VAULT_CACERT
export JUICESHOP_KEYFILE=$JUICESHOP_KEYFILE
export JUICESHOP_IP=$JUICESHOP_IP
EOF
  source juiceshop.env

}

destroy-juiceshop() {
  ENVDIR=`pwd`/environment/aws/juiceshop/
  mkdir log > /dev/null 2>&1
  terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/juiceshop.tfdestroy.log 2>&1

  vault kv delete subastion/juice_application_ec2

  unset VAULT_TOKEN
  unset VAULT_ADDR
  unset JUICESHOP_KEYFILE
  unset JUICESHOP_IP
}
