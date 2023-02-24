# 172.19.0.10 -> oempro-mx-server
# 172.19.0.11 -> oempro-mx-serve    r-roundcube
# 172.19.0.12 -> oempro-mx-server-redis

include .env
export $(shell sed 's/=.*//' .env)

build:
	docker build --platform=linux/amd64 --no-cache -t oempro-mx-server --build-arg root_password=${root_password} --build-arg catchall_password=${catchall_password} .

run:
	-@docker rm oempro-mx-server

	-@docker network create --subnet=172.19.0.0/16 oempro-mx-server-network

	# Add this to mount the codebase '-v ${PWD}/alias-server:/opt/alias-server \' to enable debug mode
	@docker run -d -it --rm \
	-v ${PWD}/docker-data/supervisor-processes.conf:/etc/supervisor/conf.d/processes.conf \
	-v ${PWD}/docker-data/var-mail:/var/mail \
	-v ${PWD}/docker-data/etc-postfix:/etc/postfix \
	-v ${PWD}/docker-data/etc-dovecot:/etc/dovecot \
	-v ${PWD}/alias-server:/opt/alias-server \
	-p 143:143 \
	-p 993:993 \
	-p 110:110 \
	-p 995:995 \
	-p 25:25 \
	-h oempro-mx-server \
	--network oempro-mx-server-network --ip 172.19.0.10 \
	--name oempro-mx-server oempro-mx-server

	@docker run -d -it --rm \
	-e ROUNDCUBEMAIL_DEFAULT_HOST=host.docker.internal \
    -e ROUNDCUBEMAIL_SMTP_SERVER=host.docker.internal \
	-p 8000:80 \
	--add-host=host.docker.internal:host-gateway \
	-h oempro-mx-server-roundcube \
	--network oempro-mx-server-network --ip 172.19.0.11 \
	--name oempro-mx-server-roundcube \
	roundcube/roundcubemail

	@docker run -d -it --rm \
	-v ${PWD}/docker-data/redis-data:/data \
	-p 6379:6379 \
	--add-host=host.docker.internal:host-gateway \
	-h oempro-mx-server-redis \
	--network oempro-mx-server-network --ip 172.19.0.12 \
	--name oempro-mx-server-redis \
	redis:alpine

stop:
	-@docker stop oempro-mx-server
	-@docker stop oempro-mx-server-roundcube
	-@docker stop oempro-mx-server-redis

kill:
	-@docker kill oempro-mx-server
	-@docker kill oempro-mx-server-roundcube
	-@docker kill oempro-mx-server-redis
	-@docker network rm oempro-mx-server-network

destroy:
	-@docker stop oempro-mx-server
	-@docker image rm oempro-mx-server
	-@docker container rm oempro-mx-server

	-@docker stop oempro-mx-server-roundcube
	-@docker image rm oempro-mx-server-roundcube
	-@docker container rm oempro-mx-server-roundcube

	-@docker stop oempro-mx-server-redis
	-@docker image rm oempro-mx-server-redis
	-@docker container rm oempro-mx-server-redis
