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

# Make the list keys request
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/admin/keys/list" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -X GET)

# Get the status code (last line)
http_code=$(echo "$response" | tail -n1)
# Get the response body (everything except the last line)
body=$(echo "$response" | sed \$d)

# Check if request was successful
if [ "$http_code" -eq 200 ]; then
    echo -e "\n\033[32m✅ Keys listed successfully\033[0m"
    # Pretty print the JSON response
    echo "$body" | python3 -m json.tool
    echo -e "\nNote that neither the API key values nor the encryption fragments are included in the response."
else
    echo -e "\n\033[31mServer response: $http_code\033[0m"
    echo "Response: $body"
    exit 1
fi
