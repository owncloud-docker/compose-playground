# EOS-DOCKER

This repository contains all containers required for setting up EOS.
Each component of EOS, as detailed below, is run in a separate container, although files and volumes may be mapped to the same locations on the host.

The `docker-compose.yml` file and the `setup` script can be used as a reference for configuring the containers, but they are only used to run up very simply and specifically configured instances of EOS to check that the containers work.

------

## TABLE OF CONTENTS

- [System Requirements](#system-requirements)
- [Quickstart](#quickstart)
- [In-Memory Namespace](#in-memory-namespace)
- [QuarkDB Namespace](#quarkdb-namespace)
- [Miscellaneous](#miscellaneous)

------

## SYSTEM REQUIREMENTS

### Docker

In the systemd docker.service file, add the line `MountFlags=shared`, then restart docker for the change to take effect - this may not work on older versions of Docker (we currently use 17.05.0-ce).
This line allows a volume mount to be accessible to other containers.

Depending on the version of Docker, the default storage driver may be set to devicemapper or overlay (or overlay2 if available).
Overlay2 is preferable - change the value in `/etc/docker/daemon.json`, then restart docker to allow the change to take effect.

### Docker-Compose

The setup script makes use of docker-compose, so this will need to be installed on the system - we currently use version 1.7.1.

### Ports

These ports must be open/ accessible

```
1094 - MGM
8000 - MGM HTTP
1097 - MQ
1095 - FST
8001 - FST HTTP
1096 - SYNC
7777 - QUARKDB
```

------

## QUICKSTART

```
./build -a IP.AD.DD.DR -t test && ./setup -a
```

### Building EOS-DOCKER Containers

```
./build [-a <ipaddr>] [-x <xrootd-version>] [-e <eos-version>] [-q <qdb-version>] [-i <list,of,images>] [-t <tag>] [-c] [-g] [-p] [-f] [-h]
  -a specify IPADDR for docker-compose.yml and config/identifier-registration.yml patching...
  -x specify xrootd version, defaults to latest known stable
  -e specify eos version, defaults to latest known working
  -q specify quarkdb version, defaults to latest known stable
  -i specify target images to build
  -t specify tag for built images
  -c compile from dss/eos repo instead of installing eos from rpm - modify Dockertmp.compile to change source repo
  -p push images to repo after building
  -f force a fresh build instead of using cache
  -h prints this thing i guess
```

When run without arguments, this script builds all the containers with the latest known working release of EOS.
The XRootD version is pinned to avoid installing potentially issue-causing release candidates - this can be overwritten using the -x flag.

The script does not do a registry push by default - only if the -p flag is specified.

**NOTE**: If you already have containers running and try to do a build, this sometimes fails - run `./setup -d` to destroy currently running containers before rebuilding.

### Testing EOS-DOCKER Containers

```
./setup -d|-s|-a [-t <type>]
    -d delete/destroy all existing containers and images
    -s start up containers and configure eos
    -a do everything, in above order
    -e turn on extra debugging: XrdSecDEBUG=3 & XRD_LOGLEVEL=Dump
    -t type of setup: 'dual' or 'qdb'
       if not defined, set up a single master with in-memory namespace
```

The script creates one of three types of EOS setups: by default, a single master using the in-memory namespace is started.
Docker network magic is used to enable a master/slave setup as well - this is further described in the test setup details section at the end.
The setup script uses the `:test` tagged images from the build script. To use specific tags or other images, edit the docker-compose file.

------

## IN-MEMORY NAMESPACE

The in-memory namespace is essentially "legacy", however it is still run in some environments.

### SINGLE MASTER

The single-master in-memory namespace setup is the simplest, consisting of only the MQ, MGM and FST containers. This is a good setup to use for just testing - we run this in UAT, support EOS and Mirror.

#### MQ/MGM

##### Required Environment Variables

```
EOS_MGM_ALIAS     = master mgm hostname, or alias pointing to master mgm
EOS_MGM_MASTER1   = master mgm hostname
EOS_INSTANCE_NAME = cluster name
EOS_SET_MASTER    = 1
EOS_MAIL_CC       = notification address for issues
```

##### Required Volume Mounts

```
/etc/eos.keytab (file)
/var/eos
/var/log/eos
/var/spool/eos
```

#### FST

##### Required Environment Variables

```
EOS_MGM_ALIAS     = master mgm hostname, or alias pointing to master mgm
EOS_MGM_URL       = master mgm hostname, or alias pointing to master mgm
EOS_MGM_MASTER1   = master mgm hostname
EOS_INSTANCE_NAME = cluster name
EOS_GEOTAG        = region the FST is in
EOS_MAIL_CC       = notification address for issues
```

##### Optional Environment Variables

When FST disks are formatted, a label is typically set based on the disk's physical location on the chassis. These environment variables tell the FST container which disks on the chassis to pick up and mount.

```
LUKSPASSPHRASE    = luks decryption key, if disks are encrypted
FSLABEL           = label for unencrypted disks
FSLABEL_ENCRYPTED = label for encrypted disks
```

##### Required Volume Mounts

The `/dev/` mounts are specifically listed - the other required volumes can be located anywhere on the host.

```
/etc/eos.keytab (file)
/var/eos
/var/log/eos
/var/spool/eos
/disks:shared
/dev/disk/by-physlocation:/dev/disk/by-physlocation:ro (:ro attribute indicates read-only)
/dev/:/hostdev
```

### MULTI MASTER

The multi-master setup is a little misleading - theoretically we should be able to switch MGMs from slave to master, but this functionality doesn't work with our docker containers. Because of this, we're essentially just running a single static master MGM, with one or more slaves that hold a copy of the production metadata, and can be queried. The only configuration difference for the master and slave MQ/MGMs is setting `EOS_SET_MASTER=1` on the master. 

If running multiple slaves, on each slave, the `EOS_MGM_MASTER1` value remains the actual master MGM, and `EOS_MGM_MASTER2` is set to that server's hostname. On the master, `EOS_MGM_MASTER2` can be set to any valid slave. 

#### MQ/MGM GENERIC

##### Required Environment Variables

```
EOS_MGM_ALIAS     = master mgm hostname, or alias pointing to master mgm
EOS_MGM_MASTER1   = master mgm hostname
EOS_MGM_MASTER2   = slave mgm hostname
EOS_INSTANCE_NAME = cluster name
EOS_MAIL_CC       = notification address for issues
```

##### Required Volume Mounts

```
/etc/eos.keytab (file)
/var/eos
/var/log/eos
/var/spool/eos
```

#### MQ/MGM MASTER

##### Additional Required Environment Variables

```
EOS_SET_MASTER=1
```

#### SYNC

The sync container runs on the slave, and listens out for connections from the eossync containers on the master server.

##### Required Environment Variables

```
EOS_MGM_ALIAS     = master mgm hostname, or alias pointing to master mgm
EOS_MGM_MASTER1   = master mgm hostname
EOS_MGM_MASTER2   = slave mgm hostname
EOS_INSTANCE_NAME = cluster name
EOS_MAIL_CC       = notification address for issues
```

##### Required Volume Mounts

```
/etc/eos.keytab (file)
/var/eos
/var/log/eos
/var/spool/eos
```

#### EOSSYNC

A set of four eossync containers must be run for every slave, on the master server. Each container is configured to stream a different file or folder to the slave.
The eossync-related environment variables for each container should be set as follows:

| SYNC\_TYPE | SYNCFILE\_NAME | SYNCFILE\_TYPE |
| ---------- | -------------- | -------------- |
| file       | files          | mdlog          |
| file       | directories    | mdlog          |
| file       | iostat         | dump           |
| dir        |                |                |

##### Required Environment Variables

```
EOS_MGM_HOST        = master mgm hostname
EOS_MGM_HOST_TARGET = target slave mgm hostname
SYNC_TYPE           = file | dir
SYNCFILE_NAME       = files | directories | iostat (only required if SYNC_TYPE is file)
SYNCFILE_TYPE       = mdlog for SYNCFILE_NAME = files | directories, dump for SYNCFILE_NAME = iostat
```

##### Required Volume Mounts

```
/etc/eos.keytab (file)
/var/eos/md
/var/eos/config
```

#### FST

##### Required Environment Variables

```
EOS_MGM_ALIAS     = master mgm hostname, or alias pointing to master mgm
EOS_MGM_URL       = master mgm hostname, or alias pointing to master mgm
EOS_MGM_MASTER1   = master mgm hostname
EOS_INSTANCE_NAME = cluster name
EOS_GEOTAG        = region the FST is in
EOS_MAIL_CC       = notification address for issues
```

##### Optional Environment Variables

When FST disks are formatted, a label is typically set based on the disk's physical location on the chassis. These environment variables tell the FST container which disks on the chassis to pick up and mount.

```
LUKSPASSPHRASE    = luks decryption key, if disks are encrypted
FSLABEL           = label for unencrypted disks
FSLABEL_ENCRYPTED = label for encrypted disks
```

##### Required Volume Mounts

The `/dev/` mounts are specifically listed - the other required volumes can be located anywhere on the host.

```
/etc/eos.keytab (file)
/var/eos
/var/log/eos
/var/spool/eos
/disks:shared
/dev/disk/by-physlocation:/dev/disk/by-physlocation:ro (:ro attribute indicates read-only)
/dev/:/hostdev
```

------

## QUARKDB NAMESPACE

#### MQ/MGM

##### MQ Required Environment Variables

```
EOS_MGM_ALIAS     = current server hostname/localhost
EOS_INSTANCE_NAME = cluster name
EOS_USE_QDB       = 1
EOS_QDB_NODES     = host:port host:port host:port (space-separated list of qdb nodes)
EOS_MAIL_CC       = notification address for issues
```

##### MGM Required Environment Variables

```
EOS_MGM_ALIAS      = current server hostname/localhost
EOS_INSTANCE_NAME  = cluster name
EOS_USE_QDB        = 1
EOS_USE_QDB_CONFIG = 1
EOS_USE_QDB_MASTER = 1
EOS_QDB_NODES      = host:port host:port host:port (space-separated list of qdb nodes)
EOS_MAIL_CC        = notification address for issues
```

##### Required Volume Mounts

```
/etc/eos.keytab (file)
/var/log/eos
```

#### QuarkDB

##### QuarkDB Bulkload Required Environment Variables

"Bulkload" is a special mode used when converting an in-memory namespace to QuarkDB - it is not used outside of that.

```
EOS_INSTANCE_NAME = cluster name
EOS_QDB_MODE      = bulkload
EOS_QDB_PORT      = port QuarkDB should listen on, usually 7777
EOS_QDB_DIR       = directory to store qdb metadata, typically /var/lib/quarkdb/convert
```

##### QuarkDB Raft Required Environment Variables

```
EOS_INSTANCE_NAME  = cluster name
EOS_QDB_MODE       = raft
EOS_QDB_CLUSTER_ID = cluster ID - usually just output of uuidgen. cluster ID must be the same for all nodes in the cluster
EOS_QDB_NODES      = list of nodes in cluster in host:port,host:port,host:port format
EOS_QDB_PORT       = port QuarkDB should listen on, usually 7777
EOS_QDB_DIR        = directory to store qdb metadata, typically /var/lib/quarkdb/eosns
```

##### Required Volume Mounts

```
/etc/eos.keytab (file)
/var/lib/quarkdb (volume mount required is parent directory of EOS_QDB_DIR)
/var/log/eos
```

#### FST

##### Required Environment Variables

```
EOS_MGM_ALIAS=master mgm hostname
EOS_INSTANCE_NAME=cluster name
EOS_GEOTAG=geotag to describe region cluster is in
EOS_MAIL_CC=notification address for issues
EOS_MGM_MASTER1=master mgm hostname
EOS_SET_MASTER=1
```

##### Required Volume Mounts

```
stuff
```

------

## MISCELLANEOUS

### EOSD

The eosd fuse client runs in this container. We almost never use this in production, as we run eosd directly on the hosts, but it can be useful to run this container up for testing.

##### Required Environment Variables

```
EOS_FUSE_MGM_ALIAS = master mgm hostname, or alias pointing to master mgm
```

##### Optional/Conditional Environment Variables

A whole list of fuse configuration variables can be found [here](http://eos-docs.web.cern.ch/eos-docs/configuration/fuse.html).

##### Required Volume Mounts

```
/etc/eos.keytab (file)
/var/log/eos
/eos:shared
```

##### Required Device Mounts

```
/dev/fuse:rwm
```

##### Required Capabilities

- set PID to "host"
- add SYS_ADMIN capability

## Past Issues & Notes
- `docker login` may be required if a registry is specified in docker-compose.yml.
- Ensure directories on host are writeable by daemon.
- MGM in particular cares a lot about hostname (EOS\_MGM\_MASTER1, EOS\_MGM\_MASTER2 environment variables). Ensure that hostname provided can be mapped to an IP address.
- If `vid enable sss` segfaults, check volume mapping is done correctly.
- If experiencing problems booting FSes, ensure daemon has correct permissions
  - `proc/admin` issues: check vid membership
  - "Cannot have rw access": file permissions
- EOS commands run from `docker exec` seem to occasionally experience strange locks and never complete - to avoid this, place commands in an eosh script and run it with `eos -b script.eosh`.
  - The argument `-r 0 0` may have to be specified if any of the commands require root.
- The `/var/log/eos/tx` folder created on install is overwritten by our docker volume mount - setup script now creates this folder to compensate for it.
- If you see the error `Rpmdb checksum is invalid: dCDPT(pkg checksums)`, add `rpm --rebuild` before a yum install command, eg. `RUN rpm --rebuilddb && yum -y install all-of-my-packages`.
- If you see `XrdConfig: Unable to create home directory //mgm; permission denied` error message from the MGM, this is due to `e/` not being owned by whichever user and group have the id `2`. Just run `id 2` and update any `chown` in the setup script.

------

## EOS-DOCKER TEST SETUP DETAILS

Skip this section if you don't care about the deployment details of the toy EOS environments for container testing!

### Docker Network

A docker network is set up in bridge mode to allow the containers to communicate with each other.
Each container on this network is assigned its own IP, and all ports on all containers are exposed to each other within the docker network.

Most of the containers are assigned static hostnames as well, defined in the `docker-compose.yml` file.
Fewer volume mounts are used as we don't care too much about persistent storage for a test environment - we do however want some containers to be able to access the same files.

#### Single Node Deployment

```
./setup -a
```

This command starts up a single MQ, MGM and FST.
The MGM exists at `mgm-master.testnet`, and the MQ at `mq-master.testnet`.
Since the MQ has a different hostname to the MGM, the EOS\_BROKER\_URL must be set to `root://mq-master.testnet:1097//eos`.

#### Multiple Node Deployment

```
./setup -a -t dual
```

This command starts up a master MQ and MGM, a slave MQ and MGM, the required SYNC and EOSSYNC containers, and one FST.
The startup process is as such:

1. Start slave MQ and SYNC - this is so the SYNC can listen for messages from EOSSYNC
2. Start master MQ and MGM
3. Start 4x EOSSYNC containers, as described above
4. Start slave MGM when required files have been synced
5. Start FST

The EOS\_MGM\_HOST\_TARGET environment variable passed to the EOSSYNC containers should be set to the hostname of the SYNC container (`sync.testnet`), not the hostname of the MGM slave container.
As with the single node deployment, the EOS\_BROKER\_URL must be set to `root://mq-master.testnet:1097//eos`.

Each node seems to however assume that the other node's mq exists at `root://other.mgm.hostname:1097//eos`, so the output shows that MQ as down.
It's possible to set the MQ hostnames with EOS\_MQ\_MASTER1 and EOS\_MQ\_MASTER2, but the checks will fail anyway because the code compares the MQ hostnames to the MGM hostnames to determine which MQ is remote.
This is a minor annoyance, but overall it's not too much of a concern, since normally you would never run the MQ and MGM on separate hosts.

The EOSSYNC containers must share `/var/eos/config` and `/var/eos/md` with the master MGM.
The SYNC container must share `/var/eos/config` and `/var/eos/md` with the slave MGM, so that the slave MGM has access to the required files.

#### Single Node with QuarkDB Namespace

```
./setup -a -t qdb
```

This command starts up a single MQ, MGM, 3 QuarkDB nodes, and FST.
The startup process is as such:

1. Start master MQ
2. Start 3x QuarkDB nodes
3. Start master MGM
4. Start FST

The MGM exists at `mgm-master.testnet`, and the MQ at `mq-master.testnet`.
Multiple MGMs are presently not supported if using QuarkDB.
Since the MQ has a different hostname to the MGM, the EOS\_BROKER\_URL must be set to `root://mq-master.testnet:1097//eos`.
Eventually the goal is to configure QuarkDB more cleverly - at present we're hard-coding all the environment variables etc (gross) for 3 nodes.
