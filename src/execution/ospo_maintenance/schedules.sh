#!/bin/bash

SCRIPTS_DIR="/app/src/execution/ospo_maintenance"
LOGS_DIR="/app/logs"

# Cronjobs
CRON_JOBS=(
    "*/5 * * * * bas_fetch_issues.rb"
    "*/5 * * * * verify_issue_existance_in_notion.rb"
    "*/5 * * * * create_work_item.rb"
    "00 00 * * * update_work_item.rb"
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
