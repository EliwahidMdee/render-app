# API Documentation for Live Agent App

This document outlines the new and updated API endpoints needed for the enhanced Live Agent application.

## Table of Contents
1. [Message Status APIs](#message-status-apis)
2. [Real-time Updates](#real-time-updates)
3. [Dashboard Statistics](#dashboard-statistics)
4. [Push Notifications](#push-notifications)
5. [Settings / Profile](#settings--profile)

---

## Message Status APIs

### 1. Mark Message as Read
**Endpoint:** `PUT /api/v1/live-agent/messages/{message_id}/read`

**Description:** Mark a message as read by the recipient (agent or user).

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "read_by": "agent"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Message marked as read",
  "data": {
    "message_id": 12345,
    "read_by_agent": true,
    "read_by_user": false,
    "read_at": "2024-01-15T10:30:00Z"
  }
}
```

---

### 2. Bulk Mark Messages as Read
**Endpoint:** `PUT /api/v1/live-agent/sessions/{session_id}/messages/read`

**Description:** Mark all messages in a session as read by the agent.

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "read_by": "agent"
}
```

Note: `read_by` can be either `"agent"` or `"user"`.

---

## Real-time Updates

### 3. Get Messages with Delivery Status
**Endpoint:** `GET /api/v1/live-agent/sessions/{session_id}/messages`

**Description:** Retrieve messages with delivery and read status (already exists, but needs to return updated fields).

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Query Parameters:**
- `limit` (optional): Number of messages to return (default: 50)
- `offset` (optional): Offset for pagination (default: 0)
- `since` (optional): Timestamp to get messages after this time (ISO 8601 format)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "session_id": "session_123",
    "messages": [
      {
        "message_id": 12345,
        "session_id": "session_123",
        "sender_type": "user",
        "sender_id": "user_456",
        "sender_name": "John Doe",
        "message_text": "Hello, I need help",
        "created_at": "2024-01-15T10:30:00Z",
        "read_by_user": false,
        "read_by_agent": true,
        "delivered_at": "2024-01-15T10:30:01Z",
        "read_at": "2024-01-15T10:30:05Z",
        "metadata": null
      },
      {
        "message_id": 12346,
        "session_id": "session_123",
        "sender_type": "agent",
        "sender_id": "agent_789",
        "sender_name": "Support Agent",
        "message_text": "Hi, how can I help you?",
        "created_at": "2024-01-15T10:31:00Z",
        "read_by_user": true,
        "read_by_agent": false,
        "delivered_at": "2024-01-15T10:31:01Z",
        "read_at": "2024-01-15T10:31:10Z",
        "metadata": null
      }
    ],
    "total": 2,
    "has_more": false
  }
}
```

**Notes:**
- `read_by_agent`: Indicates if the agent has read the message (for user messages)
- `read_by_user`: Indicates if the user has read the message (for agent messages)
- `delivered_at`: Timestamp when the message was delivered to the recipient
- `read_at`: Timestamp when the message was read by the recipient

---

## Dashboard Statistics

### 4. Get Session Statistics
**Endpoint:** `GET /api/v1/live-agent/agent/statistics`

**Description:** Get session statistics for the dashboard with date filtering.

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Query Parameters:**
- `date_filter` (optional): Filter by date range
  - `today`: Today's sessions
  - `last_week`: Last 7 days
  - `this_month`: Current month
  - `this_year`: Current year
  - `all`: All sessions (default)
- `agent_id` (optional): Filter by specific agent (defaults to authenticated agent)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "total_sessions": 150,
    "pending_sessions": 12,
    "active_sessions": 8,
    "resolved_sessions": 130,
    "closed_sessions": 0,
    "average_response_time_seconds": 45,
    "date_range": {
      "from": "2024-01-01T00:00:00Z",
      "to": "2024-01-15T23:59:59Z"
    },
    "sessions_by_date": [
      {
        "date": "2024-01-15",
        "total": 10,
        "pending": 2,
        "active": 3,
        "resolved": 5
      }
    ]
  }
}
```

---

## Push Notifications

### 5. Register FCM Token
**Endpoint:** `POST /api/v1/live-agent/agent/fcm-token`

**Description:** Register or update the agent's FCM token for push notifications (already exists, but documenting for completeness).

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "fcm_token": "fcm_token_string_here",
  "device_type": "android"
}
```

Note: `device_type` should be either `"android"` or `"ios"`.

---

### 6. Push Notification Payload Format

**New Session Notification:**
```json
{
  "notification": {
    "title": "New Session Request",
    "body": "John Doe needs assistance"
  },
  "data": {
    "type": "new_session",
    "session_id": "session_123",
    "user_name": "John Doe",
    "tenant_domain": "example.com",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**New Message Notification:**
```json
{
  "notification": {
    "title": "New Message from John Doe",
    "body": "Hello, I need help"
  },
  "data": {
    "type": "new_message",
    "session_id": "session_123",
    "message_id": 12345,
    "sender_name": "John Doe",
    "message_text": "Hello, I need help",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Session Status Changed Notification:**
```json
{
  "notification": {
    "title": "Session Status Changed",
    "body": "Session with John Doe is now resolved"
  },
  "data": {
    "type": "session_status_changed",
    "session_id": "session_123",
    "old_status": "active",
    "new_status": "resolved",
    "user_name": "John Doe"
  }
}
```

---

## Settings / Profile

Auth: Authorization: Bearer <jwt> (uses get_current_user)

### GET /api/v1/auth/profile
Purpose: return the authenticated user's account details.

URL: `/api/v1/auth/profile`

Method: `GET`

Headers:
```json
{ "Authorization": "Bearer <token>" }
```

Request body: none

Success (200) response JSON (ProfileOut):
```json
{
  "email": "alice@example.com",
  "full_name": "Alice Example",
  "role": "agent",
  "is_active": true,
  "created_at": "2024-01-15T09:27:00.000000",
  "last_login": "2025-11-06T14:00:00.000000"
}
```

Errors:
- `401 Unauthorized` — missing/invalid token
- `404 Not Found` — token valid but user not found in DB (rare)

---

### PUT /api/v1/auth/profile
Purpose: update the authenticated user's profile.

URL: `/api/v1/auth/profile`

Method: `PUT`

Headers:
```json
{ "Authorization": "Bearer <token>" }
```

Request body (any fields optional):
```json
{
  "full_name": "Alice L. Example",
  "email": "alice.new@example.com",
  "password": "newStrongPassword123"
}
```

password min length: 8

Behavior summary:
- If email changes:
  - Server checks uniqueness; returns `400 Bad Request` if the new email already exists.
  - Updates `users.email` and attempts to update any `LiveAgentProfile` where `agent_id == old_email` to the new email.
  - Note: the client's JWT still contains the old email — the client should re-login to obtain a token with the new email in claims.
- If `full_name` changes:
  - Updates `users.full_name` and also `LiveAgentProfile.agent_name` if a profile exists for the user.
- If `password` provided:
  - Stores bcrypt-hashed password.

Success (200) response JSON (updated ProfileOut):
```json
{
  "email": "alice.new@example.com",
  "full_name": "Alice L. Example",
  "role": "agent",
  "is_active": true,
  "created_at": "2024-01-15T09:27:00.000000",
  "last_login": "2025-11-06T14:00:00.000000"
}
```

Errors:
- `400 Bad Request` — new email already in use
- `401 Unauthorized` — missing/invalid token
- `404 Not Found` — user not found
- `422 Unprocessable Entity` — validation failure (e.g., invalid email, short password)

---

## Implementation Notes

### Message Delivery and Read Status

1. **Automatic Delivery Status:**
   - When a message is sent, it should be marked as delivered immediately
   - The `delivered_at` timestamp should be set to the current time

2. **Read Status Updates:**
   - When the chat screen is opened, call the bulk mark as read endpoint
   - When individual messages come into view, they can be marked as read
   - The app should auto-refresh every 800ms to get updated read statuses

3. **Visual Indicators:**
   - Single grey tick: Message sent (not used in current implementation)
   - Double grey ticks: Message delivered
   - Double blue ticks: Message read

### Real-time Updates

- The app uses polling (800ms interval) for real-time updates
- Consider implementing WebSocket support for true real-time updates in future versions
- The `/messages` endpoint should support `since` parameter for efficient polling

### Dashboard Filters

- All date filters should use the server's timezone or UTC
- The `sessions_by_date` array helps in creating charts/graphs if needed
- Consider caching statistics to reduce database load

### Push Notifications

- FCM tokens should be updated whenever they change
- The backend should handle token refresh automatically
- Failed notification deliveries should be logged for debugging
- Consider implementing notification preferences in the settings screen

---

## Error Responses

All endpoints should return consistent error responses:

**401 Unauthorized:**
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

**400 Bad Request:**
```json
{
  "success": false,
  "error": "Bad Request",
  "message": "Invalid parameters",
  "details": {
    "field": "error description"
  }
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": "Not Found",
  "message": "Session or message not found"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "error": "Internal Server Error",
  "message": "An unexpected error occurred"
}
```

---

## Migration Guide

### Database Schema Changes

**Messages Table:**
Add the following columns if they don't exist:
- `delivered_at` (TIMESTAMP, nullable)
- `read_at` (TIMESTAMP, nullable)

**Indexes:**
- Add index on `messages.session_id, messages.created_at` for efficient polling
- Add index on `sessions.created_at` for dashboard queries

### Backward Compatibility

- All new fields should be optional to maintain backward compatibility
- Existing endpoints should continue to work without changes
- New fields can be added to responses without breaking existing clients

---

## Testing Checklist

- [ ] Test message delivery status updates
- [ ] Test message read status updates
- [ ] Test bulk mark as read functionality
- [ ] Test dashboard statistics with different date filters
- [ ] Test FCM token registration and updates
- [ ] Test push notification delivery
- [ ] Test notification tap handling
- [ ] Test real-time message polling
- [ ] Test error handling for all endpoints
- [ ] Test concurrent access (multiple agents)

---

## Security Considerations

1. **Authorization:** All endpoints require valid JWT token
2. **Session Access:** Agents can only access sessions assigned to them or unassigned sessions
3. **Message Access:** Agents can only read messages from their assigned sessions
4. **Rate Limiting:** Implement rate limiting on polling endpoints (800ms is quite frequent)
5. **FCM Token Security:** FCM tokens should be encrypted in the database

---

## Performance Recommendations

1. **Caching:** Cache session statistics for dashboard (5-minute TTL)
2. **Pagination:** Always use pagination for messages endpoint
3. **Database Optimization:** Use proper indexes as mentioned above
4. **Connection Pooling:** Use database connection pooling
5. **CDN:** Consider using CDN for static assets (profile pictures, etc.)

---

## Future Enhancements

1. **WebSocket Support:** Replace polling with WebSocket for real-time updates
2. **Typing Indicators:** Show when user is typing
3. **File Attachments:** Support for image/file sharing
4. **Voice Messages:** Support for voice messages
5. **Session Assignment:** Automatic session assignment based on agent availability
6. **Agent Status:** Online/Offline/Busy status for agents
7. **Message Search:** Full-text search across messages
8. **Analytics:** Detailed analytics dashboard with charts

---

Last Updated: 2024-01-15
Version: 1.0.0
