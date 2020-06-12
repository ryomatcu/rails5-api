#!/usr/bin/env bash

if [ -n "$RAILS_ENV" ]
  then
    echo "RAILS_ENV set to $RAILS_ENV"
  else
    echo 'RAILS_ENV not set, default to production'
    export RAILS_ENV='production'
fi

echo "migrate to command: \"bundle exec rake db:create\""
bundle exec rake db:create

echo "migrate to command: \"bundle exec rake db:migrate\""
bundle exec rake db:migrate

echo "default to command: \"bundle exec rails server -e $RAILS_ENV -p 8080\""
exec bundle exec rails server -b 0.0.0.0 -e "$RAILS_ENV" -p 8080
