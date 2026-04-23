package com.example.backendAPI.auth;

import com.example.backendAPI.security.AppUserDetailsService;
import com.example.backendAPI.security.JwtService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final AppUserDetailsService userDetailsService;

    public AuthController(
        AuthenticationManager authenticationManager,
        JwtService jwtService,
        AppUserDetailsService userDetailsService
    ) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
            UserDetails user = (UserDetails) authentication.getPrincipal();
            String token = jwtService.generateToken(user);
            String role = user.getAuthorities().stream()
                .findFirst()
                .map(authority -> authority.getAuthority().replace("ROLE_", "").toLowerCase())
                .orElse("user");
            return ResponseEntity.ok(new LoginResponse(token, user.getUsername(), role));
        } catch (BadCredentialsException ex) {
            return ResponseEntity.status(401).body(Map.of(
                "message", "Invalid username or password"
            ));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(@RequestHeader(value = "Authorization", required = false) String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body(Map.of("message", "Invalid or missing bearer token"));
        }

        String token = authorization.substring(7);
        if (!jwtService.isTokenValid(token)) {
            return ResponseEntity.status(401).body(Map.of("message", "Invalid or expired token"));
        }

        String username = jwtService.extractUsername(token);
        String role = userDetailsService.resolveRoleForUsername(username);
        return ResponseEntity.ok(Map.of(
            "username", username,
            "role", role
        ));
    }
}
