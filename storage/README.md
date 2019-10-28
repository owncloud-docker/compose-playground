# Storage

Provides different storages that can be combined 

## CEPH
- `ceph-primary-compose.yml`  
    Provides a ceph container and configures owncloud to use ceph as primary storage.  
    Ceph uses [ceph/demo](https://hub.docker.com/r/ceph/demo/) image.  
    By default the tag `tag-build-master-jewel-ubuntu-16.04` is used for the container. 
    It can be override by the environment variable `CEPH_CONTAINER_TAG`  
    
## scality

- `scality-primary-compose.yml`  
    Provides a scality container and configures owncloud to use ceph as primary storage.  
    Ceph uses [scality/s3server](https://hub.docker.com/r/scality/s3server/) image.  
    By default the tag `latest` is used for the container. 
    It can be override by the environment variable `SCALITY_CONTAINER_TAG`  
    

## samba
Provides a samba share via [owncloudci/samba](https://hub.docker.com/r/owncloudci/samba/) docker container.
By default it can be mounted via:
```
Server: samba
Directory/Share: tmp
```
Available Users:

```User: user1
   Password: user1pass
   User: user2
   Password: user2pass
```

By default the container uses the tag `latest`, it can be overriden by `SAMBA_CONTAINER_TAG`


## sftp
Provides a sftp server via [atmoz/sftp](https://hub.docker.com/r/atmoz/sftp) docker container.
Be default it can be mounted via:
```
Address: sftp
User: admin
Password: password
```

By default the container uses the tag `latest`, it can be overriden by `SFTP_CONTAINER_TAG`