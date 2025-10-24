# Live Agent Flutter App Development Guide

## Complete Technical Documentation for Multi-Tenant Real-Time Live Agent System

**Version:** 2.0  
**Last Updated:** 2025-10-24  
**Target Audience:** Backend & Frontend Developers

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Backend Architecture](#2-backend-architecture)
3. [Database Schema](#3-database-schema)
4. [API Endpoints](#4-api-endpoints)
5. [Domain & User Capture](#5-domain--user-capture)
6. [Flutter Live Agent App](#6-flutter-live-agent-app)
7. [Notification Workflow](#7-notification-workflow)
8. [Security](#8-security)
9. [Testing & Deployment](#9-testing--deployment)
10. [Future Enhancements](#10-future-enhancements)

---

## 1. System Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Multi-Tenant ERP Portal                       │
│                  (tenant1.example.com, etc.)                     │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  User clicks "Contact Live Agent"                         │  │
│  │  ↓                                                         │  │
│  │  POST /api/v1/live-agent/sessions                         │  │
│  │  • Auto-capture: tenant_domain, user_account             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ↓
         ┌────────────────────────────────────┐
         │     Backend API (FastAPI)          │
         │  • Session Management               │
         │  • Message Persistence              │
         │  • FCM Notifications                │
         └────────┬──────────────┬─────────────┘
                  │              │
         ┌────────▼──────┐  ┌───▼────────────┐
         │   Database    │  │  Firebase FCM  │
         │   (Sessions   │  │  (Push Notif.) │
         │   & Messages) │  └────────┬───────┘
         └───────────────┘           │
                                     │
                          ┌──────────▼──────────────┐
                          │  Flutter Live Agent App │
                          │  • Agent Dashboard      │
                          │  • Real-time Chat       │
                          │  • Notification Handler │
                          └─────────────────────────┘
```

### 1.2 Role Separation

- **User**: End-user from ERP portal requesting help
- **Agent**: Support staff using Flutter app to respond
- **Supervisor**: Monitor sessions, reassign agents (future)

### 1.3 Core Features

✅ **Multi-tenant support**: Automatic domain isolation  
✅ **User tracking**: Authenticated user capture  
✅ **Real-time notifications**: FCM push to agents  
✅ **Persistent chat**: Message history across sessions  
✅ **Offline support**: Queue messages when agents offline  
✅ **Security**: JWT authentication, tenant validation

---

## 2. Backend Architecture

### 2.1 Technology Stack

- **Framework**: FastAPI (Python 3.10+)
- **Database**: SQLAlchemy (PostgreSQL/MySQL/SQLite)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Authentication**: JWT tokens
- **Real-time**: FCM push notifications

### 2.2 Project Structure

```
app/
├── models/
│   ├── live_agent_session.py    # Session model
│   └── live_agent_message.py    # Message model
├── api/
│   └── v1/
│       └── live_agent.py        # Live Agent endpoints
├── services/
│   └── fcm.py                   # Firebase notification service
├── deps/
│   └── auth.py                  # JWT authentication
└── config.py                    # Configuration settings
```

---

## 3. Database Schema

### 3.1 Live Agent Sessions Table

```sql
CREATE TABLE live_agent_sessions (
    id VARCHAR(36) PRIMARY KEY,              -- UUID
    tenant_domain VARCHAR(255) NOT NULL,     -- e.g., "tenant1.example.com"
    user_account VARCHAR(255) NOT NULL,      -- e.g., "john.doe@example.com"
    user_name VARCHAR(255),                  -- Display name
    assigned_agent_id INTEGER,               -- FK to agents table (nullable)
    assigned_agent_name VARCHAR(255),        -- Agent display name
    status VARCHAR(20) DEFAULT 'pending',    -- pending, active, resolved, closed
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_message_at TIMESTAMP,
    unread_count_user INTEGER DEFAULT 0,     -- Unread count for user
    unread_count_agent INTEGER DEFAULT 0,    -- Unread count for agent
    metadata JSON,                            -- Additional context
    
    INDEX idx_tenant_domain (tenant_domain),
    INDEX idx_user_account (user_account),
    INDEX idx_status (status),
    INDEX idx_assigned_agent (assigned_agent_id)
);
```

### 3.2 Live Agent Messages Table

```sql
CREATE TABLE live_agent_messages (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    session_id VARCHAR(36) NOT NULL,         -- FK to sessions
    sender_type VARCHAR(10) NOT NULL,        -- 'user' or 'agent'
    sender_id VARCHAR(255),                  -- User email or agent ID
    sender_name VARCHAR(255),                -- Display name
    message_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    read_by_user BOOLEAN DEFAULT FALSE,
    read_by_agent BOOLEAN DEFAULT FALSE,
    metadata JSON,
    
    FOREIGN KEY (session_id) REFERENCES live_agent_sessions(id) ON DELETE CASCADE,
    INDEX idx_session_id (session_id),
    INDEX idx_created_at (created_at)
);
```

### 3.3 Agent Status Table (Optional)

```sql
CREATE TABLE live_agent_profiles (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    agent_id VARCHAR(255) UNIQUE NOT NULL,   -- Agent email or username
    agent_name VARCHAR(255),
    fcm_token VARCHAR(512),                  -- FCM registration token
    is_online BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'offline',    -- online, offline, busy
    last_seen TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    INDEX idx_agent_id (agent_id),
    INDEX idx_is_online (is_online)
);
```

---

## 4. API Endpoints

### 4.1 Create Session

**Endpoint**: `POST /api/v1/live-agent/sessions`

**Description**: User initiates contact with live agent

**Headers**:
```http
Authorization: Bearer <user_jwt_token>
X-Tenant-Domain: tenant1.example.com (optional, auto-detected)
Content-Type: application/json
```

**Request Body**:
```json
{
  "initial_message": "I need help with invoice generation",
  "user_context": {
    "page_url": "/invoices/create",
    "browser": "Chrome 120"
  }
}
```

**Response** (201 Created):
```json
{
  "session_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "tenant_domain": "tenant1.example.com",
  "user_account": "john.doe@example.com",
  "user_name": "John Doe",
  "status": "pending",
  "created_at": "2025-10-24T08:00:00Z",
  "message": "Session created. An agent will respond shortly."
}
```

**Auto-Capture Logic**:
- `tenant_domain`: Extracted from `request.headers.get("host")` or `X-Tenant-Domain` header
- `user_account`: Extracted from JWT token (`token.sub` or `token.email`)

---

### 4.2 List Sessions

**Endpoint**: `GET /api/v1/live-agent/sessions`

**Description**: List sessions (for agents or admin)

**Headers**:
```http
Authorization: Bearer <agent_jwt_token>
```

**Query Parameters**:
- `tenant`: Filter by tenant domain (optional)
- `status`: Filter by status (pending, active, resolved, closed)
- `assigned_to_me`: Boolean, show only my assigned sessions
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 20)

**Response** (200 OK):
```json
{
  "sessions": [
    {
      "session_id": "a1b2c3d4-...",
      "tenant_domain": "tenant1.example.com",
      "user_account": "john.doe@example.com",
      "user_name": "John Doe",
      "assigned_agent_name": "Agent Smith",
      "status": "active",
      "created_at": "2025-10-24T08:00:00Z",
      "last_message_at": "2025-10-24T08:15:00Z",
      "unread_count_agent": 2,
      "preview": "I need help with invoice..."
    }
  ],
  "total": 45,
  "page": 1,
  "per_page": 20
}
```

---

### 4.3 Get Session Details

**Endpoint**: `GET /api/v1/live-agent/sessions/{session_id}`

**Description**: Get detailed session information

**Response** (200 OK):
```json
{
  "session_id": "a1b2c3d4-...",
  "tenant_domain": "tenant1.example.com",
  "user_account": "john.doe@example.com",
  "user_name": "John Doe",
  "assigned_agent_id": 123,
  "assigned_agent_name": "Agent Smith",
  "status": "active",
  "created_at": "2025-10-24T08:00:00Z",
  "updated_at": "2025-10-24T08:15:00Z",
  "last_message_at": "2025-10-24T08:15:00Z",
  "unread_count_user": 0,
  "unread_count_agent": 2,
  "metadata": {
    "page_url": "/invoices/create"
  }
}
```

---

### 4.4 Send Message

**Endpoint**: `POST /api/v1/live-agent/messages`

**Description**: Send a message in a session

**Headers**:
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body**:
```json
{
  "session_id": "a1b2c3d4-...",
  "message_text": "Please share your transaction ID",
  "sender_type": "agent"
}
```

**Response** (201 Created):
```json
{
  "message_id": 12345,
  "session_id": "a1b2c3d4-...",
  "sender_type": "agent",
  "sender_name": "Agent Smith",
  "message_text": "Please share your transaction ID",
  "created_at": "2025-10-24T08:16:00Z",
  "notification_sent": true
}
```

**Side Effects**:
- Updates session's `last_message_at`
- Increments unread count for recipient
- Sends FCM push notification to recipient

---

### 4.5 Get Messages

**Endpoint**: `GET /api/v1/live-agent/messages/{session_id}`

**Description**: Retrieve message history for a session

**Query Parameters**:
- `page`: Page number
- `per_page`: Messages per page (default: 50)
- `mark_as_read`: Boolean, mark as read for current user

**Response** (200 OK):
```json
{
  "messages": [
    {
      "message_id": 12343,
      "sender_type": "user",
      "sender_name": "John Doe",
      "message_text": "I need help with invoice generation",
      "created_at": "2025-10-24T08:00:00Z",
      "read_by_agent": true
    },
    {
      "message_id": 12344,
      "sender_type": "agent",
      "sender_name": "Agent Smith",
      "message_text": "I can help you with that!",
      "created_at": "2025-10-24T08:01:00Z",
      "read_by_user": false
    }
  ],
  "total": 2,
  "session": {
    "session_id": "a1b2c3d4-...",
    "status": "active"
  }
}
```

---

### 4.6 Update Session Status

**Endpoint**: `PUT /api/v1/live-agent/sessions/{session_id}/status`

**Description**: Update session status or assign agent

**Request Body**:
```json
{
  "status": "active",
  "assigned_agent_id": 123,
  "assigned_agent_name": "Agent Smith"
}
```

**Response** (200 OK):
```json
{
  "session_id": "a1b2c3d4-...",
  "status": "active",
  "assigned_agent_name": "Agent Smith",
  "updated_at": "2025-10-24T08:02:00Z"
}
```

---

### 4.7 Agent Status Management

**Endpoint**: `PUT /api/v1/live-agent/agent/status`

**Description**: Toggle agent online/offline status

**Headers**:
```http
Authorization: Bearer <agent_jwt_token>
```

**Request Body**:
```json
{
  "is_online": true,
  "fcm_token": "fcm_registration_token_here"
}
```

**Response** (200 OK):
```json
{
  "agent_id": "agent.smith@example.com",
  "agent_name": "Agent Smith",
  "is_online": true,
  "status": "online",
  "updated_at": "2025-10-24T08:00:00Z"
}
```

---

## 5. Domain & User Capture

### 5.1 Backend Implementation (Python/FastAPI)

**File**: `app/api/v1/live_agent.py`

```python
from fastapi import APIRouter, Depends, Request, HTTPException
from sqlalchemy.orm import Session
from ...database import get_db
from ...deps.auth import get_current_user
from typing import Optional
import uuid

router = APIRouter()

def extract_tenant_domain(request: Request) -> str:
    """
    Extract tenant domain from request.
    Priority:
    1. X-Tenant-Domain header (explicit)
    2. Host header (subdomain extraction)
    3. Origin header (fallback)
    """
    # Check explicit header
    tenant = request.headers.get("x-tenant-domain")
    if tenant:
        return tenant
    
    # Extract from host header
    host = request.headers.get("host", "")
    if host:
        # Remove port if present
        host = host.split(":")[0]
        return host
    
    # Fallback to origin
    origin = request.headers.get("origin", "")
    if origin:
        # Parse domain from origin URL
        from urllib.parse import urlparse
        parsed = urlparse(origin)
        return parsed.netloc
    
    return "unknown"

@router.post("/sessions", status_code=201)
async def create_session(
    payload: dict,
    request: Request,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Create a new live agent session.
    Automatically captures tenant domain and user account.
    """
    # Auto-capture tenant domain
    tenant_domain = extract_tenant_domain(request)
    
    # Extract user info from JWT token
    user_account = current_user.get("email") or current_user.get("sub")
    user_name = current_user.get("name") or user_account
    
    # Create session with UUID
    session_id = str(uuid.uuid4())
    
    # Create session record
    session = LiveAgentSession(
        id=session_id,
        tenant_domain=tenant_domain,
        user_account=user_account,
        user_name=user_name,
        status="pending",
        metadata=payload.get("user_context", {})
    )
    db.add(session)
    
    # Create initial message if provided
    if "initial_message" in payload:
        message = LiveAgentMessage(
            session_id=session_id,
            sender_type="user",
            sender_id=user_account,
            sender_name=user_name,
            message_text=payload["initial_message"]
        )
        db.add(message)
    
    db.commit()
    
    # Notify online agents via FCM
    await notify_agents_new_session(session_id, tenant_domain, user_account)
    
    return {
        "session_id": session_id,
        "tenant_domain": tenant_domain,
        "user_account": user_account,
        "user_name": user_name,
        "status": "pending",
        "created_at": session.created_at,
        "message": "Session created. An agent will respond shortly."
    }
```

### 5.2 JWT Middleware for User Extraction

**File**: `app/deps/auth.py`

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from ..config import settings

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> dict:
    """
    Decode JWT token and extract user information.
    Expected token payload:
    {
        "sub": "user@example.com",
        "email": "user@example.com",
        "name": "John Doe",
        "role": "user",
        "exp": 1234567890
    }
    """
    token = credentials.credentials
    
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[settings.jwt_algorithm]
        )
        
        if payload.get("sub") is None and payload.get("email") is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials"
            )
        
        return payload
        
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )
```

### 5.3 Alternative: Laravel/PHP Implementation

```php
// Extract domain
$tenantDomain = request()->header('X-Tenant-Domain') 
    ?? request()->getHost() 
    ?? parse_url(request()->header('Origin'), PHP_URL_HOST);

// Extract authenticated user
$user = Auth::user();
$userAccount = $user->email;
$userName = $user->name;

// Create session
$session = LiveAgentSession::create([
    'id' => Str::uuid(),
    'tenant_domain' => $tenantDomain,
    'user_account' => $userAccount,
    'user_name' => $userName,
    'status' => 'pending',
    'metadata' => json_encode($request->input('user_context', []))
]);
```

---

## 6. Flutter Live Agent App

### 6.1 Project Setup

**1. Create Flutter Project**:
```bash
flutter create live_agent_app
cd live_agent_app
```

**2. Add Dependencies** (`pubspec.yaml`):
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # HTTP Client
  dio: ^5.4.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # Local Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Firebase Messaging
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  intl: ^0.18.1
  
  # Utilities
  uuid: ^4.2.0
  logger: ^2.0.2

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

**3. Install Dependencies**:
```bash
flutter pub get
```

---

### 6.2 Project Structure (Clean Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── api_interceptor.dart
│   ├── storage/
│   │   └── secure_storage.dart
│   └── utils/
│       ├── logger.dart
│       └── date_formatter.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── agent_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── agent.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── login_screen.dart
│   │   │   └── widgets/
│   │   │       └── login_form.dart
│   │   └── auth_feature.dart
│   │
│   ├── sessions/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── session_model.dart
│   │   │   └── repositories/
│   │   │       └── session_repository.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── sessions_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── sessions_list_screen.dart
│   │   │   └── widgets/
│   │   │       └── session_card.dart
│   │   └── sessions_feature.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── message_model.dart
│   │   │   └── repositories/
│   │   │       └── chat_repository.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── chat_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── chat_screen.dart
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart
│   │   │       └── chat_input.dart
│   │   └── chat_feature.dart
│   │
│   └── notifications/
│       ├── services/
│       │   └── fcm_service.dart
│       └── handlers/
│           └── notification_handler.dart
│
└── main.dart
```

---

### 6.3 Core Setup

#### API Constants

**File**: `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String sessionsEndpoint = '/api/v1/live-agent/sessions';
  static const String messagesEndpoint = '/api/v1/live-agent/messages';
  static const String agentStatusEndpoint = '/api/v1/live-agent/agent/status';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
```

#### Dio HTTP Client

**File**: `lib/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add JWT token to headers
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle 401 Unauthorized - redirect to login
        if (e.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt_token');
          // Navigate to login screen
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
```

---

### 6.4 Authentication Feature

#### Auth Repository

**File**: `lib/features/auth/data/repositories/auth_repository.dart`

```dart
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/agent_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorage _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<AgentModel> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          'role': 'agent',
        },
      );

      final token = response.data['access_token'];
      final agent = AgentModel.fromJson(response.data['agent']);

      // Store JWT token securely
      await _storage.write('jwt_token', token);
      await _storage.write('agent_id', agent.id);
      await _storage.write('agent_email', agent.email);

      return agent;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read('jwt_token');
    return token != null;
  }
}
```

---

### 6.5 Sessions Feature

#### Session Repository

**File**: `lib/features/sessions/data/repositories/session_repository.dart`

```dart
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/session_model.dart';

class SessionRepository {
  final DioClient _dioClient;

  SessionRepository(this._dioClient);

  Future<List<SessionModel>> getSessions({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/live-agent/sessions',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'per_page': perPage,
        },
      );

      final sessions = (response.data['sessions'] as List)
          .map((json) => SessionModel.fromJson(json))
          .toList();

      return sessions;
    } catch (e) {
      throw Exception('Failed to fetch sessions: $e');
    }
  }

  Future<SessionModel> getSessionDetails(String sessionId) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/live-agent/sessions/$sessionId',
      );

      return SessionModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch session details: $e');
    }
  }

  Future<void> assignSession(String sessionId, String agentId, String agentName) async {
    await _dioClient.dio.put(
      '/api/v1/live-agent/sessions/$sessionId/status',
      data: {
        'status': 'active',
        'assigned_agent_id': agentId,
        'assigned_agent_name': agentName,
      },
    );
  }

  Future<void> closeSession(String sessionId) async {
    await _dioClient.dio.put(
      '/api/v1/live-agent/sessions/$sessionId/status',
      data: {'status': 'resolved'},
    );
  }
}
```

---

### 6.6 Chat Feature

#### Chat Repository

**File**: `lib/features/chat/data/repositories/chat_repository.dart`

```dart
import '../../../../core/network/dio_client.dart';
import '../models/message_model.dart';

class ChatRepository {
  final DioClient _dioClient;

  ChatRepository(this._dioClient);

  Future<List<MessageModel>> getMessages(String sessionId, {bool markAsRead = true}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/live-agent/messages/$sessionId',
        queryParameters: {
          'mark_as_read': markAsRead,
        },
      );

      final messages = (response.data['messages'] as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      return messages;
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<MessageModel> sendMessage(String sessionId, String messageText) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/live-agent/messages',
        data: {
          'session_id': sessionId,
          'message_text': messageText,
          'sender_type': 'agent',
        },
      );

      return MessageModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
```

---

### 6.7 Firebase Cloud Messaging Setup

#### FCM Service

**File**: `lib/features/notifications/services/fcm_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DioClient _dioClient;
  final SecureStorage _storage;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FCMService(this._dioClient, this._storage);

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      await _storage.write('fcm_token', token);
      await _updateAgentStatus(token, true);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      await _storage.write('fcm_token', newToken);
      await _updateAgentStatus(newToken, true);
    });

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _updateAgentStatus(String fcmToken, bool isOnline) async {
    try {
      await _dioClient.dio.put(
        '/api/v1/live-agent/agent/status',
        data: {
          'is_online': isOnline,
          'fcm_token': fcmToken,
        },
      );
    } catch (e) {
      print('Failed to update agent status: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.data}');
    
    // Show local notification
    _showLocalNotification(message);
    
    // Handle different notification types
    final type = message.data['type'];
    if (type == 'new_session') {
      // Refresh sessions list
    } else if (type == 'new_message') {
      // Update chat if open
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    final sessionId = message.data['session_id'];
    
    if (type == 'new_session' || type == 'new_message') {
      // Navigate to chat screen
      // Navigator.push(...);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'live_agent_channel',
      'Live Agent',
      channelDescription: 'Live agent notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      details,
    );
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    final fcmToken = await _storage.read('fcm_token');
    if (fcmToken != null) {
      await _updateAgentStatus(fcmToken, isOnline);
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.data}');
}
```

---

### 6.8 UI Screens

#### Sessions List Screen

**File**: `lib/features/sessions/presentation/screens/sessions_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionsListScreen extends ConsumerWidget {
  const SessionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Agent Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh sessions
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh sessions
        },
        child: ListView.builder(
          itemCount: 10, // Replace with actual count
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text('U${index + 1}'),
                ),
                title: Text('User ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('tenant${index + 1}.example.com'),
                    const SizedBox(height: 4),
                    Text(
                      'Last message: 5 minutes ago',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Badge(
                  label: const Text('2'),
                  child: const Icon(Icons.message),
                ),
                onTap: () {
                  // Navigate to chat screen
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle online status
        },
        child: const Icon(Icons.power_settings_new),
      ),
    );
  }
}
```

#### Chat Screen

**File**: `lib/features/chat/presentation/screens/chat_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ChatScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('John Doe'),
            Text(
              'tenant1.example.com',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Close session dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: 10, // Replace with actual messages
              itemBuilder: (context, index) {
                final isAgent = index % 2 == 0;
                return Align(
                  alignment: isAgent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAgent ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAgent ? 'You' : 'John Doe',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Message $index'),
                        const SizedBox(height: 4),
                        Text(
                          '10:${index.toString().padLeft(2, '0')} AM',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Send message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 7. Notification Workflow

### 7.1 FCM Payload Structure

#### New Session Notification

```json
{
  "notification": {
    "title": "New Live Agent Request",
    "body": "User from tenant1.example.com needs assistance"
  },
  "data": {
    "type": "new_session",
    "session_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "tenant_domain": "tenant1.example.com",
    "user_account": "john.doe@example.com",
    "user_name": "John Doe",
    "message_preview": "I need help with invoice generation"
  }
}
```

#### New Message Notification

```json
{
  "notification": {
    "title": "New message from John Doe",
    "body": "Can you help me with the payment issue?"
  },
  "data": {
    "type": "new_message",
    "session_id": "a1b2c3d4-...",
    "sender_type": "user",
    "sender_name": "John Doe",
    "message_text": "Can you help me with the payment issue?"
  }
}
```

### 7.2 Backend FCM Integration

**File**: `app/services/fcm.py`

```python
import httpx
from typing import List, Optional
from ..config import settings
from loguru import logger

class FCMService:
    def __init__(self):
        self.server_key = settings.fcm_server_key
        self.fcm_url = "https://fcm.googleapis.com/fcm/send"
    
    async def send_to_agents(
        self,
        title: str,
        body: str,
        data: dict,
        tokens: List[str]
    ) -> bool:
        """
        Send FCM notification to multiple agent tokens
        """
        if not tokens:
            logger.warning("No FCM tokens provided")
            return False
        
        payload = {
            "registration_ids": tokens,
            "notification": {
                "title": title,
                "body": body,
                "sound": "default",
                "badge": "1"
            },
            "data": data,
            "priority": "high"
        }
        
        headers = {
            "Authorization": f"key={self.server_key}",
            "Content-Type": "application/json"
        }
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    self.fcm_url,
                    json=payload,
                    headers=headers,
                    timeout=30
                )
                
                if response.status_code == 200:
                    logger.info(f"FCM sent to {len(tokens)} agents")
                    return True
                else:
                    logger.error(f"FCM failed: {response.status_code} - {response.text}")
                    return False
                    
        except Exception as e:
            logger.error(f"FCM error: {e}")
            return False
    
    async def notify_new_session(
        self,
        session_id: str,
        tenant_domain: str,
        user_account: str,
        user_name: str,
        message_preview: str
    ):
        """
        Notify all online agents about new session
        """
        from ..models.live_agent_profile import LiveAgentProfile
        from ..database import get_db_context
        
        # Get all online agents' FCM tokens
        with get_db_context() as db:
            agents = db.query(LiveAgentProfile).filter(
                LiveAgentProfile.is_online == True,
                LiveAgentProfile.fcm_token.isnot(None)
            ).all()
            
            tokens = [agent.fcm_token for agent in agents]
        
        if not tokens:
            logger.warning("No online agents to notify")
            return
        
        await self.send_to_agents(
            title="New Live Agent Request",
            body=f"User from {tenant_domain} needs assistance",
            data={
                "type": "new_session",
                "session_id": session_id,
                "tenant_domain": tenant_domain,
                "user_account": user_account,
                "user_name": user_name,
                "message_preview": message_preview
            },
            tokens=tokens
        )
    
    async def notify_new_message(
        self,
        session_id: str,
        recipient_fcm_token: str,
        sender_name: str,
        message_text: str
    ):
        """
        Notify specific recipient about new message
        """
        await self.send_to_agents(
            title=f"New message from {sender_name}",
            body=message_text[:100],
            data={
                "type": "new_message",
                "session_id": session_id,
                "sender_name": sender_name,
                "message_text": message_text
            },
            tokens=[recipient_fcm_token]
        )
```

---

## 8. Security

### 8.1 JWT Authentication

**Token Structure**:
```json
{
  "sub": "agent@example.com",
  "email": "agent@example.com",
  "name": "Agent Smith",
  "role": "agent",
  "iat": 1234567890,
  "exp": 1234571490
}
```

**Token Generation** (Backend):
```python
from jose import jwt
from datetime import datetime, timedelta
from ..config import settings

def create_access_token(user_email: str, user_name: str, role: str) -> str:
    payload = {
        "sub": user_email,
        "email": user_email,
        "name": user_name,
        "role": role,
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=24)
    }
    
    token = jwt.encode(
        payload,
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm
    )
    
    return token
```

### 8.2 Tenant Isolation

**Validation Logic**:
```python
def validate_tenant_access(session: LiveAgentSession, request_tenant: str):
    """
    Ensure users can only access sessions from their tenant
    """
    if session.tenant_domain != request_tenant:
        raise HTTPException(
            status_code=403,
            detail="Access denied: tenant mismatch"
        )
```

### 8.3 Flutter Secure Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

### 8.4 HTTPS & CSRF Protection

- **Always use HTTPS** in production
- Enable CORS with specific origins
- Implement CSRF tokens for state-changing operations
- Validate all inputs (XSS prevention)

---

## 9. Testing & Deployment

### 9.1 Local Development Setup

**1. Backend Setup**:
```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export FCM_SERVER_KEY="your_fcm_server_key"
export JWT_SECRET="your_secret_key"

# Run migrations
alembic upgrade head

# Start server
uvicorn app.main:app --reload --port 8000
```

**2. Flutter App Setup**:
```bash
# Install dependencies
flutter pub get

# Run code generation (for Hive)
flutter packages pub run build_runner build

# Run app
flutter run
```

### 9.2 Testing Scenarios

**Test 1: Create Session from ERP**
```bash
curl -X POST http://localhost:8000/api/v1/live-agent/sessions \
  -H "Authorization: Bearer USER_JWT_TOKEN" \
  -H "X-Tenant-Domain: tenant1.example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "initial_message": "I need help with invoices",
    "user_context": {"page": "/invoices"}
  }'
```

**Test 2: Agent Receives Notification**
- Start Flutter app
- Login as agent
- Create session from step 1
- Verify FCM notification received

**Test 3: Send Message**
```bash
curl -X POST http://localhost:8000/api/v1/live-agent/messages \
  -H "Authorization: Bearer AGENT_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "SESSION_ID",
    "message_text": "How can I help you?",
    "sender_type": "agent"
  }'
```

**Test 4: Message Persistence**
- Logout and login again
- Verify previous messages still visible
- Check unread count updates

### 9.3 Flutter Build & Release

**Android**:
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Sign and upload to Play Store
```

**iOS**:
```bash
# Build IPA
flutter build ipa --release

# Upload to App Store via Xcode
```

---

## 10. Future Enhancements

### 10.1 Planned Features

- **Agent Presence Tracking**: Real-time online/offline status
- **Chat Reassignment**: Transfer sessions between agents
- **Supervisor Dashboard**: Monitor all sessions, metrics
- **Analytics**: Response times, satisfaction ratings
- **File Attachments**: Send images, documents
- **Voice Messages**: Audio message support
- **Chat Templates**: Quick responses for common issues
- **Auto-Assignment**: Smart routing based on agent load
- **Multi-language**: Support for multiple languages
- **WebSocket**: Real-time bidirectional communication

### 10.2 Scalability Considerations

- Use Redis for session caching
- Implement message queue (RabbitMQ/Kafka)
- Database read replicas for high load
- CDN for static assets
- Load balancing for API servers
- Horizontal scaling with Kubernetes

---

## Conclusion

This guide provides a **complete roadmap** for implementing a production-ready, multi-tenant Live Agent system with Flutter mobile app integration. Follow the implementation steps, test thoroughly, and iterate based on user feedback.

For questions or issues, refer to the backend logs and Flutter debug console.

**Happy Coding! 🚀**
