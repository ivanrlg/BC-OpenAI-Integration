codeunit 50103 "GPT OpenAI"
{
    var
        [NonDebuggable]
        Endpoint: Text;
        [NonDebuggable]
        ApiKey: SecretText;
        Model: Enum "GPT OpenAI Model"; // The specific OpenAI model to use

    // Sets the authorization details for the OpenAI API requests
    [NonDebuggable]
    procedure SetAuthorization(NewEndpoint: Text; NewModel: Enum "GPT OpenAI Model"; NewApiKey: SecretText)
    begin
        Endpoint := NewEndpoint;
        ApiKey := NewApiKey;
    end;

    // Generates chat completions by sending a request to OpenAI and processes the response
    procedure GenerateChatCompletion(
        var ChatMessages: Codeunit "GPT Chat Messages";
        var ChatCompletionParams: Codeunit "GPT Chat Completion Params";
        var OperationResponse: Codeunit "GPT Operation Response"
    ): Text
    var
        RestClient: Codeunit "Rest Client";
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonRequestBody: JsonObject;
        RequestBody: Text;
    begin
        // Initialize REST client and set base address and authorization header
        RestClient.Initialize();
        RestClient.SetBaseAddress(Endpoint);
        RestClient.SetDefaultRequestHeader('Authorization', SecretStrSubstNo('Bearer %1', ApiKey));

        // Prepare the JSON body for the request
        ChatCompletionParams.AddChatCompletionsParametersToPayload(JsonRequestBody);
        JsonRequestBody.Add('model', Format(Model));
        JsonRequestBody.Add('messages', ChatMessages.GetMessagesJsonArray()); // Retrieve messages as JSON array
        JsonRequestBody.WriteTo(RequestBody);

        HttpContent.Create(JsonRequestBody); // Create HTTP content from the JSON request body

        // Send the POST request to OpenAI and receive the response
        HttpResponseMessage := RestClient.Send("Http Method"::POST, Endpoint, HttpContent);
        // Process the HTTP response message
        OperationResponse.SetOperationResponse(HttpResponseMessage.GetResponseMessage());
        // Extract and return the content from the JSON response
        exit(GetContent(HttpResponseMessage.GetContent().AsJson().AsObject()));
    end;

    // Extracts the generated text content from the OpenAI response
    procedure GetContent(JsonResponse: JsonObject): Text
    var
        ContentToken: JsonToken;
    begin
        // Use JSONPath to select the specific piece of content from the response
        if JsonResponse.SelectToken('$.choices[0].message.content', ContentToken) then
            exit(ContentToken.AsValue().AsText())
        else
            Error('Error getting content from the response.'); // Handle case where content cannot be extracted
    end;
}
