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
      return birthday.getMonth() === today.getMonth() && birthday.getDate() === today.getDate();
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

  } catch (err) {
    Logger.log('💥 Error al hacer fetch: ' + err.toString());
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

function format(date) {
  const d = parseDate(date);
  return Utilities.formatDate(d, Session.getScriptTimeZone(), "yyyy-MM-dd");
}
