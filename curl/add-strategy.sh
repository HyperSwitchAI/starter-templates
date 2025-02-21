#!/bin/bash

TOKEN_CACHE_FILE=".token-cache.json"
BASE_URL="https://api.hyperswitchai.com"

# Get token from cache file
if [ ! -f "$TOKEN_CACHE_FILE" ]; then
    echo "Error: Token cache file not found. Please run cache-token.sh first."
    exit 1
fi

# Extract token from cache file
token=$(cat "$TOKEN_CACHE_FILE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# Make the add-strategy request
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/admin/strategies/add-strategy" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -X POST \
    -d '{
        "code": "claude-proxy-1",
        "type": "proxy",
        "model": "claude-3-5-sonnet-20240620",
        "keyId": "claude-key-1",
        "provider": "anthropic"
    }')

# Get the status code (last line)
http_code=$(echo "$response" | tail -n1)
# Get the response body (everything except the last line)
body=$(echo "$response" | sed \$d)

# Check if request was successful
if [ "$http_code" -eq 200 ]; then
    echo -e "\n\033[32m✅ Strategy added successfully\033[0m"
elif [ "$http_code" -eq 409 ]; then
    # Try to parse error code
    if echo "$body" | grep -q '"code":"duplicate_strategy_code"'; then
        echo -e "\n\033[33m⚠️  Strategy already exists with this code\033[0m"
        exit 0
    fi
    echo -e "\n\033[31mServer response: $http_code\033[0m"
    echo "Response: $body"
    exit 1
else
    echo -e "\n\033[31mServer response: $http_code\033[0m"
    echo "Response: $body"
    exit 1
fi
