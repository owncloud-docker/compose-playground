FROM eos/base

ARG EOS_VERSION="4.6.5"

RUN rpm --rebuilddb && rpm --import http://storage-ci.web.cern.ch/storage-ci/storageci.key && yum -y install \
    eos-fusex-${EOS_VERSION} \
    eos-fusex-core-${EOS_VERSION} \
    jq \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY etc/eos/fuse.conf /etc/eos/fuse.conf.tmp
COPY entrypoint /entrypoint
