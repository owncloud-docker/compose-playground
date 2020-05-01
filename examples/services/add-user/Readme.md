# Example for adding a user to accounts service

## Build

```
go build .
```

Build docker image

```
docker build -t add-user .
```

## Run

```
docker run --rm -ti add-user Peter
```

## How to fix issues

Returns error
```
{"level":"warn","ts":"2020-05-01T18:59:38.348Z","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"endpoint://client-997fe76a-a96b-44f8-b582-6124e5573381/172.18.0.2:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = context deadline exceeded"}
Could not create user: {"id":"go.micro.client","code":500,"detail":"error selecting com.owncloud.accounts node: context deadline exceeded","status":"Internal Server Error"}
(*proto.Record)(nil)
```

Configure service discovery

```
MICRO_REGISTRY_ADDRESS=172.18.0.2:2379
MICRO_REGISTRY=etcd
```