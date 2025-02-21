# HyperSwitch AI Python Examples

Python examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern Python practices.

## Prerequisites

- Python 3.7 or higher
- pip (Python package installer)
- A HyperSwitch AI account and credentials

## Setup

1. Create a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Create a `.env` file in the root directory with your credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Scripts

### Authentication
- `cache_token.py` - Demonstrates token caching for efficient authentication

### API Key Management
- `add_key.py` - Add a new API key
- `list_keys.py` - List all API keys
- `delete_key.py` - Delete an API key
- `add_aws_credentials.py` - Add AWS credentials

### Strategy Management
- `add_strategy.py` - Add a new strategy
- `list_strategies.py` - List all strategies
- `update_strategy.py` - Update an existing strategy
- `delete_strategy.py` - Delete a strategy

## Usage

Run any example script using Python:

```bash
python src/cache_token.py
python src/add_key.py
python src/list_keys.py
# etc...
```

## Implementation Details

- Uses the `requests` library for HTTP operations
- Implements token caching for efficient authentication
- Handles errors gracefully with appropriate messages
- Uses environment variables for secure credential management
- Follows Python best practices and modern coding standards

## Common Operations

### Authentication
```python
# Token is automatically cached and reused until expiration
token = get_token()
```

### Making API Requests
```python
response = requests.post(
    f'{BASE_URL}/endpoint',
    headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    },
    json=payload
)
```

### Error Handling
```python
try:
    response.raise_for_status()
except requests.exceptions.HTTPError as e:
    print(f'Error: {str(e)}')
```

## Security Notes

- Never commit the `.env` file to version control
- Keep your API keys and encryption fragments secure
- Use environment variables for sensitive data
- Follow security best practices for credential management

## File Structure

```
python/
├── src/
│   ├── cache_token.py
│   ├── add_key.py
│   ├── list_keys.py
│   ├── delete_key.py
│   ├── add_aws_credentials.py
│   ├── add_strategy.py
│   ├── list_strategies.py
│   ├── update_strategy.py
│   └── delete_strategy.py
├── requirements.txt
└── README.md
```

## Dependencies

- `requests`: For HTTP operations
- `python-dotenv`: For environment variable management
- `pathlib`: For file path operations

## Support

For questions about:
- The HyperSwitch AI service: Visit [HyperSwitchAI.com](https://HyperSwitchAI.com)
- API documentation: Check [console.hyperswitchai.com/docs.html](https://console.hyperswitchai.com/docs.html)
- These examples: Contact HyperSwitch AI support
