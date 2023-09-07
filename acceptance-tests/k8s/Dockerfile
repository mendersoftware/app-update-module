FROM tiangolo/docker-with-compose

RUN apk --update add curl jq sysstat hdparm wget bash vim xz
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
RUN chmod +x ./kind
RUN mv ./kind /usr/bin/kind
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl

ENTRYPOINT ["sleep","65536"]
