package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

const BASE_URL = "https://api.hyperswitchai.com"

type AuthRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type AuthResponse struct {
	Token string `json:"token"`
}

func main() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file. Please ensure it exists and contains USERNAME and PASSWORD")
	}

	// Check for required environment variables
	username := os.Getenv("USERNAME")
	password := os.Getenv("PASSWORD")
	if username == "" || password == "" {
		log.Fatal("USERNAME and PASSWORD must be set in .env file")
	}

	// Create authentication request body
	authReq := AuthRequest{
		Username: username,
		Password: password,
	}

	// Convert request to JSON
	jsonData, err := json.Marshal(authReq)
	if err != nil {
		log.Fatal("Error creating JSON request:", err)
	}

	// Create HTTP request
	req, err := http.NewRequest("POST", BASE_URL+"/auth", bytes.NewBuffer(jsonData))
	if err != nil {
		log.Fatal("Error creating request:", err)
	}
	req.Header.Set("Content-Type", "application/json")

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

	// Check for successful response
	if resp.StatusCode != http.StatusOK {
		log.Fatalf("Authentication failed with status %d: %s", resp.StatusCode, string(body))
	}

	// Parse response
	var authResp AuthResponse
	err = json.Unmarshal(body, &authResp)
	if err != nil {
		log.Fatal("Error parsing response:", err)
	}

	// Print success message
	fmt.Printf("\n\033[32m✅ Token successfully retrieved\033[0m\n")
	fmt.Println("Token:", authResp.Token)
} 