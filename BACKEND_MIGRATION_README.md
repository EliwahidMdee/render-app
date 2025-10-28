# Live Agent Backend - Database Migrations

This directory contains the FastAPI backend code and Alembic database migrations for the Live Agent system.

## Issue Fixed

The error:
```
(pymysql.err.OperationalError) (1054, "Unknown column 'live_agent_messages.delivered_at' in 'field list'")
```

was caused by the database schema missing the `delivered_at` and `read_at` columns that the SQLAlchemy model was trying to query.

## Solution

Created proper database migrations that include all required columns:

### live_agent_messages table columns:
- `id` - Primary key (auto-increment)
- `session_id` - Foreign key to live_agent_sessions
- `sender_type` - 'user' or 'agent'
- `sender_id` - Sender identifier
- `sender_name` - Display name
- `message_text` - The actual message content
- `created_at` - Timestamp when message was created
- `read_by_user` - Boolean flag
- `read_by_agent` - Boolean flag
- **`delivered_at`** - Timestamp when message was delivered (NEW)
- **`read_at`** - Timestamp when message was read (NEW)
- `message_metadata` - JSON field for additional data

## How to Use

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Database Connection

Edit `alembic.ini` and update the database URL:

```ini
sqlalchemy.url = mysql+pymysql://user:password@host:port/database_name
```

**⚠️ Security Note:** Use environment variables for production credentials. Never commit actual passwords to version control.

Or use environment variable in your application.

### 3. Run Migrations

```bash
# Initialize the database with all tables
alembic upgrade head

# Or run migrations one by one
alembic upgrade 001_create_sessions
alembic upgrade 002_create_messages
```

### 4. Verify Migrations

```bash
# Check current migration version
alembic current

# View migration history
alembic history
```

## Migration Files

1. **001_create_sessions.py** - Creates the `live_agent_sessions` table
2. **002_create_messages.py** - Creates the `live_agent_messages` table with all required columns including `delivered_at` and `read_at`

## Rollback

To rollback migrations:

```bash
# Rollback one migration
alembic downgrade -1

# Rollback to specific version
alembic downgrade 001_create_sessions

# Rollback all migrations
alembic downgrade base
```

## Models

The SQLAlchemy models are defined in:
- `app/models/live_agent_session.py` - Session model
- `app/models/live_agent_message.py` - Message model with delivered_at and read_at columns

These models are now consistent with the database schema defined in the migrations.
