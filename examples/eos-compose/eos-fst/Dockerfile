FROM eos/base

RUN rpm --rebuilddb && yum -y install \
    jq \
    cryptsetup \
    e2fsprogs \
    xfsprogs \
    smartmontools && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY setup /setup
COPY entrypoint /entrypoint
