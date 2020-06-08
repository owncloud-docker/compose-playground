#! /bin/bash
#
# If we exit non-zero, xdg-open continues with a fallback cascade and tries another browser...
#
#
#### Protocol log # captured at firefox, when user at testpilotcloud first run wizard enters https://95.216.214.88:9200 for the first time:
### 01.query
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/authorize?response_type=code&client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&redirect_uri=http://localhost:41043&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&scope=openid%20offline_access%20email%20profile&prompt=consent&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache'
# GET
#
### 01.response
# HTTP/1.1 302 Found
# Access-Control-Allow-Origin: *
# Cache-Control: no-store
# Content-Length: 0
# Date: Mon, 08 Jun 2020 22:24:28 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Mon, 08 Jun 2020 22:24:28 GMT
# Location: https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A41043&response_type=code&scope=openid+offline_access+email+profile&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein
# Pragma: no-cache
# Referrer-Policy: origin
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
#
#
# # The Location redirect takes us to:
# curl 'https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A41043&response_type=code&scope=openid+offline_access+email+profile&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache'
# GET
#
# HTTP/1.1 200 OK
# Access-Control-Allow-Origin: *
# Cache-Control: no-cache, no-store, max-age=0, must-revalidate, value
# Content-Length: 865
# Content-Type: text/html; charset=utf-8
# Date: Mon, 08 Jun 2020 22:24:29 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Mon, 08 Jun 2020 22:24:29 GMT
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
#
# <!DOCTYPE html><html lang="en"><head data-kopano-build="0.28.1-3-gabe57b2-dirty"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"><meta name="theme-color" content="#ffffff"><link rel="shortcut icon" href="./static/favicon.ico" type="image/x-icon"><meta property="csp-nonce" content="9aRKS7gp4CMZigF-JDES4Jh2FQMu4ShCG4FzjBl-O7E="><title>Kopano Sign in</title><link href="./static/css/main.ed0ebb7d.chunk.css" rel="stylesheet"></head><body><noscript>You need to enable JavaScript to run this app.</noscript><div id="bg"><div id="bg-thumb"></div><div id="bg-enhanced"></div></div><div id="root" data-path-prefix="/signin/v1"></div><div id="font-preloader"><span>aA</span>Bb</div><script src="./static/js/runtime~main.766bf48a.js"></script><script src="./static/js/main.c5511071.chunk.js"></script></body></html>
#
# The scripts that load take us to (not needed)
# 01b.query
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/hello' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H 'Kopano-Konnect-XSRF: 1' -H 'Origin: https://95.216.214.88:9200' -H 'Connection: keep-alive' -H 'Referer: https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A41043&response_type=code&scope=openid+offline_access+email+profile&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw '{"prompt":"consent","scope":"openid offline_access email profile","client_id":"xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69","redirect_uri":"http://localhost:41043","flow":"oidc","state":"mj7ct5"}'
# POST
# 01b.response
#
# HTTP/1.1 204 No Content
# Access-Control-Allow-Origin: *
# Cache-Control: no-cache, no-store, must-revalidate
# Date: Mon, 08 Jun 2020 22:39:18 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Kopano-Konnect-State: mj7ct5
# Last-Modified: Mon, 08 Jun 2020 22:39:18 GMT
# Pragma: no-cache
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
#
#
# # Kopano login
# #
# # -> user enters einstein relativity on the login mask
# 02.query
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/logon' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H 'Kopano-Konnect-XSRF: 1' -H 'Origin: https://95.216.214.88:9200' -H 'Connection: keep-alive' -H 'Referer: https://95.216.214.88:9200/signin/v1/identifier?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A41043&response_type=code&scope=openid+offline_access+email+profile&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw '{"params":["einstein","relativity","1"],"hello":{"prompt":"consent","scope":"openid offline_access email profile","client_id":"xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69","redirect_uri":"http://localhost:41043","flow":"oidc"},"state":"6230s"}'
# POST
# 02.response
#
# HTTP/1.1 200 OK
# Access-Control-Allow-Origin: *
# Cache-Control: no-cache, no-store, must-revalidate
# Content-Length: 1031
# Content-Type: application/json; encoding=utf-8
# Date: Mon, 08 Jun 2020 22:44:24 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Mon, 08 Jun 2020 22:44:24 GMT
# Pragma: no-cache
# Set-Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJrN0t5OURheDlvY2xXNmdZIiwidGFnIjoiWWtXOF9PdGdtMWZKY0l0Yy1iUXJadyJ9.09D8JIWXbgrp4cGactYMOHpuyMfD1FEKfhr6A3T5m34.Jz9YD80W-9Wn2y-p.LDp_l8a2KANnhzopnnX93TmOWf_UkN7s8WoToe_SdZpJ2CpGQF2C_PO0Gkv5kXARY5SamfmDobJE6jF6jNpBitvyo0itKIoU8EpVdtf75H6T7bGexBP6EphAB029BsCRD64nMkSnk_-nuzdQ_4NO6R9phIgFEdPiI0CW46tY_7ioHINwNK0f9_d8sAt44sxxCpAlLIvEUPQnJiKH3xhKM0SDHKu9X9-HDa6pEWE3Iay6-9EY2dPkI0N11W3csuTLFzwTSGgqzytyoE-wQxxPnkLuCPVMmq5WOaiMpExwUqKT4XDWKdxwE8c_F__9upxI2oweIEPxB6zLhitby3rKuiFiKWpyhhDywQ.mPS5ynGO-4LY4s0fvB2P_A; Path=/signin/v1/identifier/_/; HttpOnly; Secure; SameSite=None
# __Secure-KKBS=; Path=/konnect/v1/session/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Secure; SameSite=None
# __Secure-KKBS=; Path=/konnect/v1/session/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Secure; SameSite=None
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
#
# {
#   "success": true,
#   "state": "6230s",
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
#       "redirect_uri": "http://localhost:41043",
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
# 03.query
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/consent' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/json;charset=utf-8' -H 'Kopano-Konnect-XSRF: 1' -H 'Origin: https://95.216.214.88:9200' -H 'Connection: keep-alive' -H 'Referer: https://95.216.214.88:9200/signin/v1/consent?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A41043&response_type=code&scope=openid+offline_access+email+profile&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein' -H 'Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJrN0t5OURheDlvY2xXNmdZIiwidGFnIjoiWWtXOF9PdGdtMWZKY0l0Yy1iUXJadyJ9.09D8JIWXbgrp4cGactYMOHpuyMfD1FEKfhr6A3T5m34.Jz9YD80W-9Wn2y-p.LDp_l8a2KANnhzopnnX93TmOWf_UkN7s8WoToe_SdZpJ2CpGQF2C_PO0Gkv5kXARY5SamfmDobJE6jF6jNpBitvyo0itKIoU8EpVdtf75H6T7bGexBP6EphAB029BsCRD64nMkSnk_-nuzdQ_4NO6R9phIgFEdPiI0CW46tY_7ioHINwNK0f9_d8sAt44sxxCpAlLIvEUPQnJiKH3xhKM0SDHKu9X9-HDa6pEWE3Iay6-9EY2dPkI0N11W3csuTLFzwTSGgqzytyoE-wQxxPnkLuCPVMmq5WOaiMpExwUqKT4XDWKdxwE8c_F__9upxI2oweIEPxB6zLhitby3rKuiFiKWpyhhDywQ.mPS5ynGO-4LY4s0fvB2P_A' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw '{"allow":true,"scope":"email offline_access openid profile","client_id":"xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69","redirect_uri":"http://localhost:41043","ref":"w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw=","flow_nonce":"","state":"imyj3"}'
# POST
# 03.response
#
# HTTP/1.1 200 OK
# Access-Control-Allow-Origin: *
# Cache-Control: no-cache, no-store, must-revalidate
# Content-Length: 42
# Content-Type: application/json; encoding=utf-8
# Date: Mon, 08 Jun 2020 22:47:22 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Mon, 08 Jun 2020 22:47:22 GMT
# Pragma: no-cache
# Set-Cookie: 1SK2N3E2-EeDNVxHsJLubMfz_PQr2NdkjRdWMhfGKyM=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiIxdnlZdUUwaWNubFZLUzNUIiwidGFnIjoieWszaFZNcHQwRTRDWjR6VlN0c19FZyJ9.u7sdwC8I26Nl1eyi2kJjKWr5jlQHCF0N0V1dpQBOy5o.xOuwxdxLFsf1mcqq.MITnapQW4Ld26v-v8cpRLyDiPyNorbVQrYTV1XVVgyXI3fiIkPiH0nx0MiBWmfriwYzLNSSQkGZAOc1J.PxVnhr6Z2bk4Xf903K2nKQ; Path=/signin/v1/identifier/_/; Max-Age=60; HttpOnly; Secure; SameSite=None
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
#
# {
#   "success": true,
#   "state": "imyj3"
# }
#
# directly afterwards without user interaction:
#
# 04.query
# curl 'https://95.216.214.88:9200/signin/v1/identifier/_/authorize?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&konnect=imyj3&prompt=none&redirect_uri=http%3A%2F%2Flocalhost%3A41043&response_type=code&scope=openid%20offline_access%20email%20profile&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' -H 'Referer: https://95.216.214.88:9200/signin/v1/consent?client_id=xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69&code_challenge=OLfovbuyxn71pPWQiKT1DVkqYdYHI1qJ-Eu7SGvpFSs&code_challenge_method=S256&flow=oidc&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A41043&response_type=code&scope=openid+offline_access+email+profile&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D&user=einstein' -H 'Cookie: __Secure-KKT=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiJrN0t5OURheDlvY2xXNmdZIiwidGFnIjoiWWtXOF9PdGdtMWZKY0l0Yy1iUXJadyJ9.09D8JIWXbgrp4cGactYMOHpuyMfD1FEKfhr6A3T5m34.Jz9YD80W-9Wn2y-p.LDp_l8a2KANnhzopnnX93TmOWf_UkN7s8WoToe_SdZpJ2CpGQF2C_PO0Gkv5kXARY5SamfmDobJE6jF6jNpBitvyo0itKIoU8EpVdtf75H6T7bGexBP6EphAB029BsCRD64nMkSnk_-nuzdQ_4NO6R9phIgFEdPiI0CW46tY_7ioHINwNK0f9_d8sAt44sxxCpAlLIvEUPQnJiKH3xhKM0SDHKu9X9-HDa6pEWE3Iay6-9EY2dPkI0N11W3csuTLFzwTSGgqzytyoE-wQxxPnkLuCPVMmq5WOaiMpExwUqKT4XDWKdxwE8c_F__9upxI2oweIEPxB6zLhitby3rKuiFiKWpyhhDywQ.mPS5ynGO-4LY4s0fvB2P_A; 1SK2N3E2-EeDNVxHsJLubMfz_PQr2NdkjRdWMhfGKyM=eyJhbGciOiJBMjU2R0NNS1ciLCJlbmMiOiJBMjU2R0NNIiwiaXYiOiIxdnlZdUUwaWNubFZLUzNUIiwidGFnIjoieWszaFZNcHQwRTRDWjR6VlN0c19FZyJ9.u7sdwC8I26Nl1eyi2kJjKWr5jlQHCF0N0V1dpQBOy5o.xOuwxdxLFsf1mcqq.MITnapQW4Ld26v-v8cpRLyDiPyNorbVQrYTV1XVVgyXI3fiIkPiH0nx0MiBWmfriwYzLNSSQkGZAOc1J.PxVnhr6Z2bk4Xf903K2nKQ' -H 'Upgrade-Insecure-Requests: 1' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache'
# GET
# 04.response
#
# HTTP/1.1 302 Found
# Access-Control-Allow-Origin: *
# Cache-Control: no-store
# Content-Length: 0
# Date: Mon, 08 Jun 2020 22:47:23 GMT
# Expires: Thu, 01 Jan 1970 00:00:00 GMT
# Last-Modified: Mon, 08 Jun 2020 22:47:23 GMT
# Location: http://localhost:41043?code=Gf9jWXJ7hkVgljjfA21v3ShIBhLgIcH4&scope=offline_access%20email%20profile%20openid&session_state=2e1df62cf55765eb61033aca4b64e10cffdbb572734c454c5ee0466cae2136bb.Awp47WBTD6o6lNuPAmwWsUghjBljop9q4RDvwDbG5dA%3D&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D
# Pragma: no-cache
# Referrer-Policy: origin
# Set-Cookie: 1SK2N3E2-EeDNVxHsJLubMfz_PQr2NdkjRdWMhfGKyM=; Path=/signin/v1/identifier/_/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; Secure; SameSite=None
# __Secure-KKCS=8Ez/S89t9h8alfpxZUpCVvkjL2GokO7LGyKfInAXpcG5mQv8z4J5QPFAvY9Rtl+YRqNpsB6JLB8mgmqnmaRfxDE+WANV94Q5lXtgZJZbyp221wlA3TU7RdYL83PP71JcQDl+ZUFXqW+IGwAwyKVrsr/R4VFO4qZM9llN+BzYY0i3E3YaqNrMkd1P1tNKQw3xuyjJyM46jutl7vb4xF658Xpl4UeDtKxNd+I4k5j+p8tUxt6a724+R1fDWxh+G8bFiwCkUl2uHK0e5tdNQ+qXyp4cU+tlXM8vitmvXtHbonsvfhDEcYbn06TcVFua1zU3tLTRQFD6oBNij5hzFoLwsurArtVmdACYrm4fDA==; Path=/signin/v1/identifier/_; HttpOnly; Secure; SameSite=None
# __Secure-KKBS=58Ma86w00fbsuHkt-s1MlX2mKsHVrnY-c_LS3aVvn64; Path=/konnect/v1/session/; Secure; SameSite=None
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# X-Konnectd-Version: 0.0.0
# X-Xss-Protection: 1; mode=block
#
#
# Redirect to local client with the desired code=. Bingo.
#############################
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
  tmpdir=/tmp/oidc-login-123	# $$
  # trap "rm -rf $tmpdir" EXIT

  if [ -z "$OC_OIDC_LOGIN_USERNAME" ]; then
    echo "$self: Environment variable OC_OIDC_LOGIN_USERNAME not set. Exiting."
    exit 1
  fi
  if [ -z "$OC_OIDC_LOGIN_PASSWORD" ]; then
    echo "$self: Environment variable OC_OIDC_LOGIN_PASSWORD not set. Exiting."
    exit 1
  fi

  mkdir -p $tmpdir
  cookiejar=$tmpdir/cookie.jar
  rm -f $cookiejar
  echo "$self: intercepting openID Connect call ..."

  echo $query_01 > $tmpdir/01.query
  # follow the first redirect, and see what we get. Exact response is unimportant, it just should look nice.
  curl -s -i -k -L -c $cookiejar $query_01 > $tmpdir/01.response
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
  refstate=$(      echo $referer | sed -ne 's@.*\bstate=\([^&]*\).*@\1@p' | sed -e 's@%3D@=@g')				# undo url-escaping, if any
  state="42"

  # now we blindly log in like we learned it from a browser's web-console and hope for the best.
  # An attempt with "prompt":"none" results in "400 Bad Request - prompt none requested"
  declare -a query_02
  query_02=($origin/signin/v1/identifier/_/logon -H 'Kopano-Konnect-XSRF: 1' -H 'Content-Type: application/json;charset=UTF-8' -H "Referer: $referer")
  query_02+=(--data-binary '{"params":["'$OC_OIDC_LOGIN_USERNAME'","'$OC_OIDC_LOGIN_PASSWORD'","1"],"hello":{"prompt":"consent","scope":"openid offline_access email profile","client_id":"'$client_id'","redirect_uri":"'$redirect'","flow":"oidc"},"state":"'$state'"}')
  echo "${query_02[*]}" > $tmpdir/02.query
  curl -s -i -k -L -b $cookiejar -c $cookiejar "${query_02[@]}" > $tmpdir/02.response
  if grep -q 'HTTP/1.1 204 No Content' $tmpdir/02.response; then
    echo "$self: 204 No Content: Wrong password?"
    exit 1
  fi
  if ! grep -q 'HTTP/1.1 200 OK' $tmpdir/02.response; then
    grep 'HTTP/1.1 ' $tmpdir/02.response
    echo "$self: Expected 200 OK login response not seen. Exiting."
    exit 1
  fi
  # We want to see
  #   "success": true,
  #   "success": true,
  #   "displayName": "Einstein",
  #   "display_name": "ownCloud desktop app",
  grep '"success":' $tmpdir/02.response | sed -e "s/^/$self: /"
  grep '"display'   $tmpdir/02.response | sed -e "s/^/$self: /"

  # After logging in, we have a cookie. With that, we give our consent to authorize the app.
  conreferer=$(echo $referer | sed -e 's@signin/v1/identifier@signin/v1/consent@')

  declare -a query_03
  query_03=(https://95.216.214.88:9200/signin/v1/identifier/_/consent -H 'Kopano-Konnect-XSRF: 1' -H 'Content-Type: application/json;charset=utf-8' -H 'Origin: '$origin -H 'Referer: '$conreferer --data-raw '{"allow":true,"scope":"email offline_access openid profile","client_id":"'$client_id'","redirect_uri":"'$redirect'","ref":"'$ref'","flow_nonce":"","state":"'$state'"}')
  echo "${query_03[*]}" > $tmpdir/03.query
  curl -s -i -k -L -b $cookiejar -c $cookiejar "${query_03[@]}" > $tmpdir/03.response

  #
  # Now we repeat the initial query, but with konnect=42 and prompt=none and a state, instead of just prompt=consent
  query_04=$(echo $query_01 | sed -e 's/\bprompt=consent\b/konnect='$state'\&prompt=none\&state='$ref'/')
  echo $query_04 > $tmpdir/04.query
  curl -s -i -k -L -b $cookiejar -c $cookiejar $query_04 > $tmpdir/04.response

  ## The final redirect should bring us back to the client with e.g.
  # http://localhost:41043/?code=B8mLss0cCnNOwaj7KvFM1TZzDaREKOLF&scope=profile%20openid%20offline_access%20email&session_state=78978fe0ad9549b23a0ea58eddf42cab0dfb7ac5537528893e65f32ac16d2778.3N1_W6PNuRcYool8V6Pj_aYaKzH3_T0h0W7SlZCwSzw%3D&state=w1PN6UIPr8G9i-AyuyLXUHfAiME8Wf4kq4gFz4Dvgzw%3D
  if ! grep -q code= $tmpdir/04.response; then
    cat $tmpdir/04.response
    echo "$self: final authorize did not return an access code"
    exit 1
  fi
  sed -ne 's@.*\(\bcode=[^&]*\).*@\1@p' /tmp/oidc-login-123/04.response | sed -e "s/^/$self: /"
  tail -n 1 /tmp/oidc-login-123/04.response | sed -e 's/You can close this window/../' -e "s/^/$self: /"
  echo
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
