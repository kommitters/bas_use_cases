# Script to Send PTOs from Google Sheets

This script is designed to be used in a Google Sheets spreadsheet that contains PTO (Paid Time Off) data. Its purpose is to filter data corresponding to the current day and send it to a webhook exposed by the backend.

---

## Script Location

This file is part of the FetchPtoFromGoogle use case and is located in the @src/implementations/fetch_pto_from_google.rb folder, as a reference. 

---

## Script

```javascript
function sendSheetToWebhook() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  const tz = SpreadsheetApp.getActive().getSpreadsheetTimeZone();
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const validDays = ['Full Day'];

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
    .map(entry => ({
      Person: entry['Person'],
      Description: 'Data',
      StartDateTime: format(entry['StartDateTime'], tz, true),
      EndDateTime: format(entry['EndDateTime'], tz, false)
    }));

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

function format(date, tz, isStart) {
  const d = parseDate(date);
  if (isStart) d.setHours(7, 0, 0, 0);
  else {
    d.setDate(d.getDate() + 1);
    d.setHours(6, 59, 59, 0);
  }
  return Utilities.formatDate(d, tz, "yyyy-MM-dd");
}
```

---

## Environment Variables and Configuration

- **<YOUR_WEBHOOK_URL>**: Replace with the backend /pto URL (can be exposed via a tunnel like Ngrok if running locally).
- The script uses spreadsheet headers, so the **column names must exactly match** what the backend expects:
  - Person, StartDateTime, EndDateTime, Category, etc.

---

## How to Set Up the Script in Google Sheets

1. **Open your Google Sheets spreadsheet** that contains the PTO data.
2. Go to the top menu and select: Extensions > Apps Script.
3. Delete any existing code in the editor.
4. Paste the full script (above) into the editor.
5. The webhook URL must be stored in the script's properties...
Go to Apps Script > Project Settings > Script Properties, and set a key named WEBHOOK_URL **<YOUR_WEBHOOK_URL>**
6. Click on the **floppy disk icon or File > Save** and give the project a name, e.g., SendPTOToWebhook.
7. (Optional) Test the function by clicking the **▶ Run** button and check the logs under View > Logs.

---

## How to Create a Time-Driven Trigger

1. In the Apps Script editor, click the **clock icon** on the left menu (or go to Triggers).
2. Click **"+ Add Trigger"** at the bottom right.
3. Configure the trigger with the following settings:
   - **Function to run**: sendSheetToWebhook
   - **Deployment**: Head
   - **Event source**: Time-driven
   - **Type of time-based trigger**: Day timer
   - **Time of day**: Early morning (e.g., 6:00 AM)

---

## Permissions Required

When you run the script or save the trigger for the first time, Google will prompt you to authorize access.

Required permissions include:

- Reading the spreadsheet
- Sending data to an external URL

Make sure to authorize using an account that has access to the spreadsheet.

---

## Manual Testing

- Run the sendSheetToWebhook function from the Apps Script editor using the ▶ button.
- Verify the backend received the data correctly (you may log it in the backend).
- If errors occur, go to View > Logs in the Apps Script editor for debugging.

---

## Notes

- This script is a reference implementation. **You may need to adapt it** if the column structure or filtering logic changes.
- Keep any updates to the script under version control by editing this file through a Pull Request.

---

## Implement a use case using 'app.rb'

To expose a webhook that can receive data from Google Sheets, you must implement a Sinatra route and mount it in a modular server such using `app.rb`.

---

### Example Structure

```ruby
# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require_relative '../../../src/implementations/do_something'

module Routes
  class DoSomething < Sinatra::Base
    post '/something' do
      request_body = request.body.read.to_s 
      ...
    end
  end
end

```
---

### Implementation on app.rb

```ruby
# frozen_string_literal: true

require 'sinatra/base'
require_relative '../use_case' # import the use case implemented

class WebServer < Sinatra::Base
  use Routes::use_case # add the new route
end

if $PROGRAM_NAME == __FILE__
  WebServer.run!(
    server: :puma,
    bind: '0.0.0.0',
    environment: :production
  )
end

```
