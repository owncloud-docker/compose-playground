FROM centos:7

# ----- Define EOS and XRD version: defaults to 'latest' ----- #
ARG EOS_VERSION="4.6.5"
ARG XRD_VERSION="4.11.0"
# xrootd                  x86_64  1:4.11.3-1.el7
# eos-server              x86_64  4.7.16-1.el7.cern

# ----- Copy the repos to install EOS and XRootD ----- #
COPY etc/yum.repos.d/*.repo /etc/yum.repos.d/

RUN rpm --rebuilddb && yum -y install \
    eos-xrootd-${XRD_VERSION}  \
    xrootd-${XRD_VERSION}  \
    xrootd-client-${XRD_VERSION} \
    xrootd-client-libs-${XRD_VERSION} \
    xrootd-client-devel-${XRD_VERSION} \
    xrootd-libs-${XRD_VERSION} \
    xrootd-selinux-${XRD_VERSION} \
    xrootd-server-${XRD_VERSION} \
    xrootd-server-devel-${XRD_VERSION} \
    xrootd-server-libs-${XRD_VERSION} \
    xrootd-private-devel-${XRD_VERSION} \
    eos-server-${EOS_VERSION} \
    eos-client-${EOS_VERSION} \
    eos-test-${EOS_VERSION} \
    bc \
    initscripts \
    libmicrohttpd \
    protobuf3 \
    hostname \
    jemalloc \
    leveldb \
    nc \
    zeromq \
    redis \
    nss-pam-ldapd \
    nscd \
    authconfig \
    && yum clean all \
    && rm -rf /var/cache/yum

# ----- Raise limits ----- #
RUN echo "*               soft    nofile          200000" >> /etc/security/limits.conf && \
    echo "*               hard    nofile          200000" >> /etc/security/limits.conf 

# ----- Copy xrd config and sysconfig files ----- #
COPY etc/xrd.* /etc/
COPY etc/eos.keytab /etc/eos.keytab
COPY etc/sysconfig/eos /etc/sysconfig/eos

RUN cp /etc/eos.keytab /etc/eos.client.keytab
RUN chown daemon:daemon /etc/eos.client.keytab && chmod 400 /etc/eos.client.keytab

# ----- Run entrypoint script to start service(s) ----- #
CMD ["/entrypoint"]
