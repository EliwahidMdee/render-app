"""
Validation script to verify the database migrations include all required columns
"""
import sys
from sqlalchemy import create_engine, inspect, MetaData
from app.models.live_agent_message import LiveAgentMessage
from app.models.live_agent_session import LiveAgentSession


def validate_message_model():
    """Validate that the LiveAgentMessage model has all required columns"""
    print("Validating LiveAgentMessage model...")
    
    required_columns = {
        'id': 'INTEGER',
        'session_id': 'VARCHAR',
        'sender_type': 'VARCHAR',
        'sender_id': 'VARCHAR',
        'sender_name': 'VARCHAR',
        'message_text': 'TEXT',
        'created_at': 'DATETIME',
        'read_by_user': 'BOOLEAN',
        'read_by_agent': 'BOOLEAN',
        'delivered_at': 'DATETIME',  # This was missing!
        'read_at': 'DATETIME',  # This was missing!
        'message_metadata': 'JSON'
    }
    
    # Get model columns
    model_columns = LiveAgentMessage.__table__.columns
    
    missing_columns = []
    for col_name in required_columns:
        if col_name not in model_columns:
            missing_columns.append(col_name)
    
    if missing_columns:
        print(f"❌ FAILED: Missing columns: {', '.join(missing_columns)}")
        return False
    
    # Specifically check for the columns that were causing the error
    if 'delivered_at' in model_columns and 'read_at' in model_columns:
        print("✅ SUCCESS: Both 'delivered_at' and 'read_at' columns are present in the model")
    else:
        print("❌ FAILED: 'delivered_at' or 'read_at' columns are missing")
        return False
    
    # List all columns
    print("\nAll columns in LiveAgentMessage model:")
    for col in model_columns:
        print(f"  - {col.name}: {col.type}")
    
    return True


def validate_session_model():
    """Validate that the LiveAgentSession model has all required columns"""
    print("\n\nValidating LiveAgentSession model...")
    
    required_columns = {
        'id', 'tenant_domain', 'user_account', 'user_name',
        'assigned_agent_id', 'assigned_agent_name', 'status',
        'created_at', 'updated_at', 'last_message_at',
        'unread_count_user', 'unread_count_agent', 'metadata'
    }
    
    # Get model columns
    model_columns = set(LiveAgentSession.__table__.columns.keys())
    
    missing_columns = required_columns - model_columns
    
    if missing_columns:
        print(f"❌ FAILED: Missing columns: {', '.join(missing_columns)}")
        return False
    
    print("✅ SUCCESS: All required columns are present in the model")
    
    # List all columns
    print("\nAll columns in LiveAgentSession model:")
    for col in LiveAgentSession.__table__.columns:
        print(f"  - {col.name}: {col.type}")
    
    return True


if __name__ == "__main__":
    print("="*70)
    print("DATABASE MODEL VALIDATION")
    print("="*70)
    
    message_valid = validate_message_model()
    session_valid = validate_session_model()
    
    print("\n" + "="*70)
    print("VALIDATION SUMMARY")
    print("="*70)
    
    if message_valid and session_valid:
        print("✅ ALL VALIDATIONS PASSED")
        print("\nThe models now include all required columns, including:")
        print("  - delivered_at (fixes the error)")
        print("  - read_at (fixes the error)")
        print("  - message_metadata")
        print("\nYou can now run the migrations to create the database tables:")
        print("  alembic upgrade head")
        sys.exit(0)
    else:
        print("❌ SOME VALIDATIONS FAILED")
        sys.exit(1)
