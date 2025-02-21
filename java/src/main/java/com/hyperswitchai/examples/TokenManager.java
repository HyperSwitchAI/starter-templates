package com.hyperswitchai.examples;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.cdimascio.dotenv.Dotenv;

import java.io.File;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

public class TokenManager {
    private static final String TOKEN_CACHE_FILE = ".token-cache.json";
    private static final String BASE_URL = "https://api.hyperswitchai.com";
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final HttpClient client = HttpClient.newHttpClient();
    private static final Dotenv dotenv = Dotenv.load();

    public static String getToken() throws Exception {
        // Check if we have a cached token
        File cacheFile = new File(TOKEN_CACHE_FILE);
        if (cacheFile.exists()) {
            Map<String, Object> cache = mapper.readValue(cacheFile, Map.class);
            // Check if token is still valid (with 5 minute buffer)
            if ((Long) cache.get("expiresAt") > Instant.now().toEpochMilli() + 300000) {
                return (String) cache.get("token");
            }
        }

        // Get new token
        Map<String, String> authPayload = new HashMap<>();
        authPayload.put("username", dotenv.get("USERNAME"));
        authPayload.put("password", dotenv.get("PASSWORD"));

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

        // Cache token with 1 hour expiry
        Map<String, Object> cacheData = new HashMap<>();
        cacheData.put("token", token);
        cacheData.put("expiresAt", Instant.now().toEpochMilli() + 3600000); // 1 hour

        Files.writeString(Path.of(TOKEN_CACHE_FILE), mapper.writeValueAsString(cacheData));

        return token;
    }
} 