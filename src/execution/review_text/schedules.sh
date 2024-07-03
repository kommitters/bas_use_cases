#!/bin/bash

SCRIPTS_DIR="/app/src/execution/review_text"
LOGS_DIR="/app/logs"

# Cronjobs
CRON_JOBS=(
    "* 13-21 * * MON-FRI fetch_text_from_notion.rb"
    "*/5 13-22 * * MON-FRI write_text_review_requests_spec.rb"
    "*/5 13-22 * * MON-FRI review_text.rb"
    "*/5 13-22 * * MON-FRI write_text_review_in_notion_spec.rb"
    "*/5 13-22 * * MON-FRI update_review_text_state.rb"
    "00 23 * * MON-FRI garbage_collector.rb"
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
