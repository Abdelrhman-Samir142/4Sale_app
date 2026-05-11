"""
Nodes 2 & 3: Parallel Retrieval
Runs Gemini vector search + Groq SQL generation simultaneously.
Both wrapped as LangChain @tools so they appear as tool calls in LangSmith.
"""

import logging
from concurrent.futures import ThreadPoolExecutor, as_completed
from langchain_core.tools import tool
from langsmith import traceable
from rag.graph.state import AgentState

logger = logging.getLogger(__name__)


# ── LangChain Tools (visible in LangSmith as tool calls) ──

@tool
def vector_search_tool(query: str) -> list:
    """
    Semantically search active products using Gemini embeddings
    and cosine similarity. Returns top matches ranked by relevance.
    """
    from rag.vector_search import vector_search
    results = vector_search(query, top_k=15)
    logger.info(f"[VectorTool] Found {len(results)} results")
    return results


@tool
def sql_search_tool(query: str) -> dict:
    """
    Generate and execute a safe PostgreSQL SELECT query using Groq LLM
    to find products matching the user's Egyptian Arabic description.
    Returns matched products and the generated SQL for debugging.
    """
    from rag.sql_generator import sql_search
    results, sql = sql_search(query)
    logger.info(f"[SQLTool] Found {len(results)} rows | SQL: {sql[:80]}")
    return {"results": results, "sql": sql}


# ── Retrieval Node ─────────────────────────────────────────

@traceable(name="Parallel Retrieval (Vector + SQL)", run_type="chain")
def retrieval_node(state: AgentState) -> dict:
    """
    Fan-out: run Gemini vector search and Groq SQL generation in parallel.
    Both are LangChain tools so each call is visible in LangSmith traces.
    """
    query = state["query"]
    entities = state.get("entities", {})

    # Build enriched query for SQL (includes entity context)
    enriched = query
    if entities.get("location"):
        enriched += f" في {entities['location']}"
    if entities.get("price_max"):
        enriched += f" أقل من {entities['price_max']} جنيه"
    if entities.get("price_min"):
        enriched += f" أكتر من {entities['price_min']} جنيه"

    vector_results = []
    sql_results = []
    generated_sql = ""

    import contextvars

    with ThreadPoolExecutor(max_workers=2) as executor:
        ctx = contextvars.copy_context()
        futures = {
            executor.submit(ctx.run, vector_search_tool.invoke, {"query": query}): "vector",
            executor.submit(ctx.run, sql_search_tool.invoke, {"query": enriched}): "sql",
        }
        for future in as_completed(futures):
            track = futures[future]
            try:
                result = future.result()
                if track == "vector":
                    vector_results = result if isinstance(result, list) else []
                elif track == "sql":
                    if isinstance(result, dict):
                        sql_results = result.get("results", [])
                        generated_sql = result.get("sql", "")
                    else:
                        sql_results = []
            except Exception as e:
                logger.error(f"[Retrieval] {track} track failed: {e}")

    logger.info(
        f"[Retrieval] vector={len(vector_results)} | sql={len(sql_results)}"
    )

    return {
        "vector_results": vector_results,
        "sql_results": sql_results,
        "generated_sql": generated_sql,
        "vector_count": len(vector_results),
        "sql_count": len(sql_results),
    }
