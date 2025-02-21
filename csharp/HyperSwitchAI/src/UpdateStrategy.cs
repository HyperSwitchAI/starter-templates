using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class UpdateStrategyRequest
    {
        public string? code { get; set; }
        public string? type { get; set; }
        public string? model { get; set; }
        public string? keyId { get; set; }
        public string? provider { get; set; }
    }

    public class UpdateStrategy
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await CacheToken.GetToken();

                // Update a strategy
                using (var client = new HttpClient())
                {
                    var updateStrategyRequest = new UpdateStrategyRequest
                    {
                        code = "claude-proxy-1",
                        type = "proxy",
                        model = "claude-3-5-haiku-20241022",
                        keyId = "claude-key-1",
                        provider = "anthropic"
                    };

                    var json = JsonSerializer.Serialize(updateStrategyRequest);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
                    var response = await client.PostAsync($"{BASE_URL}/admin/strategies/update-strategy", content);

                    if (!response.IsSuccessStatusCode)
                    {
                        if (response.StatusCode == System.Net.HttpStatusCode.Conflict)
                        {
                            var errorJson = await response.Content.ReadAsStringAsync();
                            var error = JsonSerializer.Deserialize<ErrorResponse>(errorJson);
                            
                            if (error?.error?.code == "duplicate_strategy_code")
                            {
                                Console.WriteLine("\n\u001b[33m⚠️  Strategy already exists with this code\u001b[0m");
                                return;
                            }
                        }

                        var errorText = await response.Content.ReadAsStringAsync();
                        Console.WriteLine($"\n\u001b[31mServer response: {response.StatusCode} {errorText}\u001b[0m");
                        throw new Exception($"Failed to update strategy: {response.StatusCode}");
                    }

                    Console.WriteLine("\n\u001b[32m✅ Strategy updated successfully\u001b[0m");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
