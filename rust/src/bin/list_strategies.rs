use anyhow::Result;
use colored::Colorize;
use serde::{Deserialize, Serialize};
use std::{env, fs};
use chrono::Utc;

const TOKEN_CACHE_FILE: &str = ".token-cache.json";
const BASE_URL: &str = "https://api.hyperswitchai.com";

#[derive(Debug, Serialize, Deserialize)]
struct TokenCache {
    token: String,
    expires_at: i64,
}

#[derive(Debug, Serialize)]
struct AuthRequest {
    username: String,
    password: String,
}

#[derive(Debug, Deserialize)]
struct AuthResponse {
    token: String,
}

#[derive(Debug, Deserialize, Clone, PartialEq)]
struct ListStrategiesResponse {
    strategies: Vec<StrategyInfo>,
}

#[derive(Debug, Deserialize, Clone, PartialEq)]
struct StrategyInfo {
    code: String,
    #[serde(rename = "type")]
    strategy_type: String,
    model: String,
    #[serde(rename = "keyId")]
    key_id: String,
    provider: String,
}

async fn get_token() -> Result<String> {
    // Check if we have a cached token
    if let Ok(cache_data) = fs::read_to_string(TOKEN_CACHE_FILE) {
        if let Ok(cache) = serde_json::from_str::<TokenCache>(&cache_data) {
            let now = Utc::now().timestamp_millis();
            if cache.expires_at > now + 300000 { // 5 minute buffer
                return Ok(cache.token);
            }
        }
    }

    // Get new token
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

    // Cache token with 1 hour expiry
    let cache = TokenCache {
        token: auth_resp.token.clone(),
        expires_at: Utc::now().timestamp_millis() + 3600000, // 1 hour
    };

    fs::write(
        TOKEN_CACHE_FILE,
        serde_json::to_string_pretty(&cache)?
    )?;

    Ok(auth_resp.token)
}

#[tokio::main]
async fn main() -> Result<()> {
    dotenv::dotenv()?;

    let token = get_token().await?;

    // List all strategies
    let client = reqwest::Client::new();
    let response = client
        .get(format!("{}/admin/strategies/list", BASE_URL))
        .header("Content-Type", "application/json")
        .header("Authorization", format!("Bearer {}", token))
        .send()
        .await?;

    if !response.status().is_success() {
        let status = response.status();
        let error_text = response.text().await?;
        println!("\n{} {} {}", "Server response:".red(), status, error_text);
        anyhow::bail!("Failed to list strategies: {}", status);
    }

    let result: ListStrategiesResponse = response.json().await?;
    println!("\n{}", "✅ Strategies listed successfully".green());
    println!("{:#?}", result.strategies);

    Ok(())
} 