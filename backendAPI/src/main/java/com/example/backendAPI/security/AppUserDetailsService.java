package com.example.backendAPI.security;

import com.example.backendAPI.user.GlpiUser;
import com.example.backendAPI.user.GlpiUserRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

@Service
public class AppUserDetailsService implements UserDetailsService {

    private final GlpiUserRepository userRepository;

    public AppUserDetailsService(GlpiUserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        GlpiUser user = userRepository.findByUsernameAndActive(username, 1)
            .orElseThrow(() -> new UsernameNotFoundException("User not found or inactive"));

        String authority = mapRoleToAuthority(resolveRoleForUsername(username));

        return User.builder()
            .username(user.getUsername())
            .password(user.getPasswordHash())
            .authorities(List.of(new SimpleGrantedAuthority(authority)))
            .build();
    }

    public String resolveRoleForUsername(String username) {
        try {
            var profiles = userRepository.findProfileNamesByUsername(username);
            boolean hasAdmin = false;
            boolean hasTechnicien = false;

            for (String rawProfile : profiles) {
                String profile = rawProfile == null ? "" : rawProfile.toLowerCase(Locale.ROOT);
                if (profile.contains("super-admin") || profile.equals("admin")) {
                    hasAdmin = true;
                } else if (
                    profile.contains("technician") ||
                        profile.contains("technicien") ||
                        profile.contains("hotliner") ||
                        profile.contains("itil")
                ) {
                    hasTechnicien = true;
                }
            }

            if (hasAdmin) {
                return "admin";
            }
            if (hasTechnicien) {
                return "technicien";
            }
        } catch (Exception ignored) {
            // Fall back to user role when profile lookup fails.
        }
        return "user";
    }

    private String mapRoleToAuthority(String role) {
        return switch (role) {
            case "admin" -> "ROLE_ADMIN";
            case "technicien" -> "ROLE_TECHNICIEN";
            default -> "ROLE_USER";
        };
    }
}
