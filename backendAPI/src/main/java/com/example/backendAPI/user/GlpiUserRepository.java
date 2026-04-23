package com.example.backendAPI.user;

import java.util.Optional;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface GlpiUserRepository extends JpaRepository<GlpiUser, Long> {
    Optional<GlpiUser> findByUsernameAndActive(String username, Integer active);

    @Query(value = """
        SELECT p.name
        FROM glpi_profiles p
        JOIN glpi_profiles_users pu ON pu.profiles_id = p.id
        JOIN glpi_users u ON u.id = pu.users_id
        WHERE u.name = :username
          AND u.is_active = 1
        LIMIT 1
        """, nativeQuery = true)
    Optional<String> findProfileNameByUsername(@Param("username") String username);

    @Query(value = """
        SELECT p.name
        FROM glpi_profiles p
        JOIN glpi_profiles_users pu ON pu.profiles_id = p.id
        JOIN glpi_users u ON u.id = pu.users_id
        WHERE u.name = :username
          AND u.is_active = 1
        """, nativeQuery = true)
    List<String> findProfileNamesByUsername(@Param("username") String username);
}
