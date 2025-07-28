# Google Apps Script Integration Readme

This document contains shared instructions for integrating Google Apps Scripts with the backend webhook, extracted from specific use case scripts to avoid duplication.

---

## How to Create a Time-Driven Trigger

1. In the Apps Script editor, click the **clock icon** on the left menu (Triggers).
2. Click **"+ Add Trigger"** at the bottom right.
3. Configure the trigger with the following settings:
   - **Function to run**: &lt;your_function_name&gt; (e.g., sendSheetToWebhook or sendGoogleDocsToWebhook)
   - **Deployment**: Head
   - **Event source**: Time-driven
   - **Type of time-based trigger**: Day timer
   - **Time of day**: Early morning (e.g., 5:00 AM - 6:00 AM)

---

## Permissions Required

When you run the script or save the trigger for the first time, Google will prompt you to authorize access.

Required permissions include:
- &lt;Specific reading permission, e.g., Reading the spreadsheet or Reading from Google Drive&gt;
- Sending data to an external URL (Connect to an external service)

Make sure to authorize using an account that has access to the resources.

---

## Manual Testing

- Run the &lt;your_function_name&gt; function from the Apps Script editor using the ▶ button.
- Verify the backend received the data correctly (you may log it in the backend).
- If errors occur, go to **"Executions"** in the Apps Script editor for debugging.

---

## Notes

- This script is a reference implementation. **You may need to adapt it** if the data structure or filtering logic changes.
- Keep any updates to the script under version control by editing this file through a Pull Request.

---

## Implement a use case using 'app.rb'

To expose a webhook that can receive data from Google Apps Script, you must implement a Sinatra route and mount it in a modular server using `app.rb`.

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
      # ... process the request
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
