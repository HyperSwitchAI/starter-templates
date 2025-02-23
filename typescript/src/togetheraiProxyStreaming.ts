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
        'x-strategy-code': 'togetherai-proxy-1',
        'Authorization': `Bearer ${token}`
      }
    });

    const stream = await openai.chat.completions.create({
        model: "ignored",
        messages: [ { role: "user" as const, content: "Write a short story about a ninja train." } ],
        stream: true,
        stop: ["Done", "Stop"],  // Stop sequences
      });
      for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content || "";
        if (content.includes('"type":"metrics"')) {
          try {
            const metricsData = JSON.parse(content);
            console.log(`Metrics: ${JSON.stringify(metricsData.system_fingerprint, null, 2)}\n`);
          } catch {} // Ignore parse errors
        } else {
          process.stdout.write(content);
        }
      }
      console.log('\n');


  } catch (error) {
    console.error('Error:', error);
  }
}

main();