# HyperSwitch AI Rust Examples

Rust examples for interacting with the HyperSwitch AI API. These examples demonstrate authentication, API key management, and strategy configuration using modern Rust practices.

## Prerequisites

- Rust 1.70 or higher (install via [rustup](https://rustup.rs/))
- A HyperSwitch AI account and credentials

## Setup

1. Create a `.env` file in the `rust` directory with your HyperSwitchAI credentials:
```env
USERNAME=your_username
PASSWORD=your_password
```

## Available Examples

### Authentication
- `get_token.rs` - Basic token retrieval
- `cache_token.rs` - Demonstrates token caching for efficient authentication

### API Key Management
- `add_key.rs` - Add a new API key
- `list_keys.rs` - List all API keys
- `delete_key.rs` - Delete an API key
- `add_aws_credentials.rs` - Add AWS credentials

### Strategy Management
- `add_strategy.rs` - Add a new strategy
- `list_strategies.rs` - List all strategies
- `update_strategy.rs` - Update an existing strategy
- `delete_strategy.rs` - Delete a strategy

## Usage

Run any example using Cargo:
```bash
cargo run --bin get_token
cargo run --bin cache_token
cargo run --bin add_key
cargo run --bin list_keys
cargo run --bin delete_key
cargo run --bin add_aws_credentials
cargo run --bin add_strategy
cargo run --bin list_strategies
cargo run --bin update_strategy
cargo run --bin delete_strategy
```

## Implementation Details

- Uses `reqwest` for HTTP operations
- Uses `serde` for JSON serialization/deserialization
- Implements token caching for efficient authentication
- Uses proper error handling with `anyhow`
- Uses environment variables with `dotenv`
- Follows Rust best practices and idioms

## Common Operations

### Authentication
```rust
// Token is automatically cached and reused until expiration
let token = get_token().await?;
```

### Making API Requests
```rust
let client = reqwest::Client::new();
let response = client
    .post(format!("{}/endpoint", BASE_URL))
    .header("Content-Type", "application/json")
    .header("Authorization", format!("Bearer {}", token))
    .json(&request)
    .send()
    .await?;
```

### Error Handling
```rust
if !response.status().is_success() {
    let status = response.status();
    let error_text = response.text().await?;
    println!("\n{} {} {}", "Server response:".red(), status, error_text);
    anyhow::bail!("Request failed: {}", status);
}
```

## Dependencies

Key dependencies from Cargo.toml:
```toml
[dependencies]
reqwest = { version = "0.11", features = ["json"] }
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
dotenv = "0.15"
chrono = "0.4"
colored = "2.0"
```

## Security Notes

- Never commit the `.env` file to version control
- Keep your API keys and encryption fragments secure
- Use environment variables for sensitive data
- Follow security best practices for credential management

## Support

For questions about:
- The HyperSwitch AI service: Visit [HyperSwitchAI.com](https://HyperSwitchAI.com)
- API documentation: Check [console.hyperswitchai.com/docs.html](https://console.hyperswitchai.com/docs.html)
- These examples: Contact HyperSwitch AI support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
