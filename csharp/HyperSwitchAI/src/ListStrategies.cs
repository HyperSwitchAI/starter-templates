using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class StrategyInfo
    {
        public string? code { get; set; }
        public string? type { get; set; }
        public string? model { get; set; }
        public string? keyId { get; set; }
        public string? provider { get; set; }
    }

    public class ListStrategiesResponse
    {
        public StrategyInfo[]? strategies { get; set; }
    }

    public class ListStrategies
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await CacheToken.GetToken();

                // List all strategies
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
                    var response = await client.GetAsync($"{BASE_URL}/admin/strategies/list");

                    if (!response.IsSuccessStatusCode)
                    {
                        var errorText = await response.Content.ReadAsStringAsync();
                        Console.WriteLine($"\n\u001b[31mServer response: {response.StatusCode} {errorText}\u001b[0m");
                        throw new Exception($"Failed to list strategies: {response.StatusCode}");
                    }

                    var responseBody = await response.Content.ReadAsStringAsync();
                    var result = JsonSerializer.Deserialize<ListStrategiesResponse>(responseBody);

                    Console.WriteLine("\n\u001b[32m✅ Strategies listed successfully\u001b[0m");
                    Console.WriteLine(JsonSerializer.Serialize(result, new JsonSerializerOptions 
                    { 
                        WriteIndented = true 
                    }));
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
