FROM alpine:3.4

# Install Packer
ARG PACKER_VERSION='0.10.2'
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN sed -i '/packer_${PACKER_VERSION}_linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS && \
  sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS && \
  unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
  rm -f packer_${PACKER_VERSION}_linux_amd64.zip

# Install terraform
ARG TERRAFORM_VERSION='0.7.9'
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN sed -i '/terraform_${TERRAFORM_VERSION}_linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
  sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  /bin/terraform version

# Install kubectl
ARG KUBECTL_VERSION='1.3.4'
ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod +x /bin/kubectl

# Install stern
ARG STERN_VERSION='1.0.0'
ADD https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 /bin/stern
RUN chmod +x /bin/stern

# Install docker and docker-compose
ARG DOCKER_VERSION='1.11.2'
ADD https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz ./
RUN tar xf docker-${DOCKER_VERSION}.tgz && find docker -exec cp {}  /usr/bin \; && rm -rf docker docker-${DOCKER_VERSION}.tgz

ARG DOCKER_COMPOSE_VERSION="1.8.1"
ADD https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 /bin/docker-compose
RUN chmod +x /bin/docker-compose

# Install the aws cli - can't specify versions
RUN apk -Uuv add groff less python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*
  
# Install the help ourtput that is spit out when no command is given
ADD help /help

VOLUME ["/share", "/root/.aws", "/root/.kube", "/var/run/docker.sock" ]
WORKDIR /share

CMD '/help'
