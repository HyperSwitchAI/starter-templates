using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class DeleteKeyRequest
    {
        public string? keyId { get; set; }
    }

    public class DeleteKey
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await CacheToken.GetToken();

                // Delete an API key
                using (var client = new HttpClient())
                {
                    var deleteKeyRequest = new DeleteKeyRequest
                    {
                        keyId = "claude-key-1"
                    };

                    var json = JsonSerializer.Serialize(deleteKeyRequest);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
                    var response = await client.PostAsync($"{BASE_URL}/admin/keys/delete-key", content);

                    if (!response.IsSuccessStatusCode)
                    {
                        if (response.StatusCode == System.Net.HttpStatusCode.NotFound)
                        {
                            Console.WriteLine("\n\u001b[33m⚠️  Key not found - it may have already been deleted\u001b[0m");
                            return;
                        }

                        var errorText = await response.Content.ReadAsStringAsync();
                        Console.WriteLine($"\n\u001b[31mServer response: {response.StatusCode} {errorText}\u001b[0m");
                        throw new Exception($"Failed to delete key: {response.StatusCode}");
                    }

                    Console.WriteLine("\n\u001b[32m✅ Key deleted successfully\u001b[0m");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
