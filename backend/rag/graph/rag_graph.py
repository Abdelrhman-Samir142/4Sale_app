"""
RAG LangGraph Pipeline — 4Sale Marketplace

Full pipeline:
  START
    └─► router (Zero-LLM intent classifier)
          ├─► instant_response → END   (greeting / faq / chitchat — 0 tokens)
          ├─► followup → END           (follow-up with history — 1 LLM call)
          └─► retrieval → fusion → synthesis ─┐
                                              ├─► END  (happy path)
                                              └─► synthesis (self-correction, max 1 retry)

All nodes traced in LangSmith under project "4Sale-RAG-LangGraph".
"""

import logging
from functools import lru_cache
from langgraph.graph import StateGraph, END, START
from langchain_core.runnables import RunnableConfig

from rag.graph.state import AgentState
from rag.graph.nodes.intent_router import router_node
from rag.graph.nodes.instant_response import instant_response_node
from rag.graph.nodes.followup import followup_node
from rag.graph.nodes.retrieval import retrieval_node
from rag.graph.nodes.rrf_fusion import rrf_fusion_node
from rag.graph.nodes.synthesis import synthesis_node

logger = logging.getLogger(__name__)


# ── Conditional Edge Functions ─────────────────────────────

def _route_after_router(state: AgentState) -> str:
    """Decide which node to go to after intent classification."""
    next_step = state.get("next_step", "retrieval")
    if next_step == "instant":
        return "instant_response"
    if next_step == "followup":
        return "followup"
    return "retrieval"


def _route_after_synthesis(state: AgentState) -> str:
    """
    Self-correction loop:
    If synthesis returned empty items but there are fused results,
    and we haven't retried yet → loop back to synthesis.
    Otherwise → END.
    """
    final = state.get("final_response", {})
    items = final.get("items", [])
    fused = state.get("fused_results", [])
    retry_count = state.get("retry_count", 0)

    if not items and fused and retry_count < 1:
        logger.info("[Graph] Self-correction: looping back to synthesis.")
        return "synthesis"

    return END


# ── Synthesis node wrapper that receives config ────────────

def _synthesis_with_config(state: AgentState, config: RunnableConfig) -> dict:
    """Wrap synthesis_node to forward LangGraph's config (for request/user access)."""
    return synthesis_node(state, config=config)


# ── Graph Builder ──────────────────────────────────────────

def build_rag_graph():
    """Build and compile the 4Sale RAG LangGraph StateGraph."""
    g = StateGraph(AgentState)

    # Register nodes
    g.add_node("router", router_node)
    g.add_node("instant_response", instant_response_node)
    g.add_node("followup", followup_node)
    g.add_node("retrieval", retrieval_node)
    g.add_node("fusion", rrf_fusion_node)
    g.add_node("synthesis", _synthesis_with_config)

    # Entry point
    g.add_edge(START, "router")

    # Router → branch
    g.add_conditional_edges(
        "router",
        _route_after_router,
        {
            "instant_response": "instant_response",
            "followup": "followup",
            "retrieval": "retrieval",
        },
    )

    # Instant paths → END
    g.add_edge("instant_response", END)
    g.add_edge("followup", END)

    # Search path
    g.add_edge("retrieval", "fusion")
    g.add_edge("fusion", "synthesis")

    # Synthesis → self-correction loop or END
    g.add_conditional_edges(
        "synthesis",
        _route_after_synthesis,
        {"synthesis": "synthesis", END: END},
    )

    compiled = g.compile()
    logger.info("[Graph] 4Sale RAG LangGraph compiled successfully")
    return compiled


# ── Singleton ──────────────────────────────────────────────

@lru_cache(maxsize=1)
def get_rag_agent():
    """Return the compiled LangGraph agent (singleton)."""
    return build_rag_graph()
