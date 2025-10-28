"""Create live_agent_messages table with delivered_at and read_at columns

Revision ID: 002_create_messages
Revises: 001_create_sessions
Create Date: 2025-10-28 17:18:01.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '002_create_messages'
down_revision: Union[str, None] = '001_create_sessions'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Create live_agent_messages table with all required columns"""
    op.create_table(
        'live_agent_messages',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('session_id', sa.String(36), nullable=False),
        sa.Column('sender_type', sa.String(10), nullable=False),
        sa.Column('sender_id', sa.String(255)),
        sa.Column('sender_name', sa.String(255)),
        sa.Column('message_text', sa.Text(), nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
        sa.Column('read_by_user', sa.Boolean(), server_default='0'),
        sa.Column('read_by_agent', sa.Boolean(), server_default='0'),
        sa.Column('delivered_at', sa.DateTime()),  # When the message was delivered
        sa.Column('read_at', sa.DateTime()),  # When the message was read
        sa.Column('message_metadata', sa.JSON()),  # Additional metadata
        sa.ForeignKeyConstraint(['session_id'], ['live_agent_sessions.id'], ondelete='CASCADE'),
    )
    
    # Create indexes
    op.create_index('idx_session_id', 'live_agent_messages', ['session_id'])
    op.create_index('idx_created_at', 'live_agent_messages', ['created_at'])


def downgrade() -> None:
    """Drop live_agent_messages table"""
    op.drop_index('idx_created_at', table_name='live_agent_messages')
    op.drop_index('idx_session_id', table_name='live_agent_messages')
    op.drop_table('live_agent_messages')
