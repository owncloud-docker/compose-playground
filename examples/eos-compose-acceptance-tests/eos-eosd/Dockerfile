FROM eos/base

ARG EOS_VERSION="4.6.5"

RUN rpm --rebuilddb && rpm --import http://storage-ci.web.cern.ch/storage-ci/storageci.key && yum -y install \
    eos-fuse-${EOS_VERSION} \
    eos-fuse-core-${EOS_VERSION} \
    eos-fuse-sysv-${EOS_VERSION} \
    psmisc \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY etc/sysconfig/eos /etc/sysconfig/eos
COPY entrypoint /entrypoint
