build:
	docker build --no-cache -t oempro-mx-server .

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
	-p 25:25 \
	--name oempro-mx-server oempro-mx-server
