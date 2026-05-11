"""
Zero-LLM Intent Router — classifies Arabic queries without spending any tokens.

Priority order:
  1. greeting     → instant_response
  2. faq          → instant_response
  3. chitchat     → instant_response
  4. search       → retrieval pipeline
  5. follow_up    → followup LLM node
  6. (fallback)   → retrieval pipeline
"""

import re
import logging

logger = logging.getLogger(__name__)

# ── Greeting patterns ──────────────────────────────────────
_GREETING = re.compile(
    r'(^|\s)(هاي|هاى|هلو|hello|hi\b|ازيك|عامل ايه|ايه الاخبار|صباح|مساء|السلام|مرحبا|اهلا|اهلين|يسلم|تحياتي|هلا)',
    re.IGNORECASE
)

# ── FAQ patterns ───────────────────────────────────────────
_FAQ = re.compile(
    r'(ازاي (ابيع|اشتري|اعمل)|كيف (ابيع|اشتري|اضع)|'
    r'انت (مين|ايه|اه)|ايه (ده|دا|هو)|ما هو|'
    r'شرح|وضح|افهم|قواعد|شروط|سياسة|privacy|كيف يعمل|'
    r'طريقة البيع|طريقة الشراء|كيفية البيع|كيفية الشراء)',
    re.IGNORECASE
)

# ── Chitchat patterns ──────────────────────────────────────
_CHITCHAT = re.compile(
    r'^(شكرا|شكراً|تسلم|ربنا يخليك|جميل|ممتاز|رائع|'
    r'باي|وداعا|مع السلامة|اوك|اوكي|ok|okay|يلا|تمام|'
    r'حلو|كويس|عظيم|بالتوفيق|يسلم ايدك)[\s!،.]*$',
    re.IGNORECASE
)

# ── Follow-up patterns ─────────────────────────────────────
_FOLLOWUP = re.compile(
    r'(سعره|سعرها|سعرهم|كام|قد ايه|'
    r'ارخص|الارخص|اغلى|الاغلى|'
    r'تاني|غيره|بديل|مقارنة|'
    r'في فين|فين موجود|'
    r'الاول|التاني|ده|دي|دول|هو|هي|هم)',
    re.IGNORECASE
)

# ── Search keywords (product terms) ───────────────────────
_SEARCH_KEYWORDS = [
    # Electronics
    'موبايل', 'تليفون', 'ايفون', 'سامسونج', 'شاومي', 'لابتوب', 'كمبيوتر',
    'تلفزيون', 'شاشة', 'تكييف', 'مكيف', 'غسالة', 'تلاجة', 'فريزر',
    'ميكروويف', 'بوتاجاز', 'سخان', 'هوت', 'هيتر', 'كاميرا', 'تابلت',
    'ايباد', 'ساعة', 'سماعة', 'طابعة', 'راوتر', 'ps4', 'ps5', 'بلايستيشن',
    # Furniture
    'اثاث', 'كنبة', 'كنبه', 'سرير', 'دولاب', 'خزانة', 'مكتب', 'كرسي',
    'طاولة', 'نضيفة', 'ديوان', 'سجادة', 'ستارة', 'لمبة', 'انتيكا',
    # Cars & Transport
    'عربية', 'سيارة', 'موتوسيكل', 'دراجة', 'اوتوبيس', 'نقل', 'شاحنة',
    # Scrap & Metals
    'خردة', 'خرده', 'حديد', 'نحاس', 'الومنيوم', 'بلاستيك', 'كرتون',
    'بطارية', 'محركات', 'موتور', 'كمبروسر',
    # Clothes
    'ملابس', 'هدوم', 'جاكيت', 'بنطلون', 'فستان', 'شنطة',
    # Tools
    'ادوات', 'عدة', 'مثقاب', 'ماكينة', 'كومبروسر', 'ونش',
    # Real Estate
    'شقة', 'شقه', 'منزل', 'بيت', 'محل', 'ارض', 'فيلا',
    # Books & Misc
    'كتاب', 'مجلة', 'العاب', 'لعبة', 'آلة موسيقية', 'بيانو', 'جيتار',
    # General buying intent
    'بدور', 'عايز', 'محتاج', 'ابحث', 'اجيب', 'اشتري', 'لقيت',
    'متاح', 'رخيص', 'زي الجديد', 'فرصة', 'لقطة', 'اوكازيون',
]
_SEARCH_KEYWORDS_SET = set(k.lower() for k in _SEARCH_KEYWORDS)


