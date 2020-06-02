#!/bin/sh

# Functions
die() { echo "error: $@" 1>&2 ; exit 1; }
confDie() { echo "error: $@ Check the server configuration!" 1>&2 ; exit 2; }
debug() {
  [ "$debug" = "true" ] && echo "debug: $@"
}

# Validate global configuration
[ -z "$GIT_SECRET" ] && confDie "GITLAB_TOKEN not set."

# Validate Gitlab hook
[ "$x_gitlab_token" != "$GIT_SECRET" ] && die "bad hook token"

# Validate parameters
payload=$1
[ -z "$payload" ] && die "missing request payload"
payload_type=$(echo $payload | jq type -r)
[ $? != 0 ] && die "bad body format: expecting JSON"
[ ! $payload_type = "object" ] && die "bad body format: expecting JSON object but having $payload_type"

debug "received payload: $payload"

# Extract values
object_kind=$(echo $payload | jq .object_kind -r)
[ $? != 0 -o "$object_kind" = "null" ] && die "unable to extract 'object_kind' from JSON payload"

# Do something with the payload:
# Here create a simple notification when a push has occured
if [ "$object_kind" = "push" ]
then
  git pull --ff
  php artisan migrate --force
  php artisan db:seed --force
fi
