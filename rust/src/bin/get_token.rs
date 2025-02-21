use anyhow::Result;
use colored::Colorize;
use std::env;

const BASE_URL: &str = "https://api.hyperswitchai.com";

#[derive(serde::Serialize)]
struct AuthRequest {
    username: String,
    password: String,
}

#[derive(serde::Deserialize)]
struct AuthResponse {
    token: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    dotenv::dotenv()?;

    // Check for required environment variables
    if env::var("USERNAME").is_err() || env::var("PASSWORD").is_err() {
        anyhow::bail!("USERNAME and PASSWORD must be set in a .env file in the rust directory. You can rename .env.sample to .env and fill in your own email and password.");
    }

    let auth_req = AuthRequest {
        username: env::var("USERNAME")?,
        password: env::var("PASSWORD")?,
    };

    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/auth", BASE_URL))
        .json(&auth_req)
        .send()
        .await?;

    if !response.status().is_success() {
        anyhow::bail!("Authentication failed: {}", response.status());
    }

    let auth_resp: AuthResponse = response.json().await?;

    println!("\n{}", "✅ Token successfully retrieved".green());
    println!("Token: {}", auth_resp.token);

    Ok(())
} 