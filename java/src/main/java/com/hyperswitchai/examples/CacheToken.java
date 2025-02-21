package com.hyperswitchai.examples;

public class CacheToken {
    public static void main(String[] args) {
        try {
            String token = TokenManager.getToken();
            System.out.println("\u001B[32m✅ Token retrieved successfully\u001B[0m");
            System.out.println("Token: " + token);
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
} 