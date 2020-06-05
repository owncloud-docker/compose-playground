#! /bin/bash
#
# If we exit non-zero, xdg-open continues with a fallback cascade and tries another browser...
#
#
# Initial call for oidc:
#   curl 'https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=4PptQfVWFPuFcNZPNbyx0Hvx1FYWG5LwUu1j9_HPbxM&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A42449&response_type=code&scope=openid+offline_access+email+profile&state=d0zNIJwPhpfuaCN1CnOBPkaNU8bFib6RM78RMUsH9ac%3D&user=demo' \
#  -H 'Connection: keep-alive' \
#  -H 'Pragma: no-cache' \
#  -H 'Cache-Control: no-cache' \
#  -H 'Upgrade-Insecure-Requests: 1' \
#  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/81.0.4044.122 Chrome/81.0.4044.122 Safari/537.36' \
#  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
#  -H 'Sec-Fetch-Site: none' \
#  -H 'Sec-Fetch-Mode: navigate' \
#  -H 'Sec-Fetch-User: ?1' \
#  -H 'Sec-Fetch-Dest: document' \
#  -H 'Accept-Language: en-US,en;q=0.9' \
#  --compressed \
#  --insecure
##########################
#
#   curl 'https://95.216.214.88:9200/signin/v1/identifier/_/logon' \
#  -H 'Connection: keep-alive' \
#  -H 'Accept: application/json, text/plain, */*' \
#  -H 'Kopano-Konnect-XSRF: 1' \
#  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/81.0.4044.122 Chrome/81.0.4044.122 Safari/537.36' \
#  -H 'Content-Type: application/json;charset=UTF-8' \
#  -H 'Origin: https://95.216.214.88:9200' \
#  -H 'Sec-Fetch-Site: same-origin' \
#  -H 'Sec-Fetch-Mode: cors' \
#  -H 'Sec-Fetch-Dest: empty' \
#  -H 'Referer: https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=4PptQfVWFPuFcNZPNbyx0Hvx1FYWG5LwUu1j9_HPbxM&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A42449&response_type=code&scope=openid+offline_access+email+profile&state=d0zNIJwPhpfuaCN1CnOBPkaNU8bFib6RM78RMUsH9ac%3D&user=demo' \
#  -H 'Accept-Language: en-US,en;q=0.9' \
#  --data-binary '{"params":["einstein","relativity","1"],"hello":{"prompt":"consent","scope":"openid offline_access email profile","client_id":"xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69","redirect_uri":"http://localhost:42449","flow":"oidc"},"state":"5ye9qd"}' \
#  --compressed \
#  --insecure
#
###  shortened to mimimum:
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/logon' -H 'Kopano-Konnect-XSRF: 1' -H 'Content-Type: application/json;charset=UTF-8' -H 'Referer: https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=4PptQfVWFPuFcNZPNbyx0Hvx1FYWG5LwUu1j9_HPbxM&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A42449&response_type=code&scope=openid+offline_access+email+profile&state=d0zNIJwPhpfuaCN1CnOBPkaNU8bFib6RM78RMUsH9ac%3D&user=demo' --data-binary '{"params":["einstein","relativity","1"],"hello":{"prompt":"consent","scope":"openid offline_access email profile","client_id":"xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69","redirect_uri":"http://localhost:42449","flow":"oidc"},"state":"5ye9qd"}' --insecure --cookie-jar cookie.jar
#
#### response
#  Set-Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJuemNlRlBWUHhnb0tIeHJmIiwidGFnIjoiZmRoSXlPMDFjTmljaTBNOFNtVlBXUSJ9.EyH5EdtiH6L3XoUTRNiTlptEFTnxJct-2XV_eJtoqz4.dDwoAbivXCPyo998.iWLQDMkb4u5dI8S9O-OqlcggWXkV78b7yQeDos9VEEU8za-lABmwPUZnbonHQwNUDX8RIVBDxWy6XCac3SdAm4LsrNTiUKziWZi8gr5mZNchh4_3ePb3lrVq_CMDsVKAbpYij3mZOmSqeoLaefDyntgvDjNO-ueWqInrTtmi2TzqQfpXzstb3zp5kdFno7CbbxVygeIrZ-a48tlMaubWhfu5jXDmLW7CXL7GfKJ4N1XXRi56wrNx7M9Gk6Gq2mzbb-ZvC5mhoYh2XDnOIWEAXT8SHWUOhGwAfgnORLFFrAO0kBJ_ucXDlPB-QKRj_BwGAxPkTZOO13gFxQuo_ACeRB9XgyKVhxeKIA.mp-FKDxtDQuQjjl4S-PLfg; Path=/signin/v1/identifier/_/; HttpOnly; Secure; SameSite=None
# Set-Cookie: __Secure-KKBS=; Path=/konnect/v1/session/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Secure; SameSite=None
# Set-Cookie: __Secure-KKBS=; Path=/konnect/v1/session/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Secure; SameSite=None
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
#
# {
#   "success": true,
#   "state": "5ye9qd",
#   "hello": {
#     "state": "",
#     "flow": "oidc",
#     "success": true,
#     "username": "einstein",
#     "displayName": "Einstein",
#     "next": "consent",
#     "continue_uri": "https://95.216.214.88:9200/signin/v1/identifier/_/authorize",
#     "scopes": {
#       "email": true,
#       "offline_access": true,
#       "openid": true,
#       "profile": true
#     },
#     "client": {
#       "id": "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69",
#       "display_name": "ownCloud desktop app",
#       "redirect_uri": "http://localhost:42449",
#       "trusted": false
#     },
#
# The next call is the authorization to the continue_url, that should generate the token:
# which is identical to the original call from the client but with some more:
#  curl -i -k -L -b cookie.jar -c cookie.jar 'https://95.216.214.88:9200/signin/v1/identifier/_/authorize?response_type=code&client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&redirect_uri=http://localhost:39363&code_challenge=pe2IbPifE-0yZ2JndmpPijU4aVnfWqnG7uN9ZKTJ_w8&code_challenge_method=S256&scope=openid%20offline_access%20email%20profile&prompt=consent&state=CzNCMja_G6O7MWl6WSwH1B_yPmXFKLuUIB58UC5WVgM%3D&user=einstein'
#
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/authorize?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=pe2IbPifE-0yZ2JndmpPijU4aVnfWqnG7uN9ZKTJ_w8&code_challenge_method=S256&konnect=rk3ppk&prompt=none&redirect_uri=http%3A%2F%2Flocalhost%3A39363&response_type=code&scope=openid%20offline_access%20email%20profile&state=CzNCMja_G6O7MWl6WSwH1B_yPmXFKLuUIB58UC5WVgM%3D&user=einstein' \
#   -H 'Connection: keep-alive' \
#   -H 'Upgrade-Insecure-Requests: 1' \
#   -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/81.0.4044.122 Chrome/81.0.4044.122 Safari/537.36' \
#   -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
#   -H 'Sec-Fetch-Site: same-origin' \
#   -H 'Sec-Fetch-Mode: navigate' \
#   -H 'Sec-Fetch-User: ?1' \
#   -H 'Sec-Fetch-Dest: document' \
#   -H 'Referer: https://95.216.214.88:9200/signin/v1/consent?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=pe2IbPifE-0yZ2JndmpPijU4aVnfWqnG7uN9ZKTJ_w8&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A39363&response_type=code&scope=openid+offline_access+email+profile&state=CzNCMja_G6O7MWl6WSwH1B_yPmXFKLuUIB58UC5WVgM%3D&user=einstein' \
#   -H 'Accept-Language: en-US,en;q=0.9' \
#   -H 'Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJTdXNrTUp6RTk1bV81MWNpIiwidGFnIjoiaDhRR21CcTd6eUdYUDVkMG1QMlAtZyJ9.XANrKfF-2o28uXYO5xUjYFPNPeTphEQUk-Ys2tZ2xgc.PDSp3KvOGkDaxR-o.09F8YZ4o2ktcRpvvwoImwvTEmb0c1ULOefUv-tH5Z2esNoaxa43vhkMPUAPOwdxBf32WsZNrQq7sY0x-rdD8PWCdvbrMKaoEu4q1E_L76G9dexc9BtAjb9CmjBzSak1NztH4E24L6z-mGHt4B48udInG_ARXoR_nm5D0d79E9Cf2XcllWUgVObN3-dkHxzY2nAKU94TjFenAayZ4julReDzJhWway0feiphkOVC6xkth34-5qTVc50fgBP163GQwTgjASxwmrklLIo-DzPAXwWMTYSqe1dcmy_mfquTWxIlNNXtGz-5GTZnqG71-vfpMBDDNAiq3IgNdlfKb_IXdSZyK0ZsJu3lpfQ.GLacS4ovZ7GsVx68traHuQ; VyXiYoesS0viWH7J8l_ABON7G0XVlE9cehNDHpcVXxU=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJ1NzhSbnVnLXo2dFZYSzh4IiwidGFnIjoiRHJMdnJfZW0wNDltRmJYSEpyLWpqUSJ9.zCXc8MvELz0Uy5ODj7m8jKh7c6WNu4G1ZNwVVRZD8bU.esf2oOCGe58tmVXd.yOvSnWbxhX4rOqnZ1DmQjpwDUD8TR4k-6Z-Y6SwJRangGN38Ey4B0lgtWSSjoZO-S9QaZKrcMBhKPia_.dEPWbekoUyMPC1kp470GDA' \
#   --compressed \
#   --insecure

