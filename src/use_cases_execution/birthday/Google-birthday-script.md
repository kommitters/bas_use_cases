# Birthday Notification Script

This script is designed to **post birthday notifications daily** from a Google Spreadsheet to a **webhook exposed**.

It checks for birthday entries where:
- The `Birthday` column matches **today's month and day**.
- The current day is **not filtered**, so it runs every day including weekends.

If birthdays are found, the script formats the output as a list of people with:
- `name`: Person’s name from the `Name` column.
- `birthday_date`: Formatted date in `YYYY-MM-DD` format.

Then, it sends the resulting data to a defined webhook (`WEBHOOK_URL` in Script Properties).

---

## Script

```javascript
function sendBirthdaysToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const birthdays = rows
    .map(row => Object.fromEntries(headers.map((h, i) => [h, row[i]])))
    .filter(entry => {
      const birthday = parseDate(entry['Birthday']);
      return birthday.getMonth() === today.getMonth() &&
             birthday.getDate() === today.getDate();
    })
    .map(entry => ({
      name: entry['Name'],
      birthday_date: formatDateString(entry['Birthday'])
    }));

  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');

  if (!url) {
    Logger.log("⚠️ Webhook URL not found.");
    return;
  }

  if (birthdays.length === 0) {
    Logger.log("ℹ️ No birthdays today.");
    return;
  }

  const payload = JSON.stringify({ birthdays });

  try {
    const res = UrlFetchApp.fetch(url, {
      method: 'post',
      contentType: 'application/json',
      payload,
      muteHttpExceptions: true
    });
    Logger.log('✅ Webhook sent. Status: ' + res.getResponseCode());
    Logger.log('📦 Response: ' + res.getContentText());
  } catch (err) {
    Logger.log('💥 Fetch error: ' + err.toString());
  }
}

function parseDate(val) {
  if (val instanceof Date) return val;
  if (typeof val === 'string') {
    if (val.includes('/')) {
      const [m, d, y] = val.split('/').map(Number);
      return new Date(y, m - 1, d);
    } else if (val.includes('-')) {
      const [y, m, d] = val.split('-').map(Number);
      return new Date(y, m - 1, d);
    }
  }
  return new Date(val);
}

function formatDateString(date) {
  const d = parseDate(date);
  return Utilities.formatDate(d, Session.getScriptTimeZone(), "yyyy-MM-dd");
}

```