package com.hyperswitchai.examples;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;

public class ListStrategies {
    private static final String BASE_URL = "https://api.hyperswitchai.com";
    private static final ObjectMapper mapper = new ObjectMapper()
        .enable(SerializationFeature.INDENT_OUTPUT);
    private static final HttpClient client = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(10))
        .build();

    public static void main(String[] args) throws Exception {
        try {
            System.out.println("\nStarting ListStrategies...");
            
            // Get token
            String token = TokenManager.getToken();
            System.out.println("Token obtained, fetching strategies...\n");

            // Create request
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/admin/strategies/list"))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + token)
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();

            // Make synchronous request
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            
            System.out.println("Response received with status: " + response.statusCode());

            if (response.statusCode() != 200) {
                throw new RuntimeException("Failed to list strategies. Status: " + response.statusCode() + 
                    "\nResponse: " + response.body());
            }

            // Parse and display the strategies
            Map<String, Object> result = mapper.readValue(response.body(), Map.class);
            System.out.println("\n\u001B[32m✅ Current Strategies:\u001B[0m");
            System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(result));

        } catch (Exception e) {
            System.err.println("\n\u001B[31mError occurred: " + e.getMessage() + "\u001B[0m");
            throw e; // Rethrow to ensure non-zero exit code
        }
    }
} 