# HowTo compile golang

Small example code `user.go` and a Dockerfile to build and run.

```
docker build -t user .
docker run --rm -it user root
```

## Known Issues

- User lookup: os user lookup fails getting ldap user, when compiling on Alpine and running on Centos:7

