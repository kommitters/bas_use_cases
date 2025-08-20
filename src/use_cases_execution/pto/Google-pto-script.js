function sendPtoNextWeekToWebhook() {
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

function sendPtoToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const dayOfWeek = today.getDay();
  const isWeekend = (dayOfWeek === 0 || dayOfWeek === 6);
  if (isWeekend) return false;

  const ptos = rows
    .map(row => Object.fromEntries(headers.map((h, i) => [h, row[i]])))
    .filter(entry => {
      const start = toDateOnly(entry['StartDateTime']);
      const end = toDateOnly(entry['EndDateTime']);
      const inRange = start <= today && today <= end;
      const dayValue = entry['Day'];

      return inRange &&
        entry['Category']?.includes('PTO') &&
        dayValue === 'Full Day';
    })
    .map(entry => {
      const name = entry['Person'];
      const start = toDateOnly(entry['StartDateTime']);
      const end = toDateOnly(entry['EndDateTime']);
      return formatMessage(name, start, end);
    });

  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');
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

// ---------- UTILITIES BELOW ----------

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

function formatMessage(name, startDate, endDate) {
  const startStr = formatDateString(startDate);
  const endStr = formatDateString(endDate);
  const returnStr = getNextWorkday(endDate);
  return `${name} will not be working between ${startStr} and ${endStr}. And returns the ${returnStr}`;
}

function formatDateString(date) {
/**
 * Converts a Date object to a string in 'yyyy-mm-dd' format using UTC.
 *
 * @param {Date} date - The date to format.
 * @returns {string} The formatted date as 'yyyy-mm-dd'. Returns an empty string if input is invalid.
 *
 * @example
 *   formatDateString(new Date(2025, 0, 4)); // Returns '2025-01-04'
 */

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

  return formatDateString(next);
}
// ---------- Notify ----------

function notifyPendingStakeholders() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sh = ss.getActiveSheet();
  const headers = sh.getRange(1, 1, 1, sh.getLastColumn()).getValues()[0];
  const gi = n => headers.indexOf(n) + 1;

  const stakeholderCol = gi("Stakeholder");
  const notificationCol = gi("Notification");
  const personCol = gi("Person");
  const projectCol = gi("Project");
  const startCol = gi("StartDateTime");
  const endCol = gi("EndDateTime");

  const lastRow = sh.getLastRow();
  const tz = ss.getSpreadsheetTimeZone();
  const fmt = d => Utilities.formatDate(new Date(d), tz, "yyyy-MM-dd");

  for (let row = 2; row <= lastRow; row++) {
    const stakeholder = sh.getRange(row, stakeholderCol).getValue();
    const notification = sh.getRange(row, notificationCol).getValue();

    if (stakeholder && String(notification).toUpperCase() !== "TRUE") {
      const stakeholders = String(stakeholder)
        .split(/[;,]/).map(s => s.trim()).filter(s => /@/.test(s));

      if (!stakeholders.length) continue;

      const person = sh.getRange(row, personCol).getValue();
      const project = sh.getRange(row, projectCol).getValue();
      const start = sh.getRange(row, startCol).getValue();
      const end = sh.getRange(row, endCol).getValue();

      const msg = `${person} will be on PTO from ${fmt(start)} to ${fmt(end)}.`;

      GmailApp.sendEmail(
        stakeholders.join(","),
        `PTO • ${person} • ${project}`,
        msg
      );

      sh.getRange(row, notificationCol).setValue(true);
      Logger.log(`✅ Notified: ${stakeholders.join(",")} for row ${row}`);
    }
  }
}
