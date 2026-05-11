"""
Node 5: Synthesis + Guardrails
Groq LLM synthesis with:
  - Hallucination filter (removes fabricated product IDs)
  - Self-correction loop (retry once if items empty but results exist)
  - Suggested action logic
  - Full product card builder (images, price, seller)
"""

import json
import logging
from langsmith import traceable
from openai import RateLimitError
from rag.graph.state import AgentState, SynthesisOutput
from rag.graph.config import groq_pool

logger = logging.getLogger(__name__)

SYNTHESIS_SYSTEM = """أنت مساعد ذكي لـ 4Sale — منصة بيع وشراء المستعمل والخردة في مصر.

مهمتك: تلخيص نتائج البحث للمستخدم بأسلوب ودي وعامي مصري.

القواعد الصارمة:
1. رد بالعامية المصرية فقط (مش فصحى).
2. لا تخترع معلومات — استخدم فقط البيانات الموجودة.
3. لو المنتج في مزاد (AUCTION) وضح ده.
4. الملخص 2-3 جمل بحد أقصى.
5. اختار الـ IDs اللي بتطابق السؤال فعلاً.
6. لو مفيش نتايج مناسبة: summary = "مش لاقي حاجة مناسبة دلوقتي، جرب تغير الكلمات أو سيب الوكيل يتابعلك." وعمل items = [].

الإجابة في JSON فقط — بدون أي نص زيادة:
{
  "summary": "ملخص بالعامية المصرية",
  "items": [قائمة بـ IDs المنتجات المناسبة],
  "suggested_action": "view_listing | place_bid | compare_prices | set_agent"
}"""


def _build_context(fused_results: list) -> str:
    """Build a readable context block from fused results for the LLM."""
    lines = []
    for item in fused_results:
        pid = item.get("id") or item.get("product_id")
        title = item.get("title", "")
        price = item.get("price", "?")
        condition = item.get("condition", "")
        location = item.get("location", "")
        is_auction = item.get("is_auction", False)
        owner = item.get("owner__username") or item.get("owner_name", "")
        source = item.get("_source", "")

        line = f"- #{pid}: {title} | {price} EGP | {condition} | {location}"
        if owner:
            line += f" | البائع: {owner}"
        if is_auction:
            line += " | 🔨 مزاد"
        if source == "both":
            line += " | ⭐ مطابقة عالية"
        lines.append(line)
    return "\n".join(lines)


def _decide_action(items: list, fused_results: list) -> str:
    """Suggest the best next action based on matched results."""
    if not items:
        return "set_agent"
    if len(items) == 1:
        return "view_listing"
    # Check if any matched item is an auction
    matched_ids = set(items)
    for doc in fused_results:
        pid = doc.get("id") or doc.get("product_id")
        if pid in matched_ids and doc.get("is_auction"):
            return "place_bid"
    if len(items) >= 3:
        return "compare_prices"
    return "view_listing"


def _build_product_cards(product_ids: list, request=None) -> list:
    """Fetch full product details and build frontend-ready cards with images."""
    from marketplace.models import Product

    if not product_ids:
        return []

    try:
        products = Product.objects.filter(
            id__in=product_ids
        ).select_related("owner", "owner__profile").prefetch_related("images")

        product_map = {p.id: p for p in products}
        cards = []

        for pid in product_ids:
            product = product_map.get(pid)
            if not product:
                continue

            # Primary image
            img = product.images.filter(is_primary=True).first() or product.images.first()
            image_url = None
            if img:
                try:
                    image_url = request.build_absolute_uri(img.image.url) if request else img.image.url
                except Exception:
                    pass

            # Trust score
            trust_score = None
            try:
                trust_score = product.owner.profile.trust_score
            except Exception:
                pass

            cards.append({
                "id": product.id,
                "title": product.title,
                "price": str(product.price),
                "category": product.category,
                "condition": product.condition,
                "status": product.status,
                "is_auction": product.is_auction,
                "location": product.location or "",
                "primary_image": image_url,
                "owner_name": product.owner.username,
                "owner_trust_score": trust_score,
                "created_at": product.created_at.isoformat(),
            })

        return cards

    except Exception as e:
        logger.error(f"[Synthesis] Product card building failed: {e}")
        return []


