#!/bin/bash
export ENVDIR=`pwd`/environment/cryptocerts/
echo "Resetting the CA and ICA..."

terraform -chdir=$ENVDIR destroy -no-color -auto-approve | tee log/dockervault.tfapply.log 2>&1

rm -fr $ENVDIR/terraform.tfstate*
rm -fr $ENVDIR/.terraform.lock.hcl

rm -fr $ENVDIR../../terraform/modules/openssl/ica/index*
rm -fr $ENVDIR../../terraform/modules/openssl/ica/serial*
rm -fr $ENVDIR../../terraform/modules/openssl/ica/*.pem
rm -fr $ENVDIR../../terraform/modules/openssl/ica/ica.openssl.conf

rm -fr $ENVDIR../../terraform/modules/openssl/ca/index*
rm -fr $ENVDIR../../terraform/modules/openssl/ca/serial*
rm -fr $ENVDIR../../terraform/modules/openssl/ca/*.pem
rm -fr $ENVDIR../../terraform/modules/openssl/ca/ca.openssl.conf

##TEMP: it's faster to leave this!
##rm -fr $ENVDIR../../terraform/modules/openssl/dh.2048.pem
rm -fr $ENVDIR../../terraform/modules/openssl/ca.ica.pfx
rm -fr $ENVDIR../../terraform/modules/openssl/ca.ica.pem

git checkout terraform/modules/openssl/ca > /dev/null 2>&1
git checkout terraform/modules/openssl/ica > /dev/null 2>&1