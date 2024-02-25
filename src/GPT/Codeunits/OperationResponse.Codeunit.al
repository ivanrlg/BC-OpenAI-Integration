codeunit 50107 "GPT Operation Response"
{
    var
        StatusCode: Integer;
        Success: Boolean;
        Result: Text;
        ErrorMessage: Text;

    // Returns true if the API call was successful
    procedure IsSuccess(): Boolean
    begin
        exit(Success);
    end;

    // Retrieves the HTTP status code from the API response
    procedure GetStatusCode(): Integer
    begin
        exit(StatusCode);
    end;

    // Retrieves the result content from a successful API response
    procedure GetResult(): Text
    begin
        exit(Result);
    end;

    // Retrieves the error message from an unsuccessful API response
    procedure GetError(): Text
    begin
        exit(ErrorMessage);
    end;

    // Processes the HTTP response from the OpenAI API call
    procedure SetOperationResponse(HttpResponseMessage: HttpResponseMessage)
    var
        JsonBody: JsonObject;
        ContentText: Text;
        ErrorToken: JsonToken;
    begin
        // Set the status code and success status based on the HTTP response
        StatusCode := HttpResponseMessage.HttpStatusCode();
        Success := HttpResponseMessage.IsSuccessStatusCode();

        // Read the response content as text
        HttpResponseMessage.Content().ReadAs(ContentText);

        // Try to parse the content text into a JSON object
        if JsonBody.ReadFrom(ContentText) then begin
            if Success then
                // If the call was successful, store the entire response content
                Result := ContentText
            else
                // If the call was unsuccessful, try to extract the error message
                if JsonBody.Get('error', ErrorToken) then
                    // Ensure the error token is not an array before extracting the text
                    if not ErrorToken.IsArray() then
                        ErrorMessage := ErrorToken.AsValue().AsText();
        end else
            // If parsing fails, set a generic error message
            ErrorMessage := 'Failed to parse JSON response';
    end;
}
