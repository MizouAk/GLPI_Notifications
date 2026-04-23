package com.example.backendAPI.ticket;

public class TicketDto {
    private String id;
    private String title;
    private String description;
    private String status;
    private String priority;
    private String date;
    private String assignedUser;

    public TicketDto(
        String id,
        String title,
        String description,
        String status,
        String priority,
        String date,
        String assignedUser
    ) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.status = status;
        this.priority = priority;
        this.date = date;
        this.assignedUser = assignedUser;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getStatus() {
        return status;
    }

    public String getPriority() {
        return priority;
    }

    public String getDate() {
        return date;
    }

    public String getAssignedUser() {
        return assignedUser;
    }
}
