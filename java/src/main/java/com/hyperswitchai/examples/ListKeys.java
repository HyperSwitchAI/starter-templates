package com.hyperswitchai.examples;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class ListKeys {
    private static final String BASE_URL = "https://api.hyperswitchai.com";
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final HttpClient client = HttpClient.newHttpClient();

    public static void main(String[] args) {
        try {
            String token = TokenManager.getToken();

            // List API keys
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/admin/keys/list"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + token)
                .GET()
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                System.out.println("\u001B[31mServer response: " + response.statusCode() + " " + response.body() + "\u001B[0m");
                throw new RuntimeException("Failed to list keys: " + response.body());
            }

            Object result = mapper.readValue(response.body(), Object.class);
            System.out.println("\u001B[32m✅ Keys listed successfully\u001B[0m");
            System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(result));
            
            System.out.println("\nNote that neither the API key values nor the encryption fragments are included in the response.");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
} 