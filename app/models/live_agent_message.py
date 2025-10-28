"""
SQLAlchemy model for Live Agent Messages
"""
from sqlalchemy import Column, String, Integer, DateTime, Boolean, JSON, ForeignKey, Index, Text
from sqlalchemy.sql import func
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class LiveAgentMessage(Base):
    """Live Agent Message model"""
    __tablename__ = 'live_agent_messages'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String(36), ForeignKey('live_agent_sessions.id', ondelete='CASCADE'), nullable=False, index=True)
    sender_type = Column(String(10), nullable=False)  # 'user' or 'agent'
    sender_id = Column(String(255))
    sender_name = Column(String(255))
    message_text = Column(Text, nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False, index=True)
    read_by_user = Column(Boolean, default=False)
    read_by_agent = Column(Boolean, default=False)
    delivered_at = Column(DateTime)  # When the message was delivered
    read_at = Column(DateTime)  # When the message was read
    message_metadata = Column(JSON)  # Additional metadata for the message
    
    __table_args__ = (
        Index('idx_session_id', 'session_id'),
        Index('idx_created_at', 'created_at'),
    )
