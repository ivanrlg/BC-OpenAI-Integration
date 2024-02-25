codeunit 50104 "Generate Series with OpenAI"
{
    var
        NoSeriesCopilotSetup: Record "GPT OpenAI Setup";

    // Validates the combined token count of system prompt and input text against the maximum input tokens allowed
    internal procedure ValidateMaxInputTokens(var SystemPromptTxt: Text; InputText: Text): Boolean
    var
        CompletePromptTokenCount: Integer;
        TokenCountImpl: Codeunit "GPT Tokens Count Impl."; // Utility for estimating token counts
    begin
        // Calculate total token count for system prompt and user input
        CompletePromptTokenCount := TokenCountImpl.EstimateTokenCount(SystemPromptTxt) + TokenCountImpl.EstimateTokenCount(InputText);
        // Ensure total token count does not exceed max allowed input tokens
        exit(CompletePromptTokenCount <= MaxInputTokens());
    end;

    // Generates number series based on system prompt and user input using OpenAI
    [NonDebuggable]
    internal procedure GenerateNoSeries(SystemPromptTxt: Text; InputText: Text): Text
    var
        OpenAI: Codeunit "GPT OpenAi";
        OperationResponse: Codeunit "GPT Operation Response";
        ChatCompletionParams: Codeunit "GPT Chat Completion Params";
        ChatMessages: Codeunit "GPT Chat Messages";
        CompletionAnswerTxt: Text;
        ResultContent: Text;
    begin
        // Set OpenAI authorization with endpoint, model, and secret key
        OpenAI.SetAuthorization(GetEndpoint(), GetModel(), GetSecret());

        // Initialize and set chat completion parameters
        ChatCompletionParams.Initialize();
        ChatCompletionParams.SetMaxTokens(MaxOutputTokens());
        ChatCompletionParams.SetTemperature(0);

        // Add system prompt and user input to chat messages
        ChatMessages.AddSystemMessage(SystemPromptTxt);
        ChatMessages.AddUserMessage(InputText);

        // Generate chat completion and handle the response
        ResultContent := OpenAI.GenerateChatCompletion(ChatMessages, ChatCompletionParams, OperationResponse);
        if OperationResponse.IsSuccess() then
            CompletionAnswerTxt := ResultContent
        else
            Error(OperationResponse.GetError()); // Raise error if operation failed

        exit(CompletionAnswerTxt); // Return the generated series
    end;

    // Helper procedures to get setup values
    local procedure GetEndpoint(): Text
    begin
        exit(NoSeriesCopilotSetup.GetEndpoint())
    end;

    local procedure GetModel(): Enum "GPT OpenAI Model"
    begin
        exit(NoSeriesCopilotSetup.GetModel())
    end;

    [NonDebuggable]
    local procedure GetSecret(): Text
    begin
        NoSeriesCopilotSetup.Get();
        exit(NoSeriesCopilotSetup.GetSecretKeyFromIsolatedStorage())
    end;

    // Configuration for maximum tokens handling
    local procedure MaxInputTokens(): Integer
    begin
        exit(MaxModelTokens() - MaxOutputTokens());
    end;

    local procedure MaxOutputTokens(): Integer
    begin
        exit(3500);
    end;

    local procedure MaxModelTokens(): Integer
    begin
        exit(4096); // GPT 3.5 Turbo model's maximum token limit
    end;
}
