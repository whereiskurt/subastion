# docker build 
#      --build-arg aws_access_key=changeme \
#      --build-arg aws_secret_key=changeme \
#      --build-arg aws_key_id=changeme \
#      --build-arg aws_key_alias=changeme \
#      --tag subastion:v1 \
#      .

# docker run --tty --interactive --rm subastion:v1

# docker rmi subastion:v1

FROM archlinux:base-20211212.0.41353

RUN pacman --noconfirm -Sy jq openssl vault terraform git bash aws-cli sudo

ARG aws_access_key=changewithbuildarg
ARG aws_secret_key=changewithbuildarg
ARG aws_kms_key_id=changewithbuildarg
ARG aws_kms_alias="orchestration"

ARG aws_region="ca-central-1"
ARG aws_zones='["ca-central-1a", "ca-central-1b"]'
ARG aws_build_nat="false"

ENV AWS_ACCESS_KEY_ID=$aws_access_key
ENV AWS_SECRET_ACCESS_KEY=$aws_secret_key
ENV AWS_DEFAULT_REGION=$aws_region
ENV TF_VAR_aws_region=$aws_region
ENV TF_VAR_aws_zones=$aws_zones
ENV TF_VAR_aws_kms_key_alias=$aws_kms_alias
ENV TF_VAR_aws_kms_key_id=$aws_kms_key_id
ENV TF_VAR_build_nat_gateway=$aws_build_nat


RUN useradd -m subastion
USER subastion

WORKDIR /home/subastion/
RUN git clone https://github.com/whereiskurt/subastion 

ENTRYPOINT [ "/bin/bash" ]