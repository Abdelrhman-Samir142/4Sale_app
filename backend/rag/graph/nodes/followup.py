"""
Node: Follow-Up
LLM-powered response using conversation history.
No retrieval — answers based on context from previous turns.
Uses Groq key rotation for resilience.
"""

import json
import logging
from langsmith import traceable
from openai import RateLimitError
from rag.graph.state import AgentState, SynthesisOutput
from rag.graph.config import groq_pool

logger = logging.getLogger(__name__)

FOLLOWUP_SYSTEM = """أنت مساعد ذكي لـ 4Sale — منصة بيع وشراء المستعمل في مصر.

مهمتك: الرد على سؤال المستخدم بناءً على سياق المحادثة السابقة.

القواعد:
1. رد بالعربية العامية المصرية.
2. استخدم فقط المعلومات الموجودة في سياق المحادثة.
3. لو مش قادر تجاوب، قول "مش فاهم قصدك، ممكن توضح أكتر؟"
4. الرد يكون موجز وواضح.

الرد في JSON فقط:
{
  "summary": "الرد بالعربية العامية",
  "items": [],
  "suggested_action": "view_listing"
}"""

_FALLBACK = SynthesisOutput(
    summary="مش فاهم قصدك كويس. ممكن توضح أكتر أو تسألني عن منتج معين؟",
    items=[],
    suggested_action="view_listing",
)


@traceable(name="Follow-Up LLM (Groq)", run_type="llm")
def followup_node(state: AgentState) -> dict:
    """
    Answer follow-up questions using conversation history.
    Tries all Groq keys in rotation on 429 errors.
    """
    query = state["query"]
    messages = state.get("messages", [])

    # Build context from last 3 messages
    history_text = ""
    for msg in messages[-3:]:
        role = "المستخدم" if msg.get("role") == "user" else "المساعد"
        history_text += f"{role}: {msg.get('content', '')}\n"

    user_message = f"السياق:\n{history_text}\nالسؤال الجديد: {query}"

    result = _FALLBACK.model_dump()
    last_err = None

    for attempt in range(3):
        key = groq_pool.next_key()
        from openai import OpenAI
        client = OpenAI(api_key=key, base_url="https://api.groq.com/openai/v1")
        try:
            resp = client.chat.completions.create(
                model="llama-3.3-70b-versatile",
                messages=[
                    {"role": "system", "content": FOLLOWUP_SYSTEM},
                    {"role": "user", "content": user_message},
                ],
                temperature=0.3,
                max_tokens=400,
            )
            raw = resp.choices[0].message.content.strip()
            raw = raw.replace("```json", "").replace("```", "").strip()
            data = json.loads(raw)
            validated = SynthesisOutput(**data)
            result = validated.model_dump()
            logger.info(f"[Followup] Answered on attempt {attempt + 1}")
            break
        except RateLimitError:
            groq_pool.mark_rate_limited(key)
            last_err = "RateLimitError"
        except Exception as e:
            last_err = str(e)
            logger.warning(f"[Followup] Attempt {attempt + 1} failed: {e}")
            break

    if last_err and result == _FALLBACK.model_dump():
        logger.error(f"[Followup] All attempts failed: {last_err}")

    return {
        "final_response": result,
        "products_data": [],
        "fused_results": [],
    }
