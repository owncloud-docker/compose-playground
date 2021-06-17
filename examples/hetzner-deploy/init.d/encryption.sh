#!/bin/bash
#
# 2021-06-18, jw@owncloud.com
#
# - encryption with softHSM

occ app:enable encryption
occ encryption:enable
occ encryption:select-encryption-type masterkey -y
occ encryption:encrypt-all -y

mkdir -p src/github/opendnssec
cd src/github/opendnssec
git clone https://github.com/opendnssec/SoftHSMv2.git
apt install -y build-essential automake autoconf libtool opensc unzip
cd SoftHSMv2
sh autogen.sh; ./configure; make; make install
cp src/lib/common/softhsm2.conf ~
export SOFTHSM2_CONF=$HOME/softhsm2.conf
grep -q SOFTHSM2_CONF ~/.bashrc || echo >> ~/.bashrc "export SOFTHSM2_CONF=$HOME/softhsm2.conf"

softhsm2-util --delete-token --slot 0 --token "My token 1" >/dev/null 2>&1 && true
softhsm2-util --init-token --slot 0 --label "My token 1" --pin 1234 --so-pin 123456
softhsm2-dump-file /var/lib/softhsm/tokens/*/token.object | head -7
pkcs11-tool --module /usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so -l -O --pin 1234

#FIXME: must first configure encryption with HSM to initialize the hsm.jwt.secret

cd ~/src
unzip ~/hsmdaemon-0.0.8.zip
cd hsmdaemon-0.0.8
mkdir -p /etc/hsmdaemon
cat << EO_TOML > /etc/hsmdaemon
logger]
level = "debug"    # one of debug, info, warn, error, panic, fatal
path = "file:///var/log/hsm.log"   # stderr, stdoul, a path or a file:// uri
encoding = "json" # json or console

[server]
#hostname = "localhost"
#hostname = "" # to listen on all interfaces
#port = 8513

[jwt]
#secret = "secret" # change this to the shared secret configured in the owncloud config
secret = "$(occ config:list --private | jq '.apps.encryption|.["hsm.jwt.secret"]' -r)"

[pkcs11]
# module is the path to the pkcs11 implementation. typically a .so file
module = "/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so"
pin = "1234"
slot = "$(./hsmdaemon listslots | grep Slot: | head -1 | tr -d 'Slot: ,')" # The token has been initialized and is reassigned to slot 1188462905
EO_TOML