self=$(basename $0)

if echo "$1" | grep -q "signin/v1/identifier"; then
  query_01="$1"
  tmpdir=/tmp/oidc-login-123
  trap "rm -rf $tmpdir" EXIT

  if [ -z "$OC_OIDC_LOGIN_USERNAME" ]; then
    echo "$self: Environment variable OC_OIDC_LOGIN_USERNAME not set. Exiting."
    exit 2
  fi
  if [ -z "$OC_OIDC_LOGIN_PASSWORD" ]; then
    echo "$self: Environment variable OC_OIDC_LOGIN_PASSWORD not set. Exiting."
    exit 3
  fi

  mkdir -p $tmpdir
  cookiejar=$tmpdir/cookie.jar
  rm -f $cookiejar
  echo "$self: intercepting openID Connect call ..."
  set -x
  echo $query_01 > $tmpdir/01.query
  # follow the first redirect, and see what we get. Exact response is unimportant, it just should look nice.
  curl -s -i -k -L -c $cookiejar $query_01 | tee $tmpdir/01.response
  if ! grep -q 'HTTP/1.1 200 OK' $tmpdir/01.response; then
    grep 'HTTP/1.1 ' $tmpdir/01.response
    echo "$self: Expected 200 OK response not seen. Exiting."
    exit 1
  fi
  referer=$(sed -ne  's@^Location: @@p' $tmpdir/01.response | tr -d \\015)	# strip CR-LF, yes, headers have that!
  test -z "$referer" && referer=$query_01 	# there was no redirect
  origin=$(   echo $referer | sed -ne 's@^\(https\?://[^/][^/]*\).*@\1@p')
  client_id=$(echo $referer | sed -ne 's@.*\bclient_id=\([^&]*\).*@\1@p')
  redirect=$( echo $referer | sed -ne 's@.*\bredirect_uri=\([^&]*\).*@\1@p' | sed -e 's@%3A@:@g' -e 's@%2F@/@g')	# undo url-escaping, if any
  state="42"

  # now we blindly log in like we learned it from a browser's web-console and hope for the best.
  # An attempt with "prompt":"none" results in "400 Bad Request - prompt none requested"
  declare -a query_02
  query_02=($origin/signin/v1/identifier/_/logon -H 'Kopano-Konnect-XSRF: 1' -H 'Content-Type: application/json;charset=UTF-8' -H "Referer: $referer")
  query_02+=(--data-binary '{"params":["'$OC_OIDC_LOGIN_USERNAME'","'$OC_OIDC_LOGIN_PASSWORD'","1"],"hello":{"prompt":"consent","scope":"openid offline_access email profile","client_id":"'$client_id'","redirect_uri":"'$redirect'","flow":"oidc"},"state":"'$state'"}')
  echo "${query_02[*]}" > $tmpdir/02.query
  curl -s -i -k -L -b $cookiejar -c $cookiejar "${query_02[@]}" | tee $tmpdir/02.response
  if grep -q 'HTTP/1.1 204 No Content' $tmpdir/02.response; then
    echo "$self: 204 No Content: Wrong password?"
    exit 4
  fi
  if ! grep -q 'HTTP/1.1 200 OK' $tmpdir/02.response; then
    grep 'HTTP/1.1 ' $tmpdir/02.response
    echo "$self: Expected 200 OK login response not seen. Exiting."
    exit 5
  fi
  # We want to see
  #   "success": true,
  #   "success": true,
  #   "displayName": "Einstein",
  #   "display_name": "ownCloud desktop app",
  grep '"success' $tmpdir/02.response
  grep '"display' $tmpdir/02.response

  # after logging in, we have a cookie. Now we repeat the initial query, but with konnect=rk3pp and prompt=none instead of prompt=consent
  # FIXME: That is one step too early, we have to get the consent first!
  query_03=$(echo $query_01 | sed -e 's/\bprompt=consent\b/konnect=rk3ppk\&prompt=none/')
  echo $query_03 > $tmpdir/03.query
  curl -s -i -k -L -b $cookiejar -c $cookiejar $query_03 | tee $tmpdir/03.response

  rm -f $cookiejar
  exit 0
fi

if echo "$1" | grep -q "index.php/apps/oauth2/authorize"; then
  echo "$self: intercepting oauth call ..."
  echo "$self: ... not implemented. Fall back to BROWSER"
fi

test -z "$BROWSER" && BROWSER=chromium-browser
echo calling: $BROWSER "$@"
exec $BROWSER "$@"
