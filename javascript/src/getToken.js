import dotenv from 'dotenv';

dotenv.config();

const BASE_URL = 'https://api.hyperswitchai.com';

async function main() {
  try {

    if (!process.env.USERNAME || !process.env.PASSWORD) {
      throw new Error('USERNAME and PASSWORD must be set in a .env file in the javascript directory. You can rename .env.sample to .env and fill in your own email and password.');
    }
    
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
  
      const { token } = await authResponse.json();

      console.log('\n\x1b[32m%s\x1b[0m', '✅ Token successfully retrieved');
      console.log('Token:', token);

  } catch (error) {
    console.error('Error:', error);
  }
}

main();
