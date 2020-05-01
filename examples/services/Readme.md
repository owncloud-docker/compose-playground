# go micro, service comunication, service discovery

## Learn by example

```
# Start etcd, micro and accounts service
docker-compose up -d etcd micro accounts

# See logs of starting containers, exit with ctrl-c
docker-compose logs -f

# Have some fun with micro
docker-compose exec micro ./micro list services
docker-compose exec micro ./micro list routes
docker-compose exec micro ./micro get service com.owncloud.accounts


# How to access services and nodes via micro in golang
docker-compose run --rm list-nodes

# How to talk to accounts service in golang
docker-compose run --rm add-user Peter
docker-compose exec accounts ls ocis-data

# Now scale out accounts service and look at services again
docker-compose up -d --scale accounts=3
docker-compose run --rm list-nodes

docker-compose down -v
```