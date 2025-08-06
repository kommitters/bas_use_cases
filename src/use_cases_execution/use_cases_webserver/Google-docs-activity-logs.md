## Script to fetch Google Docs activity logs

This script is designed to fetch Google Docs activity logs and send them to a webhook exposed by the backend.

---

## Script

```javascript
function extractUserDetails(user) {
  const { knownUser } = user;
  const userId = user.user.knownUser.personName;
  const person = People.People.get(userId, { personFields: 'emailAddresses' });
  const { resourceName, emailAddresses: [{ value: email }] } = person;

  return { email, id: resourceName.replace('people/', '') };
}

function extractActionDetails(actionObject) {
  const [action] = Object.keys(actionObject.detail);
  
  return { action, details: actionObject.detail[action] }
}

/**
 * Gets the revision history (changelog) for a specific Google Document.
 * given a document id.
 */
function getDocumentChangelog(documentId) {
  const completeId = `items/${documentId}`;
  const response = DriveActivity.Activity.query({ itemName: completeId });

  const changelogs = []

  response.activities.forEach(activity => {
    const { email, id } = extractUserDetails(activity.actors[0]);
    const { action, details } = extractActionDetails(activity.actions[0]);
    changelogs.push({ document_id: documentId, person_id: id, person_email: email, action, details })
  });

  return changelogs;
}

/**
 * Recursively processes a folder to list its documents activity logs.
 * @param {GoogleAppsScript.Drive.Folder} folder The folder object to process.
 */
function processFolder(folder, domainId, level) {
  let fileSet = [];
  const subfolders = folder.getFolders();

  while (subfolders.hasNext()) {
    const subfolder = subfolders.next();

    // Recursive call for the subfolder with increased indentation
    const subfolderSet = processFolder(subfolder, level === 1 ? subfolder.getName() : domainId, level + 1);
    fileSet = fileSet.concat(subfolderSet);
  }

  // Get and process all files in the current folder
  const files = folder.getFiles();
  while (files.hasNext()) {
    const file = files.next();
    const fileId = file.getId();
    const changelogs = getDocumentChangelog(fileId);
    // fileSet.push({ external_document_id: fileId, name: file.getName(), domain_id: domainId });
    fileSet = fileSet.concat(changelogs)
  }

  return fileSet;
}

function sendGoogleDocsActivityLogsToWebhook() {
  let activityLogs;
  // const rootFolderId = PropertiesService.getScriptProperties().getProperty('ROOT_FOLDER_ID');
  const rootFolderId = '1UMR1GlH3h9QpeJBqD5Wbhjh1dcEz-B7K';
  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');

  try {
    const rootFolder = DriveApp.getFolderById(rootFolderId);
    console.log(`Fetching activity logs recursively from ${rootFolder.getName()}...`);
    activityLogs = processFolder(rootFolder, null, 1);
  } catch (e) {
    console.error(`Error: Failed to access folder ${rootFolderId}. Details: ${e.message}`);
  }

  const payload = JSON.stringify({ google_docs_activity_logs: activityLogs });
  console.log(activityLogs.length, 'document activity logs fetched')

  try {
    // const res = UrlFetchApp.fetch(url, {
    console.log({
      method: 'post',
      contentType: 'application/json',
      payload,
      muteHttpExceptions: true
    });
    //console.log('Webhook status:', res.getResponseCode(), 'Body:', res.getContentText());
  } catch (err) {
    console.error('Error:', err);
  }
}
```

---

## Environment Variables and Configuration

Set up these variables in the script properties section in the Google Apps Script editor.

- **ROOT_FOLDER_ID**: The ID of the root Google Drive folder you want to scan. It can be found in the URL of the folder.
- **WEBHOOK_URL**: The backend URL that will receive the list of documents including the path (i.e it should end with /google_docs). For local development, you can expose the backend via a tunnel like Ngrok or Cloudflare Tunnels.

---

For instructions on setting up the script, creating time-driven triggers, required permissions, manual testing, notes, and implementing the backend webhook, please refer to [Google-apps-readme.md](./Google-apps-readme.md).
