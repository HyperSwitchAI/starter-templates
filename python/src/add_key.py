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

        print('Token:', token)
        
        # Add a new API key
        add_key_response = requests.post(
            f'{BASE_URL}/admin/keys/add-key',
            headers={
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {token}'
            },
            json={
                'keyId': 'claude-key-1',
                'encryptionFragment': 'OpenThePodBayDoorsHAL-2001',
                'provider': 'claude',
                'apiKey': 'sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA'
            }
        )

        if add_key_response.status_code == 409:
            error_data = add_key_response.json()
            if error_data.get('error', {}).get('code') == 'duplicate_key_id':
                print('\n\033[93m⚠️  Key already exists with this ID\033[0m')
                return

        # Raise exception for other error status codes
        add_key_response.raise_for_status()

        print('\n\033[92m✅ Key added successfully\033[0m')
        
    except requests.exceptions.HTTPError as e:
        error_text = e.response.text if hasattr(e, 'response') else str(e)
        print(f'\n\033[91mServer response: {e.response.status_code if hasattr(e, "response") else "Unknown"} {error_text}\033[0m')
        print(f'Failed to add key: {str(e)}')
    except Exception as e:
        print('Error:', str(e))

if __name__ == '__main__':
    main()
