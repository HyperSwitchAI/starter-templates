using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class AuthRequest
    {
        public string? username { get; set; }
        public string? password { get; set; }
    }

    public class AuthResponse
    {
        public string? token { get; set; }
    }

    public class GetToken
    {
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task RunAsync()
        {
            try
            {
                // Load environment variables
                Env.Load();

                var username = Environment.GetEnvironmentVariable("USERNAME");
                var password = Environment.GetEnvironmentVariable("PASSWORD");

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                {
                    throw new Exception("USERNAME and PASSWORD must be set in a .env file in the csharp directory. You can rename .env.sample to .env and fill in your own email and password.");
                }

                using (var client = new HttpClient())
                {
                    var authRequest = new AuthRequest
                    {
                        username = username,
                        password = password
                    };

                    var json = JsonSerializer.Serialize(authRequest);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    var response = await client.PostAsync($"{BASE_URL}/auth", content);

                    if (!response.IsSuccessStatusCode)
                    {
                        throw new Exception("Authentication failed");
                    }

                    var responseBody = await response.Content.ReadAsStringAsync();
                    var authResponse = JsonSerializer.Deserialize<AuthResponse>(responseBody);

                    Console.WriteLine("\u001b[32m✅ Token successfully retrieved\u001b[0m");
                    Console.WriteLine($"Token: {authResponse?.token}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}