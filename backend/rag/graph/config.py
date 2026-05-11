"""
Groq Key Pool + LangSmith Setup for the RAG graph.

- Round-robin across 3 Groq API keys
- 60-second cooldown on 429 rate-limit errors
- LangSmith tracing auto-configured from env vars
"""

import os
import time
import threading
import logging

logger = logging.getLogger(__name__)


# ── LangSmith Setup ────────────────────────────────────────

def setup_langsmith():
    """Configure LangSmith tracing from environment variables."""
    key = os.environ.get("LANGCHAIN_API_KEY", "").strip().strip('"').strip("'")
    if key:
        os.environ.setdefault("LANGSMITH_API_KEY", key)
        os.environ["LANGCHAIN_TRACING_V2"] = os.environ.get("LANGCHAIN_TRACING_V2", "true")
        os.environ["LANGCHAIN_PROJECT"] = os.environ.get("LANGCHAIN_PROJECT", "4Sale-RAG-LangGraph")
        logger.info(
            f"[Config] LangSmith tracing enabled  project={os.environ['LANGCHAIN_PROJECT']}"
        )
    else:
        logger.info("[Config] LangSmith disabled — set LANGCHAIN_API_KEY to enable.")


# ── Groq Key Pool ──────────────────────────────────────────

class GroqKeyPool:
    """
    Thread-safe round-robin pool for 3 Groq API keys.
    Puts a key on 60-second cooldown when it hits a 429 response.
    """

    COOLDOWN_SECONDS = 60

    def __init__(self):
        self._lock = threading.Lock()
        self._index = 0
        self._keys: list[str] = []
        self._cooldowns: dict[str, float] = {}
        self._loaded = False

    def _load(self):
        if self._loaded:
            return
        raw = [
            os.environ.get("GROQ_API_KEY", "").strip().strip('"').strip("'"),
            os.environ.get("GROQ_API_KEY_RAG", "").strip().strip('"').strip("'"),
            os.environ.get("GROQ_AGENT_API_KEY", "").strip().strip('"').strip("'"),
        ]
        self._keys = [k for k in raw if k]
        if not self._keys:
            raise RuntimeError(
                "No Groq API keys found. Set GROQ_API_KEY, GROQ_API_KEY_RAG, "
                "or GROQ_AGENT_API_KEY in your .env file."
            )
        logger.info(f"[Config] Groq key pool loaded — {len(self._keys)} key(s).")
        self._loaded = True

    def next_key(self) -> str:
        """Return the next available API key (round-robin, respecting cooldowns)."""
        with self._lock:
            self._load()
            now = time.time()
            for _ in range(len(self._keys)):
                key = self._keys[self._index % len(self._keys)]
                self._index += 1
                if now >= self._cooldowns.get(key, 0):
                    return key
            # All on cooldown — pick the one that recovers soonest
            key = min(self._keys, key=lambda k: self._cooldowns.get(k, 0))
            logger.warning("[Config] All Groq keys on cooldown — using soonest-available.")
            return key

    def mark_rate_limited(self, key: str):
        """Put a key on cooldown after a 429 error."""
        with self._lock:
            self._cooldowns[key] = time.time() + self.COOLDOWN_SECONDS
            logger.warning(
                f"[Config] Groq key ...{key[-8:]} rate-limited. "
                f"Cooldown until {time.strftime('%H:%M:%S', time.localtime(self._cooldowns[key]))}"
            )


# Global singletons
groq_pool = GroqKeyPool()
setup_langsmith()
