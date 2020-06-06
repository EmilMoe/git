#!/bin/sh

GITHUB_SECRET=

# Functions
die() { echo "error: $@" 1>&2 ; exit 1; }
confDie() { echo "error: $@ Check the server configuration!" 1>&2 ; exit 2; }
debug() {
  [ "$debug" = "true" ] && echo "debug: $@"
}

# Validate global configuration
[ -z "$GITHUB_SECRET" ] && confDie "GITHUB_SECRET not set."

# Validate Github hook
signature=$(echo -n "$1" | openssl sha1 -hmac "$GITHUB_SECRET" | sed -e 's/^.* //')
[ "sha1=$signature" != "$x_hub_signature" ] && die "bad hook signature: expecting $x_hub_signature and got sha1=$signature"

# Validate parameters
payload=$1
[ -z "$payload" ] && die "missing request payload"
payload_type=$(echo $payload | jq type -r)
[ $? != 0 ] && die "bad body format: expecting JSON"
[ ! $payload_type = "object" ] && die "bad body format: expecting JSON object but having $payload_type"

debug "received payload: $payload"

# Do something with the payload:
# Here create a simple notification when an issue has been published
if [ "$x_github_event" = "push" ]
then
  cd /var/www/html
  git stash push --include-untracked
  git stash drop
  git pull -ff
  composer install --no-dev --no-interaction
  php artisan migrate --force
  php artisan db:seed --force
fi
