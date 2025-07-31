function sendBirthdaysToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  const tz = SpreadsheetApp.getActive().getSpreadsheetTimeZone();
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const dayOfWeek = today.getDay(); 
  const isWeekend = (dayOfWeek === 0 || dayOfWeek === 6);
  if (isWeekend) return false;

  const birthdays = rows
    .map(row => Object.fromEntries(headers.map((h, i) => [h, row[i]])))
    .filter(entry => {
      const birthday = parseDate(entry['Birthday']);
      const birthdayInTz = new Date(birthday.toLocaleString("en-US", {timeZone: tz}));
      const todayInTz = new Date(today.toLocaleString("en-US", {timeZone: tz}));
      return birthdayInTz.getMonth() === todayInTz.getMonth() && birthdayInTz.getDate() === todayInTz.getDate();
    })
    .map(entry => ({
      name: entry['Name'],
      birthday_date: format(entry['Birthday'])
    }));

  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');

  if (!url) {
    Logger.log("⚠️ No se encontró la URL del webhook.");
    return;
  }

  if (birthdays.length === 0) {
    Logger.log("ℹ️ No hay cumpleaños hoy.");
    return;
  }

  const payload = JSON.stringify({ birthdays });
  console.log(birthdays)
  try {
    const res = UrlFetchApp.fetch(url, {
      method: 'post',
      contentType: 'application/json',
      payload,
      muteHttpExceptions: true
    });
    Logger.log('Status:', res.getResponseCode());
    Logger.log('Body:', res.getContentText());
  } catch (err) {
    Logger.log('Error: ' + err.toString());
  }
}

function parseDate(val) {
  if (val instanceof Date) return val;
  if (typeof val === 'string' && val.includes('/')) {
    const [m, d, y] = val.split('/').map(Number);
    return new Date(y, m - 1, d);
  }
  return new Date(val);
}

function format(date, timeZone = null) {
  const d = parseDate(date);
  const tz = timezone || SpreadsheetApp.getActive().getSpreadsheetTimeZone();
  return Utilities.formatDate(d, tz, "yyyy-MM-dd");
}
