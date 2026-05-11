"""
Node: Instant Response
Packages pre-built responses for greeting / faq / chitchat intents.
Zero tokens — no LLM call needed.
"""

import logging
from rag.graph.state import AgentState

logger = logging.getLogger(__name__)


def instant_response_node(state: AgentState) -> dict:
    """
    Return the pre-built response from the intent router directly.
    No retrieval, no LLM, no tokens spent.
    """
    intent = state.get("intent", "greeting")
    response_text = state.get("intent_response", "أهلاً! ازاي أقدر أساعدك؟")

    logger.info(f"[InstantResponse] Returning instant response for intent={intent}")

    return {
        "final_response": {
            "summary": response_text,
            "items": [],
            "suggested_action": "view_listing",
        },
        "products_data": [],
        "fused_results": [],
    }
