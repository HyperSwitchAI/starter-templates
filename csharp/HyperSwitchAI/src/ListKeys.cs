using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class KeyInfo
    {
        public string? keyId { get; set; }
        public string? provider { get; set; }
        // Note: API key values and encryption fragments are not included in the response
    }

    public class ListKeysResponse
    {
        public KeyInfo[]? keys { get; set; }
    }

    public class ListKeys
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await CacheToken.GetToken();

                // List all API keys
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
                    var response = await client.GetAsync($"{BASE_URL}/admin/keys/list");

                    if (!response.IsSuccessStatusCode)
                    {
                        var errorText = await response.Content.ReadAsStringAsync();
                        Console.WriteLine($"\n\u001b[31mServer response: {response.StatusCode} {errorText}\u001b[0m");
                        throw new Exception($"Failed to list keys: {response.StatusCode}");
                    }

                    var responseBody = await response.Content.ReadAsStringAsync();
                    var result = JsonSerializer.Deserialize<ListKeysResponse>(responseBody);

                    Console.WriteLine("\n\u001b[32m✅ Keys listed successfully\u001b[0m");
                    Console.WriteLine(JsonSerializer.Serialize(result, new JsonSerializerOptions 
                    { 
                        WriteIndented = true 
                    }));

                    Console.WriteLine("\nNote that neither the API key values nor the encryption fragments are included in the response.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
