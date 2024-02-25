page 50102 "GPT OpenAI Setup"
{

    Caption = 'OpenAI Setup';
    PageType = Card;
    SourceTable = "GPT OpenAI Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;
    UsageCategory = Administration;


    layout
    {
        area(content)
        {
            group(General)
            {
                field(Endpoint; Rec.Endpoint)
                {
                    ApplicationArea = All;
                }
                field(Deployment; Rec.Model)
                {
                    ApplicationArea = All;
                }
                field(SecretKey; SecretKey)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Secret Key';
                    NotBlank = true;
                    ShowMandatory = true;
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        Rec.SetSecretKeyToIsolatedStorage(SecretKey);
                    end;
                }
            }
        }
    }

    var
        [NonDebuggable]
        SecretKey: Text;


    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SecretKey := Rec.GetSecretKeyFromIsolatedStorage();
    end;

}