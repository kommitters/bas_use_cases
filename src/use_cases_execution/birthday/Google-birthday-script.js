function sendBirthdaysToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  const tz = SpreadsheetApp.getActive().getSpreadsheetTimeZone();
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Collect today's birthdays
  const birthdays = rows
    .map(row => Object.fromEntries(headers.map((h, i) => [h, row[i]])))
    .filter(entry => {
      const birthday = parseDate(entry['Birthday']);
      if (!birthday) return false;
      const birthdayInTz = new Date(birthday.toLocaleString("en-US", { timeZone: tz }));
      const todayInTz = new Date(today.toLocaleString("en-US", { timeZone: tz }));
      return birthdayInTz.getMonth() === todayInTz.getMonth() && birthdayInTz.getDate() === todayInTz.getDate();
    })
    .map(entry => ({
      name: entry['Name'],
      birthday_date: format(entry['Birthday'])
    }));

  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');
  const token = PropertiesService.getScriptProperties().getProperty('WEBHOOK_TOKEN');
  if (!url) {
    Logger.log("Webhook URL not found in script properties.");
    return;
  }
  if (!token) {
    Logger.log("Webhook token not found in script properties.");
    return;
  }
  if (birthdays.length === 0) {
    Logger.log("There are no birthdays today.");
    return;
  }
  const payload = JSON.stringify({ birthdays });
  try {
    const res = UrlFetchApp.fetch(url, {
      method: 'post',
      contentType: 'application/json',
      payload,
      muteHttpExceptions: true,
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    Logger.log('Status: ' + res.getResponseCode());
    Logger.log('Response Body: ' + res.getContentText());
  } catch (err) {
    Logger.log('Error occurred while sending birthdays: ' + err.toString());
  }
}

/**
 * Sends next week's birthdays to the webhook.
 */
function sendBirthdaysNextWeekToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  const tz = SpreadsheetApp.getActive().getSpreadsheetTimeZone();

  const targetDate = new Date();
  targetDate.setHours(0, 0, 0, 0);
  targetDate.setDate(targetDate.getDate() + 7);

  // Collect next week's birthdays
  const birthdays = rows
    .map(row => Object.fromEntries(headers.map((h, i) => [h, row[i]])))
    .filter(entry => {
      const birthday = parseDate(entry['Birthday']);
      if (!birthday) return false;
      const birthdayThisYear = new Date(targetDate.getFullYear(), birthday.getMonth(), birthday.getDate());
      const tzBirthday = new Date(birthdayThisYear.toLocaleString("en-US", { timeZone: tz }));
      return tzBirthday.getTime() === targetDate.getTime();
    })
    .map(entry => ({
      name: entry['Name'],
      birthday_date: format(entry['Birthday'])
    }));

  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL_NW');
  const token = PropertiesService.getScriptProperties().getProperty('WEBHOOK_TOKEN');
  if (!url) {
    Logger.log("Webhook URL for next week not found in script properties.");
    return;
  }
  if (!token) {
    Logger.log("Webhook token not found in script properties.");
    return;
  }
  if (birthdays.length === 0) {
    Logger.log("There are no birthdays next week.");
    return;
  }
  const payload = JSON.stringify({ birthdays });
  try {
    const res = UrlFetchApp.fetch(url, {
      method: 'post',
      contentType: 'application/json',
      payload,
      muteHttpExceptions: true,
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    Logger.log('Status: ' + res.getResponseCode());
    Logger.log('Response Body: ' + res.getContentText());
  } catch (err) {
    Logger.log('Error occurred while sending next week birthdays: ' + err.toString());
  }
}

/**
 * Parses a date string or Date object to a Date.
 * @param {string|Date} val - The date value to parse.
 * @return {Date|null}
 */
function parseDate(val) {
  if (val instanceof Date) return val;
  if (typeof val === 'string' && val.includes('/')) {
    const [m, d, y] = val.split('/').map(Number);
    return new Date(y, m - 1, d);
  }
  const d = new Date(val);
  return isNaN(d) ? null : d;
}

/**
 * Formats a date to 'yyyy-MM-dd' in the given or spreadsheet's time zone.
 * @param {string|Date} date
 * @param {string|null} timeZone
 * @return {string}
 */
function format(date, timeZone = null) {
  const d = parseDate(date);
  if (!d) return '';
  const tz = timeZone || SpreadsheetApp.getActive().getSpreadsheetTimeZone();
  return Utilities.formatDate(d, tz, "yyyy-MM-dd");
}
