#! /bin/bash
#
# If we exit non-zero, xdg-open continues with a fallback cascade and tries another browser...
#
#
#### Protocol log # captured at firefox, when user at testpilotcloud first run wizard enters https://95.216.214.88:9200 for the first time:
# # Kopano login
# #
# # -> user enters einstein relativity on the login mask
# 
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/logon' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H 'Kopano-Konnect-XSRF: 1' -H 'Origin: https://95.216.214.88:9200' -H 'Connection: keep-alive' -H 'Referer: https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=lQQGX4yWb5xaEq3vUu-vtANW3b0A0e4orT-bKNu0ORk&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A38397&response_type=code&scope=openid+offline_access+email+profile&state=gbDU4vjNlo7f4ilhQc4hZ_9rBXOXqjQmfQyZBOVnZW0%3D' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw '{"params":["einstein","relativity","1"],"hello":{"prompt":"consent","scope":"openid offline_access email profile","client_id":"xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69","redirect_uri":"http://localhost:38397","flow":"oidc"},"state":"y9dkw5"}'
# # POST
# 
# HTTP/1.1 200 OK
# Access-Control-Allow-Origin: *
# Cache-Control: no-cache, no-store, must-revalidate
# Content-Length: 1032
# Content-Type: application/json; encoding=utf-8
# Date: Sun, 07 Jun 2020 20:15:10 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Sun, 07 Jun 2020 20:15:10 GMT
# Pragma: no-cache
# Set-Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJVYUR4a0doQVo1aWUyMUlSIiwidGFnIjoiMW15Vkc2T0FXRWx0dWlZRUJnaWZFZyJ9.nCUu4hFJG5_JwSsdREv8YQPHiwG5s-aG8TJTOhRUxvs.MIQD2dzI1JlLlqxG.KPaEqcZpm5jIo-uJCfCuX0vKJ6emzKLt7ORFJZmUQnLT3ntHDGmQMOM1bmJPbtfEiqj8S_EetXq-5Q-yD_VBhBsgPbPmJAjE3Y4HVeLp7qabApIrDJe5mfe87oHpNxUddgQ7axM0PtC88ELcpesFo2RHfuSlGgFTurZQQf9fWw2iQ4-gxJGAVKOYMEsuLgFjUf1HyDqPuJYq9DyBgZB7eJ6DN0quVgcT6NsXkPAc_P13dNHyMTSxvldfsOdW5qd-RsuKC4-52ZXLWsmAKcsoIDJ_LIe8-8EWUv86MLe8Qh0l9IMt0_UybG_k3T6hIAm29NVNqyj4LG5NUHl68wtsFTok6Nhg94OSHA.5ovqOaz70PzdnXdSTZuI3w; Path=/signin/v1/identifier/_/; HttpOnly; Secure; SameSite=None
# Set-Cookie: __Secure-KKBS=; Path=/konnect/v1/session/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Secure; SameSite=None
# Set-Cookie: __Secure-KKBS=; Path=/konnect/v1/session/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Secure; SameSite=None
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
# 
# {
#   "success": true,
#   "state": "y9dkw5",
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
#       "redirect_uri": "http://localhost:38397",
#       "trusted": false
#     },
#     "meta": {
#       "scopes": {
#         "mapping": {
#           "email": "basic",
#           "openid": "basic",
#           "profile": "basic"
#         },
#         "definitions": {
#           "basic": {
#             "priority": 20,
#             "id": "scope_alias_basic"
#           },
#           "offline_access": {
#             "priority": 10,
#             "id": "scope_offline_access"
#           }
#         }
#       }
#     }
#   }
# }
# 
# 
# # ownCloud desktop app wants to 
# # [x] Access your basic account information
# # [x] Keep the allowed acess persistently and forever
# #
# # -> User allows ownCloud desktop app to do this -> ALLOW
# 
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/consent' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H 'Kopano-Konnect-XSRF: 1' -H 'Origin: https://95.216.214.88:9200' -H 'Connection: keep-alive' -H 'Referer: https://95.216.214.88:9200/signin/v1/consent?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=lQQGX4yWb5xaEq3vUu-vtANW3b0A0e4orT-bKNu0ORk&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A38397&response_type=code&scope=openid+offline_access+email+profile&state=gbDU4vjNlo7f4ilhQc4hZ_9rBXOXqjQmfQyZBOVnZW0%3D' -H 'Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJVYUR4a0doQVo1aWUyMUlSIiwidGFnIjoiMW15Vkc2T0FXRWx0dWlZRUJnaWZFZyJ9.nCUu4hFJG5_JwSsdREv8YQPHiwG5s-aG8TJTOhRUxvs.MIQD2dzI1JlLlqxG.KPaEqcZpm5jIo-uJCfCuX0vKJ6emzKLt7ORFJZmUQnLT3ntHDGmQMOM1bmJPbtfEiqj8S_EetXq-5Q-yD_VBhBsgPbPmJAjE3Y4HVeLp7qabApIrDJe5mfe87oHpNxUddgQ7axM0PtC88ELcpesFo2RHfuSlGgFTurZQQf9fWw2iQ4-gxJGAVKOYMEsuLgFjUf1HyDqPuJYq9DyBgZB7eJ6DN0quVgcT6NsXkPAc_P13dNHyMTSxvldfsOdW5qd-RsuKC4-52ZXLWsmAKcsoIDJ_LIe8-8EWUv86MLe8Qh0l9IMt0_UybG_k3T6hIAm29NVNqyj4LG5NUHl68wtsFTok6Nhg94OSHA.5ovqOaz70PzdnXdSTZuI3w' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw '{"allow":true,"scope":"email offline_access openid profile","client_id":"xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69","redirect_uri":"http://localhost:38397","ref":"gbDU4vjNlo7f4ilhQc4hZ_9rBXOXqjQmfQyZBOVnZW0=","flow_nonce":"","state":"qzhbr"}'
# # POST
# 
# HTTP/1.1 200 OK
# Access-Control-Allow-Origin: *
# Cache-Control: no-cache, no-store, must-revalidate
# Content-Length: 42
# Content-Type: application/json; encoding=utf-8
# Date: Sun, 07 Jun 2020 20:20:08 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Sun, 07 Jun 2020 20:20:08 GMT
# Pragma: no-cache
# Set-Cookie: SHowz0MfPHfr_hFIszqQNyP4CqJwzfHh2t8iiIJRkX4=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJMQi1BSDFiNng5dTRWeEoyIiwidGFnIjoib3Rub1paeGNaVGZ3TDlTNkczbVdvUSJ9.3hzpj2MLQu23zt54xrF-KGde4yjnYEaXnT0BEy_Ic0Y.A8U78xetI9FzOXM5.-DR_6nnCzYvqXaGB7LhcEAImkx65Sh9J170x14WajoOWfqbYj_mDMvr4zhjQYTFfJ162t39IJbUhR6qd.Wv9RsewNK5Q8EQ8mKYOpZw; Path=/signin/v1/identifier/_/; Max-Age=60; HttpOnly; Secure; SameSite=None
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
# 
# {
#   "success": true,
#   "state": "qzhbr"
# }
# 
# # then without user interaction
# 
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/authorize?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=lQQGX4yWb5xaEq3vUu-vtANW3b0A0e4orT-bKNu0ORk&code_challenge_method=S256&konnect=qzhbr&prompt=none&redirect_uri=http%3A%2F%2Flocalhost%3A38397&response_type=code&scope=openid%20offline_access%20email%20profile&state=gbDU4vjNlo7f4ilhQc4hZ_9rBXOXqjQmfQyZBOVnZW0%3D' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' -H 'Referer: https://95.216.214.88:9200/signin/v1/consent?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=lQQGX4yWb5xaEq3vUu-vtANW3b0A0e4orT-bKNu0ORk&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A38397&response_type=code&scope=openid+offline_access+email+profile&state=gbDU4vjNlo7f4ilhQc4hZ_9rBXOXqjQmfQyZBOVnZW0%3D' -H 'Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJVYUR4a0doQVo1aWUyMUlSIiwidGFnIjoiMW15Vkc2T0FXRWx0dWlZRUJnaWZFZyJ9.nCUu4hFJG5_JwSsdREv8YQPHiwG5s-aG8TJTOhRUxvs.MIQD2dzI1JlLlqxG.KPaEqcZpm5jIo-uJCfCuX0vKJ6emzKLt7ORFJZmUQnLT3ntHDGmQMOM1bmJPbtfEiqj8S_EetXq-5Q-yD_VBhBsgPbPmJAjE3Y4HVeLp7qabApIrDJe5mfe87oHpNxUddgQ7axM0PtC88ELcpesFo2RHfuSlGgFTurZQQf9fWw2iQ4-gxJGAVKOYMEsuLgFjUf1HyDqPuJYq9DyBgZB7eJ6DN0quVgcT6NsXkPAc_P13dNHyMTSxvldfsOdW5qd-RsuKC4-52ZXLWsmAKcsoIDJ_LIe8-8EWUv86MLe8Qh0l9IMt0_UybG_k3T6hIAm29NVNqyj4LG5NUHl68wtsFTok6Nhg94OSHA.5ovqOaz70PzdnXdSTZuI3w; SHowz0MfPHfr_hFIszqQNyP4CqJwzfHh2t8iiIJRkX4=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJMQi1BSDFiNng5dTRWeEoyIiwidGFnIjoib3Rub1paeGNaVGZ3TDlTNkczbVdvUSJ9.3hzpj2MLQu23zt54xrF-KGde4yjnYEaXnT0BEy_Ic0Y.A8U78xetI9FzOXM5.-DR_6nnCzYvqXaGB7LhcEAImkx65Sh9J170x14WajoOWfqbYj_mDMvr4zhjQYTFfJ162t39IJbUhR6qd.Wv9RsewNK5Q8EQ8mKYOpZw' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache'
# 
# HTTP/1.1 302 Found
# Access-Control-Allow-Origin: *
# Cache-Control: no-store
# Content-Length: 0
# Date: Sun, 07 Jun 2020 20:20:08 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Sun, 07 Jun 2020 20:20:08 GMT
# Location: http://localhost:38397?code=X-Rp9zCN1blRh2QjCEaCjD5YI9RpTSVe&scope=openid%20offline_access%20email%20profile&session_state=414f0c294ee36f7548168b59a8d7f0fc92df377ccaf4af26630d871669800392.q7eSH35l2FE-4sxostSacZaykmxBQqFZPw06OAo47Ag%3D&state=gbDU4vjNlo7f4ilhQc4hZ_9rBXOXqjQmfQyZBOVnZW0%3D
# Pragma: no-cache
# Referrer-Policy: origin
# Set-Cookie: SHowz0MfPHfr_hFIszqQNyP4CqJwzfHh2t8iiIJRkX4=; Path=/signin/v1/identifier/_/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; Secure; SameSite=None
# __Secure-KKCS=VrLOmBuALBDq+AxDFAji/aC4+3k+aQ8FL8R80D24RkjyOc1NLcxMPmnZq5I0kCMrk7NK0mrpvGli8V/T7JCtw+ckwQqoEpR+o5vd3mqbs6sRB207EKx/INeuox1jVBZG3osT6P3pGiIA49LlHWxilC8ERN94eLuM3vdtDq0exurJ429VKQl6DFeXS/pKgAwkqmfUZYqSXLFHvQ5IkNMIAEEw+FQksOgxKB2g20F02xuAlgNTvtvIkVBsGJaklLLLe3JPr4oMqKYtJWT5WyWVM5VUTN11lynfMUbmyrdythExvFnVfMkocSX8Bkt5vgTwDTkbliXJfi+DsaYsLAezAEpYBSS+rvZ8911zmw==; Path=/signin/v1/identifier/_; HttpOnly; Secure; SameSite=None
# __Secure-KKBS=58Ma86w00fbsuHkt-s1MlX2mKsHVrnY-c_LS3aVvn64; Path=/konnect/v1/session/; Secure; SameSite=None
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
# 
# 
# # this redirect triggers 
# 
# curl 'http://localhost:38397/?code=X-Rp9zCN1blRh2QjCEaCjD5YI9RpTSVe&scope=openid%20offline_access%20email%20profile&session_state=414f0c294ee36f7548168b59a8d7f0fc92df377ccaf4af26630d871669800392.q7eSH35l2FE-4sxostSacZaykmxBQqFZPw06OAo47Ag%3D&state=gbDU4vjNlo7f4ilhQc4hZ_9rBXOXqjQmfQyZBOVnZW0%3D' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://95.216.214.88:9200/' -H 'Connection: keep-alive' -H 'Cookie: oc5h7h0t7qyl=cfsser4po8hflllbkrhusr67a1; oc_sessionPassphrase=FFobqne3uGPuSjyHf4iqG6kOA4vD6EHE48Rs0JdSaVHcaWsHNr7xGLH5ULHtgCPPTqyxCCoB7GwN2KEEtiEXXDpHzxJDdGcfXmaKroB7Pl0wFxWh4Irpi%2BAZzPkMKxjN; ocvg8vh9fy5m=7l7hi4ijvbknlu64io33vjdk2i' -H 'Upgrade-Insecure-Requests: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache'
# 
# HTTP/1.1 200 OK
# Content-Type: text/html; charset=utf-8
# Connection: close
# Content-Length: 58
# 
# <h1>Login Successful</h1><p>You can close this window.</p>
###########################

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
