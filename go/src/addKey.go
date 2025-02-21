package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
)

const (
	BASE_URL        = "https://api.hyperswitchai.com"
	TOKEN_CACHE_FILE = ".token-cache.json"
)

type AuthRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type AuthResponse struct {
	Token string `json:"token"`
}

type TokenCache struct {
	Token     string `json:"token"`
	ExpiresAt int64  `json:"expiresAt"`
}

type AddKeyRequest struct {
	KeyID             string `json:"keyId"`
	EncryptionFragment string `json:"encryptionFragment"`
	Provider          string `json:"provider"`
	APIKey            string `json:"apiKey"`
}

type ErrorResponse struct {
	Error struct {
		Code string `json:"code"`
	} `json:"error"`
}

func getToken() (string, error) {
	// Check if we have a cached token
	if _, err := os.Stat(TOKEN_CACHE_FILE); err == nil {
		data, err := os.ReadFile(TOKEN_CACHE_FILE)
		if err == nil {
			var cache TokenCache
			if err := json.Unmarshal(data, &cache); err == nil {
				// Check if token is still valid (with 5 minute buffer)
				if cache.ExpiresAt > time.Now().UnixMilli()+300000 {
					return cache.Token, nil
				}
			}
		}
	}

	// Load environment variables
	username := os.Getenv("USERNAME")
	password := os.Getenv("PASSWORD")
	if username == "" || password == "" {
		return "", fmt.Errorf("USERNAME and PASSWORD must be set in .env file")
	}

	// Create authentication request body
	authReq := AuthRequest{
		Username: username,
		Password: password,
	}

	// Convert request to JSON
	jsonData, err := json.Marshal(authReq)
	if err != nil {
		return "", fmt.Errorf("error creating JSON request: %v", err)
	}

	// Create HTTP request
	req, err := http.NewRequest("POST", BASE_URL+"/auth", bytes.NewBuffer(jsonData))
	if err != nil {
		return "", fmt.Errorf("error creating request: %v", err)
	}
	req.Header.Set("Content-Type", "application/json")

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("error sending request: %v", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading response: %v", err)
	}

	// Check for successful response
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("authentication failed with status %d: %s", resp.StatusCode, string(body))
	}

	// Parse response
	var authResp AuthResponse
	if err := json.Unmarshal(body, &authResp); err != nil {
		return "", fmt.Errorf("error parsing response: %v", err)
	}

	// Cache token with 1 hour expiry
	cache := TokenCache{
		Token:     authResp.Token,
		ExpiresAt: time.Now().UnixMilli() + 3600000, // 1 hour
	}

	cacheData, err := json.Marshal(cache)
	if err != nil {
		return "", fmt.Errorf("error creating cache data: %v", err)
	}

	if err := os.WriteFile(TOKEN_CACHE_FILE, cacheData, 0600); err != nil {
		return "", fmt.Errorf("error writing cache file: %v", err)
	}

	return authResp.Token, nil
}

func main() {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}

	token, err := getToken()
	if err != nil {
		log.Fatal("Error:", err)
	}

	fmt.Println("Token:", token)

	// Create add key request
	addKeyReq := AddKeyRequest{
		KeyID:             "claude-key-1",
		EncryptionFragment: "OpenThePodBayDoorsHAL-2001",
		Provider:          "claude",
		APIKey:            "sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA",
	}

	// Convert request to JSON
	jsonData, err := json.Marshal(addKeyReq)
	if err != nil {
		log.Fatal("Error creating JSON request:", err)
	}

	// Create HTTP request
	req, err := http.NewRequest("POST", BASE_URL+"/admin/keys/add-key", bytes.NewBuffer(jsonData))
	if err != nil {
		log.Fatal("Error creating request:", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal("Error sending request:", err)
	}
	defer resp.Body.Close()

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal("Error reading response:", err)
	}

	if resp.StatusCode != http.StatusOK {
		if resp.StatusCode == http.StatusConflict {
			var errResp ErrorResponse
			if err := json.Unmarshal(body, &errResp); err == nil {
				if errResp.Error.Code == "duplicate_key_id" {
					fmt.Printf("\n\033[33m⚠️  Key already exists with this ID\033[0m\n")
					return
				}
			}
		}
		fmt.Printf("\n\033[31mServer response: %d %s\033[0m\n", resp.StatusCode, string(body))
		log.Fatalf("Failed to add key: %s", resp.Status)
	}

	fmt.Printf("\n\033[32m✅ Key added successfully\033[0m\n")
} 