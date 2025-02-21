using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class AddAwsCredentialsRequest
    {
        public string? keyId { get; set; }
        public string? encryptionFragment { get; set; }
        public string? provider { get; set; }
        public string? accessKeyId { get; set; }
        public string? secretAccessKey { get; set; }
    }

    public class AddAwsCredentials
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await CacheToken.GetToken();

                // Add AWS credentials
                using (var client = new HttpClient())
                {
                    var addKeyRequest = new AddAwsCredentialsRequest
                    {
                        keyId = "bedrock-key-1",
                        encryptionFragment = "OpenThePodBayDoorsHAL-2001",
                        provider = "bedrock",
                        accessKeyId = "AKIDFGRTHTHYTHTY",
                        secretAccessKey = "ehegruherghekjllkdfjhgkjdfh"
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
                        throw new Exception($"Failed to add AWS credentials: {response.StatusCode}");
                    }

                    Console.WriteLine("\n\u001b[32m✅ AWS credentials added successfully\u001b[0m");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
