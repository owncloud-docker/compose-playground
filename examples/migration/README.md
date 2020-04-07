# oc-ocis-migration

docker-compose up
docker-compose exec -e OC_PASS=relativity owncloud occ user:add einstein --password-from-env

- Add some files and shares in owncloud10 for einstein

docker-compose exec owncloud occ instance:export:user einstein /tmp/shared
docker-compose exec ocis migration import /tmp/shared/einstein


