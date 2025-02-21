# Hyperswitch AI Curl Examples

This directory contains examples of how to interact with the Hyperswitch AI API using curl commands.

## Prerequisites

1. Make sure you have `curl` installed on your system
2. You'll need your Hyperswitch AI username and password

## Making Scripts Executable

If you save these commands as shell scripts (e.g., `auth.sh`, `list-keys.sh`), make sure to make them executable:

```bash
chmod +x *.sh    # Makes all .sh files in the current directory executable
# or
chmod +x add-key.sh # Makes a specific script executable
```

Then you can run them like this:
```bash
./auth.sh
```

## Authentication

First, get an authentication token:

```bash
curl -X POST https://api.hyperswitchai.com/auth \
  -H "Content-Type: application/json" \
  -d '{
    "username": "your-email@example.com",
    "password": "your-password"
  }'
```

Save the token from the response for use in subsequent requests.

## API Keys

### List API Keys
```bash
curl -X GET https://api.hyperswitchai.com/admin/keys/list \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### Add API Key
```bash
curl -X POST https://api.hyperswitchai.com/admin/keys/add-key \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "keyId": "claude-key-1",
    "encryptionFragment": "your-encryption-fragment",
    "provider": "anthropic",
    "apiKey": "your-api-key"
  }'
```

### Delete API Key
```bash
curl -X POST https://api.hyperswitchai.com/admin/keys/delete-key \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "keyId": "claude-key-1"
  }'
```

## Strategies

### List Strategies
```bash
curl -X GET https://api.hyperswitchai.com/admin/strategies/list \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### Add Strategy
```bash
curl -X POST https://api.hyperswitchai.com/admin/strategies/add-strategy \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "claude-proxy-1",
    "type": "proxy",
    "model": "claude-3-5-sonnet-20240620",
    "keyId": "claude-key-1",
    "provider": "anthropic"
  }'
```

### Update Strategy
```bash
curl -X POST https://api.hyperswitchai.com/admin/strategies/update-strategy \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "claude-proxy-1",
    "type": "proxy",
    "model": "claude-3-5-haiku-20241022",
    "keyId": "claude-key-1",
    "provider": "anthropic"
  }'
```

### Delete Strategy
```bash
curl -X POST https://api.hyperswitchai.com/admin/strategies/delete-strategy \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "claude-proxy-1"
  }'
```

## Notes

- Replace `YOUR_TOKEN` with the actual token received from the authentication endpoint
- The token expires after some time, so you'll need to get a new one periodically
- All requests require the `Content-Type: application/json` header
- All responses will be in JSON format
