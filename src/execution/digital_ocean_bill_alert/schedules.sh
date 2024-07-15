#!/bin/bash

SCRIPTS_DIR="/app/src/execution/digital_ocean_bill_alert"
LOGS_DIR="/app/logs"

# Cronjobs
CRON_JOBS=(
    "*/5 * * * * fetch_billing_from_digital_ocean.rb"
    "*/5 * * * * format_do_bill_alert.rb"
    "*/5 * * * * notify_do_bill_alert_discord.rb"
    "00 00 * * * garbage_collector.rb"
)

# Temporary file to store the new crontab
TEMP_CRONTAB=$(mktemp)

# Iterate over each cronjob configuration and add to the crontab file
for CRON_JOB in "${CRON_JOBS[@]}"
do
    # Split the schedule and script name
    SCHEDULE=$(echo "$CRON_JOB" | awk '{print $1, $2, $3, $4, $5}')
    SCRIPT=$(echo "$CRON_JOB" | awk '{print $6}')

    touch $LOGS_DIR/$SCRIPT.log

    # Add the cronjob
    echo "$SCHEDULE /usr/local/bin/ruby $SCRIPTS_DIR/$SCRIPT >> $LOGS_DIR/$SCRIPT.log 2>&1" >> $TEMP_CRONTAB
done

# Print
cat $TEMP_CRONTAB

# Clean up
rm $TEMP_CRONTAB
