#!/bin/bash

SCRIPTS_DIR="/app/src/execution/wip_limit"
LOGS_DIR="/app/logs"

# Cronjobs
CRON_JOBS=(
    "03 21 * * * fetch_domains_wip_count.rb"
    "04 21 * * * fetch_domains_wip_limit.rb"
    "05 21 * * * compare_wip_limit_count.rb"
    "06 21 * * * format_wip_limit_exceeded.rb"
    "07 21 * * * notify_domains_wip_limit_exceeded.rb"
    "08 21 * * * garbage_collector.rb"
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