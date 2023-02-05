include .env
export $(shell sed 's/=.*//' .env)

build:
	docker build --no-cache -t oempro-mx-server --build-arg root_password=${root_password} --build-arg catchall_password=${catchall_password} .

run:
	-docker rm oempro-mx-server
	docker run -d -it --rm \
	-v ${PWD}/docker-data/supervisor-processes.conf:/etc/supervisor/conf.d/processes.conf \
	-v ${PWD}/alias-server:/opt/alias-server \
	-v ${PWD}/docker-data/var-mail:/var/mail \
	-v ${PWD}/docker-data/etc-postfix:/etc/postfix \
	-v ${PWD}/docker-data/etc-dovecot:/etc/dovecot \
	-p 143:143 \
	-p 993:993 \
	-p 110:110 \
	-p 995:995 \
	-p 25:25 \
	-h oempro-mx-server \
	--name oempro-mx-server oempro-mx-server

stop:
	docker stop oempro-mx-server

kill:
	docker kill oempro-mx-server

destroy:
	-docker stop oempro-mx-server
	-docker image rm oempro-mx-server
	-docker container rm oempro-mx-server
