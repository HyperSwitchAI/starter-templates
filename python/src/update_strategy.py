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
        
        # Update strategy
        response = requests.post(
            f'{BASE_URL}/admin/strategies/update-strategy',
            headers={
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {token}'
            },
            json={
                "code": "claude-proxy-1",
                "type": "proxy",
                "model": "claude-3-5-haiku-20241022",
                "keyId": "claude-key-1",
                "provider": "anthropic"
            }
        )

        if response.status_code == 409:
            try:
                error_data = response.json()
                if error_data.get('error', {}).get('code') == 'duplicate_strategy_code':
                    print('\n\033[93m⚠️  Strategy already exists with this code\033[0m')
                    return
            except json.JSONDecodeError:
                # If JSON parsing fails, continue with error handling
                pass

        # Raise exception for other error status codes
        if not response.ok:
            print(f'\n\033[91mServer response: {response.status_code} {response.text}\033[0m')
            raise requests.exceptions.HTTPError(f'Failed to update strategy: {response.reason}')

        print('\n\033[92m✅ Strategy updated successfully\033[0m')
        
    except requests.exceptions.HTTPError as e:
        print('Error:', str(e))
    except Exception as e:
        print('Error:', str(e))

if __name__ == '__main__':
    main()
