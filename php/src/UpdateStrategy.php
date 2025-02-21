<?php

namespace HyperSwitchAI\Examples;

require __DIR__ . '/../vendor/autoload.php';

use Dotenv\Dotenv;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;

// Load environment variables from .env file
$dotenv = Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

const BASE_URL = 'https://api.hyperswitchai.com';
const TOKEN_CACHE_FILE = __DIR__ . '/../.token-cache.json';

function getToken() {
    try {
        // Check if we have a cached token
        if (file_exists(TOKEN_CACHE_FILE)) {
            $cache = json_decode(file_get_contents(TOKEN_CACHE_FILE), true);
            // Check if token is still valid (with 5 minute buffer)
            if ($cache['expiresAt'] > (time() * 1000) + 300000) {
                return $cache['token'];
            }
        }

        // Create HTTP client
        $client = new Client();

        // Get new token
        $response = $client->post(BASE_URL . '/auth', [
            'headers' => [
                'Content-Type' => 'application/json'
            ],
            'json' => [
                'username' => $_ENV['USERNAME'],
                'password' => $_ENV['PASSWORD']
            ]
        ]);

        $data = json_decode($response->getBody(), true);
        $token = $data['token'];

        // Cache token with 1 hour expiry
        file_put_contents(TOKEN_CACHE_FILE, json_encode([
            'token' => $token,
            'expiresAt' => (time() * 1000) + 3600000 // 1 hour
        ]));

        return $token;

    } catch (GuzzleException $e) {
        echo "Auth error: " . $e->getMessage() . "\n";
        throw $e;
    }
}

try {
    $token = getToken();
    
    // Create HTTP client
    $client = new Client();

    // Update strategy
    $response = $client->post(BASE_URL . '/admin/strategies/update-strategy', [
        'headers' => [
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' . $token
        ],
        'json' => [
            'code' => 'claude-proxy-1',
            'type' => 'proxy',
            'model' => 'claude-3-5-haiku-20241022',
            'keyId' => 'claude-key-1',
            'provider' => 'anthropic'
        ]
    ]);

    $statusCode = $response->getStatusCode();

    if ($statusCode !== 200) {
        if ($statusCode === 409) {
            $error = json_decode($response->getBody(), true);
            if (isset($error['error']['code']) && $error['error']['code'] === 'duplicate_strategy_code') {
                echo "\n\033[33m⚠️  Strategy already exists with this code\033[0m\n";
                exit;
            }
        }
        
        $errorText = (string) $response->getBody();
        echo "\n\033[31mServer response: " . $statusCode . " " . $errorText . "\033[0m\n";
        throw new \Exception("Failed to update strategy: " . $response->getReasonPhrase());
    }

    echo "\n\033[32m✅ Strategy updated successfully\033[0m\n";

} catch (GuzzleException $e) {
    echo "Error: " . $e->getMessage() . "\n";
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
} 