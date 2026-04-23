package com.example.backendAPI.ticket;

import com.example.backendAPI.security.AppUserDetailsService;
import com.example.backendAPI.security.JwtService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    private final TicketService ticketService;
    private final JwtService jwtService;
    private final AppUserDetailsService userDetailsService;

    public TicketController(
        TicketService ticketService,
        JwtService jwtService,
        AppUserDetailsService userDetailsService
    ) {
        this.ticketService = ticketService;
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
    }

    @GetMapping
    public ResponseEntity<?> getTickets(
        @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        if (authenticate(authorization) == null) return unauthorized();
        return ResponseEntity.ok(ticketService.getLatestTickets());
    }

    @PostMapping
    public ResponseEntity<?> createTicket(
        @RequestHeader(value = "Authorization", required = false) String authorization,
        @Valid @RequestBody CreateTicketRequest request
    ) {
        String username = authenticate(authorization);
        if (username == null) return unauthorized();

        try {
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ticketService.createTicket(request.getTitle(), request.getDescription(), request.getPriority(), username));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of("message", ex.getMessage()));
        }
    }

    @PatchMapping("/{ticketRef}/status")
    public ResponseEntity<?> updateStatus(
        @RequestHeader(value = "Authorization", required = false) String authorization,
        @PathVariable String ticketRef,
        @Valid @RequestBody UpdateStatusRequest request
    ) {
        String username = authenticate(authorization);
        if (username == null) return unauthorized();
        if (!canModerateTickets(username)) return forbidden();

        try {
            return ResponseEntity.ok(ticketService.updateTicketStatus(ticketRef, request.getStatus(), username));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", ex.getMessage()));
        }
    }

    @PostMapping("/{ticketRef}/comments")
    public ResponseEntity<?> addComment(
        @RequestHeader(value = "Authorization", required = false) String authorization,
        @PathVariable String ticketRef,
        @Valid @RequestBody AddCommentRequest request
    ) {
        String username = authenticate(authorization);
        if (username == null) return unauthorized();
        if (!canModerateTickets(username)) return forbidden();

        try {
            ticketService.addComment(ticketRef, request.getContent(), username);
            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "Comment added"));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", ex.getMessage()));
        }
    }

    private String authenticate(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            return null;
        }
        String token = authorization.substring(7);
        if (!jwtService.isTokenValid(token)) {
            return null;
        }
        return jwtService.extractUsername(token);
    }

    private ResponseEntity<Map<String, String>> unauthorized() {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
            "message", "Invalid or missing bearer token"
        ));
    }

    private ResponseEntity<Map<String, String>> forbidden() {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of(
            "message", "Only admin and technicien can add comments or change status"
        ));
    }

    private boolean canModerateTickets(String username) {
        try {
            UserDetails user = userDetailsService.loadUserByUsername(username);
            return user.getAuthorities().stream().anyMatch(authority ->
                "ROLE_ADMIN".equals(authority.getAuthority()) ||
                    "ROLE_TECHNICIEN".equals(authority.getAuthority())
            );
        } catch (RuntimeException ex) {
            return false;
        }
    }
}
