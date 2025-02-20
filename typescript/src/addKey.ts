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

    console.log('Token:', token);
    
    // Add a new API key
    const addKeyResponse = await fetch(`${BASE_URL}/admin/keys/addKey`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        keyId: 'claude-key-1',
        encryptionFragment: 'OpenThePodBayDoorsHAL-2001',
        provider: 'claude',
        apiKey: 'sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA'
      })
    });

    if (!addKeyResponse.ok) {
      if (addKeyResponse.status === 409) {
        const error = await addKeyResponse.json() as { error?: { code: string } };
        if (error.error?.code === 'duplicate_key_id') {
          console.log('\n\x1b[33m⚠️  Key already exists with this ID\x1b[0m');
          return;
        }
      }
      const errorText = await addKeyResponse.text();
      console.error('\n\x1b[31mServer response:', addKeyResponse.status, errorText, '\x1b[0m');
      throw new Error(`Failed to add key: ${addKeyResponse.statusText}`);
    }

    console.log('\n\x1b[32m✅ Key added successfully\x1b[0m');
    
  } catch (error) {
    console.error('Error:', error);
  }
}

main();
