#!/usr/bin/env bash
set -euo pipefail

echo "INITIALIZE WEBHOOKS"
export RACK_ENV="${APP_ENV:-staging}"

exec bundle exec ruby src/use_cases_execution/use_cases_webserver/app.rb
