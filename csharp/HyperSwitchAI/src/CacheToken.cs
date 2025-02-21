using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using DotNetEnv;

namespace HyperSwitchAI
{
    public class TokenCache
    {
        public string? token { get; set; }
        public long expiresAt { get; set; }
    }

    public class CacheToken
    {
        private const string TOKEN_CACHE_FILE = ".token-cache.json";
        private const string BASE_URL = "https://api.hyperswitchai.com";

        public static async Task<string> GetToken()
        {
            try
            {
                // Check if we have a cached token
                if (File.Exists(TOKEN_CACHE_FILE))
                {
                    var cacheJson = File.ReadAllText(TOKEN_CACHE_FILE);
                    var cache = JsonSerializer.Deserialize<TokenCache>(cacheJson);
                    
                    // Check if token is still valid (with 5 minute buffer)
                    if (cache?.expiresAt > DateTimeOffset.Now.ToUnixTimeMilliseconds() + 300000)
                    {
                        return cache.token ?? throw new Exception("Cached token is null");
                    }
                }

                // Get new token
                using (var client = new HttpClient())
                {
                    var authRequest = new AuthRequest
                    {
                        username = Environment.GetEnvironmentVariable("USERNAME"),
                        password = Environment.GetEnvironmentVariable("PASSWORD")
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

                    // Cache token with 1 hour expiry
                    var cache = new TokenCache
                    {
                        token = authResponse?.token,
                        expiresAt = DateTimeOffset.Now.ToUnixTimeMilliseconds() + 3600000 // 1 hour
                    };

                    File.WriteAllText(TOKEN_CACHE_FILE, JsonSerializer.Serialize(cache));

                    return cache.token ?? throw new Exception("New token is null");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Auth error: {ex.Message}");
                throw;
            }
        }

        public static async Task RunAsync()
        {
            try
            {
                Env.Load();
                var token = await GetToken();

                Console.WriteLine("\u001b[32m✅ Token successfully cached in .token-cache.json\u001b[0m");
                Console.WriteLine($"Token: {token}");

                Console.WriteLine("\u001b[36mNow the token is cached in .token-cache.json, you can use it in your code and not have to get a new one all the time (until it expires).\u001b[0m");
                Console.WriteLine("\u001b[36mIf you run this code again you should see the same token is being used.\u001b[0m");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
} 