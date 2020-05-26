FROM centos:7 as build
ARG BRANCH=master

ENV CGO_ENABLED=0 
ENV GOOS=linux
RUN rpm --rebuilddb && yum -y install \
    wget \
    make \
    gcc \
    git
RUN wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
RUN mkdir -p /usr/local/bin
RUN tar xf go1.14.2.linux-amd64.tar.gz -C /usr/local
RUN ln -s /usr/local/go/bin/* /usr/local/bin
RUN git clone https://github.com/owncloud/ocis.git
RUN cd ocis && git checkout ${BRANCH}
RUN cd ocis && git log -n 1
RUN cd ocis && make generate bin/ocis

FROM eos/base
RUN mkdir -p /usr/local/bin
COPY --from=build ocis/bin/ocis /usr/local/bin/
RUN chmod +x /usr/local/bin/ocis

COPY setup /setup
COPY entrypoint /entrypoint
