codeunit 50101 "GPT Tokens Count Impl."
{
    procedure ApproximateTokenCount(Input: Text): Decimal
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        exit(AzureOpenAI.ApproximateTokenCount(Input));
    end;

    // Estimates the token count of a given text input based on delimiters and spaces
    procedure EstimateTokenCount(Text: Text): Integer
    var
        Delimiters: Text[50];
        TokenCount: Integer;
        I: Integer;
    begin
        Delimiters := ' .,!?;:''"()[]{}<>-/';
        TokenCount := 0;

        // Counts each punctuation and space as a token
        for I := 1 to StrLen(Text) do
            if StrPos(Delimiters, CopyStr(Text, I, 1)) > 0 then
                TokenCount += 1;

        // Adds the number of words by counting spaces and adding one
        TokenCount += CountCharacters(Text, ' ') + 1;

        exit(TokenCount);
    end;

    procedure EstimateListTokens(Text: Text): List of [Text]
    var
        TokenList: List of [Text];
        CurrentToken: Text;
        I: Integer;
        Delimiters: Text[50];
        Char: Text[1];
    begin
        Delimiters := ' .,!?;:''"()[]{}<>-/';
        CurrentToken := '';

        for I := 1 to StrLen(Text) do begin
            Char := CopyStr(Text, I, 1);

            if StrPos(Delimiters, Char) > 0 then begin
                if CurrentToken <> '' then begin
                    TokenList.Add(CurrentToken);
                    CurrentToken := '';
                end;
                TokenList.Add(Char);
            end else
                CurrentToken := CurrentToken + Char;
        end;

        if CurrentToken <> '' then
            TokenList.Add(CurrentToken);

        exit(TokenList);
    end;

    procedure CountCharacters(Text: Text; CharacterToCount: Char): Integer
    var
        Count: Integer;
        i: Integer;
    begin
        Count := 0;
        for i := 1 to StrLen(Text) do
            if CopyStr(Text, i, 1) = CharacterToCount then
                Count := Count + 1;
        exit(Count);
    end;
}
