codeunit 50102 "GPT No. Series Copilot Impl."
{
    procedure Generate(var GenerationId: Record "Name/Value Buffer"; var NoSeriesGenerated: Record "GPT No. Series Proposal"; InputText: Text)
    var
        SystemPromptTxt: Text;
        Completion: Text;
        GenerateSeriesWithOpenAI: Codeunit "Generate Series with OpenAI";
    begin
        SystemPromptTxt := GetSystemPrompt();
        if GenerateSeriesWithOpenAI.ValidateMaxInputTokens(SystemPromptTxt, InputText) then begin
            Completion := GenerateSeriesWithOpenAI.GenerateNoSeries(SystemPromptTxt, InputText);
            if CheckIfValidCompletion(Completion) then begin
                SaveGenerationHistory(GenerationId, InputText);
                CreateNoSeries(GenerationId, NoSeriesGenerated, Completion);
            end;
        end;
    end;

    local procedure GetSystemPrompt(): Text
    var
        SystemPrompt: TextBuilder;
    begin
        SystemPrompt.AppendLine('You are `generateNumberSeries` API');
        SystemPrompt.AppendLine();
        SystemPrompt.AppendLine('Your task: Generate No. Series for the next entities:');
        SystemPrompt.AppendLine('"""');
        ListAllWsheTablesWithNoSeries(SystemPrompt);
        SystemPrompt.AppendLine('"""');
        SystemPrompt.AppendLine();
        SystemPrompt.AppendLine('User might add additional instructions on how to name series.');
        SystemPrompt.AppendLine('Try to fullfil them.');
        SystemPrompt.AppendLine();
        SystemPrompt.AppendLine('IMPORTANT!');
        SystemPrompt.AppendLine('Don''t add comments.');
        SystemPrompt.AppendLine('Fill all fields.');
        SystemPrompt.AppendLine('Always respond in the next JSON format:');
        SystemPrompt.AppendLine('''''''');
        SystemPrompt.AppendLine('[');
        SystemPrompt.AppendLine('    {');
        SystemPrompt.AppendLine('        "noseries": "string (len 20)",');
        SystemPrompt.AppendLine('        "lineNo": "integer",');
        SystemPrompt.AppendLine('        "description": "string (len 30)",');
        SystemPrompt.AppendLine('        "startingNo": "string (len 20)",');
        SystemPrompt.AppendLine('        "endingNo": "string (len 20)",');
        SystemPrompt.AppendLine('        "warningNo": "string (len 20)",');
        SystemPrompt.AppendLine('        "incrementByNo": "integer"');
        SystemPrompt.AppendLine('    }');
        SystemPrompt.AppendLine(']');
        SystemPrompt.AppendLine('''''''');
        SystemPrompt.AppendLine('Respects the types and sizes presented in the format');
        SystemPrompt.AppendLine('The `description` field must exactly match the name of the entity and it must be in Capital');
        SystemPrompt.AppendLine();
        SystemPrompt.AppendLine('If you can''t answer or don''t know the answer, respond with: []');
        SystemPrompt.AppendLine('Your answer in a JSON format: []');
        exit(SystemPrompt.ToText());
    end;

    local procedure ListAllWsheTablesWithNoSeries(var SystemPrompt: TextBuilder)
    var
        "Field": Record "Field";
        a: Record "Warehouse Setup";
        i: Integer;
    begin
        Field.SetRange(TableNo, Database::"Warehouse Setup");
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetRange(Type, Field.Type::Code);
        Field.SetRange(Len, 20);
        if Field.FindSet() then
            repeat
                SystemPrompt.AppendLine(Field.FieldName);
                if i > 12 then
                    break;
                i += 1;
            until Field.Next() = 0;
    end;

    local procedure CreateNoSeries(var GenerationId: Record "Name/Value Buffer"; var NoSeriesGenerated: Record "GPT No. Series Proposal"; Completion: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        NoSeriesObj: Text;
        i: Integer;
    begin
        JSONManagement.InitializeCollection(Completion);

        for i := 0 to JSONManagement.GetCollectionCount() - 1 do begin
            JSONManagement.GetObjectFromCollectionByIndex(NoSeriesObj, i);

            InsertNoSeriesGenerated(NoSeriesGenerated, NoSeriesObj, GenerationId.ID);
        end;
    end;

    [TryFunction]
    local procedure CheckIfValidCompletion(var Completion: Text)
    var
        JsonArray: JsonArray;
    begin
        JsonArray.ReadFrom(Completion);
    end;

    local procedure SaveGenerationHistory(var GenerationId: Record "Name/Value Buffer"; InputText: Text)
    begin
        GenerationId.ID += 1;
        GenerationId."Value Long" := InputText;
        GenerationId.Insert(true);
    end;

    local procedure InsertNoSeriesGenerated(var NoSeriesGenerated: Record "GPT No. Series Proposal"; var NoSeriesObj: Text; GenerationId: Integer)
    var
        JSONManagement: Codeunit "JSON Management";
        RecRef: RecordRef;
    begin
        JSONManagement.InitializeObject(NoSeriesObj);

        RecRef.GetTable(NoSeriesGenerated);
        RecRef.Init();
        SetGenerationId(RecRef, GenerationId, NoSeriesGenerated.FieldNo("Generation Id"));
        JSONManagement.GetValueAndSetToRecFieldNo(RecRef, 'noseries', NoSeriesGenerated.FieldNo("No Series"));
        JSONManagement.GetValueAndSetToRecFieldNo(RecRef, 'lineNo', NoSeriesGenerated.FieldNo("Line No."));
        JSONManagement.GetValueAndSetToRecFieldNo(RecRef, 'description', NoSeriesGenerated.FieldNo("Description"));
        JSONManagement.GetValueAndSetToRecFieldNo(RecRef, 'startingNo', NoSeriesGenerated.FieldNo("Starting No."));
        JSONManagement.GetValueAndSetToRecFieldNo(RecRef, 'endingNo', NoSeriesGenerated.FieldNo("Ending No."));
        JSONManagement.GetValueAndSetToRecFieldNo(RecRef, 'warningNo', NoSeriesGenerated.FieldNo("Warning No."));
        JSONManagement.GetValueAndSetToRecFieldNo(RecRef, 'incrementByNo', NoSeriesGenerated.FieldNo("Increment-by No."));
        RecRef.Insert(true);
    end;

    local procedure SetGenerationId(var RecRef: RecordRef; GenerationId: Integer; FieldNo: Integer)
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value(GenerationId);
    end;

    procedure ApplyProposedNoSeries(var NoSeriesGenerated: Record "GPT No. Series Proposal")
    begin
        if NoSeriesGenerated.FindSet() then
            repeat
                InsertNoSeriesWithLines(NoSeriesGenerated);
            until NoSeriesGenerated.Next() = 0;
    end;

    local procedure InsertNoSeriesWithLines(var NoSeriesGenerated: Record "GPT No. Series Proposal")
    begin
        InsertNoSeries(NoSeriesGenerated);
        InsertNoSeriesLine(NoSeriesGenerated);
    end;

    local procedure InsertNoSeries(var NoSeriesGenerated: Record "GPT No. Series Proposal")
    var
        NoSeries: Record "No. Series";
        WarehouseSetup: Record "Warehouse Setup";
        DataTypeManagement: Codeunit "Data Type Management";
        WarehouseSetupRef: RecordRef;
        FieldRef: FieldRef;
    begin
        NoSeries.Init();
        NoSeries.Code := NoSeriesGenerated."No Series";
        NoSeries.Description := NoSeriesGenerated.Description;
        NoSeries."Manual Nos." := true;
        NoSeries."Default Nos." := true;
        if not NoSeries.Insert(true) then
            NoSeries.Modify();

        WarehouseSetupRef.GetTable(WarehouseSetup);
        WarehouseSetupRef.FindFirst();

        DataTypeManagement.FindFieldByName(WarehouseSetupRef, FieldRef, NoSeriesGenerated.Description);
        SetWsheSetupCode(WarehouseSetupRef, NoSeriesGenerated."No Series", FieldRef.Number);
        WarehouseSetupRef.Modify();
    end;

    local procedure SetWsheSetupCode(var RecRef: RecordRef; Code: Code[20]; FieldNo: Integer)
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value(Code);
    end;

    local procedure InsertNoSeriesLine(var NoSeriesGenerated: Record "GPT No. Series Proposal")
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesGenerated."No Series";
        NoSeriesLine."Line No." := NoSeriesGenerated."Line No.";
        NoSeriesLine."Starting No." := NoSeriesGenerated."Starting No.";
        NoSeriesLine."Ending No." := NoSeriesGenerated."Ending No.";
        NoSeriesLine."Warning No." := NoSeriesGenerated."Warning No.";
        NoSeriesLine."Increment-by No." := NoSeriesGenerated."Increment-by No.";
        if not NoSeriesLine.Insert(true) then
            NoSeriesLine.Modify();
    end;
}