# ── FAQ pre-built responses ────────────────────────────────
_FAQ_RESPONSES = {
    'sell': (
        '🛍️ عشان تبيع، اضغط على "بيع" من الشاشة الرئيسية، '
        'حط صورة المنتج وهيتصنف تلقائياً بالذكاء الاصطناعي!'
    ),
    'buy': (
        '🛒 للشراء، دور على المنتج اللي عايزه، '
        'ابعت للبائع أو اشتري مباشرة، أو استخدم نظام المزايدة للمزادات!'
    ),
    'about': (
        '🏪 أنا مساعد 4Sale الذكي — منصة بيع وشراء المستعمل والخردة في مصر. '
        'بساعدك تلاقي المنتج اللي بتدور عليه!'
    ),
    'agent': (
        '🤖 الوكيل الذكي بيتابعلك المزادات ويزايد تلقائياً لما يلاقي '
        'المنتج اللي بيناسبك بالسعر اللي إنت تحدده!'
    ),
    'default': (
        '❓ ممكن توضح سؤالك أكتر؟ أنا هنا أساعدك تلاقي '
        'أي منتج مستعمل أو خردة في مصر!'
    ),
}

# ── Greeting responses ─────────────────────────────────────
_GREETING_RESPONSES = [
    '👋 أهلاً وسهلاً! أنا مساعد 4Sale الذكي. قولي بتدور على إيه؟',
    '🌟 هلا! عايز أساعدك تلاقي أفضل المنتجات المستعملة. ايه اللي بتدور عليه؟',
    '😊 أهلاً! اسأل عن أي منتج وهدور في كل المنتجات عشان ألاقيلك أنسب واحد.',
]

# ── Chitchat responses ─────────────────────────────────────
_CHITCHAT_RESPONSES = [
    '😊 على الرحب! لو احتجت أي حاجة تاني أنا هنا.',
    '🙏 يسلم! في أي وقت تحتاج مساعدة، ابعتلي.',
    '👍 عظيم! قولي لو عايز تدور على أي حاجة.',
]


# ── Entity Extraction ──────────────────────────────────────

_EGYPTIAN_CITIES = [
    'القاهرة', 'الجيزة', 'الاسكندرية', 'اسكندرية', 'الاسماعيلية',
    'بورسعيد', 'السويس', 'المنصورة', 'طنطا', 'الزقازيق', 'اسيوط',
    'اسوان', 'قنا', 'سوهاج', 'الفيوم', 'المنيا', 'بني سويف',
    'دمياط', 'شبرا', 'مدينة نصر', 'مصر الجديدة', 'المعادي', 'الدقي',
    'الهرم', 'امبابة', 'بولاق', 'التجمع', 'الشروق', 'السادس من اكتوبر',
    'المقطم', 'عين شمس', 'المطرية', 'حلوان', 'الرحاب', 'مدينتي',
    'الشيخ زايد', 'العبور', 'العاشر من رمضان',
]
_LOCATION_RE = re.compile(
    r'(' + '|'.join(re.escape(c) for c in _EGYPTIAN_CITIES) + r')',
    re.IGNORECASE
)

_PRICE_PATTERNS = [
    # "أقل من X" / "تحت X"
    (re.compile(r'(اقل من|تحت|مش اكتر من|ما يتعداش)\s*(\d[\d,\.]*)', re.IGNORECASE),
     lambda m: {'price_max': _to_num(m.group(2))}),
    # "أكتر من X" / "فوق X"
    (re.compile(r'(اكتر من|فوق|ما يقلش عن|من)\s*(\d[\d,\.]*)', re.IGNORECASE),
     lambda m: {'price_min': _to_num(m.group(2))}),
    # "من X لـ Y"
    (re.compile(r'من\s*(\d[\d,\.]*)\s*(ل|لحد|الي|الى|حتى)\s*(\d[\d,\.]*)', re.IGNORECASE),
     lambda m: {'price_min': _to_num(m.group(1)), 'price_max': _to_num(m.group(3))}),
    # "X جنيه" / "X ج"
    (re.compile(r'(\d[\d,\.]*)\s*(جنيه|ج\b|EGP|egp)', re.IGNORECASE),
     lambda m: {'price_max': _to_num(m.group(1))}),
]

