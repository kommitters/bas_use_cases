## Script to Send Google Calendar Activity

This script is designed to fetch Google Calendar activity reports from the last 24 hours and send them to a webhook exposed by the backend.

---

## Script

```javascript
/**
 * Fetches Google Calendar activity reports from the last 24 hours
 * and sends them to a configured webhook.
 */
function sendCalendarEventsToWebhook() {
  try {
    const properties = PropertiesService.getScriptProperties();
    const webhookUrl = properties.getProperty('WEBHOOK_URL');
    const startTime = getStartTime();

    const activities = fetchCalendarActivities(startTime);

    if (activities.length === 0) {
      Logger.log('No new calendar activities found to send.');
      return;
    }

    Logger.log(`Sending ${activities.length} calendar activities to webhook...`);
    const response = postToWebhook(webhookUrl, { calendar_events: activities });

    Logger.log(`Webhook response: Status ${response.getResponseCode()}, Body: ${response.getContentText()}`);
  } catch (e) {
    Logger.log(`Error in sendCalendarEventsToWebhook: ${e.toString()}`);
    Logger.log(`Stack: ${e.stack}`);
  }
}

function getStartTime() {
  const ONE_DAY_IN_MS = 24 * 60 * 60 * 1000;
  const now = new Date();
  return new Date(now.getTime() - ONE_DAY_IN_MS).toISOString();
}

function fetchCalendarActivities(startTime) {
  const activities = [];
  let pageToken;

  do {
    const response = AdminReports.Activities.list('all', 'calendar', {
      startTime: startTime,
      pageToken: pageToken
    });

    if (response.items?.length) {
      activities.push(...response.items);
    }

    pageToken = response.nextPageToken;
  } while (pageToken);

  return activities;
}

function postToWebhook(url, payload) {
  const options = {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  };

  return UrlFetchApp.fetch(url, options);
}
```

---

## Environment Variables and Configuration

Set up this variable in the Script Properties section in the Google Apps Script editor.

- **WEBHOOK_URL**: The backend URL that will receive the calendar events including the path (i.e it should end with /calendar_events). For local development, you can expose the backend via a tunnel like Ngrok or Cloudflare Tunnels.

---

For instructions on setting up the script, creating time-driven triggers, required permissions, manual testing, notes, and implementing the backend webhook, please refer to [Google-apps-readme.md](./Google-apps-readme.md).
