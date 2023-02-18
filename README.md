# Oempro MX Server

This module can be installed to any server regardless of Oempro installation. It will serve as a "catch-all" MX server for bounces, FBL reports and replies.

This module contains;

- Postfix
- Dovecot
- Supervisor
- PHP

## Production Server Installation Instructions

```shell
apt update
apt install -y software-properties-common sharutils apt-utils iputils-ping telnet git unzip zip openssl vim wget debconf-utils cron supervisor mysql-client docker.io ufw make
curl -L "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
mkdir /opt/oempro-mx-server
cd /opt/oempro-mx-server
git clone https://github.com/octeth/oempro-mx-server.git .
cp .env_example .env
cd alias-server/
cp .env_example .env
```

Set `.env` file configurations.

```shell
make build
make run
```

Edit the Postfix `main.cf` and change the `myhostname` parameter:

```shell
vi /opt/oempro-mx-server/docker-data/etc-postfix/main.cf
```

Once the Postfix configuration change is made, restart the container:

```shell
cd /opt/oempro-mx-server/
make kill
make run
```

> Make sure that Postfix `myhostname` value, server IP address PTR domain, and domain IP address match.

## Local Development Installation Instructions

Copy `.env_example` to `.env` and set the configuration. 

Then run:

```shell
make build
make run
```

## Purpose

The purpose of this project is to take care of asynchronous bounce DSN emails by a separate, robust system. When an email is sent, there are two different bounce possibilities:

- Asynchronous: This bounce occurs after the recipient MX server accepts the email. It accepts the email and then sends a delivery status notification email (DSN) to the MAIL-FROM domain MX server.
- Synchronous: This bounce occurs during the SMTP transfer of the email. The recipient MX server rejects the message with a 4.x.x or 5.x.x SMTP error code.

This project takes care of asynchronous bounce handling.

This project is powered by Postfix (for accepting incoming emails) and Dovecot IMAP server (for serving these received messages in IMAP protocol). We have also added PHP to the system to validate incoming emails.

## How It Works

When an async bounce occurs, the recipient MX server sends a delivery status notification (DSN) email to the MAIL-FROM domain MX server. The following workflow will be executed for each received DSN email to this system:

1. Postfix receives the email.
2. It validates the recipient domain with a TCP data communication via Oempro server. [Configuration is done in main.cf](https://github.com/octeth/oempro-mx-server/blob/main/docker-data/etc-postfix/main.cf#L41-L43)
   1. If Oempro cannot identify the MAiL-FROM domain, relaying denied error will be returned for unathorized MAIL-FROM domains.
   2. Otherwise, Oempro will simply identify the MAIL-FROM domain and the incoming email will be accepted by Postfix.
3. The received email will be stored inside `catchall` user mailbox file.
4. Oempro will connect to Dovecot, authenticate as `catchall` user and fetch emails from the mailbox for bounce processing.

## Accessing the IMAP Mailbox

You can access the IMAP mailbox by any third party IMAP email client.

The username is `catchall` and the password (`catchall_password`) written in the `.env` file. 

In addition to this, you can also use the built-in RoundCube Email Client to access the mailbox.

Simply visit `http://<server_ip_address>:8000` on your web browser. Enter the `catchall` username and the password written in the `.env` file.

## How To Enable TLS

First, edit `docker-data/etc-postfix/main.cf` file:

If you want to enforce TLS connections, set `smtpd_tls_security_level` to `encrypt`. Otherwise, set it to `may`.

Run these commands:

```shell
docker exec -ti oempro-mx-server bash
cd /tmp/
mkdir ssl
cd ssl
apt install wget
apt install certbot
wget https://github.com/joohoi/acme-dns-certbot-joohoi/raw/master/acme-dns-auth.py .
chmod +x acme-dns-auth.py
apt install nano
nano acme-dns-auth.py
```

Change `#!/usr/bin/env python` to `#!/usr/bin/env python3`. Save and exit the file.

Run the following command to request SSL certificate using Let's Encrypt. Make sure to replace `mx.yourdomain.com` with your MX server domain name.

```shell
certbot certonly --manual --manual-auth-hook ./acme-dns-auth.py --preferred-challenges dns --debug-challenges -d mx.yourdomain.com
```

Certbot will ask you to set a CNAME record on your MX domain to validate. Once your MX domain is validated, Certbot will save your SSL certificate files and display you the path.

Example:
```shell
Certificate is saved at: /etc/letsencrypt/live/mx.yourdomain.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/mx.yourdomain.com/privkey.pem
```

Copy these two files to `/etc/postfix/ssl/` directory:

```shell
cp /etc/letsencrypt/live/mx.yourdomain.com/fullchain.pem /etc/postfix/ssl/
cp /etc/letsencrypt/live/mx.yourdomain.com/privkey.pem /etc/postfix/ssl/
```

Edit `docker-data/etc-postfix/main.cf` file and update these variables:

```shell
smtpd_tls_cert_file=/etc/postfix/ssl/fullchain.pem
smtpd_tls_key_file=/etc/postfix/ssl/privkey.pem
```

Now restart Docker containers:

```shell
make kill
make run
```

In order to test and validate TLS, connect to your MX server by running this command:

```shell
openssl s_client -quiet -starttls smtp -connect locahost:25
```

and you should see the TLS validation in the beginning:

```text
depth=2 C = US, O = Internet Security Research Group, CN = ISRG Root X1
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = R3
verify return:1
depth=0 CN = mx.yourdomain.com
verify return:1
250 CHUNKING
```

That's it.

## Deploy To Docker Hub

```shell
make build
make run
docker commit -m 'Deploy commit' -a "Cem Hurturk" oempro-mx-server octeth/octeth_mx_server:v1.0.0
docker login -u cemhurturk
docker push octeth/octeth_mx_server:v1.0.0
```

> After `docker login`, enter the password you have set. [Check this kb article](https://www.notion.so/chmyos/Updating-Oempro-Docker-Container-cd62f83e5d054969bae57a51f25b0e91?pvs=4) for the password.



## Directory Structure

```
.
├── alias-server           # The PHP script to get the MAIL-FROM domain from Postfix and validate on Oempro
├── docker-data            # Dovecot, Postfix, Supervisor configuration, Mailbox directory
├── Dockerfile             # The Dockerfile for building the image required to run the container
├── Makefile               # Build, run, stop, etc.
├── entrypoint.sh          # Entrypoint file to execute when the container is spinned up.
└── README.md
```

## Oempro Integration Instructions

...

