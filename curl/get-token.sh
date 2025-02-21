#!/bin/bash

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

# Make the auth request
response=$(curl -s -w "\n%{http_code}" https://api.hyperswitchai.com/auth \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}")

# Get the status code (last line)
http_code=$(echo "$response" | tail -n1)
# Get the response body (everything except the last line)
body=$(echo "$response" | sed \$d)

# Check if request was successful
if [ "$http_code" -eq 200 ]; then
    # Extract token using grep and cut
    token=$(echo "$body" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo -e "\n\033[32m✅ Token successfully retrieved\033[0m"
    echo "Token: $token"
else
    echo -e "\n\033[31mAuthentication failed with status code: $http_code\033[0m"
    echo "Response: $body"
    exit 1
fi
