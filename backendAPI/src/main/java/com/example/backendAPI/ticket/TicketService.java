package com.example.backendAPI.ticket;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
public class TicketService {

    private final JdbcTemplate jdbcTemplate;

    public TicketService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<TicketDto> getLatestTickets() {
        String sql = """
            SELECT
                t.id,
                COALESCE(NULLIF(t.name, ''), CONCAT('Ticket #', t.id)) AS title,
                COALESCE(NULLIF(t.content, ''), 'No description') AS description,
                t.status,
                t.priority,
                COALESCE(t.date_mod, t.date_creation) AS date_value,
                COALESCE(u.name, 'Unassigned') AS assigned_user
            FROM glpi_tickets t
            LEFT JOIN (
                SELECT tu.tickets_id, MIN(tu.users_id) AS users_id
                FROM glpi_tickets_users tu
                WHERE tu.type = 2
                GROUP BY tu.tickets_id
            ) ass ON ass.tickets_id = t.id
            LEFT JOIN glpi_users u ON u.id = COALESCE(ass.users_id, t.users_id_recipient)
            ORDER BY t.id DESC
            LIMIT 100
            """;

        List<TicketDto> tickets = jdbcTemplate.query(sql, (rs, rowNum) -> mapRow(rs));
        if (!tickets.isEmpty()) {
            return tickets;
        }

        String fallbackSql = """
            SELECT
                c.id,
                COALESCE(NULLIF(c.name, ''), CONCAT('Asset #', c.id)) AS title,
                COALESCE(NULLIF(c.serial, ''), 'No serial') AS description,
                COALESCE(c.date_mod, c.date_creation) AS date_value,
                COALESCE(u.name, 'Unassigned') AS assigned_user
            FROM glpi_computers c
            LEFT JOIN glpi_users u ON u.id = c.users_id
            WHERE c.is_deleted = 0
            ORDER BY c.id DESC
            LIMIT 100
            """;

        return jdbcTemplate.query(fallbackSql, (rs, rowNum) -> new TicketDto(
            "#ASSET-" + rs.getLong("id"),
            rs.getString("title"),
            rs.getString("description"),
            "open",
            "medium",
            rs.getString("date_value"),
            rs.getString("assigned_user")
        ));
    }

