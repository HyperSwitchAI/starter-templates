# HyperSwitch AI R Examples

R examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern R practices.

## Prerequisites

- R 4.0 or higher
- Required R packages (installed automatically):
  - httr2 (modern HTTP client)
  - jsonlite (JSON handling)
  - dotenv (environment variables)
  - glue (string interpolation)

## Setup

1. Install required packages:
```r
Rscript install.R
```

2. Create a `.env` file in the `r` directory with your HyperSwitchAI credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Examples

### Authentication
- `get_token.R` - Get a new authentication token
- `cache_token.R` - Demonstrates token caching for efficient authentication

### API Key Management
- `add_key.R` - Add a new API key
- `list_keys.R` - List all API keys
- `delete_key.R` - Delete an API key
- `add_aws_credentials.R` - Add AWS credentials

### Strategy Management
- `add_strategy.R` - Add a new strategy
- `list_strategies.R` - List all strategies
- `update_strategy.R` - Update an existing strategy
- `delete_strategy.R` - Delete a strategy

## Usage

Run any example using R:
```bash
Rscript src/get_token.R
Rscript src/add_key.R
# etc...
```

## Implementation Details

- Uses httr2 for modern HTTP operations
- Implements token caching for efficient authentication
- Uses jsonlite for JSON handling
- Uses dotenv for secure credential management
- Uses glue for string interpolation
- Follows R best practices and modern coding standards
- Provides clear error messages and response handling
- Includes colored terminal output for better readability

## Error Handling

All scripts include comprehensive error handling:
- Authentication errors
- HTTP status codes
- JSON parsing errors
- Network issues
- Missing credentials

## Response Formatting

- Keys and strategies are displayed in a clear, numbered list format
- Success messages are shown in green
- Warnings in yellow
- Errors in red
- Detailed error information when things go wrong 