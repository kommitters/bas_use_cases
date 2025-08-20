## Script to Send Key Results from Google Sheets

This script is designed to fetch all raw data from the "OKRs 2025" Google Sheet and send it to a webhook exposed by the backend for processing and storage.

---

## Script

```javascript
/**
 * Main function: orchestrates fetching the raw data from the Google Sheet
 * and sending it to the configured webhook.
 * This is the function that should be triggered to run automatically.
 */
function sendKeyResultsToWebhook() {
  try {
    const webhookUrl = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');
    if (!webhookUrl) {
      console.error('Error: WEBHOOK_URL is not set in Script Properties.');
      return;
    }

    const sheetData = fetchSheetData();

    if (!sheetData || sheetData.length <= 1) { // <= 1 to account for header-only sheets
      console.log('No data found in the sheet to send.');
      return;
    }

    console.log(`Sending ${sheetData.length - 1} data rows to webhook...`);
    const payload = { "key_results_raw": sheetData };
    const response = postToWebhook(webhookUrl, payload);

    console.log(`Webhook response: Status ${response.getResponseCode()}, Body: ${response.getContentText()}`);
  } catch (e) {
    console.error(`Error in sendKeyResultsToWebhook: ${e.toString()}`);
  }
}

/**
 * Fetches all raw data from the Key Results Google Sheet.
 */
function fetchSheetData() {
  const spreadsheetId = PropertiesService.getScriptProperties().getProperty('SPREADSHEET_ID');
  if (!spreadsheetId) {
    throw new Error('SPREADSHEET_ID is not set in Script Properties.');
  }

  try {
    const sheetName = 'OKRs 2025'; // <-- Make sure this is your exact sheet name
    const sheet = SpreadsheetApp.openById(spreadsheetId).getSheetByName(sheetName);

    if (!sheet) {
      throw new Error(`Could not find a sheet named '${sheetName}'.`);
    }

    // Return all data in the sheet, including the header row.
    return sheet.getDataRange().getValues();
  } catch (e) {
    // Re-throw the error to be caught by the main function
    throw new Error(`Failed to access or process spreadsheet ${spreadsheetId}. Details: ${e.message}`);
  }
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

- **SPREADSHEET_ID**: The unique ID of the Google Sheet containing the Key Results. You can find this in the sheet's URL (the long string between /d/ and /edit).

- **WEBHOOK_URL**: The backend URL that will receive the raw sheet data, including the path (i.e., it should end with /key_results). For local development, you can expose the backend via a tunnel like Ngrok or Cloudflare Tunnels.

---

For instructions on setting up the script, creating time-driven triggers, required permissions, manual testing, notes, and implementing the backend webhook, please refer to [Google-apps-readme.md](./Google-apps-readme.md).
