function sendSheetToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  const tz = SpreadsheetApp.getActive().getSpreadsheetTimeZone();
  const today = new Date();
  const validDays = ['Full Day'];
  const dayOfWeek = today.getDay()
  const isWeekend = (dayOfWeek === 0 || dayOfWeek === 6);
  if(isWeekend) return false;

  const ptos = rows
    .map(row => Object.fromEntries(headers.map((h, i) => [h, row[i]])))
    .filter(entry => {
      const start = parseDate(entry['StartDateTime']);
      const end = parseDate(entry['EndDateTime']);
      const isToday = start.toDateString() === today.toDateString();
      const inRange = start <= today && today <= end;
      return (isToday || inRange)
        && entry['Category']?.includes('PTO')
        && validDays.includes(entry['Day']);
    })
    .map(entry => {
      const name = entry['Person'];
      const start = parseDate(entry['StartDateTime']);
      const end = parseDate(entry['EndDateTime']);

      return formatMessage(name, start, end);
    });

  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');
  if (!url || ptos.length === 0) return;

  const payload = JSON.stringify({ ptos });
  console.log(ptos)

  try {
    const res = UrlFetchApp.fetch(url, {
      method: 'post',
      contentType: 'application/json',
      payload,
      muteHttpExceptions: true
    });
    console.log('Status:', res.getResponseCode());
    console.log('Body:', res.getContentText());
  } catch (err) {
    console.error('Error:', err);
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

function formatMessage(name, startDate, endDate) {
  const startStr = formatDateString(startDate);
  const endStr = formatDateString(endDate);
  const returnStr = getNextWorkday(endDate);
  return `${name} will not be working between ${startStr} and ${endStr}. And returns the ${returnStr}`;
}

function formatDateString(date) {
  const options = { timeZone: 'UTC', year: 'numeric', month: '2-digit', day: '2-digit' };
  const [month, day, year] = new Intl.DateTimeFormat('en-US', options).format(date).split('/');
  return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
}

function getNextWorkday(date) {
  const next = new Date(date);
  switch (next.getDay()) {
    case 5: next.setDate(next.getDate() + 3); break; // Friday → Monday
    case 6: next.setDate(next.getDate() + 2); break; // Saturday → Monday
    default: next.setDate(next.getDate() + 1); break;
  }

  const options = { weekday: 'long', month: 'long', day: '2-digit', year: 'numeric', timeZone: 'UTC' };
  return new Intl.DateTimeFormat('en-US', options).format(next);
}

