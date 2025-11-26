# services/session_store.py

from typing import Dict, Any

class SessionStore:
    """
    Simple in-memory session manager.
    You may later replace with Redis, Firestore, or DB.
    """

    def __init__(self):
        self.sessions: Dict[str, Dict[str, Any]] = {}

    def get(self, session_id: str) -> Dict[str, Any]:
        """Return session or create new."""
        if session_id not in self.sessions:
            self.sessions[session_id] = {
                "last_crop": None,
                "last_env": None,
                "partial_args": None,
                "fertilizer_ready": False,
                "last_location": None,
            }
        return self.sessions[session_id]

    def save(self, session_id: str, session_data: Dict[str, Any]):
        """Save entire session."""
        self.sessions[session_id] = session_data

    def clear(self, session_id: str):
        if session_id in self.sessions:
            del self.sessions[session_id]


# global store instance
session_store = SessionStore()
