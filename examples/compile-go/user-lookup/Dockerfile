FROM golang:alpine as build

WORKDIR /build

ADD . /build/
ENV CGO_ENABLED=0 
ENV GOOS=linux
RUN go build -o user-linux-amd64 user.go


FROM centos:7

ENTRYPOINT ["/usr/bin/user"]
COPY --from=build /build/user-linux-amd64 /usr/bin/user
