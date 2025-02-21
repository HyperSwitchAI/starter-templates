# Hyperswitch AI JavaScript Starter

This is a simple starter project for using Hyperswitch AI in JavaScript.

## Prerequisites

1. Make sure you have Node.js installed on your system. You can download it from [nodejs.org](https://nodejs.org/)

## Installation

1. Open a terminal and cd into the javascript directory and run:

```bash
npm install
```

2. Create a .env file in the javascript directory and fill in your username and password. You can rename .env.sample to .env and fill in your own email and password.

3. Run the example scripts:

```bash
npm run example:getToken        # Test authentication
npm run example:cacheToken      # Test token caching
npm run example:addKey          # Add a new API key
npm run example:addAWSCredentials # Add AWS credentials
npm run example:listKeys        # List all API keys
npm run example:deleteKey       # Delete an API key
npm run example:addStrategy     # Add a new strategy
npm run example:listStrategies  # List all strategies
npm run example:updateStrategy  # Update a strategy
npm run example:deleteStrategy  # Delete a strategy
```

## Notes

- This project uses ES modules (import/export syntax)
- All scripts are in the `src` directory
- The `.env` file should never be committed to version control
- Token caching is implemented to avoid unnecessary authentication requests
