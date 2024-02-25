pageextension 50100 "GPT No. Series Ext" extends "Warehouse Setup"
{
    actions
    {
        addlast(Processing)
        {
            action("GPT Generate")
            {
                Caption = 'Generate';
                ToolTip = 'Generate No. Series using Copilot';
                Image = Sparkle;
                ApplicationArea = All;
                trigger OnAction()
                var
                    NoSeriesCopilot: Page "GPT No. Series Proposal";
                    c: Page "Warehouse Setup";
                begin
                    NoSeriesCopilot.LookupMode := true;
                    if NoSeriesCopilot.RunModal = Action::LookupOK then
                        CurrPage.Update();
                end;
            }
        }
    }
}