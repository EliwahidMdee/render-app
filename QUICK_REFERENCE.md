# Quick Reference: Database Schema Fix

## Problem
The backend API was failing with error:
```
(pymysql.err.OperationalError) (1054, "Unknown column 'live_agent_messages.delivered_at' in 'field list'")
```

## Root Cause
The SQLAlchemy models were querying for columns `delivered_at` and `read_at` in the `live_agent_messages` table, but these columns didn't exist in the database.

## Solution
Created complete database migrations that include ALL required columns.

## live_agent_messages Table Schema

| Column Name        | Type      | Description                                |
|-------------------|-----------|-------------------------------------------|
| id                | INTEGER   | Primary key (auto-increment)              |
| session_id        | VARCHAR(36)| Foreign key to live_agent_sessions       |
| sender_type       | VARCHAR(10)| 'user' or 'agent'                        |
| sender_id         | VARCHAR(255)| Sender identifier                       |
| sender_name       | VARCHAR(255)| Display name                            |
| message_text      | TEXT      | Message content                           |
| created_at        | DATETIME  | When message was created                  |
| read_by_user      | BOOLEAN   | Read flag for user                        |
| read_by_agent     | BOOLEAN   | Read flag for agent                       |
| **delivered_at**  | DATETIME  | **When message was delivered (NEW)**      |
| **read_at**       | DATETIME  | **When message was read (NEW)**           |
| message_metadata  | JSON      | Additional metadata                       |

## How to Apply

### Step 1: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Configure Database
Edit `alembic.ini` and set your database URL:
```ini
sqlalchemy.url = mysql+pymysql://username:password@host:port/database_name
```

**⚠️ Security:** Use environment variables for production. Never commit credentials to git.

### Step 3: Run Migrations
```bash
# Apply all migrations
alembic upgrade head
```

### Step 4: Verify
```bash
# Check current version
alembic current

# This should show: 002_create_messages
```

## Verification
Run the validation script to verify models are correct:
```bash
python3 validate_models.py
```

Expected output:
```
✅ ALL VALIDATIONS PASSED
```

## Files Created
- `app/models/live_agent_session.py` - Session model
- `app/models/live_agent_message.py` - Message model (with delivered_at and read_at)
- `migrations/versions/001_create_sessions.py` - Creates sessions table
- `migrations/versions/002_create_messages.py` - Creates messages table with all columns
- `alembic.ini` - Alembic configuration
- `requirements.txt` - Python dependencies

## Important Notes
1. The `delivered_at` and `read_at` columns are nullable (can be NULL)
2. They should be updated by your API when:
   - `delivered_at`: When the message is successfully delivered to the recipient
   - `read_at`: When the message is marked as read
3. The `session_metadata` attribute in the model maps to the `metadata` column in the database (to avoid SQLAlchemy reserved word)

## Testing
After running migrations, test the API endpoint:
```bash
curl http://localhost:8000/api/v1/live-agent/sessions?page=1&per_page=20
```

This should now return successfully without the column error.