@traceable(name="LLM Synthesis + Guardrails (Groq)", run_type="llm")
def synthesis_node(state: AgentState, config: dict = None) -> dict:
    """
    Synthesise a final Arabic answer from fused results.

    Guardrails:
    1. Hallucination filter — remove IDs not in fused_results
    2. Self-correction — retry once if items empty but results exist
    """
    query = state["query"]
    fused_results = state.get("fused_results", [])
    retry_count = state.get("retry_count", 0)
    request = (config or {}).get("configurable", {}).get("request") if config else None

    # Valid IDs from fused results
    valid_ids = {
        int(doc.get("id") or doc.get("product_id"))
        for doc in fused_results
        if doc.get("id") or doc.get("product_id")
    }

    # Empty results shortcut
    if not fused_results:
        return {
            "final_response": {
                "summary": "مش لاقي حاجة دلوقتي بتطابق اللي بتدور عليه. جرب كلمات تانية أو سيب الوكيل يتابعلك.",
                "items": [],
                "suggested_action": "set_agent",
            },
            "products_data": [],
            "retry_count": retry_count,
        }

    context = _build_context(fused_results)
    fallback = SynthesisOutput(
        summary=f"لقيتلك {len(fused_results)} نتيجة. اتفضل شوفهم.",
        items=sorted(list(valid_ids))[:4],
        suggested_action="view_listing",
    )

    result = fallback.model_dump()

    for attempt in range(3):
        key = groq_pool.next_key()
        from openai import OpenAI
        client = OpenAI(api_key=key, base_url="https://api.groq.com/openai/v1")
        try:
            resp = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[
                    {"role": "system", "content": SYNTHESIS_SYSTEM},
                    {"role": "user", "content": f"سؤال المستخدم: {query}\n\nالنتائج:\n{context}"},
                ],
                temperature=0.3,
                max_tokens=500,
            )
            raw = resp.choices[0].message.content.strip()
            raw = raw.replace("```json", "").replace("```", "").strip()
            data = json.loads(raw)
            validated = SynthesisOutput(**data)

            # ── Guardrail 1: Hallucination filter ─────────────
            clean_ids = [i for i in validated.items if i in valid_ids]
            validated.items = clean_ids

            # ── Guardrail 2: Self-correction ───────────────────
            if not clean_ids and fused_results and retry_count < 1:
                logger.warning(
                    f"[Synthesis] Empty items after filter, triggering self-correction "
                    f"(retry {retry_count + 1})"
                )
                return {
                    "final_response": validated.model_dump(),
                    "retry_count": retry_count + 1,
                }

            # ── Enforce valid action ───────────────────────────
            if validated.suggested_action not in {
                "view_listing", "place_bid", "compare_prices", "set_agent"
            }:
                validated.suggested_action = _decide_action(clean_ids, fused_results)
            elif not clean_ids:
                validated.suggested_action = "set_agent"

            result = validated.model_dump()
            logger.info(
                f"[Synthesis] Done — items={result['items']} | "
                f"action={result['suggested_action']} | attempt={attempt + 1}"
            )
            break

        except RateLimitError:
            groq_pool.mark_rate_limited(key)
            logger.warning(f"[Synthesis] 429 on attempt {attempt + 1}, rotating key...")
        except Exception as e:
            logger.error(f"[Synthesis] Attempt {attempt + 1} failed: {e}")
            break

    # Build product cards for matched IDs
    products_data = _build_product_cards(result.get("items", []), request=request)

    return {
        "final_response": result,
        "products_data": products_data,
        "retry_count": retry_count,
    }
