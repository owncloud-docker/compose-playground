#! /bin/bash
#
# owncloud client uses xdg-open to call a browser.
# this gets into uncontrollable special cases per desktop flavour per default.
# We can force it into the generic case, by specifying XDG_CURRENT_DESKTOP=X-Generic
#
# Then, effectively "xdg-mime query default x-scheme-handler/https" is consulted to find the
# correct browser for an https URL. this tool can be redirected to a local
# mini-database with XDG_DATA_HOME, so that in the end ./bin/mock_browser.sh is called.

client_name=$1
server_url=$2
user_name=$3	
password=$4	
shift; shift
shift; shift

test -z "$client_name" && client_name=owncloud
test -z "$server_url"  && server_url=https://demo.owncloud.com
test -z "$user_name"   && user_name=demo
test -z "$password"    && password=demo

if killall -s 0 $client_name 2>/dev/null; then
  echo "A process named '$client_name' is already running. Aboring."
  echo "Please quit that process (or choose another client), then try again"
  exit 1
fi

echo client_name=$client_name server_url=$server_url user_name=$user_name password=$password

mydir=$(readlink -f $(dirname $0))

# for ./bin/oidc_login_redirect.sh
export OC_OIDC_LOGIN_USERNAME="$user_name"
export OC_OIDC_LOGIN_PASSWORD="$password"

# for /usr/bin/xdg-open
export XDG_CURRENT_DESKTOP=X-Generic
export XDG_DATA_HOME=$mydir/xdg_data_home
export PATH=$mydir/bin:$PATH

## prepare a sync folder
sync_folder=$mydir/sync-$client_name
test -n "$OC_SYNC_FOLDER" && sync_folder="$OC_SYNC_FOLDER"
mkdir -p $sync_folder
test -z "$OC_SYNC_FOLDER" && rm -f $sync_folder/.sync_*		# start without local database unless user takes control of the sync folder

## prepare a config file with server and sync folder
mkdir -p $mydir/conf
cat <<EOF > $mydir/conf/$client_name.cfg
[Accounts]
0\url=$server_url
0\dav_user=$user_name
0\http_user=$user_name
0\user=$user_name
0\Folders\1\localPath=$sync_folder
0\Folders\1\ignoreHiddenFiles=true
0\Folders\1\paused=false
0\Folders\1\targetPath=/
0\Folders\1\usePlaceholders=false
0\Folders\1\virtualFilesMode=off
EOF

## grab the server certificate
server=$(echo $server_url | sed -e 's@.*://@@')
echo "$server" | grep -q : || server=$server:443
cert=$(echo | openssl s_client -connect $server 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'  | tr '\012' '@' | sed -e 's/@/\\n/g')

## trust it, what ever it is.
test -n "$cert" && echo "0\General\CaCertificates=\"@ByteArray($cert\n)\"" >> $mydir/conf/$client_name.cfg

set -x
$client_name --showsettings --confdir $mydir/conf "$@"
