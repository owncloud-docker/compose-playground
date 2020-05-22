FROM eos/base

ARG EOS_VERSION="4.6.5"
ARG QDB_VERSION="0.4.0"

RUN rpm --rebuilddb && yum -y install \
    eos-ns-inspect-${EOS_VERSION} \
    quarkdb-${QDB_VERSION} \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY etc/sysconfig/eos /etc/sysconfig/eos
COPY entrypoint /entrypoint
