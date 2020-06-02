FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV WHD_SCRIPTS=/scripts
ENV WHD_LISTEN_ADDR=:80

RUN apt-get update && apt-get upgrade -yq
RUN groupadd -r www-data && useradd -r -g www-data do-agent
RUN apt-get install gnupg2 wget -yq
RUN echo "deb http://packages.azlux.fr/debian/ buster main" | tee /etc/apt/sources.list.d/azlux.list
RUN wget -qO - https://azlux.fr/repo.gpg.key | apt-key add -
RUN apt-get update && apt-get upgrade -yq
RUN apt-get install git webhookd jq openssh-client -yq
RUN mkdir -p /root/.ssh
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN ssh-keyscan gitlab.com >> /root/.ssh/known_hosts
RUN mkdir -p /var/www/html
RUN mkdir -p /scripts

EXPOSE 80/tcp 443/tcp

USER do-agent

COPY github.sh /scripts/github.sh
RUN chmod -R +x /scripts/*

WORKDIR /var/www/html

ENTRYPOINT ["webhookd"]
