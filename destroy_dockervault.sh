#!/bin/bash
export ENVDIR=`pwd`/environment/dockervault/
echo "Resetting dockervault builds..."

terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/dockervault.tfapply.log 2>&1
rm -fr $ENVDIR/terraform.tfstate*
rm -fr $ENVDIR/.terraform.lock.hcl

docker kill vaultsubastion > /dev/null 2>&1
docker rm vaultsubastion > /dev/null 2>&1

rm -fr terraform/modules/dockervault/*.pem
rm -fr terraform/modules/dockervault/root.secret
  
##NOTE: vault docker container runs as root and outputs files as root.
echo "Removing files created by docker container..."
sudo rm -fr docker/vault/volumes/file/*
sudo rm -fr docker/vault/volumes/log/*

rm -fr docker/*.pem
rm -fr docker/*.pfx
rm -fr docker/*.token