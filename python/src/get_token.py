import os
import json
from dotenv import load_dotenv
import requests

# Load environment variables from .env file
load_dotenv()

BASE_URL = 'https://api.hyperswitchai.com'

def main():
    try:
        # Check for required environment variables
        if not os.getenv('USERNAME') or not os.getenv('PASSWORD'):
            raise ValueError('USERNAME and PASSWORD must be set in a .env file in the python directory. '
                           'You can rename .env.sample to .env and fill in your own email and password.')
        
        # Make authentication request
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
        
        # Print success message with color
        print('\n\033[92m✅ Token successfully retrieved\033[0m')
        print('Token:', token)

    except requests.exceptions.RequestException as e:
        print('Error: Authentication failed')
        print('Details:', str(e))
    except Exception as e:
        print('Error:', str(e))

if __name__ == '__main__':
    main()
