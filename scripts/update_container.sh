# UPDATE DATABASE
echo "UPDATE DATABASE"
rake -f /app/scripts/update_database.rb db:migrate
echo "DATABASE UPDATED"

# UPDATE CRONJOBS
echo "INITIALIZE CRONJOBS"
ruby /app/scripts/execute_orchestrator.rb
