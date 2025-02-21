using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class AddKeyRequest
    {
        public string? keyId { get; set; }
        public string? encryptionFragment { get; set; }
        public string? provider { get; set; }
        public string? apiKey { get; set; }
    }

    public class ErrorResponse
    {
        public Error? error { get; set; }
    }

    public class Error
    {
        public string? code { get; set; }
    }

    public class AddKey
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await GetToken();

                Console.WriteLine($"Token: {token}");

                // Add a new API key
                using (var client = new HttpClient())
                {
                    var addKeyRequest = new AddKeyRequest
                    {
                        keyId = "claude-key-1",
                        encryptionFragment = "OpenThePodBayDoorsHAL-2001",
                        provider = "anthropic",
                        apiKey = "sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA"
                    };

                    var json = JsonSerializer.Serialize(addKeyRequest);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {token}");
                    var response = await client.PostAsync($"{BASE_URL}/admin/keys/add-key", content);

                    if (!response.IsSuccessStatusCode)
                    {
                        if (response.StatusCode == System.Net.HttpStatusCode.Conflict)
                        {
                            var errorJson = await response.Content.ReadAsStringAsync();
                            var error = JsonSerializer.Deserialize<ErrorResponse>(errorJson);
                            
                            if (error?.error?.code == "duplicate_key_id")
                            {
                                Console.WriteLine("\n\u001b[33m⚠️  Key already exists with this ID\u001b[0m");
                                return;
                            }
                        }

                        var errorText = await response.Content.ReadAsStringAsync();
                        Console.WriteLine($"\n\u001b[31mServer response: {response.StatusCode} {errorText}\u001b[0m");
                        throw new Exception($"Failed to add key: {response.StatusCode}");
                    }

                    Console.WriteLine("\n\u001b[32m✅ Key added successfully\u001b[0m");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task<string> GetToken()
        {
            // Reuse the token caching logic from CacheToken.cs
            try
            {
                return await CacheToken.GetToken();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Auth error: {ex.Message}");
                throw;
            }
        }
    }
}
