docker-compose-up:
	bash create-identifier-registration.sh
	docker-compose up -d

docker-compose-up-foreground:
	bash create-identifier-registration.sh
	docker-compose up

docker-compose-down:
	rm -f config/identifier-registration.yml
	docker-compose down -v
