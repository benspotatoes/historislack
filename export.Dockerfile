# Copied from GoogleCloudPlatform/cloud-sdk-docker
FROM alpine:3.9
ARG CLOUD_SDK_VERSION=251.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ENV PATH /google-cloud-sdk/bin:$PATH
RUN apk --no-cache add \
  curl \
  python \
  py-crcmod \
  bash \
  libc6-compat \
  openssh-client \
  git \
  gnupg \
  # Install postgresql-client for pg_dump
  postgresql-client \
  && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
  tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
  rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
  ln -s /lib /lib64 && \
  gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image && \
  gcloud --version

COPY opt/historislack /opt/

ARG organizations=""
ARG bucket=""

RUN rm /etc/crontabs/root

RUN for org in $organizations; do \
  echo "0 0 * * 1 /opt/historislack/export $org $bucket" >> /etc/crontabs/root; \
  done

CMD ["crond", "-f", "-d", "8"]
