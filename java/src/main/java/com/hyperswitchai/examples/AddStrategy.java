package com.hyperswitchai.examples;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.Map;

public class AddStrategy {
    private static final String BASE_URL = "https://api.hyperswitchai.com";
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final HttpClient client = HttpClient.newHttpClient();

    public static void main(String[] args) {
        try {
            String token = TokenManager.getToken();

            // Add a new strategy
            Map<String, String> strategyPayload = new HashMap<>();
            strategyPayload.put("code", "claude-proxy-1");
            strategyPayload.put("type", "proxy");
            strategyPayload.put("model", "claude-3-5-sonnet-20240620");
            strategyPayload.put("keyId", "claude-key-1");
            strategyPayload.put("provider", "anthropic");

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/admin/strategies/add-strategy"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + token)
                .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(strategyPayload)))
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 409) {
                try {
                    Map<String, Object> errorResponse = mapper.readValue(response.body(), Map.class);
                    Map<String, String> error = (Map<String, String>) errorResponse.get("error");
                    if (error != null && "duplicate_strategy_code".equals(error.get("code"))) {
                        System.out.println("\n\u001B[33m⚠️  Strategy already exists with this code\u001B[0m");
                        return;
                    }
                } catch (Exception e) {
                    // If JSON parsing fails, continue with error handling
                }
            }

            if (response.statusCode() != 200) {
                System.out.println("\u001B[31mServer response: " + response.statusCode() + " " + response.body() + "\u001B[0m");
                throw new RuntimeException("Failed to add strategy: " + response.body());
            }

            System.out.println("\u001B[32m✅ Strategy added successfully\u001B[0m");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
} 