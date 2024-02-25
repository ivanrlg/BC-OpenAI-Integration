codeunit 50105 "GPT Chat Messages"
{
    var
        ChatMessages: List of [JsonObject];

    // Adds a system message to the chat, identified by the 'system' role.
    procedure AddSystemMessage(NewMessage: Text)
    var
        MessageObject: JsonObject;
    begin
        MessageObject.Add('role', 'system'); // Specifies the role of the message as 'system'.
        MessageObject.Add('content', NewMessage); // The actual message content.
        ChatMessages.Add(MessageObject); // Adds the message to the chat messages list.
    end;

    // Adds a user message to the chat, identified by the 'user' role.
    procedure AddUserMessage(NewMessage: Text)
    var
        MessageObject: JsonObject;
    begin
        MessageObject.Add('role', 'user'); // Specifies the role of the message as 'user'.
        MessageObject.Add('content', NewMessage); // The actual message content.
        ChatMessages.Add(MessageObject); // Adds the message to the chat messages list.
    end;

    // Adds an assistant message to the chat, identified by the 'assistant' role.
    procedure AddAssistantMessage(NewMessage: Text)
    var
        MessageObject: JsonObject;
    begin
        MessageObject.Add('role', 'assistant'); // Specifies the role of the message as 'assistant'.
        MessageObject.Add('content', NewMessage); // The actual message content.
        ChatMessages.Add(MessageObject); // Adds the message to the chat messages list.
    end;

    // Clears all messages from the chat, resetting the conversation.
    procedure ClearMessages()
    begin
        Clear(ChatMessages); // Empties the list of chat messages.
    end;

    // Compiles all chat messages into a JSON array for API submission.
    procedure GetMessagesJsonArray(): JsonArray
    var
        MessagesArray: JsonArray;
        CurrentMessage: JsonObject;
    begin
        foreach CurrentMessage in ChatMessages do
            MessagesArray.Add(CurrentMessage); // Adds each message to the JSON array.

        exit(MessagesArray); // Returns the compiled JSON array of messages.
    end;
}
