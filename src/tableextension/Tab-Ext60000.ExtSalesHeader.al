tableextension 60000 "Ext_SalesHeader" extends "Sales Header"
{
    fields
    {
        field(60000; "Report To Print"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Report To Print';
        }

    }
    fieldgroups
    {

    }

    var
        myInt: Integer;




}