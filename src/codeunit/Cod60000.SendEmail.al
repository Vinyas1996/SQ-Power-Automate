codeunit 60000 "Send_Email"
{
    trigger OnRun()
    var

    begin

    end;

    procedure SendEmail(SalesQteHdrRec: Record "Sales Header")
    var
        SalesQuote: Report "Standard Sales - Quote";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        Outstr: OutStream;
        Reportparameter: Text;
        XmlParameters: Text;
        SendTo: Text;
        CustomeRrec: Record Customer;
        SalesHdrRec: Record "Sales Header";
        recRef: RecordRef;
        FileName: Text;
        Body: Text;
        Subject: Text;
    begin
        CustomeRrec.Reset();
        Clear(SendTo);
        SalesQteHdrRec.Reset();
        SalesHdrRec.Reset();

        TempBlob.CreateOutStream(Outstr);
        SalesHdrRec.SetFilter("Document Type", '%1', SalesHdrRec."Document Type"::Quote);
        SalesHdrRec.SetRange("No.", SalesQteHdrRec."No.");
        if SalesHdrRec.FindFirst() then;

        recRef.GetTable(SalesHdrRec);
        Report.SaveAs(Report::"Standard Sales - Quote", XmlParameters, ReportFormat::Pdf, Outstr, recRef);
        TempBlob.CreateInStream(InStr);

        if CustomeRrec.Get(SalesHdrRec."Sell-to Customer No.") then
            SendTo := CustomeRrec."E-Mail";

        FileName := ('Sales Quote Report - ') + '.pdf';
        Body := 'Please find your sales quotation. <br>';
        Subject := 'Test Subject';
        EmailMessage.Create(SendTo, Subject, Body, true);
        EmailMessage.AddAttachment(FileName, 'PDF', InStr);
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;


    var
        myInt: Integer;
}