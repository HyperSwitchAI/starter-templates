package com.hyperswitchai.examples;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.Map;

public class DeleteKey {
    private static final String BASE_URL = "https://api.hyperswitchai.com";
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final HttpClient client = HttpClient.newHttpClient();

    public static void main(String[] args) {
        try {
            String token = TokenManager.getToken();

            // Delete an API key
            Map<String, String> deletePayload = new HashMap<>();
            deletePayload.put("keyId", "claude-key-1");

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/admin/keys/delete-key"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + token)
                .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(deletePayload)))
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 404) {
                System.out.println("\n\u001B[33m⚠️  Key not found - it may have already been deleted\u001B[0m");
                return;
            }

            if (response.statusCode() != 200) {
                System.out.println("\u001B[31mServer response: " + response.statusCode() + " " + response.body() + "\u001B[0m");
                throw new RuntimeException("Failed to delete key: " + response.body());
            }

            System.out.println("\u001B[32m✅ Key deleted successfully\u001B[0m");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
} 