package com.hyperswitchai.examples;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.Map;

public class AddKey {
    private static final String BASE_URL = "https://api.hyperswitchai.com";
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final HttpClient client = HttpClient.newHttpClient();

    public static void main(String[] args) {
        try {
            String token = TokenManager.getToken();

            // Add a new API key
            Map<String, String> keyPayload = new HashMap<>();
            keyPayload.put("keyId", "claude-key-1");
            keyPayload.put("encryptionFragment", "OpenThePodBayDoorsHAL-2001");
            keyPayload.put("provider", "claude");
            keyPayload.put("apiKey", "sk-ant-api03-LhOEBAVFlPnTIy8e80m9lNkJpKBSV3v7xSwXkpX4f02lICRAAAAAAAAAAAAAAA");

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/admin/keys/add-key"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + token)
                .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(keyPayload)))
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 409) {
                Map<String, Object> errorResponse = mapper.readValue(response.body(), Map.class);
                Map<String, String> error = (Map<String, String>) errorResponse.get("error");
                if (error != null && "duplicate_key_id".equals(error.get("code"))) {
                    System.out.println("\u001B[33m⚠️  Key already exists with this ID\u001B[0m");
                    return;
                }
            }

            if (response.statusCode() != 200) {
                System.out.println("\u001B[31mServer response: " + response.statusCode() + " " + response.body() + "\u001B[0m");
                throw new RuntimeException("Failed to add key: " + response.body());
            }

            System.out.println("\u001B[32m✅ Key added successfully\u001B[0m");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
} 