"""
Node 4: RRF Fusion
Merges vector and SQL results using Reciprocal Rank Fusion.

Formula: RRF_score(doc) = Σ 1 / (k + rank_in_list)   where k=60

If a product appears in BOTH tracks, its scores add up (boosted).
SQL results carry seller JOIN data and are used for the final card.
Output: top-8 fused results for synthesis.
"""

import logging
from langsmith import traceable
from rag.graph.state import AgentState

logger = logging.getLogger(__name__)

RRF_K = 60
TOP_N = 8


@traceable(name="RRF Fusion", run_type="chain")
def rrf_fusion_node(state: AgentState) -> dict:
    """
    Merge vector and SQL results with Reciprocal Rank Fusion.
    Products in both tracks get a score boost.
    """
    sql_results = state.get("sql_results", [])
    vector_results = state.get("vector_results", [])

    if not sql_results and not vector_results:
        return {"fused_results": []}

    # ── Compute RRF scores ─────────────────────────────────
    scores: dict[int, float] = {}
    doc_map: dict[int, dict] = {}   # prefer SQL docs (they have seller info)

    for rank, item in enumerate(sql_results):
        pid = int(item.get("id") or item.get("product_id") or 0)
        if not pid:
            continue
        scores[pid] = scores.get(pid, 0.0) + 1.0 / (RRF_K + rank + 1)
        if pid not in doc_map:
            doc_map[pid] = {**item, "_source": "sql"}

    for rank, item in enumerate(vector_results):
        pid = int(item.get("product_id") or item.get("id") or 0)
        if not pid:
            continue
        scores[pid] = scores.get(pid, 0.0) + 1.0 / (RRF_K + rank + 1)
        if pid not in doc_map:
            doc_map[pid] = {**item, "_source": "vector"}
        else:
            # Mark as appearing in both tracks
            doc_map[pid]["_source"] = "both"

    # ── Sort by RRF score ──────────────────────────────────
    sorted_ids = sorted(scores.keys(), key=lambda pid: scores[pid], reverse=True)
    fused = []
    for pid in sorted_ids[:TOP_N]:
        doc = doc_map[pid]
        doc["_rrf_score"] = round(scores[pid], 6)
        fused.append(doc)

    logger.info(
        f"[RRF] Fused {len(fused)} results "
        f"from sql={len(sql_results)}, vector={len(vector_results)}"
    )

    # Log top results for debugging
    for i, doc in enumerate(fused[:3]):
        pid = doc.get("id") or doc.get("product_id")
        logger.debug(
            f"  #{i+1} pid={pid} | rrf={doc['_rrf_score']:.4f} | "
            f"source={doc.get('_source')} | title={str(doc.get('title', ''))[:40]}"
        )

    return {"fused_results": fused}
