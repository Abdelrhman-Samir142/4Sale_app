"""
LRU Response Cache for the RAG pipeline.
- Max 100 entries
- 10-minute TTL
- Arabic-normalized cache keys
- Thread-safe
"""

import hashlib
import re
import time
import threading
import logging

logger = logging.getLogger(__name__)


class RAGResponseCache:
    def __init__(self, max_size: int = 100, ttl: int = 600):
        self._max_size = max_size
        self._ttl = ttl
        self._cache: dict = {}         # key → {value, expires_at}
        self._order: list = []         # LRU order (oldest first)
        self._lock = threading.Lock()

    def _normalize(self, text: str) -> str:
        """Normalize Arabic query for consistent cache keys."""
        text = text.strip().lower()
        # Normalize Arabic chars
        text = re.sub(r'[إأآا]', 'ا', text)
        text = re.sub(r'ى', 'ي', text)
        text = re.sub(r'ة', 'ه', text)
        text = re.sub(r'\s+', ' ', text)
        return text

    def _make_key(self, query: str, user_id: int = 0) -> str:
        normalized = self._normalize(query)
        raw = f"{user_id}:{normalized}"
        return hashlib.md5(raw.encode('utf-8')).hexdigest()

    def get(self, query: str, user_id: int = 0):
        key = self._make_key(query, user_id)
        with self._lock:
            entry = self._cache.get(key)
            if entry is None:
                return None
            if time.time() > entry['expires_at']:
                # Expired
                self._cache.pop(key, None)
                if key in self._order:
                    self._order.remove(key)
                return None
            # Move to end (most recently used)
            if key in self._order:
                self._order.remove(key)
            self._order.append(key)
            logger.debug(f"[Cache] HIT for key {key[:8]}...")
            return entry['value']

    def set(self, query: str, value, user_id: int = 0):
        key = self._make_key(query, user_id)
        with self._lock:
            # Evict LRU if at capacity
            while len(self._cache) >= self._max_size and self._order:
                oldest = self._order.pop(0)
                self._cache.pop(oldest, None)
                logger.debug(f"[Cache] Evicted LRU entry {oldest[:8]}...")
            self._cache[key] = {
                'value': value,
                'expires_at': time.time() + self._ttl,
            }
            if key in self._order:
                self._order.remove(key)
            self._order.append(key)
            logger.debug(f"[Cache] SET key {key[:8]}...")

    def invalidate_all(self):
        with self._lock:
            self._cache.clear()
            self._order.clear()
            logger.info("[Cache] Invalidated all entries.")

    def stats(self) -> dict:
        with self._lock:
            return {
                "size": len(self._cache),
                "max_size": self._max_size,
                "ttl_seconds": self._ttl,
            }


# Global singleton
_cache = RAGResponseCache()
