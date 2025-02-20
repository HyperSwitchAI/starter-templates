import OpenAI from 'openai';
import dotenv from 'dotenv';
import fs from 'node:fs';

dotenv.config();

const TOKEN_CACHE_FILE = '.token-cache.json';

const BASE_URL = 'https://api.hyperswitchai.com';

async function getToken() {
  try {
    // Check if we have a cached token
    if (fs.existsSync(TOKEN_CACHE_FILE)) {
      const cache = JSON.parse(fs.readFileSync(TOKEN_CACHE_FILE, 'utf8'));
      // Check if token is still valid (with 5 minute buffer)
      if (cache.expiresAt > Date.now() + 300000) {
        return cache.token;
      }
    }

    // Get new token
    const authResponse = await fetch(`${BASE_URL}/auth`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: 'ryan321@outlook.com',
        password: 'Password!123',
        //poolId: 'us-east-1_a3YukGFJQ',
        //type: 'private'
      })
    });

    if (!authResponse.ok) {
      throw new Error('Authentication failed');
    }

    const { token, accessToken } = await authResponse.json() as { token: string, accessToken: string };

    // console.log('Token:', token);
    // console.log('Access Token:', accessToken);
    
    // Cache token with 1 hour expiry
    fs.writeFileSync(TOKEN_CACHE_FILE, JSON.stringify({
      token,
      expiresAt: Date.now() + 3600000 // 1 hour
    }));

    return token;
  } catch (error) {
    console.error('Auth error:', error);
    throw error;
  }
}

async function main() {
  try {
    const token = await getToken();
    
    const openai = new OpenAI({
      baseURL: BASE_URL,
      apiKey: 'ignored',
      defaultHeaders: {
        'x-encryption-fragment': 'bubba',
        // 'x-strategy': JSON.stringify({
        //   type: "proxy",
        //   provider: "anthropic",
        //   model: "claude-3-5-sonnet-20240620",
        //   keyId: "claude-key-1"
        // }),
        'x-strategy-code': 'failover-1',
        'Authorization': `Bearer ${token}`
      }
    });

    const messages = [
      { role: "user" as const, content: "Write a short story about a ninja train." }
    ];

    const isStreaming = true; // Toggle this to test different modes

    if (isStreaming) {
      const stream = await openai.chat.completions.create({
        model: "ignored",
        messages,
        stream: true,
        // Generation parameters
        temperature: 0.7,        // Controls randomness (0-2)
        max_tokens: 512,        // Max length of response
        top_p: 0.9,            // Nucleus sampling
        n: 1,                  // Number of completions
        stop: ["Done", "Stop"],  // Stop sequences
        presence_penalty: 0,    // Penalize new topics (-2 to 2)
        frequency_penalty: 0,   // Penalize repetition (-2 to 2)
        // Additional parameters
        seed: 123,             // For deterministic outputs
        response_format: { type: "text" },  // Force text responses
        tools: [],             // Function calling
        tool_choice: "auto",   // Tool selection behavior
        user: "test-user"      // For tracking
      });
      for await (const chunk of stream) {
        // Check for system fingerprint in metadata
        if (chunk.system_fingerprint) {
          console.log('\nExecution Metrics:', JSON.parse(chunk.system_fingerprint));
        }
        // Display content as usual
        process.stdout.write(chunk.choices[0]?.delta?.content || "");
      }
      console.log('\n');
    } else {
      const response = await openai.chat.completions.create({
        model: "ignored",
        messages,
        stream: false
      });
      
      // Display all responses from different models
      response.choices.forEach((choice, index) => {
        console.log(`\nResponse ${index + 1}:`, choice.message?.content);
      });

      // Display metrics if available
      if (response.system_fingerprint) {
        const metrics = JSON.parse(response.system_fingerprint);
        console.log('\nExecution Metrics:', metrics);
      }
    }

  } catch (error) {
    console.error('Error:', error);
  }
}

main();
