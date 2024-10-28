#!/bin/bash

SCRIPTS_DIR="/app/src/execution/pto_next_week"
LOGS_DIR="/app/logs"

# Cronjobs
CRON_JOBS=(
    "40 12 * * THU fetch_next_week_pto_from_notion.rb"
    "50 12 * * THU humanize_next_week_pto.rb"
    "00 13 * * THU notify_next_week_pto_in_discord.rb"
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
