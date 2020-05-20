FROM golang:alpine as build

WORKDIR /build

ADD . /build/
ENV CGO_ENABLED=0 
ENV GOOS=linux
RUN go build -o user-linux-amd64 user.go

# FROM amd64/alpine:edge
# RUN apk update && \
# 	apk upgrade && \
# 	apk add ca-certificates mailcap && \
# 	rm -rf /var/cache/apk/* && \
# 	echo 'hosts: files dns' >| /etc/nsswitch.conf

FROM centos:7
RUN rpm --rebuilddb && yum -y install \
    nss-pam-ldapd \
    nscd \
    authconfig

# ENTRYPOINT ["/usr/bin/user"]
COPY --from=build /build/user-linux-amd64 /usr/bin/user
