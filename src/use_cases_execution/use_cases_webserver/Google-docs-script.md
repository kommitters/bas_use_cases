## Script to list all files in a folder

This script is designed to list all files in a folder. And send them to a webhook exposed by the backend.

---

## Script

```javascript
/**
 * Recursively processes a folder to list its subfolders and files.
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
    fileSet.push({ external_document_id: fileId, name: file.getName(), external_domain_id: domainId })
  }

  return fileSet;
}

function sendGoogleDocsToWebhook() {
  let docs;
  const rootFolderId = PropertiesService.getScriptProperties().getProperty('ROOT_FOLDER_ID');
  const url = PropertiesService.getScriptProperties().getProperty('WEBHOOK_URL');

  try {
    const rootFolder = DriveApp.getFolderById(rootFolderId);
    console.log(`Scanning: ${rootFolder.getName()}`);
    docs = processFolder(rootFolder, null, 1);
  } catch (e) {
    console.error(`Error: Failed to access folder ${rootFolderId}. Details: ${e.message}`);
  }

  const payload = JSON.stringify({ google_documents: docs });
    console.log(docs.length, "documents fetched")

    try {
      const res = UrlFetchApp.fetch(url, {
        method: 'post',
        contentType: 'application/json',
        payload,
        muteHttpExceptions: true
      });
      console.log('Status:', res.getResponseCode(), 'Body:', res.getContentText());
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
