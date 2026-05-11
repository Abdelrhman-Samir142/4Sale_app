"""
Node 1: Intent Router
Classifies the query with ZERO LLM tokens.
Also extracts entities (location, price, category, product).
"""

import logging
from langsmith import traceable
from rag.graph.state import AgentState
from rag.intent_router import classify_intent, extract_entities

logger = logging.getLogger(__name__)


@traceable(name="Intent Router (Zero-LLM)", run_type="chain")
def router_node(state: AgentState) -> dict:
    """
    Classify query intent and extract search entities.
    No LLM call — pure regex + keyword matching.
    """
    query = state["query"]

    intent, intent_response, next_step = classify_intent(query)

    entities = {}
    if next_step == "retrieval":
        entities = extract_entities(query)

    logger.info(
        f"[RouterNode] intent={intent} | next_step={next_step} | "
        f"entities={entities}"
    )

    return {
        "intent": intent,
        "intent_response": intent_response,
        "next_step": next_step,
        "entities": entities,
        "metadata": {
            **(state.get("metadata") or {}),
            "intent": intent,
        },
    }
