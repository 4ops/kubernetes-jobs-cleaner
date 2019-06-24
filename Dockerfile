FROM bash:4

ARG KUBECTL_BASEURL=https://storage.googleapis.com/kubernetes-release/release
ARG KUBECTL_VERSION=v1.14.3

RUN set -ex ; \
    apk add --no-cache ca-certificates curl && \
    curl -s -o /usr/bin/kubectl -L ${KUBECTL_BASEURL}/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl

COPY ./src/jobs-cleaner.sh /jobs-cleaner.sh

ENTRYPOINT ["/jobs-cleaner.sh"]

CMD ["--help"]
