namespace kodoo.ExternalDocAttach;
using System.ExternalFileStorage;
using Microsoft.Foundation.Attachment;
using System.Environment;
using System.Utilities;


codeunit 84359 "kd_ex_DocAttachmentBridge"
{
    #region eevent subscribers

    /// <summary>
    /// Return value AttachmentIsAvailable if the attachment file content available.
    /// </summary>
    /// <param name="DocumentAttachment"></param>
    /// <param name="AttachmentIsAvailable">Return Value</param>
    /// <param name="IsHandled"></param>
    [EventSubscriber(ObjectType::Table, database::"Document Attachment", OnBeforeHasContent, '', false, false)]
    local procedure DocumentAttachment_OnBeforeHasContent(var DocumentAttachment: Record "Document Attachment"; var AttachmentIsAvailable: Boolean; var IsHandled: Boolean)
    begin
        if not GetAttachmentFileAccount(DocumentAttachment) then
            exit;
        FileStore.Initialize(TempFileAccount);
        AttachmentIsAvailable := FileStore.FileExists(DocumentAttachment.kd_ex_FileName);
        if AttachmentIsAvailable then
            IsHandled := true;
    end;


    /// <summary>
    /// imports and stores the content of AttachmentInStream. 
    /// </summary>
    /// <param name="DocumentAttachment"></param>
    /// <param name="AttachmentInStream">File content to store</param>
    /// <param name="FileName"></param>
    /// <param name="IsHandled"></param>
    [EventSubscriber(ObjectType::Table, database::"Document Attachment", OnBeforeImportFromStream, '', false, false)]
    local procedure DocumentAttachment_OnBeforeImportFromStream(var DocumentAttachment: Record "Document Attachment"; var AttachmentInStream: InStream; var FileName: Text; var IsHandled: Boolean)

    begin
        if AttachmentInStream.Length = 0 then  //return to hit error
            exit;
        if not GetFileAccountFromScenario() then
            exit;

        FileStore.Initialize(TempFileAccount);
        DocumentAttachment.kd_ex_FileName := StoragePath(DocumentAttachment);
        IsHandled := FileStore.CreateFile(DocumentAttachment.kd_ex_FileName, AttachmentInStream);
        if IsHandled then
            DocumentAttachment.kd_ex_FileAccount := TempFileAccount."Account Id";
        //DocumentAttachment.kd_ex_FileAccount := TempFileAccount.SystemId;
    end;


    /// <summary>
    /// exports the file content to AttachmentOutStream
    /// </summary>
    /// <param name="DocumentAttachment"></param>
    /// <param name="AttachmentOutStream">Return value - the content of the file</param>
    /// <param name="IsHandled"></param>
    [EventSubscriber(ObjectType::Table, database::"Document Attachment", OnBeforeExportToStream, '', false, false)]
    local procedure DocumentAttachment_OnBeforeExportToStream(var DocumentAttachment: Record "Document Attachment"; var AttachmentOutStream: OutStream; var IsHandled: Boolean)
    var
        FileInStr: InStream;
    begin
        if not GetAttachmentFileAccount(DocumentAttachment) then
            exit;
        FileStore.Initialize(TempFileAccount);

        if not FileStore.GetFile(DocumentAttachment.kd_ex_FileName, FileInStr) then
            exit;
        CopyStream(AttachmentOutStream, FileInStr);
        IsHandled := true;
    end;

    /// <summary>
    /// Fetches external file content and stores in TempBlob
    /// </summary>
    /// <param name="DocumentAttachment"></param>
    /// <param name="TempBlob">Return Value</param>
    /// <param name="IsHandled"></param>
    [EventSubscriber(ObjectType::Table, database::"Document Attachment", OnBeforeGetAsTempBlob, '', false, false)]
    local procedure DocumentAttachment_OnBeforeGetAsTempBlob(var DocumentAttachment: Record "Document Attachment"; var TempBlob: Codeunit "Temp Blob"; var IsHandled: Boolean)
    var
        FileInStr: InStream;
        FileOutStr: OutStream;
    begin
        if not GetAttachmentFileAccount(DocumentAttachment) then
            exit;
        FileStore.Initialize(TempFileAccount);

        if not FileStore.GetFile(DocumentAttachment.kd_ex_FileName, FileInStr) then
            exit;
        TempBlob.CreateOutStream(FileOutStr);
        CopyStream(FileOutStr, FileInStr);
        IsHandled := true;
    end;


    /// <summary>
    /// returns the file Mime Type in ContentType
    /// </summary>
    /// <param name="Rec"></param>
    /// <param name="ContentType">Return Value - a Mime Type</param>
    /// <param name="IsHandled"></param>
    [EventSubscriber(ObjectType::Table, database::"Document Attachment", OnBeforeGetContentType, '', false, false)]
    local procedure DocumentAttachment_OnBeforeGetContentType(var Rec: Record "Document Attachment"; var ContentType: Text[100]; var IsHandled: Boolean)
    var
        TempMedia: Record "Tenant Media" temporary;
        AttachmentInStream: InStream;
    begin
        TempMedia.Content.CreateInStream(AttachmentInStream);
        if not GetFileContent(Rec, AttachmentInStream) then
            exit;
        TempMedia.Insert(true);
        ContentType := TempMedia."Mime Type";
        IsHandled := true;
    end;

    //TODO - address scenarios where the ile iis opened / shared on onedrive.

    #endregion

    local procedure StoragePath(DocumentAttachment: Record "Document Attachment"): Text[1024]
    var
        FilePathTok: Label '%1/%2/%3/%4.%5', Locked = true, Comment = '%1 %2 %3 %4 %5 - the primary key of the document attachment record.';
    begin
        exit(format(StrSubstNo(FilePathTok,
            DocumentAttachment."Table ID",
            DocumentAttachment."No.",
            DocumentAttachment."Line No.",
            DocumentAttachment."File Name",
            DocumentAttachment."File Extension"), -1024));
    end;

    local procedure GetAttachmentFileAccount(DocumentAttachment: Record "Document Attachment"): Boolean
    var
        FileAccount: Codeunit "File Account";
    begin
        FileAccount.GetAllAccounts(TempFileAccount);
        TempFileAccount.SetRange("Account Id", DocumentAttachment.kd_ex_FileAccount);
        exit(TempFileAccount.FindFirst());
    end;

    [TryFunction]
    local procedure GetFileContent(var DocumentAttachment: Record "Document Attachment"; var AttachmentInStream: InStream)
    begin
        if not GetAttachmentFileAccount(DocumentAttachment) then
            Error('');
        FileStore.Initialize(TempFileAccount);
        if not FileStore.GetFile(StoragePath(DocumentAttachment), AttachmentInStream) then
            Error('');



    end;

    local procedure GetFileAccountFromScenario(): Boolean
    begin
        exit(FileScenario.GetFileAccount("File Scenario"::"Document Attachment", TempFileAccount));
    end;

    var
        TempFileAccount: Record "File Account" temporary;
        FileStore: Codeunit "External File Storage";
        FileScenario: Codeunit "File Scenario";

}
