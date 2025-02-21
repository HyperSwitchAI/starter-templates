# HyperSwitch AI Go Examples

Go examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern Go practices.

## Prerequisites

- Go 1.21 or higher
- A HyperSwitch AI account and credentials

## Setup

1. Install dependencies:
```bash
go mod tidy
```

2. Create a `.env` file in the `go` directory with your HyperSwitchAI credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Examples

### Authentication
- `getToken.go` - Basic token retrieval
- `cacheToken.go` - Demonstrates token caching for efficient authentication

### API Key Management
- `addKey.go` - Add a new API key
- `listKeys.go` - List all API keys
- `deleteKey.go` - Delete an API key
- `addAwsCredentials.go` - Add AWS credentials

### Strategy Management
- `addStrategy.go` - Add a new strategy
- `listStrategies.go` - List all strategies
- `updateStrategy.go` - Update an existing strategy
- `deleteStrategy.go` - Delete a strategy

## Usage

Run any example using Go:
```bash
go run src/getToken.go
go run src/addKey.go
# etc...
```

## Implementation Details

- Uses standard Go HTTP client
- Implements token caching for efficient authentication
- Handles errors gracefully with appropriate messages
- Uses environment variables for secure credential management
- Follows Go best practices and modern coding standards 