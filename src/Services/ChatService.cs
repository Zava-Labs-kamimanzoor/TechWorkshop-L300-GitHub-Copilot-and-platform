using Azure;
using Azure.AI.OpenAI;
using Azure.Identity;
using OpenAI.Chat;

namespace ZavaStorefront.Services;

public class ChatService
{
    private readonly string _endpoint;
    private readonly string _deploymentName;
    private readonly AzureOpenAIClient? _client;

    public ChatService(IConfiguration configuration)
    {
        _endpoint = configuration["FOUNDRY_ENDPOINT"] ?? string.Empty;
        _deploymentName = configuration["FOUNDRY_MODEL_DEPLOYMENT_NAME"] ?? "gpt-4o-mini";

        if (!string.IsNullOrEmpty(_endpoint))
        {
            try
            {
                // Use DefaultAzureCredential for authentication (works with Managed Identity in Azure)
                var credential = new DefaultAzureCredential();
                _client = new AzureOpenAIClient(new Uri(_endpoint), credential);
                Console.WriteLine("Azure OpenAI client initialized with built-in content filtering");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to initialize Azure OpenAI client: {ex.Message}");
            }
        }
    }

    public async Task<string> SendMessageAsync(string userMessage)
    {
        if (_client == null)
        {
            return "Chat service is not configured. Please check the FOUNDRY_ENDPOINT environment variable.";
        }

        if (string.IsNullOrWhiteSpace(userMessage))
        {
            return "Please enter a message.";
        }

        try
        {
            var chatClient = _client.GetChatClient(_deploymentName);

            var messages = new List<ChatMessage>
            {
                new SystemChatMessage("You are a helpful AI assistant for the Zava Storefront. Help users with their questions about products, shopping, or general inquiries."),
                new UserChatMessage(userMessage)
            };

            var chatCompletionOptions = new ChatCompletionOptions
            {
                MaxOutputTokenCount = 800,
                Temperature = 0.7f
            };

            var response = await chatClient.CompleteChatAsync(messages, chatCompletionOptions);

            return response.Value.Content[0].Text;
        }
        catch (RequestFailedException ex) when (ex.ErrorCode == "content_filter")
        {
            Console.WriteLine($"Content filter triggered: {ex.Message}");
            return "I'm sorry, but I can't process that message as it may contain inappropriate content. Please rephrase your question.";
        }
        catch (RequestFailedException ex)
        {
            Console.WriteLine($"Azure OpenAI request failed: {ex.Message}");
            return $"Sorry, I encountered an error processing your request: {ex.Message}";
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Unexpected error in chat service: {ex.Message}");
            return "Sorry, I encountered an unexpected error. Please try again later.";
        }
    }
}
