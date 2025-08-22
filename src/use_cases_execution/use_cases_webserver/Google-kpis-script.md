## Script to Send KPIs from Google Sheets

This script is designed to fetch all data from the "KPIs Tracking" Google Sheet and send it to a configured webhook on the backend. The data is formatted and sorted before being sent.

---

## Script

```javascript
/**
 * Main function: fetches the raw data from the Google Sheet,
 * enriches it with IDs, formats it, and sends it to the configured webhook.
 * This is the function that should be triggered to run automatically.
 */
function sendKpisToWebhook() {
  try {
    const webhookUrl = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');
    if (!webhookUrl) {
      console.error('Error: WEBHOOK_URL is not set in Script Properties.');
      return;
    }

    const sheetDataWithIds = fetchSheetDataWithIds();
    console.log(sheetDataWithIds);

    if (!sheetDataWithIds || sheetDataWithIds.length <= 1) { // <= 1 to account for header-only sheets
      console.log('No data found in the sheet to send.');
      return;
    }

    console.log(`Sending ${sheetDataWithIds.length - 1} data rows to webhook...`);
    const payload = { "key_performance_raw": sheetDataWithIds };
    const response = postToWebhook(webhookUrl, payload);

    console.log(`Webhook response: Status ${response.getResponseCode()}, Body: ${response.getContentText()}`);
  } catch (e) {
    console.error(`Error in sendKpisToWebhook: ${e.toString()}`);
  }
}

/**
 * Fetches all raw data from the "KPIs Tracking" Google Sheet, reverses the order
 * of the rows, and appends a column with the external_kpi_id from a Google Doc.
 */
function fetchSheetDataWithIds() {
  const spreadsheetId = PropertiesService.getScriptProperties().getProperty('SPREADSHEET_ID');
  const documentId = PropertiesService.getScriptProperties().getProperty('DOCUMENT_ID');

  if (!spreadsheetId || !documentId) {
    throw new Error('SPREADSHEET_ID or DOCUMENT_ID is not set in Script Properties.');
  }

  try {
    const listItemMap = getListItemMapFromDoc(documentId);

    const sheetName = 'KPIs Tracking'; // Make sure this is the exact name of your sheet
    const sheet = SpreadsheetApp.openById(spreadsheetId).getSheetByName(sheetName);

    if (!sheet) {
      throw new Error(`Could not find a sheet named '${sheetName}'.`);
    }

    const values = sheet.getDataRange().getValues();
    const headers = values[0];

    // Reverse the order of the rows (excluding the header) so they are stored chronologically.
    const reversedRows = values.slice(1).reverse();

    const newHeaders = [...headers, "external_kpi_id"];

    const rowsWithIds = reversedRows.map(row => {
      const kpiName = row[0].toString().split(',')[0].trim();
      const externalId = listItemMap[kpiName] || "";
      return [...row, externalId];
    });

    return [newHeaders, ...rowsWithIds];
  } catch (e) {
    throw new Error(`Failed to fetch sheet data with IDs. Details: ${e.message}`);
  }
}

/**
 * Reads a Google Doc and creates a map of list items.
 * The key is the list item's text, and the value is its stable heading ID.
 */
function getListItemMapFromDoc(documentId) {
  const doc = DocumentApp.openById(documentId);
  const tabs = doc.getTabs();
  const listItemMap = {};

  console.log(`Found ${tabs.length} tab(s) to process.`);

  tabs.forEach(function(tab) {
    const tabId = tab.getId();
    const name = tab.getTitle().trim();
    listItemMap[name] = tabId;
  });

  return listItemMap;
}

/**
 * Sends a JSON payload to a specified URL via a POST request.
 */
function postToWebhook(url, payload) {
  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'payload': JSON.stringify(payload),
    'muteHttpExceptions': true
  };

  return UrlFetchApp.fetch(url, options);
}

```

---

## Environment Variables and Configuration

Set up this variable in the Script Properties section in the Google Apps Script editor.

- **SPREADSHEET_ID**: The unique ID of the Google Sheet containing the KPIs. You can find this in the sheet's URL (the long string between /d/ and /edit).

- **DOCUMENT_ID**: The unique ID of the Google Doc that contains the KPI IDs. This ID is also found in the document's URL.

- **WEBHOOK_URL**: The backend URL that will receive the raw sheet data, including the path (i.e., it should end with /kpis). For local development, you can expose the backend via a tunnel like Ngrok or Cloudflare Tunnels.

---

For instructions on setting up the script, creating time-driven triggers, required permissions, manual testing, notes, and implementing the backend webhook, please refer to [Google-apps-readme.md](./Google-apps-readme.md).
