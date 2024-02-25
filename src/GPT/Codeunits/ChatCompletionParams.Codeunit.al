codeunit 50106 "GPT Chat Completion Params"
{
    var
        Temperature: Decimal;
        Top_p: Integer;
        MaxTokens: Integer;
        MaxHistory: Integer;
        PresencePenalty: Decimal;
        FrequencyPenalty: Decimal;

    // Set the temperature for AI responses, influencing randomness.
    procedure SetTemperature(NewTemperature: Decimal)
    begin
        Temperature := NewTemperature;
    end;

    // Set the maximum number of tokens (words/punctuation) the AI can generate.
    procedure SetMaxTokens(NewMaxTokens: Integer)
    begin
        MaxTokens := NewMaxTokens;
    end;

    // Set the maximum number of messages to include in the chat history.
    procedure SetMaxHistory(NewMaxHistory: Integer)
    begin
        MaxHistory := NewMaxHistory;
    end;

    // Set the presence penalty to encourage the model to generate new topics.
    procedure SetPresencePenalty(NewPresencePenalty: Decimal)
    begin
        PresencePenalty := NewPresencePenalty;
    end;

    // Set the frequency penalty to discourage repetition in the AI's responses.
    procedure SetFrequencyPenalty(NewFrequencyPenalty: Decimal)
    begin
        FrequencyPenalty := NewFrequencyPenalty;
    end;

    // Set the proportion of the most likely tokens considered for generation.
    procedure SetTop_P(NewTop_P: Decimal)
    begin
        Top_p := NewTop_P;
    end;

    // Initialize default values for all parameters.
    procedure Initialize()
    begin
        // Default values are set based on common practices for balanced output.
        Temperature := 1;
        MaxTokens := 1000;
        MaxHistory := 0;
        PresencePenalty := 0;
        FrequencyPenalty := 0;
        Top_p := 1;
    end;

    // Compile all chat completion parameters into a JSON object for API requests.
    procedure AddChatCompletionsParametersToPayload(var Payload: JsonObject)
    begin
        // These parameters will customize the behavior of the AI model.
        Payload.Add('temperature', Temperature);
        Payload.Add('max_tokens', MaxTokens);
        if MaxHistory > 0 then
            Payload.Add('max_history', MaxHistory);
        Payload.Add('presence_penalty', PresencePenalty);
        Payload.Add('frequency_penalty', FrequencyPenalty);
        Payload.Add('top_p', Top_p);
    end;
}
