# Example for scripting hcloud servers

## Getting Started

Cheat sheet
```
# list available images
hcloud image list

# list all ssh keys in the project
hcloud ssh-key list -o noheader -o columns=name

# create a server
hcloud server create --type cx11 --image ubuntu-20.04 --ssh-key felix --name fb-test --label owner=felix --label for=testing

# set rdns - important to find the server by IP
hcloud server set-rdns -r test.owncloud.works fb-test

# get the IP
ip=$(hcloud server ip fb-test)
echo $ip

# login via ssh
ssh root@$ip

# poweroff
hcloud server poweroff fb-test

# poweron
hcloud server poweron fb-test

# find all servers created by me, via labels
hcloud server list -l owner=felix

# remove
hcloud server delete fb-test
```

## Install

Install hcloud commandline tool: https://github.com/hetznercloud/cli#installation


## Configure

You need a api-token from a hetzner cloud project. Every project has own tokens.

On the command line configure the projects you work with:
```
hcloud context create DevOps
```
You will be prompted to enter the api-token.

## Scripting

In scripts you can use a env variable to specify the project to use via the token:
```
HCLOUD_TOKEN=any-projects-api-token hcloud list server
```
See example (./list-hcloud-server.sh)[list-hcloud-server.sh] on howto work with different hcloud projects. The script assumes that you have stored the tokens in a vault.

TODO: Example for vault usage
