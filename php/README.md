# HyperSwitch AI PHP Examples

PHP examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern PHP practices.

## Prerequisites

- PHP 7.4 or higher
- Composer
- A HyperSwitch AI account and credentials

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/hyperswitchai-examples.git
cd hyperswitchai-examples/php
```

2. Install dependencies:
```bash
composer install
```

3. Create a `.env` file in the root directory with your credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Examples

### Authentication
- `CacheToken.php` - Demonstrates token caching for efficient authentication

### API Key Management
- `AddKey.php` - Add a new API key
- `ListKeys.php` - List all API keys
- `DeleteKey.php` - Delete an API key
- `AddAwsCredentials.php` - Add AWS credentials

### Strategy Management
- `AddStrategy.php` - Add a new strategy
- `ListStrategies.php` - List all strategies
- `UpdateStrategy.php` - Update an existing strategy
- `DeleteStrategy.php` - Delete a strategy

## Usage

Run any example using PHP:
```bash
php src/CacheToken.php
php src/AddKey.php
# etc...
```

## Implementation Details

- Uses Guzzle for HTTP operations
- Implements token caching for efficient authentication
- Handles errors gracefully with appropriate messages
- Uses environment variables for secure credential management
- Follows PHP best practices and modern coding standards 