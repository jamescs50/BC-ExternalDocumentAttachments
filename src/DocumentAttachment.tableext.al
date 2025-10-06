namespace kodoo.ExternalDocAttach;

using Microsoft.Foundation.Attachment;

tableextension 84359 "Document Attachment" extends "Document Attachment"
{
    fields
    {
        field(84359; kd_ex_FileAccount; Guid)
        {
            Caption = 'File Account';
            ToolTip = 'Reerence to the file account that holds the content for this attachment.';
            DataClassification = CustomerContent;
        }
        field(84360; kd_ex_FileName; text[1024])
        {
            Caption = 'File Name';
            ToolTip = 'Full file path and name within the external storage.';
            DataClassification = CustomerContent;
        }

    }
}
