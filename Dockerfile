FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV WHD_SCRIPTS=/scripts
ENV WHD_LISTEN_ADDR=:80

RUN apt-get update && apt-get upgrade -yq
RUN apt-get install gnupg2 wget -yq
RUN echo "deb http://packages.azlux.fr/debian/ buster main" | tee /etc/apt/sources.list.d/azlux.list
RUN wget -qO - https://azlux.fr/repo.gpg.key | apt-key add -
RUN apt-get update && apt-get upgrade -yq
RUN apt-get install git webhookd jq php-mysql php-common php-cli php-xml php-curl php-bcmath php-bz2 php-mbstring php-zip php-intl openssh-client -yq
RUN mkdir -p /root/.ssh
RUN mkdir -p /var/www/html
RUN mkdir -p /scripts
RUN { \
        echo "#!/usr/bin/env bash"; \
        echo "set -e"; \
        echo "if [ ! -f \"/root/.ssh/id_rsa\" ]; then"; \
        echo "ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa"; \
        echo "fi"; \
        echo "if [ ! -f \"/root/.ssh/known_hosts\" ]; then"; \
        echo "ssh-keyscan github.com >> /root/.ssh/known_hosts"; \
        echo "ssh-keyscan gitlab.com >> /root/.ssh/known_hosts"; \
        echo "fi"; \
        echo "webhookd"; \
    } > /usr/local/bin/entrypoint \
    && chmod a+rx /usr/local/bin/entrypoint \
    && apt-get -yq clean autoclean && apt-get -yq autoremove \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80/tcp

COPY github.sh /scripts/github.sh

RUN chmod -R +x /scripts/*

WORKDIR /var/www/html

ENTRYPOINT ["entrypoint"]
