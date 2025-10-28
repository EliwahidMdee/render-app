"""
SQLAlchemy model for Live Agent Sessions
"""
from sqlalchemy import Column, String, Integer, DateTime, Boolean, JSON, Index
from sqlalchemy.sql import func
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class LiveAgentSession(Base):
    """Live Agent Session model"""
    __tablename__ = 'live_agent_sessions'
    
    id = Column(String(36), primary_key=True)  # UUID
    tenant_domain = Column(String(255), nullable=False, index=True)
    user_account = Column(String(255), nullable=False, index=True)
    user_name = Column(String(255))
    assigned_agent_id = Column(Integer, index=True)
    assigned_agent_name = Column(String(255))
    status = Column(String(20), default='pending', index=True)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)
    last_message_at = Column(DateTime)
    unread_count_user = Column(Integer, default=0)
    unread_count_agent = Column(Integer, default=0)
    session_metadata = Column('metadata', JSON)  # Renamed to avoid SQLAlchemy reserved word
    
    __table_args__ = (
        Index('idx_tenant_domain', 'tenant_domain'),
        Index('idx_user_account', 'user_account'),
        Index('idx_status', 'status'),
        Index('idx_assigned_agent', 'assigned_agent_id'),
    )
