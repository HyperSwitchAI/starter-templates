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
            'expiresAt': int(time.time() * 1000) + 3600000  # 1 hour
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
        
        # List strategies
        list_strategies_response = requests.get(
            f'{BASE_URL}/admin/strategies/list',
            headers={
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {token}'
            }
        )

        # Raise exception for error status codes
        list_strategies_response.raise_for_status()

        # Get the result
        result = list_strategies_response.json()
        print('\n\033[92m✅ Strategies listed successfully\033[0m')
        print(result)
        
    except requests.exceptions.HTTPError as e:
        print('Error:', str(e))
    except Exception as e:
        print('Error:', str(e))

if __name__ == '__main__':
    main()
