FROM ubuntu:22.04

ARG root_password=root
ARG catchall_password=catchall

ENV root_password=$root_password
ENV catchall_password=$catchall_password

# Set time zone to UTC
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages
RUN apt update
RUN apt install -y postfix-pcre
RUN apt install -y php php-zip dovecot-imapd dovecot-pop3d telnet supervisor git

# Install Composer
WORKDIR /root/
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

# Change root password
RUN echo root:${root_password} | chpasswd

# Create "catchall" user account
RUN useradd -ms /bin/bash catchall
RUN echo catchall:${catchall_password} | chpasswd

# Entrypoint setup
ADD entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh
ENTRYPOINT /entrypoint.sh