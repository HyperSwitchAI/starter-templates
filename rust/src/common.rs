use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::fs;
use chrono::Utc;
use std::env;

pub const BASE_URL: &str = "https://api.hyperswitchai.com";
pub const TOKEN_CACHE_FILE: &str = ".token-cache.json";

#[derive(Debug, Serialize, Deserialize)]
pub struct TokenCache {
    pub token: String,
    pub expires_at: i64,
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

pub async fn ensure_valid_token() -> Result<String> {
    if let Ok(cache_data) = fs::read_to_string(TOKEN_CACHE_FILE) {
        if let Ok(cache) = serde_json::from_str::<TokenCache>(&cache_data) {
            let now = Utc::now().timestamp_millis();
            if cache.expires_at > now + 300000 { // 5 minute buffer
                return Ok(cache.token);
            }
        }
    }
    
    get_new_token().await
}

async fn get_new_token() -> Result<String> {
    let username = env::var("USERNAME")?;
    let password = env::var("PASSWORD")?;

    let auth_req = AuthRequest { username, password };
    
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