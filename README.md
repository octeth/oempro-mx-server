# Oempro MX Server

This module can be installed to any server regardless of Oempro installation. It will serve as a "catch-all" MX server for bounces, FBL reports and replies.

This module contains;

- Postfix
- Dovecot
- Supervisor
- PHP

## Installation Instructions

```shell
make build
make run
```

## Oempro Integration Instructions

...

## To Do

-[] Configure Dovecot
-[] Configure a cron job to empty the mail file every X days
-[] Setup a web mail browser
-[] Turn this into a package and make it configurable
-[] Add to the git repo
-[] Push to the Docker hub
-[] Integrate alias server to Oempro
-[] Ioncube compile the code(?)
-[] Instead of voliume mount of the alias server, add it to the container