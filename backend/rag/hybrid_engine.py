"""
Hybrid RAG Engine (V2 - LangGraph)

Orchestrates the entire RAG pipeline using LangGraph:
1. Cache check (LRU)
2. LangGraph Agent (.invoke)
   - Zero-LLM Intent Routing
   - Follow-up logic
   - Parallel Retrieval (Vector + SQL)
   - Reciprocal Rank Fusion
   - LLM Synthesis + Guardrails
3. Cache Set
4. Logging to RAGQueryLog
"""

import time
import logging
from langchain_core.runnables import RunnableConfig

from rag.response_cache import _cache
from rag.graph.rag_graph import get_rag_agent

logger = logging.getLogger(__name__)


def rag_query(query: str, user=None, request=None, history: list = None) -> dict:
    """
    Main entry point for the API view.
    Checks cache, runs the LangGraph pipeline if needed, and logs the query.
    """
    from rag.models import RAGQueryLog

    start_time = time.time()
    user_id = user.id if user and user.is_authenticated else 0
    history = history or []
    error_msg = ""
    cache_hit = False

    # 1. Cache Check
    cached_response = _cache.get(query, user_id=user_id)
    if cached_response:
        logger.info(f"[HybridEngine] Cache hit for query: {query[:40]}")
        cache_hit = True
        final_data = cached_response
        final_data["meta"]["cache_hit"] = True
        
        # We still log the cache hit
        latency_ms = int((time.time() - start_time) * 1000)
        try:
            RAGQueryLog.objects.create(
                user=user if user and user.is_authenticated else None,
                query_text=query,
                generated_sql="-- CACHE HIT",
                sql_results_count=final_data["meta"].get("sql_results", 0),
                vector_results_count=final_data["meta"].get("vector_results", 0),
                merged_results_count=final_data["meta"].get("merged_results", 0),
                final_answer=final_data["answer"].get("summary", ""),
                latency_ms=latency_ms,
                error="",
            )
        except Exception as e:
            logger.error(f"[RAG] Logging failed: {e}")
            
        return final_data

    # 2. Run LangGraph Agent
    agent = get_rag_agent()
    
    # Setup initial state
    initial_state = {
        "query": query,
        "messages": history,
        "retry_count": 0,
        "metadata": {},
    }
    
    # Pass request object in config so synthesis node can build absolute image URLs
    config = RunnableConfig(
        configurable={"request": request}
    )

    try:
        logger.info(f"[HybridEngine] Invoking LangGraph for: {query[:40]}")
        final_state = agent.invoke(initial_state, config=config)
        
        # Extract results from state
        answer = final_state.get("final_response", {})
        products_data = final_state.get("products_data", [])
        intent = final_state.get("intent", "search")
        sql_count = final_state.get("sql_count", 0)
        vector_count = final_state.get("vector_count", 0)
        fused = final_state.get("fused_results", [])
        generated_sql = final_state.get("generated_sql", "")
        
    except Exception as e:
        logger.error(f"[HybridEngine] Graph invocation failed: {e}")
        error_msg = str(e)
        answer = {
            "summary": "حصلت مشكلة تقنية في السيرفر. جرب تاني بعد شوية.",
            "items": [],
            "suggested_action": "view_listing",
        }
        products_data = []
        intent = "error"
        sql_count = 0
        vector_count = 0
        fused = []
        generated_sql = ""

    latency_ms = int((time.time() - start_time) * 1000)

    # 3. Build Final Response
    final_data = {
        "answer": answer,
        "products_data": products_data,
        "meta": {
            "latency_ms": latency_ms,
            "sql_results": sql_count,
            "vector_results": vector_count,
            "merged_results": len(fused),
            "intent": intent,
            "cache_hit": False,
        }
    }

    # 4. Cache Set (only if successful)
    if not error_msg and intent != "error":
        _cache.set(query, final_data, user_id=user_id)

    # 5. Log to Database
    try:
        RAGQueryLog.objects.create(
            user=user if user and user.is_authenticated else None,
            query_text=query,
            generated_sql=generated_sql,
            sql_results_count=sql_count,
            vector_results_count=vector_count,
            merged_results_count=len(fused),
            final_answer=answer.get("summary", ""),
            latency_ms=latency_ms,
            error=error_msg,
        )
    except Exception as e:
        logger.error(f"[HybridEngine] Logging failed: {e}")

    return final_data
