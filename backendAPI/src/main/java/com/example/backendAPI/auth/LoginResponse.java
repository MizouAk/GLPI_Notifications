package com.example.backendAPI.auth;

public class LoginResponse {
    private final String accessToken;
    private final String tokenType;
    private final String username;
    private final String role;

    public LoginResponse(String accessToken, String username, String role) {
        this.accessToken = accessToken;
        this.tokenType = "Bearer";
        this.username = username;
        this.role = role;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getTokenType() {
        return tokenType;
    }

    public String getUsername() {
        return username;
    }

    public String getRole() {
        return role;
    }
}
