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

    echo "\n\033[32m✅ Token successfully cached in .token-cache.json\033[0m\n";
    echo "Token: " . $token . "\n";
    
    echo "\n\033[36mNow the token is cached in .token-cache.json, you can use it in your code and not have to get a new one all the time (until it expires).\033[0m\n";
    
    echo "\033[36mIf you run this code again you should see the same token is being used.\033[0m\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
} 