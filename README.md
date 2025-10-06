### Store document attachments using External File Storage.

This app allows BC administrators to store document attachments in Azure Blob storage or other external file stores - instead of within the BC database. This will reduce database size.

This app makes use of the [External File Storage](https://learn.microsoft.com/en-us/dynamics365/release-plan/2025wave1/smb/dynamics365-business-central/manage-external-files-more-easily-through-unified-api-external-file-storage-module) introduced in version 26. 

#### Setup
Run the Set up External File Accounts wizard. 

Select the type of External file account. 

Once the external account has been created, go to "File Scenario Assignment". Assign your file account to the Document Attachment scenario as shown. 

<img src="https://github.com/jamescs50/BC-ExternalDocumentAttachments/blob/Initial/res/readme/FileScenaro.png">

From now on - any Document attachments will be stored within the file store instead of the BC database. 
