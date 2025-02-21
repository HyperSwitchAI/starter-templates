# HyperSwitch AI Ruby Examples

Ruby examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern Ruby practices.

## Prerequisites

- Ruby 3.0 or higher
- Bundler

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Create a `.env` file in the `ruby` directory with your HyperSwitchAI credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Examples

### Authentication
- `get_token.rb` - Get a new authentication token
- `cache_token.rb` - Demonstrates token caching for efficient authentication

### API Key Management
- `add_key.rb` - Add a new API key for Claude
- `add_aws_credentials.rb` - Add AWS credentials for Bedrock
- `list_keys.rb` - List all API keys
- `delete_key.rb` - Delete an API key

### Strategy Management
- `add_strategy.rb` - Add a new strategy
- `list_strategies.rb` - List all strategies
- `update_strategy.rb` - Update an existing strategy
- `delete_strategy.rb` - Delete a strategy

## Usage

Run any example using Ruby:
```bash
ruby src/get_token.rb
ruby src/add_key.rb
# etc...
```

## Implementation Details

- Uses Faraday for modern HTTP operations
- Implements token caching for efficient authentication
- Uses JSON for data handling
- Uses dotenv for secure credential management
- Follows Ruby best practices and modern coding standards
- Provides clear error messages and response handling
- Includes colored terminal output for better readability

## Error Handling

All scripts include comprehensive error handling:
- Authentication errors
- HTTP status codes
- JSON parsing errors
- Network issues
- Missing credentials
- Duplicate resource errors
- Not found errors

## Response Formatting

- Keys and strategies are displayed in a clear, formatted list
- Success messages are shown in green
- Warnings in yellow
- Errors in red
- Detailed error information when things go wrong

## File Structure

```
ruby/
├── .env                # Your credentials file (create this)
├── .gitignore         # Git ignore file
├── Gemfile            # Ruby dependencies
├── README.md          # This file
└── src/               # Source code directory
    ├── get_token.rb
    ├── cache_token.rb
    ├── add_key.rb
    ├── add_aws_credentials.rb
    ├── list_keys.rb
    ├── delete_key.rb
    ├── add_strategy.rb
    ├── list_strategies.rb
    ├── update_strategy.rb
    └── delete_strategy.rb
```

## Security Notes

- Never commit your `.env` file to version control
- Keep your API keys and encryption fragments secure
- The `.token-cache.json` file is created with secure permissions
- Credentials are only stored in memory during execution 