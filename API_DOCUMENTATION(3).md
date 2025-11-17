# SmartBiashara AI Assistant - API Documentation

## Overview

This is a comprehensive API documentation for the SmartBiashara AI Assistant API. This FastAPI-based backend provides endpoints for authentication, AI assistant chat, Q&A management, WhatsApp integration, live agent support, and more.

**Base URL**: `http://your-domain.com/api/v1`

**API Documentation (Interactive)**: `http://your-domain.com/docs`

## Table of Contents

1. [Authentication](#authentication)
2. [POST Endpoints](#post-endpoints)
   - [Auth Endpoints](#auth-endpoints)
   - [Assistant Endpoints](#assistant-endpoints)
   - [Q&A Management](#qa-management)
   - [WhatsApp Integration](#whatsapp-integration)
   - [Feedback](#feedback)
   - [Unanswered Questions](#unanswered-questions)
   - [Live Agent Sessions](#live-agent-sessions)
   - [Live Agent Messages](#live-agent-messages)
   - [Live Agent Q&A Capture](#live-agent-qa-capture)
   - [Agent Management](#agent-management)
   - [Access Control](#access-control)
   - [Ingest](#ingest)
3. [Error Responses](#error-responses)
4. [Rate Limiting](#rate-limiting)
5. [Data Types](#data-types)
6. [Best Practices](#best-practices)
7. [Testing](#testing)
8. [Support](#support)
9. [Common Use Cases](#common-use-cases)
10. [Quick Reference: All POST Endpoints](#quick-reference-all-post-endpoints)

---

## Authentication

Most endpoints require authentication via JWT Bearer token. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Authentication Levels

- **Public**: No authentication required
- **User**: Requires valid JWT token
- **Agent**: Requires JWT token with `agent` or `supervisor` role
- **Admin**: Requires JWT token with `admin` role

---

## POST Endpoints

### Auth Endpoints

#### POST /api/v1/auth/login

Authenticate a user and receive a JWT token.

**Authentication**: None (Public)

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "your-password"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User email address |
| password | string | Yes | User password |

**Success Response (200)**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "role": "admin",
  "redirect_url": "/admin/"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| access_token | string | JWT token for authentication |
| token_type | string | Always "bearer" |
| role | string | User role (admin, agent, supervisor) |
| redirect_url | string | Recommended redirect URL based on role |

**Error Responses**:
- `401 Unauthorized`: Invalid credentials
- `403 Forbidden`: Account is inactive

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "changeme"}'
```

---

#### POST /api/v1/auth/seed-admin

Create default admin user (development only).

**Authentication**: None (Public)

**Request Body**: None

**Success Response (200)**:
```json
{
  "status": "created"
}
```
or
```json
{
  "status": "exists"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| status | string | "created" if new admin was created, "exists" if admin already exists |

---

### Assistant Endpoints

#### POST /api/v1/assistant/chat

Send a message to the AI assistant and get an intelligent response.

**Authentication**: Optional (Can use X-Assistant-Key header if ASSISTANT_API_KEY is configured)

**Headers**:
- `X-Tenant-ID` (optional): Tenant identifier for multi-tenant setups
- `X-Assistant-Key` (optional): API key if ASSISTANT_API_KEY is configured

**Request Body**:
```json
{
  "message": "How do I register my business in Tanzania?",
  "language": "en"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| message | string | Yes | User's question or message |
| language | string | No | Language code: "en" or "sw" (default: null) |

**Success Response (200)**:
```json
{
  "answer": "To register your business in Tanzania, you need to...",
  "guide_url": "https://userguide.example.com/business-registration",
  "show_live_agent": false,
  "live_agent_email": null,
  "live_agent_whatsapp": null
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| answer | string | AI-generated answer to the question |
| guide_url | string or null | URL to relevant documentation |
| show_live_agent | boolean | Whether to suggest live agent contact |
| live_agent_email | string or null | Live agent email (if show_live_agent is true) |
| live_agent_whatsapp | string or null | Live agent WhatsApp number (if show_live_agent is true) |

**Error Responses**:
- `401 Unauthorized`: Invalid or missing API key
- `429 Too Many Requests`: Rate limit exceeded

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/assistant/chat" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: company123" \
  -d '{"message": "What are the business hours?", "language": "en"}'
```

---

### Q&A Management

#### POST /api/v1/qa/

Create a new Q&A pair in the knowledge base.

**Authentication**: Admin

**Request Body**:
```json
{
  "question": "What are the business registration fees?",
  "answer": "The business registration fee in Tanzania is...",
  "category": "Business Registration",
  "language": "en",
  "source_url": "https://example.com/business-fees"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| question | string | Yes | The question text |
| answer | string | Yes | The answer text |
| category | string | No | Category for organization |
| language | string | No | Language code (e.g., "en", "sw") |
| source_url | string | No | Source URL for reference |

**Success Response (200)**:
```json
{
  "id": 123,
  "question": "What are the business registration fees?",
  "answer": "The business registration fee in Tanzania is...",
  "category": "Business Registration",
  "language": "en",
  "source_url": "https://example.com/business-fees",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| id | integer | Unique identifier for the Q&A pair |
| question | string | The question text |
| answer | string | The answer text |
| category | string or null | Category name |
| language | string or null | Language code |
| source_url | string or null | Source URL |
| created_at | string (datetime) | Creation timestamp |
| updated_at | string (datetime) | Last update timestamp |

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/qa/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "How do I pay taxes?",
    "answer": "You can pay taxes through...",
    "category": "Taxation"
  }'
```

---

#### POST /api/v1/qa/retrain

Retrain the AI model with the latest Q&A pairs.

**Authentication**: Admin

**Request Body**: None

**Success Response (200)**:
```json
{
  "status": "success",
  "message": "Training completed",
  "pairs_processed": 150
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| status | string | Status of retraining operation |
| message | string | Human-readable message |
| pairs_processed | integer | Number of Q&A pairs processed |

---

#### POST /api/v1/qa/bulk

Bulk upsert Q&A pairs.

**Authentication**: Admin

**Request Body**:
```json
{
  "items": [
    {
      "question": "Question 1?",
      "answer": "Answer 1",
      "category": "Category A",
      "language": "en",
      "source_url": "https://example.com/1"
    },
    {
      "question": "Question 2?",
      "answer": "Answer 2",
      "category": "Category B",
      "language": "sw",
      "source_url": null
    }
  ]
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| items | array | Yes | Array of Q&A items to upsert |
| items[].question | string | Yes | Question text |
| items[].answer | string | Yes | Answer text |
| items[].category | string | No | Category name |
| items[].language | string | No | Language code |
| items[].source_url | string | No | Source URL |

**Success Response (200)**:
```json
{
  "created": 15,
  "updated": 5
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| created | integer | Number of new Q&A pairs created |
| updated | integer | Number of existing Q&A pairs updated |

---

#### POST /api/v1/qa/bulk-upload-file

Upload Q&A pairs from Excel or CSV file.

**Authentication**: Admin

**Request**: Multipart form data

**Form Fields**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| file | file | Yes | Excel (.xlsx, .xls) or CSV file |

**File Format**:
- Must contain columns: `question`, `answer`
- Optional columns: `category`, `language`, `source_url` (or `url`)
- First row should contain headers

**Success Response (200)**:
```json
{
  "created": 25,
  "updated": 10
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| created | integer | Number of new Q&A pairs created |
| updated | integer | Number of existing Q&A pairs updated |

**Error Responses**:
- `400 Bad Request`: Invalid file format or missing required columns

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/qa/bulk-upload-file" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@qa_data.xlsx"
```

---

### WhatsApp Integration

#### POST /api/v1/whatsapp/webhook

Receive incoming WhatsApp messages (webhook endpoint).

**Authentication**: Verified using webhook token

**Request Body** (Meta WABA format):
```json
{
  "entry": [
    {
      "changes": [
        {
          "value": {
            "messages": [
              {
                "from": "1234567890",
                "text": {
                  "body": "Hello, I need help"
                },
                "type": "text"
              }
            ]
          }
        }
      ]
    }
  ]
}
```

**Success Response (200)**:
```json
{
  "status": "received",
  "provider": "meta"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| status | string | "received" |
| provider | string | "meta" or "generic" |

---

#### POST /api/v1/whatsapp/send

Send a WhatsApp message.

**Authentication**: Admin

**Request Body**:
```json
{
  "from_number": "1234567890",
  "body": "Thank you for your message!",
  "media_urls": null
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| from_number | string | Yes | Recipient phone number |
| body | string | No | Message text |
| media_urls | array | No | URLs of media attachments |

**Success Response (200)**:
```json
{
  "status": "sent"
}
```

---

### Feedback

#### POST /api/v1/feedback/

Submit user feedback.

**Authentication**: Admin

**Request Body**:
```json
{
  "conversation_id": 123,
  "user_phone": "+255712345678",
  "rating": 5,
  "comment": "Very helpful service!"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| conversation_id | integer | No | Associated conversation ID |
| user_phone | string | No | User phone number |
| rating | integer | No | Rating (1-5) |
| comment | string | No | Feedback comment |

**Success Response (200)**:
```json
{
  "id": 456,
  "conversation_id": 123,
  "user_phone": "+255712345678",
  "rating": 5,
  "comment": "Very helpful service!",
  "resolved": false,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| id | integer | Feedback ID |
| conversation_id | integer or null | Associated conversation ID |
| user_phone | string or null | User phone number |
| rating | integer or null | Rating value |
| comment | string or null | Feedback comment |
| resolved | boolean | Whether feedback is resolved |
| created_at | string (datetime) | Creation timestamp |

---

### Unanswered Questions

#### POST /api/v1/unanswered/{qid}/answer

Provide an answer to an unanswered question and add it to the knowledge base.

**Authentication**: Admin

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| qid | integer | Unanswered question ID |

**Request Body**:
```json
{
  "answer": "The answer to your question is...",
  "category": "General",
  "language": "en"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| answer | string | Yes | Answer text |
| category | string | No | Category name |
| language | string | No | Language code |

**Success Response (200)**:
```json
{
  "status": "updated",
  "qa_id": 789
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| status | string | "updated" or "not_found" |
| qa_id | integer or null | ID of created Q&A pair |

---

### Live Agent Sessions

#### POST /api/v1/live-agent/sessions

Create a new live agent support session.

**Authentication**: User (JWT token required)

**Request Body**:
```json
{
  "initial_message": "I need help with my account",
  "user_context": {
    "page_url": "https://example.com/account",
    "user_agent": "Mozilla/5.0..."
  }
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| initial_message | string | Yes | First message from user |
| user_context | object | No | Additional context information |

**Success Response (201)**:
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "tenant_domain": "company.example.com",
  "user_account": "user@example.com",
  "user_name": "John Doe",
  "status": "pending",
  "created_at": "2024-01-15T10:30:00Z",
  "message": "Session created. An agent will respond shortly."
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| session_id | string (UUID) | Unique session identifier |
| tenant_domain | string | Tenant domain |
| user_account | string | User's email/account |
| user_name | string or null | User's display name |
| status | string | Session status ("pending") |
| created_at | string (datetime) | Creation timestamp |
| message | string | Confirmation message |

**Error Responses**:
- `500 Internal Server Error`: Failed to create session

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/sessions" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": "I need help",
    "user_context": {"page": "/dashboard"}
  }'
```

---

### Live Agent Messages

#### POST /api/v1/live-agent/messages

Send a message in a live agent session.

**Authentication**: User (JWT token required)

**Request Body**:
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "message_text": "Can you help me with this issue?",
  "sender_type": "user"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| session_id | string (UUID) | Yes | Session identifier |
| message_text | string | Yes | Message content |
| sender_type | string | Yes | "user" or "agent" |

**Success Response (201)**:
```json
{
  "message_id": 12345,
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "sender_type": "user",
  "sender_name": "John Doe",
  "message_text": "Can you help me with this issue?",
  "created_at": "2024-01-15T10:35:00Z",
  "notification_sent": true
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| message_id | integer | Unique message identifier |
| session_id | string (UUID) | Session identifier |
| sender_type | string | "user" or "agent" |
| sender_name | string or null | Sender's display name |
| message_text | string | Message content |
| created_at | string (datetime) | Creation timestamp |
| notification_sent | boolean | Whether push notification was sent |

**Error Responses**:
- `404 Not Found`: Session not found
- `500 Internal Server Error`: Failed to send message

---

### Agent Management

#### POST /api/v1/live-agent/agents

Create a new live agent account.

**Authentication**: Admin

**Request Body**:
```json
{
  "email": "agent@example.com",
  "password": "SecurePass123!",
  "full_name": "Jane Smith",
  "role": "agent",
  "agent_rights": {
    "can_manage_agents": false,
    "can_view_all_sessions": true,
    "can_close_sessions": true,
    "can_reassign_sessions": false,
    "can_export_data": false,
    "can_approve_qa": false
  }
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string (email) | Yes | Agent email address |
| password | string | Yes | Password (min 8 characters) |
| full_name | string | Yes | Agent full name |
| role | string | No | "agent" or "supervisor" (default: "agent") |
| agent_rights | object | No | Agent permissions |

**Success Response (200)**:
```json
{
  "id": 42,
  "email": "agent@example.com",
  "full_name": "Jane Smith",
  "role": "agent",
  "is_active": true,
  "agent_rights": {
    "can_manage_agents": false,
    "can_view_all_sessions": true,
    "can_close_sessions": true,
    "can_reassign_sessions": false,
    "can_export_data": false,
    "can_approve_qa": false
  },
  "created_at": "2024-01-15T10:30:00Z",
  "last_login": null,
  "is_online": false,
  "status": "offline",
  "last_seen": null
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| id | integer | Agent user ID |
| email | string | Agent email |
| full_name | string or null | Agent name |
| role | string | Agent role |
| is_active | boolean | Whether account is active |
| agent_rights | object or null | Agent permissions |
| created_at | string (datetime) or null | Account creation time |
| last_login | string (datetime) or null | Last login time |
| is_online | boolean | Current online status |
| status | string | Status ("offline", "online") |
| last_seen | string (datetime) or null | Last seen timestamp |

**Error Responses**:
- `400 Bad Request`: Email already registered

---

#### POST /api/v1/live-agent/agent/fcm-token

Register or update FCM token for push notifications.

**Authentication**: User (Agent/Supervisor)

**Request Body**:
```json
{
  "fcm_token": "eXampleFCMTokenString123..."
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| fcm_token | string | Yes | Firebase Cloud Messaging token |

**Success Response (200)**:
```json
{
  "success": true,
  "message": "FCM token registered successfully",
  "data": {
    "agent_id": "agent@example.com",
    "agent_name": "Jane Smith",
    "fcm_token": "eXampleFCMTokenString123...",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Whether operation succeeded |
| message | string | Success message |
| data | object | Registration details |
| data.agent_id | string | Agent identifier |
| data.agent_name | string | Agent name |
| data.fcm_token | string | Registered FCM token |
| data.updated_at | string (datetime) | Update timestamp |

---

### Access Control

#### POST /api/v1/access-control/groups

Create a new user group.

**Authentication**: Admin

**Request Body**:
```json
{
  "name": "Support Team",
  "description": "Customer support agents",
  "permissions": "{\"can_view_reports\": true, \"can_edit_qa\": false}"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Group name |
| description | string | No | Group description |
| permissions | string | Yes | JSON string of permissions |

**Success Response (200)**:
```json
{
  "id": 5,
  "name": "Support Team",
  "description": "Customer support agents",
  "permissions": "{\"can_view_reports\": true, \"can_edit_qa\": false}",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| id | integer | Group ID |
| name | string | Group name |
| description | string or null | Group description |
| permissions | string | JSON permissions string |
| created_at | string (datetime) | Creation timestamp |
| updated_at | string (datetime) | Last update timestamp |

**Error Responses**:
- `400 Bad Request`: Group name already exists

---

### Live Agent Q&A Capture

#### POST /api/v1/live-agent/qa/auto-capture

Automatically capture Q&A pairs from a completed live agent session.

**Authentication**: User (JWT token required)

**Request Body**:
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| session_id | string (UUID) | Yes | Session ID to capture Q&A from |

**Success Response (200)**:
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "captured_count": 3,
  "message": "Captured 3 Q&A pairs from session"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| session_id | string (UUID) | Session identifier |
| captured_count | integer | Number of Q&A pairs captured |
| message | string | Success message |

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/qa/auto-capture" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"session_id": "550e8400-e29b-41d4-a716-446655440000"}'
```

---

#### POST /api/v1/live-agent/qa/{qa_id}/approve

Approve a captured Q&A pair and integrate it into the knowledge base.

**Authentication**: Admin

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| qa_id | integer | Q&A pair ID to approve |

**Request Body**:
```json
{
  "quality_score": 8
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| quality_score | integer | No | Quality rating (1-10, default: 5) |

**Success Response (200)**:
```json
{
  "id": 123,
  "approved": true,
  "integrated": true,
  "message": "Q&A pair approved and integrated into knowledge base"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| id | integer | Q&A pair ID |
| approved | boolean | Whether Q&A is approved |
| integrated | boolean | Whether Q&A is integrated into knowledge base |
| message | string | Success message |

**Error Responses**:
- `404 Not Found`: Q&A pair not found

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/qa/123/approve" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"quality_score": 8}'
```

---

### Ingest

#### POST /api/v1/ingest/userguide

Ingest content from user guide website into Q&A knowledge base.

**Authentication**: Admin

**Request Body**:
```json
{
  "base_url": "https://userguide.example.com",
  "max_pages": 50
}
```

**Request Schema**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| base_url | string | No | Base URL to crawl (uses USER_GUIDE_BASE_URL if not provided) |
| max_pages | integer | No | Maximum pages to crawl (default: 100) |

**Success Response (200)**:
```json
{
  "created": 35,
  "updated": 12
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| created | integer | Number of new Q&A pairs created |
| updated | integer | Number of existing Q&A pairs updated |

**Error Responses**:
- `400 Bad Request`: Missing base_url and USER_GUIDE_BASE_URL not configured

**Example**:
```bash
curl -X POST "http://localhost:8000/api/v1/ingest/userguide" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"base_url": "https://guide.example.com", "max_pages": 100}'
```

---

## Error Responses

All endpoints follow a consistent error response format:

### 400 Bad Request
```json
{
  "detail": "Validation error message or specific error description"
}
```

### 401 Unauthorized
```json
{
  "detail": "Invalid credentials"
}
```
or
```json
{
  "detail": "Not authenticated"
}
```

### 403 Forbidden
```json
{
  "detail": "Not enough permissions"
}
```
or
```json
{
  "detail": "Account is inactive. Contact administrator."
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found"
}
```

### 429 Too Many Requests
```json
{
  "detail": "Rate limit exceeded"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error description"
}
```

---

## Rate Limiting

The `/api/v1/assistant/chat` endpoint has configurable rate limiting:
- Rate limit: Configured via `ASSISTANT_RATE_LIMIT_PER_MINUTE` environment variable
- Per tenant/user
- Default: No limit (set to 0)
- Returns `429 Too Many Requests` when exceeded

---

## Data Types

### DateTime Format
All datetime fields use ISO 8601 format with UTC timezone:
```
2024-01-15T10:30:00Z
```

### UUID Format
Session IDs use UUID v4 format:
```
550e8400-e29b-41d4-a716-446655440000
```

---

## Best Practices

1. **Always validate responses**: Check HTTP status codes before processing response data
2. **Handle errors gracefully**: Implement proper error handling for all possible error responses
3. **Use pagination**: When listing resources, use pagination parameters to avoid large responses
4. **Rate limiting**: Implement exponential backoff when rate limited
5. **Secure tokens**: Never expose JWT tokens in logs or client-side code
6. **HTTPS only**: Always use HTTPS in production environments
7. **Timeout handling**: Implement reasonable timeouts for API calls (recommended: 30 seconds)

---

## Testing

Use the interactive API documentation at `/docs` to test endpoints:

```
http://localhost:8000/docs
```

The Swagger UI provides:
- Interactive endpoint testing
- Request/response examples
- Schema validation
- Authentication testing

---

## Support

For issues or questions about the API:
1. Check the interactive documentation at `/docs`
2. Review error messages for specific guidance
3. Contact your system administrator

---

## Common Use Cases

### Use Case 1: Building a Chat Widget

**Step 1**: Get an answer from the AI assistant
```bash
curl -X POST "http://localhost:8000/api/v1/assistant/chat" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: mycompany" \
  -d '{
    "message": "How do I register a business?",
    "language": "en"
  }'
```

**Step 2**: If AI can't help, create a live agent session
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/sessions" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": "I need help with business registration",
    "user_context": {"page": "/registration"}
  }'
```

**Step 3**: Send follow-up messages
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/messages" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "SESSION_ID_FROM_STEP_2",
    "message_text": "Can you provide more details?",
    "sender_type": "user"
  }'
```

### Use Case 2: Managing Knowledge Base

**Step 1**: Add a single Q&A pair
```bash
curl -X POST "http://localhost:8000/api/v1/qa/" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What are the business hours?",
    "answer": "We are open Monday to Friday, 8 AM to 5 PM",
    "category": "General Information"
  }'
```

**Step 2**: Bulk upload from file
```bash
curl -X POST "http://localhost:8000/api/v1/qa/bulk-upload-file" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -F "file=@qa_pairs.xlsx"
```

**Step 3**: Retrain the AI model
```bash
curl -X POST "http://localhost:8000/api/v1/qa/retrain" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

### Use Case 3: Agent Workflow

**Step 1**: Agent logs in
```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "agent@example.com",
    "password": "secure-password"
  }'
```

**Step 2**: Get list of pending sessions
```bash
curl -X GET "http://localhost:8000/api/v1/live-agent/sessions?status=pending" \
  -H "Authorization: Bearer AGENT_TOKEN"
```

**Step 3**: Take a session and respond
```bash
# Update session status to active
curl -X PUT "http://localhost:8000/api/v1/live-agent/sessions/SESSION_ID/status" \
  -H "Authorization: Bearer AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "active",
    "assigned_agent_name": "Agent Name"
  }'

# Send response
curl -X POST "http://localhost:8000/api/v1/live-agent/messages" \
  -H "Authorization: Bearer AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "SESSION_ID",
    "message_text": "Hello! How can I help you today?",
    "sender_type": "agent"
  }'
```

**Step 4**: After resolving, capture Q&A for knowledge base
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/qa/auto-capture" \
  -H "Authorization: Bearer AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "SESSION_ID"
  }'
```

### Use Case 4: Admin Dashboard Integration

**Get statistics**:
```bash
curl -X GET "http://localhost:8000/api/v1/live-agent/agent/statistics?date_filter=this_month" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

**Create new agent**:
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/agents" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newagent@example.com",
    "password": "SecurePass123!",
    "full_name": "New Agent",
    "role": "agent"
  }'
```

**Review and approve captured Q&A**:
```bash
curl -X POST "http://localhost:8000/api/v1/live-agent/qa/123/approve" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quality_score": 9
  }'
```

---

## Quick Reference: All POST Endpoints

| Endpoint | Auth | Purpose |
|----------|------|---------|
| `/api/v1/auth/login` | None | User authentication |
| `/api/v1/auth/seed-admin` | None | Create default admin (dev) |
| `/api/v1/assistant/chat` | Optional | AI assistant chat |
| `/api/v1/qa/` | Admin | Create Q&A pair |
| `/api/v1/qa/retrain` | Admin | Retrain AI model |
| `/api/v1/qa/bulk` | Admin | Bulk upsert Q&A pairs |
| `/api/v1/qa/bulk-upload-file` | Admin | Upload Q&A from file |
| `/api/v1/whatsapp/webhook` | Webhook | Receive WhatsApp messages |
| `/api/v1/whatsapp/send` | Admin | Send WhatsApp message |
| `/api/v1/feedback/` | Admin | Submit feedback |
| `/api/v1/unanswered/{qid}/answer` | Admin | Answer unanswered question |
| `/api/v1/live-agent/sessions` | User | Create support session |
| `/api/v1/live-agent/messages` | User | Send message in session |
| `/api/v1/live-agent/qa/auto-capture` | User | Auto-capture Q&A from session |
| `/api/v1/live-agent/qa/{qa_id}/approve` | Admin | Approve captured Q&A |
| `/api/v1/live-agent/agents` | Admin | Create agent account |
| `/api/v1/live-agent/agent/fcm-token` | Agent | Register FCM token |
| `/api/v1/access-control/groups` | Admin | Create user group |
| `/api/v1/ingest/userguide` | Admin | Ingest user guide content |

---

**Document Version**: 1.0  
**Last Updated**: 2024-01-15  
**API Version**: v1