_CATEGORY_MAP = {
    'electronics': ['موبايل', 'تليفون', 'لابتوب', 'كمبيوتر', 'شاشة', 'تلفزيون',
                    'تكييف', 'مكيف', 'غسالة', 'تلاجة', 'كاميرا', 'تابلت', 'سماعة'],
    'furniture': ['اثاث', 'كنبة', 'سرير', 'دولاب', 'مكتب', 'كرسي', 'طاولة'],
    'cars': ['عربية', 'سيارة', 'موتوسيكل', 'دراجة'],
    'scrap_metals': ['خردة', 'حديد', 'نحاس', 'الومنيوم', 'بطارية', 'محركات'],
    'books': ['كتاب', 'مجلة', 'كتب'],
}


def _to_num(s: str) -> float:
    return float(s.replace(',', '').replace('.', ''))


def _extract_price(text: str) -> dict:
    for pattern, extractor in _PRICE_PATTERNS:
        m = pattern.search(text)
        if m:
            return extractor(m)
    return {}


def _extract_location(text: str) -> str | None:
    m = _LOCATION_RE.search(text)
    return m.group(0) if m else None


def _extract_category(text: str) -> str | None:
    lower = text.lower()
    for cat, keywords in _CATEGORY_MAP.items():
        for kw in keywords:
            if kw in lower:
                return cat
    return None


def extract_entities(query: str) -> dict:
    """Extract price, location, category, and product term from query."""
    entities: dict = {}

    price = _extract_price(query)
    entities.update(price)

    loc = _extract_location(query)
    if loc:
        entities['location'] = loc

    cat = _extract_category(query)
    if cat:
        entities['category'] = cat

    # Product term: remove filler words and extracted entities
    product_q = query
    for filler in ['عايز', 'بدور على', 'محتاج', 'ابحث عن', 'هات', 'اجيب', 'في', 'بـ', 'من']:
        product_q = product_q.replace(filler, '')
    if loc:
        product_q = product_q.replace(loc, '')
    entities['product'] = product_q.strip()

    return entities


# ── Main Classifier ────────────────────────────────────────

def classify_intent(query: str) -> tuple[str, str, str]:
    """
    Classify the user's query without any LLM call.

    Returns:
        (intent, pre_built_response, next_step)
        next_step is one of: 'instant' | 'followup' | 'retrieval'
    """
    import random

    q = query.strip()

    # 1. Greeting
    if _GREETING.search(q):
        response = random.choice(_GREETING_RESPONSES)
        logger.debug(f"[Router] Intent=greeting for: {q[:40]}")
        return 'greeting', response, 'instant'

    # 2. FAQ
    if _FAQ.search(q):
        if any(w in q for w in ['ابيع', 'بيع']):
            response = _FAQ_RESPONSES['sell']
        elif any(w in q for w in ['اشتري', 'شراء']):
            response = _FAQ_RESPONSES['buy']
        elif any(w in q for w in ['انت مين', 'الوكيل']):
            response = _FAQ_RESPONSES['agent']
        elif any(w in q for w in ['انت', 'مين']):
            response = _FAQ_RESPONSES['about']
        else:
            response = _FAQ_RESPONSES['default']
        logger.debug(f"[Router] Intent=faq for: {q[:40]}")
        return 'faq', response, 'instant'

    # 3. Chitchat
    if _CHITCHAT.search(q):
        response = random.choice(_CHITCHAT_RESPONSES)
        logger.debug(f"[Router] Intent=chitchat for: {q[:40]}")
        return 'chitchat', response, 'instant'

    # 4. Search (check keywords)
    q_lower = q.lower()
    for kw in _SEARCH_KEYWORDS_SET:
        if kw in q_lower:
            logger.debug(f"[Router] Intent=search (keyword: {kw}) for: {q[:40]}")
            return 'search', '', 'retrieval'

    # 5. Follow-up
    if _FOLLOWUP.search(q):
        logger.debug(f"[Router] Intent=follow_up for: {q[:40]}")
        return 'follow_up', '', 'followup'

    # 6. Fallback → search
    logger.debug(f"[Router] Intent=search (fallback) for: {q[:40]}")
    return 'search', '', 'retrieval'
