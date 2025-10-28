"""Create live_agent_sessions table

Revision ID: 001_create_sessions
Revises: 
Create Date: 2025-10-28 17:18:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '001_create_sessions'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Create live_agent_sessions table"""
    op.create_table(
        'live_agent_sessions',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('tenant_domain', sa.String(255), nullable=False),
        sa.Column('user_account', sa.String(255), nullable=False),
        sa.Column('user_name', sa.String(255)),
        sa.Column('assigned_agent_id', sa.Integer()),
        sa.Column('assigned_agent_name', sa.String(255)),
        sa.Column('status', sa.String(20), server_default='pending'),
        sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.func.now(), onupdate=sa.func.now(), nullable=False),
        sa.Column('last_message_at', sa.DateTime()),
        sa.Column('unread_count_user', sa.Integer(), server_default='0'),
        sa.Column('unread_count_agent', sa.Integer(), server_default='0'),
        sa.Column('metadata', sa.JSON()),
    )
    
    # Create indexes
    op.create_index('idx_tenant_domain', 'live_agent_sessions', ['tenant_domain'])
    op.create_index('idx_user_account', 'live_agent_sessions', ['user_account'])
    op.create_index('idx_status', 'live_agent_sessions', ['status'])
    op.create_index('idx_assigned_agent', 'live_agent_sessions', ['assigned_agent_id'])


def downgrade() -> None:
    """Drop live_agent_sessions table"""
    op.drop_index('idx_assigned_agent', table_name='live_agent_sessions')
    op.drop_index('idx_status', table_name='live_agent_sessions')
    op.drop_index('idx_user_account', table_name='live_agent_sessions')
    op.drop_index('idx_tenant_domain', table_name='live_agent_sessions')
    op.drop_table('live_agent_sessions')
