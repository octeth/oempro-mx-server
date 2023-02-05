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

## Oempro Integration Instructions

...

## To Do

- [ ] Configure a cron job to empty the mail file every X days
- [ ] Setup a web mail browser
- [ ] Turn this into a package and make it configurable
- [ ] Push to the Docker hub
- [ ] Integrate alias server to Oempro
- [ ] Ioncube compile the code(?)
- [ ] Instead of volume mount of the alias server, add it to the container
- [ ] TLS support for both Postfix and Dovecot
