package com.example.backendAPI.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "glpi_users")
public class GlpiUser {

    @Id
    @Column(name = "id")
    private Long id;

    @Column(name = "name")
    private String username;

    @Column(name = "password")
    private String passwordHash;

    @Column(name = "is_active")
    private Integer active;

    public Long getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public Integer getActive() {
        return active;
    }
}
