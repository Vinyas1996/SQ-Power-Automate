page 60000 "Sales Qquote API"
{
    APIGroup = 'AllGrowTech1';
    APIPublisher = 'allgrowtechnologies';
    APIVersion = 'v2.0';
    EntityCaption = 'SalesQuoteAPI';
    EntitySetCaption = 'SalesQuoteAPI';
    ChangeTrackingAllowed = true;
    ApplicationArea = All;
    DelayedInsert = true;
    EntityName = 'SalesQuoteAPI';
    EntitySetName = 'SalesQuoteAPI';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Sales Header";
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin

                    end;
                }
                field(sellToCustomerNo; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.';
                }
                field(sellToEMail; Rec."Sell-to E-Mail")
                {
                    Caption = 'Email';
                }
                field(reportToPrint; Rec."Report To Print")
                {
                    Caption = 'Report To Print';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure "Send SQ Report"()
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
        SalesHeader: Record "Sales Header";
        SalesHeader1: Record "Sales Header";
        recRef: RecordRef;
        FileName: Text;
        Body: Text;
        Subject: Text;
    begin
        CustomeRrec.Reset();
        Clear(SendTo);

        TempBlob.CreateOutStream(Outstr);
        SalesHeader.Reset();
        SalesHeader.SetFilter("Document Type", '%1', SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Report To Print", true);
        if SalesHeader.Findfirst() then begin

            recRef.GetTable(SalesHeader);
            Report.SaveAs(Report::"Standard Sales - Quote", XmlParameters, ReportFormat::Pdf, Outstr, recRef);
            TempBlob.CreateInStream(InStr);

            if CustomeRrec.Get(SalesHeader."Sell-to Customer No.") then
                SendTo := CustomeRrec."E-Mail";

            FileName := ('Sales Quote Report - ') + '.pdf';
            Body := 'Please find your sales quotation. <br>';
            Subject := 'Sales Quote';
            EmailMessage.Create(SendTo, Subject, Body, true);
            EmailMessage.AddAttachment(FileName, 'PDF', InStr);
            Email.Send(EmailMessage, Enum::"Email Scenario"::Default);

            SalesHeader1.Reset();
            SalesHeader1.SetFilter("Document Type", '%1', SalesHeader."Document Type"::Quote);
            SalesHeader1.SetRange("Report To Print", true);
            if SalesHeader1.FindFirst() then
                repeat
                    SalesHeader1."Report To Print" := false;
                    SalesHeader1.Modify();
                until SalesHeader1.Next() = 0;
        end;
    end;




    var

}
