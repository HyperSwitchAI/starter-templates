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

try {
    // Check for required environment variables
    if (!isset($_ENV['USERNAME']) || !isset($_ENV['PASSWORD'])) {
        throw new \Exception('USERNAME and PASSWORD must be set in a .env file in the php directory. You can rename .env.sample to .env and fill in your own email and password.');
    }

    // Create HTTP client
    $client = new Client();

    // Make authentication request
    $response = $client->post(BASE_URL . '/auth', [
        'headers' => [
            'Content-Type' => 'application/json'
        ],
        'json' => [
            'username' => $_ENV['USERNAME'],
            'password' => $_ENV['PASSWORD']
        ]
    ]);

    // Parse response
    $data = json_decode($response->getBody(), true);
    $token = $data['token'];

    // Output success message
    echo "\n\033[32m✅ Token successfully retrieved\033[0m\n";
    echo "Token: " . $token . "\n";

} catch (GuzzleException $e) {
    echo "Error: Authentication failed - " . $e->getMessage() . "\n";
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
} 