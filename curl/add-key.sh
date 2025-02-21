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

# Make the add-key request
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/admin/keys/add-key" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -X POST \
    -d '{
        "keyId": "claude-key-1",
        "encryptionFragment": "OpenThePodBayDoorsHAL-2001",
        "provider": "claude",
        "apiKey": "sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA"
    }')

# Get the status code (last line)
http_code=$(echo "$response" | tail -n1)
# Get the response body (everything except the last line)
body=$(echo "$response" | sed \$d)

# Check if request was successful
if [ "$http_code" -eq 200 ]; then
    echo -e "\n\033[32m✅ Key added successfully\033[0m"
elif [ "$http_code" -eq 409 ]; then
    # Try to parse error code
    if echo "$body" | grep -q '"code":"duplicate_key_id"'; then
        echo -e "\n\033[33m⚠️  Key already exists with this ID\033[0m"
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
