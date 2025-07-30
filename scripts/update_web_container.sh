# INITIALIZE WEBHOOKS
echo "INITIALIZE WEBHOOKS"
RACK_ENV=production ruby src/use_cases_execution/use_cases_webserver/app.rb
