pageextension 60000 "Ext_SalesQuote" extends "Sales Quote"
{
    layout
    {
        addafter("No. of Archived Versions")
        {

            field("Report To Print"; Rec."Report To Print")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Report To Print field.', Comment = '%';
            }
        }
    }
    actions
    {
        addafter(AttachAsPDF)
        {
            action("Send Quote As Pdf")
            {
                ApplicationArea = All;
                Caption = 'Sales Quote AGT';
                Image = Print;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Category9;

                trigger OnAction()
                var

                begin
                    SendEmail(Rec);
                end;
            }

            action(SaveQuoteAsPdf)
            {
                Caption = 'Save Quote As Pdf';
                ApplicationArea = All;
                Image = Export;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileManagement: Codeunit "File Management";
                    OStream: OutStream;
                    SalesHeader: Record "Sales Header";
                    RecRef: RecordRef;
                begin
                    Clear(OStream);
                    SalesHeader.Reset();
                    SalesHeader.SetFilter("Document Type", '%1', SalesHeader."Document Type"::Quote);
                    SalesHeader.SetRange("Report To Print", true);
                    if SalesHeader.Findfirst() then begin
                        RecRef.GetTable(SalesHeader);
                        TempBlob.CreateOutStream(OStream);
                        Report.SaveAs(Report::"Standard Sales - Quote", '', ReportFormat::Pdf, OStream, RecRef);
                        FileManagement.BLOBExport(TempBlob, 'Sales Quote_' + Rec."No." + UserId + '.pdf', true);
                    end;
                end;
            }
        }
    }

    local procedure SendEmail(SalesQteHdrRec: Record "Sales Header")
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
