using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class AddStrategyRequest
    {
        public string? code { get; set; }
        public string? type { get; set; }
        public string? model { get; set; }
        public string? keyId { get; set; }
        public string? provider { get; set; }
    }

    public class AddStrategy
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await CacheToken.GetToken();

                // Add a new strategy
                using (var client = new HttpClient())
                {
                    var addStrategyRequest = new AddStrategyRequest
                    {
                        code = "claude-proxy-1",
                        type = "proxy",
                        model = "claude-3-5-sonnet-20240620",
                        keyId = "claude-key-1",
                        provider = "anthropic"
                    };

                    var json = JsonSerializer.Serialize(addStrategyRequest);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
                    var response = await client.PostAsync($"{BASE_URL}/admin/strategies/add-strategy", content);

                    if (!response.IsSuccessStatusCode)
                    {
                        var responseData = await response.Content.ReadAsStringAsync();

                        if (response.StatusCode == System.Net.HttpStatusCode.Conflict)
                        {
                            try
                            {
                                var error = JsonSerializer.Deserialize<ErrorResponse>(responseData);
                                if (error?.error?.code == "duplicate_strategy_code")
                                {
                                    Console.WriteLine("\n\u001b[33m⚠️  Strategy already exists with this code\u001b[0m");
                                    return;
                                }
                            }
                            catch
                            {
                                // If JSON parsing fails, continue with the text response
                            }
                        }

                        Console.WriteLine($"\n\u001b[31mServer response: {response.StatusCode} {responseData}\u001b[0m");
                        throw new Exception($"Failed to add strategy: {response.StatusCode}");
                    }

                    Console.WriteLine("\n\u001b[32m✅ Strategy added successfully\u001b[0m");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