    public TicketDto createTicket(String title, String description, String priority, String username) {
        long userId = requireUserId(username);
        int priorityValue = mapPriorityToGlpi(priority);
        int urgencyValue = Math.max(1, priorityValue);
        int impactValue = Math.max(1, priorityValue - 1);
        LocalDateTime now = LocalDateTime.now();

        String insertTicketSql = """
            INSERT INTO glpi_tickets (
                entities_id, name, date, date_mod, users_id_lastupdater, status,
                users_id_recipient, requesttypes_id, content, urgency, impact, priority,
                itilcategories_id, type, global_validation, is_deleted, date_creation
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        jdbcTemplate.update(
            insertTicketSql,
            0,
            title,
            now,
            now,
            userId,
            1,
            userId,
            1,
            description,
            urgencyValue,
            impactValue,
            priorityValue,
            0,
            1,
            1,
            0,
            now
        );

        Long newTicketId = jdbcTemplate.queryForObject("SELECT LAST_INSERT_ID()", Long.class);
        if (newTicketId == null) {
            throw new IllegalStateException("Could not create ticket.");
        }

        String insertLinkSql = """
            INSERT INTO glpi_tickets_users (tickets_id, users_id, type, use_notification)
            VALUES (?, ?, ?, ?)
            """;
        jdbcTemplate.update(insertLinkSql, newTicketId, userId, 1, 1); // requester
        jdbcTemplate.update(insertLinkSql, newTicketId, userId, 2, 1); // assigned

        return getTicketById(newTicketId);
    }

    public TicketDto updateTicketStatus(String ticketRef, String status, String username) {
        long ticketId = parseTicketRef(ticketRef);
        long userId = requireUserId(username);
        int glpiStatus = mapStatusToGlpi(status);
        LocalDateTime now = LocalDateTime.now();

        String updateSql = """
            UPDATE glpi_tickets
            SET status = ?,
                users_id_lastupdater = ?,
                date_mod = ?,
                solvedate = CASE WHEN ? IN (5, 6) THEN ? ELSE solvedate END,
                closedate = CASE WHEN ? IN (5, 6) THEN ? ELSE closedate END
            WHERE id = ?
            """;

        int updated = jdbcTemplate.update(
            updateSql,
            glpiStatus,
            userId,
            now,
            glpiStatus,
            now,
            glpiStatus,
            now,
            ticketId
        );

        if (updated == 0) {
            throw new IllegalArgumentException("Ticket not found: " + ticketRef);
        }

        return getTicketById(ticketId);
    }

    public void addComment(String ticketRef, String content, String username) {
        long ticketId = parseTicketRef(ticketRef);
        long userId = requireUserId(username);
        LocalDateTime now = LocalDateTime.now();

        Integer exists = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM glpi_tickets WHERE id = ?",
            Integer.class,
            ticketId
        );
        if (exists == null || exists == 0) {
            throw new IllegalArgumentException("Ticket not found: " + ticketRef);
        }

        String insertFollowupSql = """
            INSERT INTO glpi_itilfollowups (
                itemtype, items_id, date, users_id, users_id_editor, content,
                is_private, requesttypes_id, date_mod, date_creation,
                timeline_position, sourceitems_id, sourceof_items_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;

        jdbcTemplate.update(
            insertFollowupSql,
            "Ticket",
            ticketId,
            now,
            userId,
            userId,
            content,
            0,
            1,
            now,
            now,
            0,
            0,
            0
        );

        jdbcTemplate.update(
            "UPDATE glpi_tickets SET date_mod = ?, users_id_lastupdater = ? WHERE id = ?",
            now,
            userId,
            ticketId
        );
    }

    private TicketDto getTicketById(long ticketId) {
        String sql = """
            SELECT
                t.id,
                COALESCE(NULLIF(t.name, ''), CONCAT('Ticket #', t.id)) AS title,
                COALESCE(NULLIF(t.content, ''), 'No description') AS description,
                t.status,
                t.priority,
                COALESCE(t.date_mod, t.date_creation) AS date_value,
                COALESCE(u.name, 'Unassigned') AS assigned_user
            FROM glpi_tickets t
            LEFT JOIN (
                SELECT tu.tickets_id, MIN(tu.users_id) AS users_id
                FROM glpi_tickets_users tu
                WHERE tu.type = 2
                GROUP BY tu.tickets_id
            ) ass ON ass.tickets_id = t.id
            LEFT JOIN glpi_users u ON u.id = COALESCE(ass.users_id, t.users_id_recipient)
            WHERE t.id = ?
            """;

        return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> mapRow(rs), ticketId);
    }

    private long requireUserId(String username) {
        Long userId = jdbcTemplate.queryForObject(
            "SELECT id FROM glpi_users WHERE name = ? AND is_active = 1 LIMIT 1",
            Long.class,
            username
        );
        if (userId == null) {
            throw new IllegalArgumentException("Active user not found: " + username);
        }
        return userId;
    }

    private long parseTicketRef(String ticketRef) {
        String digits = ticketRef.replaceAll("\\D+", "");
        if (digits.isEmpty()) {
            throw new IllegalArgumentException("Invalid ticket reference: " + ticketRef);
        }
        return Long.parseLong(digits);
    }

    private int mapPriorityToGlpi(String priority) {
        return switch (Objects.requireNonNullElse(priority, "medium").toLowerCase()) {
            case "low" -> 2;
            case "high" -> 5;
            case "urgent" -> 6;
            default -> 3;
        };
    }

    private int mapStatusToGlpi(String status) {
        return switch (Objects.requireNonNullElse(status, "open")) {
            case "closed" -> 6;
            case "inProgress" -> 2;
            default -> 1;
        };
    }

    private TicketDto mapRow(ResultSet rs) throws SQLException {
        String id = "#INC-" + rs.getLong("id");
        String title = rs.getString("title");
        String description = rs.getString("description");
        String status = mapStatus(rs.getInt("status"));
        String priority = mapPriority(rs.getInt("priority"));
        String date = rs.getString("date_value");
        String assignedUser = rs.getString("assigned_user");

        return new TicketDto(id, title, description, status, priority, date, assignedUser);
    }

    private String mapStatus(int status) {
        return switch (status) {
            case 5, 6 -> "closed";
            case 2, 3, 4 -> "inProgress";
            default -> "open";
        };
    }

    private String mapPriority(int priority) {
        if (priority <= 2) return "low";
        if (priority <= 4) return "medium";
        if (priority == 5) return "high";
        return "urgent";
    }
}
