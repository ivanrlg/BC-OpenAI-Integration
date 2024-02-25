table 50101 "GPT OpenAI Setup"
{
    Description = 'Upsell with OpenAI Setup';

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(2; Endpoint; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Endpoint';
        }

        field(3; Model; Enum "GPT OpenAI Model")
        {
            Caption = 'Model';
        }

        field(4; "Secret Key"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Secret';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    procedure GetEndpoint() Endpoint: Text[250]
    var
        Rec: Record "GPT OpenAI Setup";
    begin
        Rec.Get();
        exit(Rec.Endpoint);
    end;

    procedure GetModel(): Enum "GPT OpenAI Model"
    var
        Rec: Record "GPT OpenAI Setup";
    begin
        Rec.Get();
        exit(Rec.Model);
    end;


    [NonDebuggable]
    procedure GetSecretKeyFromIsolatedStorage() SecretKey: Text
    begin
        if not IsNullGuid(Rec."Secret Key") then
            if not IsolatedStorage.Get(Rec."Secret Key", DataScope::Module, SecretKey) then;

        exit(SecretKey);
    end;

    [NonDebuggable]
    procedure SetSecretKeyToIsolatedStorage(SecretKey: Text)
    var
        NewSecretGuid: Guid;
    begin
        if not IsNullGuid(Rec."Secret Key") then
            if not IsolatedStorage.Delete(Rec."Secret Key", DataScope::Module) then;

        NewSecretGuid := CreateGuid();

        IsolatedStorage.Set(NewSecretGuid, SecretKey, DataScope::Module);

        Rec."Secret Key" := NewSecretGuid;
    end;
}