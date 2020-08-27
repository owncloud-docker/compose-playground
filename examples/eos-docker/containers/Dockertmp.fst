### DOCKER FILE FOR eos/fst IMAGE BASED ON EOS CITRINE -- EOS 4.x Version ###

FROM eos/base:VERSION_PLACEHOLDER

MAINTAINER David Jericho <david.jericho@aarnet.edu.au>
MAINTAINER Crystal Chua <crystal.chua@aarnet.edu.au>

RUN rpm --rebuilddb && yum -y install \
    jq \
    cryptsetup \
    e2fsprogs \
    xfsprogs \
    smartmontools && \
    yum clean all && \
    rm -rf /var/cache/yum


# ----- Copy some scripts so we can run them ----- #
COPY containers/content/scripts/entrypoint.fst.generic /entrypoint
COPY containers/content/scripts/entrypoint.fst         /entrypoint.fst
COPY containers/content/scripts/entrypoint.fst.k8s     /entrypoint.fst.k8s
