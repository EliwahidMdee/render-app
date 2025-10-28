# Expected SQL Statements from Migrations

This document shows the SQL statements that will be executed when running the migrations.

## Migration 001: Create Sessions Table

```sql
CREATE TABLE live_agent_sessions (
    id VARCHAR(36) NOT NULL,
    tenant_domain VARCHAR(255) NOT NULL,
    user_account VARCHAR(255) NOT NULL,
    user_name VARCHAR(255),
    assigned_agent_id INTEGER,
    assigned_agent_name VARCHAR(255),
    status VARCHAR(20) DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    last_message_at DATETIME,
    unread_count_user INTEGER DEFAULT 0,
    unread_count_agent INTEGER DEFAULT 0,
    metadata JSON,
    PRIMARY KEY (id)
);

CREATE INDEX idx_tenant_domain ON live_agent_sessions (tenant_domain);
CREATE INDEX idx_user_account ON live_agent_sessions (user_account);
CREATE INDEX idx_status ON live_agent_sessions (status);
CREATE INDEX idx_assigned_agent ON live_agent_sessions (assigned_agent_id);
```

## Migration 002: Create Messages Table

```sql
CREATE TABLE live_agent_messages (
    id INTEGER NOT NULL AUTO_INCREMENT,
    session_id VARCHAR(36) NOT NULL,
    sender_type VARCHAR(10) NOT NULL,
    sender_id VARCHAR(255),
    sender_name VARCHAR(255),
    message_text TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_by_user BOOLEAN DEFAULT 0,
    read_by_agent BOOLEAN DEFAULT 0,
    delivered_at DATETIME,           -- FIXES THE ERROR
    read_at DATETIME,                -- FIXES THE ERROR
    message_metadata JSON,
    PRIMARY KEY (id),
    FOREIGN KEY (session_id) REFERENCES live_agent_sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_session_id ON live_agent_messages (session_id);
CREATE INDEX idx_created_at ON live_agent_messages (created_at);
```

## Key Points

1. **delivered_at column**: Nullable DATETIME field that should be set when a message is successfully delivered to the recipient
2. **read_at column**: Nullable DATETIME field that should be set when a message is marked as read
3. **message_metadata column**: JSON field for storing additional message-specific data

## Database Compatibility

These migrations are compatible with:
- MySQL 5.7+
- MariaDB 10.2+
- PostgreSQL 9.4+ (with minor syntax adjustments for JSON type)

For PostgreSQL, change `JSON` to `JSONB` for better performance.

## Rollback

To rollback the migrations:

```bash
# Rollback the messages table
alembic downgrade 001_create_sessions

# Rollback everything
alembic downgrade base
```

This will drop both tables in reverse order.
