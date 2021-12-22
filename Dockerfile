# docker build 
#      --build-arg aws_access_key=changeme \
#      --build-arg aws_secret_key=changeme \
#      --build-arg aws_key_id=changeme \
#      --build-arg aws_key_alias=changeme \
#      --build-arg vault_addr=https://vaultsubastion:8200
#      --build-arg vault_cacert=terraform/modules/dockervault/vault.cert.pem
#      --tag subastion:v1 \
#      .
#
# docker rmi $(docker images -f "dangling=true" -q)
#
# docker run --tty --interactive --rm subastion:v1
#
# docker rmi subastion:v1
#
#
#FROM archlinux:base-20211212.0.41353
#RUN pacman --noconfirm -Sy jq openssl vault terraform git bash aws-cli sudo

FROM alpine:3.14
RUN apk add --no-cache jq openssl vault terraform git bash aws-cli sudo

ARG aws_access_key=changewithbuildarg
ARG aws_secret_key=changewithbuildarg
ARG aws_kms_key_id=changewithbuildarg
ARG aws_kms_alias="orchestration"

ARG aws_region="ca-central-1"
ARG aws_zones='["ca-central-1a", "ca-central-1b"]'
ARG aws_build_nat="false"

ARG vault_addr="https://vault:8200"
ARG vault_cacert_file=terraform/modules/dockervault/vault.cert.pem

ENV AWS_ACCESS_KEY_ID=$aws_access_key \
    AWS_SECRET_ACCESS_KEY=$aws_secret_key \
    AWS_DEFAULT_REGION=$aws_region \
    TF_VAR_aws_region=$aws_region \
    TF_VAR_aws_zones=$aws_zones \
    TF_VAR_aws_kms_key_alias=$aws_kms_alias \
    TF_VAR_aws_kms_key_id=$aws_kms_key_id \
    TF_VAR_build_nat_gateway=$aws_build_nat\
    PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')\[\e[00m\]$ " \
    VAULT_ADDR=${vault_addr} \
    VAULT_CACERT=/home/subastion/vault.cert.pem

RUN adduser -S subastion
USER subastion

WORKDIR /home/subastion/
RUN git clone https://github.com/whereiskurt/subastion .

COPY ${vault_cacert_file} /home/subastion/vault.cert.pem

ENTRYPOINT [ "/bin/bash" ]