"""LangGraph AgentState and Pydantic output schemas."""

from typing import TypedDict, Optional
from pydantic import BaseModel, Field


class AgentState(TypedDict):
    # ── Input ──────────────────────────────
    query: str
    messages: list           # conversation history [{role, content}]

    # ── Router output ──────────────────────
    intent: str              # greeting|faq|chitchat|search|follow_up
    intent_response: str     # pre-built response for instant intents
    next_step: str           # instant|followup|retrieval

    # ── Entity extraction ──────────────────
    entities: dict           # {product, price_min, price_max, location, category}

    # ── Retrieval outputs ──────────────────
    vector_results: list
    sql_results: list
    generated_sql: str
    vector_count: int
    sql_count: int

    # ── Fusion output ──────────────────────
    fused_results: list      # RRF-merged, top-8

    # ── Synthesis output ───────────────────
    final_response: dict     # {summary, items, suggested_action}
    products_data: list      # full product cards (with images)

    # ── Control flow ───────────────────────
    retry_count: int
    metadata: dict


class SynthesisOutput(BaseModel):
    """Structured output schema for the synthesis LLM call."""
    summary: str = Field(
        description="Egyptian Arabic (3ammeya) summary of search results, 2-3 sentences max."
    )
    items: list[int] = Field(
        description="List of product IDs from the results that match the query. Must be real IDs."
    )
    suggested_action: str = Field(
        description="One of: view_listing, place_bid, compare_prices, set_agent"
    )
