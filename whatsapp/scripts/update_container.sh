echo "Starting update container script"

# ACTIVATE BOT
echo "Starting whatsapp webhook"
ruby /app/bin/webhook.rb &

# UPDATE CRONJOBS
echo "Starting cronjobs"
ruby /app/bin/execute_orchestrator.rb
