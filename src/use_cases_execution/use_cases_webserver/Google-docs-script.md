## Script to list all files in a folder

This script is designed to list all files in a folder. And send them to a webhook exposed by the backend.

---

## Script

```javascript
/**
 * Lists all files in a specified Google Drive folder and logs their names to the console.
 */
function listFilesInFolder() {
  const rootFolderId = '1lxKiJjHqlOkT-feF8-BI0XA_5jBxCV1X';

  try {
    const rootFolder = DriveApp.getFolderById(rootFolderId);
    console.log(`Scanning: 📁 ${rootFolder.getName()}`);

    // Start the recursive processing from the root folder.
    const result = processFolder(rootFolder, null, 1);
    console.log("RESULT", result);
    
  } catch (e) {
    console.error(`Error: Failed to access folder ${rootFolderId}. Details: ${e.message}`);
  }
}

/**
 * Recursively processes a folder to list its subfolders and files.
 * @param {GoogleAppsScript.Drive.Folder} folder The folder object to process.
 */
function processFolder(folder, domainId, level) {
  console.log({domainId, level})
  let fileSet = [];
  const subfolders = folder.getFolders();

  while (subfolders.hasNext()) {
    const subfolder = subfolders.next();
    console.log(`${' '.repeat(level)}📁 [${level}]${subfolder.getName()}`);
    
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
    console.log(`${' '.repeat(level)}📄 ${fileId} - ${file.getName()}`);
  }

  return fileSet;
}
```
