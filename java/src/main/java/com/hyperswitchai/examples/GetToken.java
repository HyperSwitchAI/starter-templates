package com.hyperswitchai.examples;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.cdimascio.dotenv.Dotenv;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.Map;

public class GetToken {
    private static final String BASE_URL = "https://api.hyperswitchai.com";
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final HttpClient client = HttpClient.newHttpClient();
    private static final Dotenv dotenv = Dotenv.load();

    public static void main(String[] args) {
        try {
            // Check for required environment variables
            String username = dotenv.get("USERNAME");
            String password = dotenv.get("PASSWORD");
            
            if (username == null || password == null) {
                throw new RuntimeException("USERNAME and PASSWORD must be set in a .env file in the java directory. " +
                    "You can rename .env.sample to .env and fill in your own email and password.");
            }

            // Prepare authentication request
            Map<String, String> authPayload = new HashMap<>();
            authPayload.put("username", username);
            authPayload.put("password", password);

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/auth"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(authPayload)))
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                throw new RuntimeException("Authentication failed: " + response.body());
            }

            Map<String, String> authResponse = mapper.readValue(response.body(), Map.class);
            String token = authResponse.get("token");

            System.out.println("\u001B[32m✅ Token successfully retrieved\u001B[0m");
            System.out.println("Token: " + token);

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
} 