function sendNextWeekToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);

  const { monday, sunday } = getNextWeekRange();

  const ptos = rows
    .map(row => Object.fromEntries(headers.map((h, i) => [h, row[i]])))
    .filter(entry => {
      const start = toDateOnly(entry['StartDateTime']);
      const end = toDateOnly(entry['EndDateTime']);
      const dayValue = entry['Day'];
      const isPTO = entry['Category']?.includes('PTO');

      const startsInRange = start >= monday && start <= sunday;
      const endsInRange = end >= monday && end <= sunday;
      const coversRange = start <= monday && end >= sunday;

      return (
        (startsInRange || endsInRange || coversRange) &&
        isPTO &&
        dayValue === 'Full Day'
      );
    })
    .map(entry => {
      const name = entry['Person'] || 'Someone';
      const start = toDateOnly(entry['StartDateTime']);
      const end = toDateOnly(entry['EndDateTime']);
      return formatMessage(name, start, end);
    });

  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL_NW_PTO');
  const token = PropertiesService.getScriptProperties().getProperty('WEBHOOK_TOKEN');
  if (!url || ptos.length === 0) return;

  const payload = JSON.stringify({ ptos });
  console.log(ptos);

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
    console.log('Status:', res.getResponseCode());
    console.log('Body:', res.getContentText());
  } catch (err) {
    console.error('Error:', err);
  }
}

function getNextWeekRange() {
  const today = new Date();
  const day = today.getDay();
  const daysUntilNextMonday = day === 0 ? 1 : 8 - day;

  const monday = new Date(today);
  monday.setDate(today.getDate() + daysUntilNextMonday);
  monday.setHours(0, 0, 0, 0);

  const sunday = new Date(monday);
  sunday.setDate(monday.getDate() + 6);
  sunday.setHours(0, 0, 0, 0);

  return { monday, sunday };
}

function toDateOnly(val) {
  const date = new Date(val);
  date.setHours(0, 0, 0, 0);
  return date;
}

function formatDateString(date) {
  return date.toISOString().split('T')[0];
}

function formatMessage(name, startDate, endDate) {
  const startStr = formatDateString(startDate);
  const endStr = formatDateString(endDate);
  const returnStr = getNextWorkday(endDate);
  return `${name} will not be working between ${startStr} and ${endStr}. And returns the ${returnStr}`;
}

function getNextWorkday(date) {
  const next = new Date(date);
  switch (next.getDay()) {
    case 5: next.setDate(next.getDate() + 3); break; // Friday → Monday
    case 6: next.setDate(next.getDate() + 2); break; // Saturday → Monday
    default: next.setDate(next.getDate() + 1); break;
  }
  return formatDateString(next);
}
