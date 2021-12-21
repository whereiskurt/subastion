#!/bin/bash
export ENVDIR=`pwd`/environment/dockervault/
echo "Resetting dockervault builds..."

terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/dockervault.tfapply.log 2>&1

docker kill vault > /dev/null 2>&1
docker rm vault > /dev/null 2>&1

rm -fr $ENVDIR../../terraform/modules/dockervault/*.pem
rm -fr $ENVDIR../../terraform/modules/dockervault/root.secret
  
##NOTE: vault docker container runs as root and outputs files as root.
echo "Removing files created by docker container..."
sudo rm -fr $ENVDIR/../../../docker/vault/volumes/file/*
sudo rm -fr $ENVDIR/../../../docker/vault/volumes/log/*
