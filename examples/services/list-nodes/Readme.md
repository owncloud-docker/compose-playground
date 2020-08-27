# Example for listing all services

## Build

```
go build .
```

Build docker image

```
docker build -t list-nodes .
```

## Run

```
docker run --rm -ti list-nodes
```

## Issues

Returns error
```
{"level":"warn","ts":"2020-05-01T18:52:33.295Z","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"endpoint://client-44097cd4-e405-43e3-b5ee-1bfb1dd326ec/172.18.0.2:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = context deadline exceeded"}
Could not list services: context deadline exceeded
```

Configure service discovery

```
MICRO_REGISTRY_ADDRESS=172.18.0.2:2379
MICRO_REGISTRY=etcd
```