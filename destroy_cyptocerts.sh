#!/bin/bash
export ENVDIR=`pwd`/environment/cryptocerts/
echo "Resetting the CA and ICA..."

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