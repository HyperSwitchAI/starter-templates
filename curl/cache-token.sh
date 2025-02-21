#!/bin/bash

TOKEN_CACHE_FILE=".token-cache.json"
BASE_URL="https://api.hyperswitchai.com"

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
else
    echo "Error: .env file not found. Please create one with USERNAME and PASSWORD variables."
    exit 1
fi

# Check if USERNAME and PASSWORD are set
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Error: USERNAME and PASSWORD must be set in the .env file"
    exit 1
fi

get_token() {
    # Check if we have a cached token
    if [ -f "$TOKEN_CACHE_FILE" ]; then
        # Get expiry time from cache
        expires_at=$(cat "$TOKEN_CACHE_FILE" | grep -o '"expiresAt":[0-9]*' | cut -d':' -f2)
        current_time=$(date +%s)  # Current time in seconds
        buffer_time=300  # 5 minute buffer in seconds

        # Check if token is still valid (with 5 minute buffer)
        if [ $((expires_at)) -gt $((current_time + buffer_time)) ]; then
            cached_token=$(cat "$TOKEN_CACHE_FILE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
            echo "$cached_token"
            return 0
        fi
    fi

    # Get new token
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL/auth" \
        -H "Content-Type: application/json" \
        -X POST \
        -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}")

    # Get the status code (last line)
    http_code=$(echo "$response" | tail -n1)
    # Get the response body (everything except the last line)
    body=$(echo "$response" | sed \$d)

    if [ "$http_code" -eq 200 ]; then
        # Extract token
        token=$(echo "$body" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
        
        # Cache token with 1 hour expiry
        current_time=$(date +%s)
        expires_at=$((current_time + 3600))  # 1 hour in seconds
        echo "{\"token\":\"$token\",\"expiresAt\":$expires_at}" > "$TOKEN_CACHE_FILE"
        
        echo "$token"
        return 0
    else
        echo "Authentication failed with status code: $http_code" >&2
        echo "Response: $body" >&2
        return 1
    fi
}

# Main execution
token=$(get_token)
if [ $? -eq 0 ]; then
    echo -e "\n\033[32m✅ Token successfully cached in .token-cache.json\033[0m"
    echo "Token: $token"
    echo -e "\033[36mNow the token is cached in .token-cache.json, you can use it in your code and not have to get a new one all the time (until it expires).\033[0m"
    echo -e "\033[36mIf you run this code again you should see the same token is being used.\033[0m"
else
    echo -e "\n\033[31mError getting token\033[0m"
    exit 1
fi
