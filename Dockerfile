FROM ubuntu:20.04

LABEL maintainer="Lucas Pribbenow"
LABEL company="oh22information services GmbH"
LABEL version="1.0"
LABEL description="SFTP Server with Azure Blob Storage mount support"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        apt-utils && \
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get remove -y \
        wget && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        fuse \
        blobfuse \
        libcurl3-gnutls \
        libgnutls30 \
        openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY data/sshd_config /etc/ssh/sshd_config
COPY data/create-sftp-user /usr/local/bin/
COPY data/entrypoint /
COPY data/mount-az-storage /etc/sftp.d/

ENTRYPOINT ["/entrypoint"]