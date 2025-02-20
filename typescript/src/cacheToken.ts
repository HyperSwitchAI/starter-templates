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
      expiresAt: Date.now() + 3600000 // 1 hour. Note that this is just for our convenience in determining if the token is still valid. Changing this value does not affect the token's actual expiration from the server.
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

    console.log('\n\x1b[32m%s\x1b[0m', '✅ Token successfully cached in .token-cache.json');
    
    console.log('Token:', token);

    console.log('\x1b[36m%s\x1b[0m', 'Now the token is cached in .token-cache.json, you can use it in your code and not have to get a new one all the time (until it expires).');

    console.log('\x1b[36m%s\x1b[0m', 'If you run this code again you should see the same token is being used.');


  } catch (error) {
    console.error('Error:', error);
  }
}

main();
