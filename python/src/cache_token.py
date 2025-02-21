import os
import json
import time
from pathlib import Path
from dotenv import load_dotenv
import requests

# Load environment variables from .env file
load_dotenv()

TOKEN_CACHE_FILE = '.token-cache.json'
BASE_URL = 'https://api.hyperswitchai.com'

def get_token():
    try:
        # Check if we have a cached token
        cache_path = Path(TOKEN_CACHE_FILE)
        if cache_path.exists():
            with cache_path.open('r') as f:
                cache = json.load(f)
                # Check if token is still valid (with 5 minute buffer)
                if cache['expiresAt'] > int(time.time() * 1000) + 300000:
                    return cache['token']

        # Get new token
        auth_response = requests.post(
            f'{BASE_URL}/auth',
            headers={'Content-Type': 'application/json'},
            json={
                'username': os.getenv('USERNAME'),
                'password': os.getenv('PASSWORD')
            }
        )
        
        # Check if request was successful
        auth_response.raise_for_status()
        
        # Extract token from response
        token = auth_response.json()['token']

        # Cache token with 1 hour expiry
        cache_data = {
            'token': token,
            'expiresAt': int(time.time() * 1000) + 3600000  # 1 hour. Note that this is just for our convenience in determining if the token is still valid. Changing this value does not affect the token's actual expiration from the server.
        }
        
        with cache_path.open('w') as f:
            json.dump(cache_data, f)

        return token

    except requests.exceptions.RequestException as e:
        print('Auth error:', str(e))
        raise
    except Exception as e:
        print('Auth error:', str(e))
        raise

def main():
    try:
        token = get_token()

        print('\n\033[92m✅ Token successfully cached in .token-cache.json\033[0m')
        print('Token:', token)
        
        print('\033[96mNow the token is cached in .token-cache.json, you can use it in your code and not have to get a new one all the time (until it expires).\033[0m')
        print('\033[96mIf you run this code again you should see the same token is being used.\033[0m')

    except Exception as e:
        print('Error:', str(e))

if __name__ == '__main__':
    main()
