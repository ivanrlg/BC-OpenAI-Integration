// Temporary AL table to keep the history of No. Series proposals in the copilot
table 50103 "GPT No. Series Proposal"
{
    TableType = Temporary;

    fields
    {
        field(1; "Generation Id"; Integer)
        {
            Caption = 'Generation Id';
        }
        field(2; "No Series"; Code[20])
        {
            Caption = 'No Series 1';
        }

        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Starting No."; Code[20])
        {
            Caption = 'Starting No.';
        }
        field(7; "Ending No."; Code[20])
        {
            Caption = 'Ending No.';
        }
        field(8; "Warning No."; Code[20])
        {
            Caption = 'Warning No.';
        }
        field(9; "Increment-by No."; Integer)
        {
            Caption = 'Increment-by No.';
        }
    }

    keys
    {
        key(PK; "Generation Id", "No Series", "Line No.")
        {
            Clustered = true;
        }
    }
}