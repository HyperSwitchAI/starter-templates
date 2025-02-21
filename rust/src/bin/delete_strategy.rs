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

#[derive(Debug, Serialize)]
struct DeleteStrategyRequest {
    code: String,
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

    // Delete the strategy
    let delete_strategy_req = DeleteStrategyRequest {
        code: "claude-proxy-1".to_string(),
    };

    let client = reqwest::Client::new();
    let response = client
        .post(format!("{}/admin/strategies/delete-strategy", BASE_URL))
        .header("Content-Type", "application/json")
        .header("Authorization", format!("Bearer {}", token))
        .json(&delete_strategy_req)
        .send()
        .await?;

    if !response.status().is_success() {
        let status = response.status();
        
        if status == reqwest::StatusCode::NOT_FOUND {
            println!("\n{}", "⚠️  Strategy not found - it may have already been deleted".yellow());
            return Ok(());
        }
        
        let error_text = response.text().await?;
        println!("\n{} {} {}", "Server response:".red(), status, error_text);
        anyhow::bail!("Failed to delete strategy: {}", status);
    }

    println!("\n{}", "✅ Strategy deleted successfully".green());

    Ok(())
} 