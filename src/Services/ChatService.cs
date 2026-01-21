using Azure;
using Azure.AI.OpenAI;
using Azure.AI.ContentSafety;
using Azure.Identity;
using OpenAI.Chat;

namespace ZavaStorefront.Services;

public class ChatService
{
    private readonly string _endpoint;
    private readonly string _deploymentName;
    private readonly AzureOpenAIClient? _client;
    private readonly ContentSafetyClient? _contentSafetyClient;

    public ChatService(IConfiguration configuration)
    {
        _endpoint = configuration["FOUNDRY_ENDPOINT"] ?? string.Empty;
        _deploymentName = configuration["FOUNDRY_MODEL_DEPLOYMENT_NAME"] ?? "gpt-4o-mini";
        var contentSafetyEndpoint = configuration["FOUNDRY_ENDPOINT"] ?? string.Empty;

        if (!string.IsNullOrEmpty(_endpoint))
        {
            try
            {
                // Use DefaultAzureCredential for authentication (works with Managed Identity in Azure)
                var credential = new DefaultAzureCredential();
                _client = new AzureOpenAIClient(new Uri(_endpoint), credential);
                _contentSafetyClient = new ContentSafetyClient(new Uri(contentSafetyEndpoint), credential);
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

        // Check content safety
        var (isSafe, reason) = await CheckContentSafetyAsync(userMessage);
        if (!isSafe)
        {
            Console.WriteLine($"Content safety check failed: {reason}");
            return "I'm sorry, but I can't process that message as it may contain inappropriate content. Please rephrase your question.";
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

    private async Task<(bool isSafe, string reason)> CheckContentSafetyAsync(string text)
    {
        if (_contentSafetyClient == null)
        {
            Console.WriteLine("Content Safety client not initialized, skipping safety check");
            return (true, string.Empty);
        }

        try
        {
            var request = new AnalyzeTextOptions(text);
            var response = await _contentSafetyClient.AnalyzeTextAsync(request);
            var result = response.Value;

            // Check categories: violence, sexual, hate, self-harm
            // Treat severity >= 2 as unsafe
            if (result.HateResult?.Severity >= 2)
            {
                return (false, $"Hate content detected (severity: {result.HateResult.Severity})");
            }
            if (result.SelfHarmResult?.Severity >= 2)
            {
                return (false, $"Self-harm content detected (severity: {result.SelfHarmResult.Severity})");
            }
            if (result.SexualResult?.Severity >= 2)
            {
                return (false, $"Sexual content detected (severity: {result.SexualResult.Severity})");
            }
            if (result.ViolenceResult?.Severity >= 2)
            {
                return (false, $"Violence content detected (severity: {result.ViolenceResult.Severity})");
            }

            Console.WriteLine("Content safety check passed");
            return (true, string.Empty);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Content safety check failed: {ex.Message}");
            // On error, allow the message through but log it
            return (true, string.Empty);
        }
    }
}
