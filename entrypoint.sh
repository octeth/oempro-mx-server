#!/bin/bash

hostname --fqdn > /etc/mailname

/etc/init.d/dovecot start
/etc/init.d/supervisor start

postfix start

tail -f /dev/null