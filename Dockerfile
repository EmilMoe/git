FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://packages.azlux.fr/debian/ buster main" | tee /etc/apt/sources.list.d/azlux.list
RUN wget -qO - https://azlux.fr/repo.gpg.key | apt-key add -
RUN apt-get update && apt-get upgrade -yq
RUN apt-get install git webhookd jq -yq
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
RUN mkdir -p /var/www/html
RUN mkdir -p /scripts
RUN { \
        echo "#!/usr/bin/env bash"; \
        echo "set -e"; \
        echo "git pull --ff -r"; \
        webhookd -scripts=/scripts; \
    } > /usr/local/bin/entrypoint \
    && chmod a+rx /usr/local/bin/entrypoint \
    && apt-get -yq clean autoclean && apt-get -yq autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY github.sh /scripts/github.sh

WORKDIR /var/www/html

ENTRYPOINT ["entrypoint"]
