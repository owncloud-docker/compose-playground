FROM golang:alpine as build

WORKDIR /build

ADD . /build/
ENV CGO_ENABLED=0 
ENV GOOS=linux
RUN go build -o add-user-linux-amd64 add-user.go

FROM amd64/alpine:edge
RUN apk update && \
	apk upgrade && \
	apk add ca-certificates mailcap && \
	rm -rf /var/cache/apk/* && \
	echo 'hosts: files dns' >| /etc/nsswitch.conf

ENTRYPOINT ["/usr/bin/add-user"]
COPY --from=build /build/add-user-linux-amd64 /usr/bin/add-user
