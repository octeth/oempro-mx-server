# Oempro MX Server

This module can be installed to any server regardless of Oempro installation. It will serve as a "catch-all" MX server for bounces, FBL reports and replies.

This module contains;

- Postfix
- Dovecot
- Supervisor
- PHP

## Installation Instructions

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

