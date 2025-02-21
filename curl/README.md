# Hyperswitch AI Curl Examples

This directory contains examples of how to interact with the Hyperswitch AI API using curl commands.

## Prerequisites

1. Make sure you have `curl` installed on your system
2. You'll need your HyperswitchAI username and password

## Setup

1. Create a `.env` file in the `curl` directory with your HyperswitchAI credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

2. Cache your authentication token:
```bash
./cache-token.sh
```
This will create a `.token-cache.json` file that other scripts will use.

## Making Scripts Executable

Make the scripts executable:

```bash
chmod +x *.sh    # Makes all .sh files in the current directory executable
# or
chmod +x add-key.sh # Makes a specific script executable
```

## Available Scripts

### Authentication
- `cache-token.sh` - Authenticates and caches your token
- All other scripts will use this cached token automatically

### API Keys
```bash
./add-key.sh     # Add a new API key
./list-keys.sh   # List all API keys
./delete-key.sh  # Delete an API key
```

### Strategies
```bash
./add-strategy.sh      # Add a new strategy
./list-strategies.sh   # List all strategies
./update-strategy.sh   # Update an existing strategy
./delete-strategy.sh   # Delete a strategy
```

### AWS Credentials
```bash
./add-aws-credentials.sh  # Add AWS credentials
```

## Example Script Usage

### Adding an API Key
```bash
./add-key.sh
```
This script will:
- Use the cached token from `.token-cache.json`
- Send a request to add a new API key
- Handle success/error responses appropriately

### Listing Strategies
```bash
./list-strategies.sh
```
This script will:
- Use the cached token from `.token-cache.json`
- Retrieve and display all strategies
- Format the output for readability

## Notes

- Run `cache-token.sh` first before using other scripts
- The token cache expires after 1 hour
- If you get authentication errors, try running `cache-token.sh` again
- All responses will be in JSON format
- Scripts will display colored output for success/error states
