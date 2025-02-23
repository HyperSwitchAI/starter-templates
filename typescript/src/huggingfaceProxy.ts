import OpenAI from 'openai';
import dotenv from 'dotenv';
import fs from 'node:fs';

dotenv.config();

const TOKEN_CACHE_FILE = '.token-cache.json';
const BASE_URL = 'http://localhost:3000';
//const BASE_URL = 'https://api.hyperswitchai.com';

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
        username: process.env.USERNAME,
        password: process.env.PASSWORD,
      })
    });

    if (!authResponse.ok) {
      throw new Error('Authentication failed');
    }

    const { token } = await authResponse.json() as { token: string };

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
        'x-encryption-fragment': 'OpenThePodBayDoorsHAL-2001',
        'x-strategy-code': 'huggingface-proxy-1',
        'Authorization': `Bearer ${token}`
      }
    });

    const response = await openai.chat.completions.create({
        model: "ignored",
        messages: [ { role: "user" as const, content: "Write a haiku about a frozen waterfall." } ],
        stream: false
    });
    
    // Display the response
    console.log('\nResponse:', response.choices[0].message?.content);

    // Display metrics if available
    if (response.system_fingerprint) {
        const metrics = JSON.parse(response.system_fingerprint);
        console.log('\nMetrics:', metrics);
    }
    

  } catch (error) {
    console.error('Error:', error);
  }
}

main();