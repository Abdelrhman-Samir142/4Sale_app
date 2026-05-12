"""
YOLO-based image classifier for product categorization.
Uses a custom YOLOv11 model (best.pt) to detect objects in product images
and map them to marketplace categories.
"""

import os
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

# Path to the YOLO model
MODEL_PATH = Path(__file__).resolve().parent.parent.parent / 'ai' / 'best.pt'

# Map detected YOLO class names → Arabic category labels
# NOTE: Variants like food_trip / "Food trip" and wardrobe / "Wardrobe" are ALL mapped.
CATEGORY_MAP = {
    # ─── أثاث وديكور (Furniture & Decor) ───
    'bed': 'أثاث وديكور',
    'chair': 'أثاث وديكور',
    'cabinet': 'أثاث وديكور',
    'cupboard': 'أثاث وديكور',
    'curtain': 'أثاث وديكور',
    'lamp': 'أثاث وديكور',
    'mirror': 'أثاث وديكور',
    'sofa': 'أثاث وديكور',
    'table': 'أثاث وديكور',
    'wardrobe': 'أثاث وديكور',
    'Wardrobe': 'أثاث وديكور',
    'Dressing Table': 'أثاث وديكور',
    'food_trip': 'أثاث وديكور',
    'Food trip': 'أثاث وديكور',
    'safe': 'أثاث وديكور',
    'office': 'أثاث وديكور',

    # ─── الكترونيات واجهزه (Electronics & Devices) ───
    'laptop': 'الكترونيات واجهزه',
    'computer': 'الكترونيات واجهزه',
    'mobile_phone': 'الكترونيات واجهزه',
    'phone': 'الكترونيات واجهزه',
    'tv': 'الكترونيات واجهزه',
    'camera': 'الكترونيات واجهزه',
    'headphone': 'الكترونيات واجهزه',
    'airpods': 'الكترونيات واجهزه',
    'speaker': 'الكترونيات واجهزه',
    'receiver': 'الكترونيات واجهزه',
    'router': 'الكترونيات واجهزه',
    'printer': 'الكترونيات واجهزه',
    'keyboard': 'الكترونيات واجهزه',
    'watch': 'الكترونيات واجهزه',
    'controller': 'الكترونيات واجهزه',
    'ps_console': 'الكترونيات واجهزه',
    'pc_case': 'الكترونيات واجهزه',

    # ─── أجهزة منزلية (Home Appliances) ───
    'washing_machine': 'أجهزة منزلية',
    'fridge': 'أجهزة منزلية',
    'refrigerator': 'أجهزة منزلية',
    'cooker': 'أجهزة منزلية',
    'stove': 'أجهزة منزلية',
    'microwave': 'أجهزة منزلية',
    'blender': 'أجهزة منزلية',
    'ac_unit': 'أجهزة منزلية',
    'fan': 'أجهزة منزلية',
    'heater': 'أجهزة منزلية',
    'water_heater': 'أجهزة منزلية',
    'iron': 'أجهزة منزلية',
    'vacuum_cleaner': 'أجهزة منزلية',
    'vacuum cleaner': 'أجهزة منزلية',
    'water_filter': 'أجهزة منزلية',
    'gas_cylinder': 'أجهزة منزلية',
    'gas_bottle': 'أجهزة منزلية',
    'freighter': 'أجهزة منزلية',

    # ─── خورده ومعادن (Scrap & Metals) ───
    'korda': 'خورده ومعادن',
    'scrap_metal': 'خورده ومعادن',
    'copper_wire': 'خورده ومعادن',
    'wire': 'خورده ومعادن',
    'aluminum': 'خورده ومعادن',
    'equipment': 'خورده ومعادن',
    'mator': 'خورده ومعادن',

    # ─── سيارات للبيع (Cars) ───
    'car': 'سيارات للبيع',

    # ─── عقارات (Real Estate) ───
    'building': 'عقارات',

    # ─── كتب (Books) ───
    'book': 'كتب',
}

# Build case-insensitive lookup (lowercase key → original Arabic label)
_CATEGORY_MAP_LOWER = {k.lower(): v for k, v in CATEGORY_MAP.items()}

# Map Arabic category labels → Django model category IDs
ARABIC_TO_CATEGORY_ID = {
    'أثاث وديكور': 'furniture',
    'الكترونيات واجهزه': 'electronics',
    'أجهزة منزلية': 'appliances',
    'خورده ومعادن': 'scrap_metals',
    'سيارات للبيع': 'cars',
    'عقارات': 'real_estate',
    'كتب': 'books',
    'أخرى': 'other',
}

# Human-readable Arabic labels for YOLO classes (for agent target dropdown)
YOLO_CLASS_LABELS = {
    # أثاث
    'bed': 'سرير', 'chair': 'كرسي', 'cabinet': 'خزانة',
    'cupboard': 'دولاب', 'curtain': 'ستارة', 'lamp': 'لمبة / أباجورة',
    'mirror': 'مرآة', 'sofa': 'كنبة', 'table': 'طاولة / ترابيزة',
    'wardrobe': 'دولاب ملابس', 'Wardrobe': 'دولاب ملابس',
    'Dressing Table': 'تسريحة', 'food_trip': 'سفرة', 'Food trip': 'سفرة',
    'safe': 'خزنة',
    # الكترونيات
    'laptop': 'لابتوب', 'computer': 'كمبيوتر',
    'mobile_phone': 'موبايل', 'phone': 'موبايل',
    'tv': 'تلفزيون', 'camera': 'كاميرا',
    'headphone': 'سماعات', 'airpods': 'سماعات إيربودز',
    'speaker': 'سبيكر', 'receiver': 'رسيفر',
    'router': 'راوتر', 'printer': 'طابعة',
    'keyboard': 'كيبورد', 'watch': 'ساعة',
    'controller': 'دراعة تحكم', 'ps_console': 'بلايستيشن',
    'pc_case': 'كيسة كمبيوتر',
    # أجهزة منزلية
    'washing_machine': 'غسالة', 'fridge': 'ثلاجة', 'refrigerator': 'ثلاجة',
    'cooker': 'بوتاجاز', 'stove': 'بوتاجاز',
    'microwave': 'ميكروويف', 'blender': 'خلاط',
    'ac_unit': 'تكييف', 'fan': 'مروحة',
    'heater': 'دفاية', 'water_heater': 'سخان مياه',
    'iron': 'مكواة',
    'vacuum_cleaner': 'مكنسة كهربائية', 'vacuum cleaner': 'مكنسة كهربائية',
    'water_filter': 'فلتر مياه',
    'gas_cylinder': 'أنبوبة غاز', 'gas_bottle': 'أنبوبة غاز',
    'freighter': 'ديب فريزر',
    # خردة
    'korda': 'خردة', 'scrap_metal': 'خردة معادن',
    'copper_wire': 'سلك نحاس', 'wire': 'سلك',
    'aluminum': 'ألومنيوم', 'equipment': 'معدات', 'mator': 'موتور',
    # سيارات
    'car': 'سيارة',
    # عقارات
    'building': 'مبنى', 'office': 'مكتب / أوفيس',
    # كتب
    'book': 'كتاب',
}


def get_available_targets():
    """
    Return a list of all YOLO classes the agent can target,
    grouped by their Arabic category, for the frontend dropdown.
    Deduplicates variant names (e.g. wardrobe/Wardrobe → one entry).
    """
    targets = []
    seen = set()  # track lowercase keys to avoid duplicates
    for class_name, arabic_category in CATEGORY_MAP.items():
        key = class_name.lower().replace(' ', '_')
        if key in seen:
            continue
        seen.add(key)
        label = YOLO_CLASS_LABELS.get(class_name, class_name)
        targets.append({
            'id': class_name,
            'label': f"{label} ({arabic_category})",
            'label_ar': label,
            'category': arabic_category,
        })
    return targets


# Lazy-loaded model instance
_model = None

def _normalize_arabic(text: str) -> str:
    """Normalize Arabic text for fuzzy matching: taa marbuta, alef, etc."""
    if not text:
        return ""
    t = text
    t = t.replace('ة', 'ه')      # taa marbuta → haa
    t = t.replace('أ', 'ا')      # alef hamza above → alef
    t = t.replace('إ', 'ا')      # alef hamza below → alef
    t = t.replace('آ', 'ا')      # alef madda → alef
    t = t.replace('ى', 'ي')      # alef maqsura → yaa
    t = t.replace('ؤ', 'و')      # waw hamza → waw
    t = t.replace('ئ', 'ي')      # yaa hamza → yaa
    return t.strip()

# Direct keyword → YOLO class mapping (covers common Egyptian Arabic)
_KEYWORD_MAP = {
    # Appliances
    'غساله': 'washing_machine', 'غسال': 'washing_machine', 'اوتوماتيك': 'washing_machine',
    'ثلاجه': 'fridge', 'تلاجه': 'fridge',
    'بوتاجاز': 'cooker', 'فرن': 'cooker',
    'ميكروويف': 'microwave',
    'خلاط': 'blender',
    'تكييف': 'ac_unit', 'تكيف': 'ac_unit',
    'مروحه': 'fan',
    'دفايه': 'heater', 'سخان': 'water_heater',
    'مكواه': 'iron', 'مكنسه': 'vacuum_cleaner',
    'فلتر': 'water_filter', 'ديب فريزر': 'freighter',
    # Electronics (product types first, brands last)
    'تلفزيون': 'tv', 'شاشه': 'tv', 'تليفزيون': 'tv',
    'لابتوب': 'laptop', 'لاب': 'laptop', 'كمبيوتر': 'computer',
    'موبايل': 'mobile_phone', 'تليفون': 'phone',
    'كاميرا': 'camera', 'سماعه': 'headphone', 'ايربودز': 'airpods',
    'سبيكر': 'speaker', 'رسيفر': 'receiver', 'راوتر': 'router',
    'طابعه': 'printer', 'برنتر': 'printer',
    'ساعه': 'watch', 'بلايستيشن': 'ps_console', 'ps': 'ps_console',
    'كيسه': 'pc_case',
    'ايفون': 'phone', 'سامسونج': 'phone',  # brands last
    # Furniture
    'سرير': 'bed', 'كرسي': 'chair', 'كنبه': 'sofa', 'انتريه': 'sofa',
    'طاوله': 'table', 'ترابيزه': 'table', 'مكتب': 'office',
    'دولاب': 'wardrobe', 'خزنه': 'safe', 'خزانه': 'cabinet',
    'ستاره': 'curtain', 'مرايه': 'mirror', 'نجفه': 'lamp', 'اباجوره': 'lamp',
    'سفره': 'food_trip', 'تسريحه': 'Dressing Table',
    # Cars / Real Estate / Books
    'عربيه': 'car', 'سياره': 'car',
    'شقه': 'building', 'عقار': 'building',
    'كتاب': 'book',
    # Scrap
    'خرده': 'korda', 'نحاس': 'copper_wire', 'المنيوم': 'aluminum', 'موتور': 'mator',
}


def guess_item_from_text(text: str) -> str:
    """
    Fallback: If YOLO fails or HF space is down, guess the class from the product title.
    Uses normalized Arabic matching to handle taa marbuta / alef variants.
    """
    if not text:
        return None

    text_norm = _normalize_arabic(text.lower())

    # 1. Check the direct keyword map (normalized)
    for keyword, yolo_class in _KEYWORD_MAP.items():
        if _normalize_arabic(keyword) in text_norm:
            logger.info(f"[TextGuess] Matched keyword '{keyword}' → '{yolo_class}' in '{text}'")
            return yolo_class

    # 2. Check English keys from CATEGORY_MAP
    text_lower = text.lower()
    for key in CATEGORY_MAP.keys():
        if key.lower() in text_lower:
            return key

    # 3. Check Arabic YOLO labels (normalized)
    for key, ar_label in YOLO_CLASS_LABELS.items():
        labels = [l.strip() for l in ar_label.split('/')]
        for label in labels:
            if label and _normalize_arabic(label) in text_norm:
                logger.info(f"[TextGuess] Matched label '{label}' → '{key}' in '{text}'")
                return key

    return None

def _lookup_category(class_name: str):
    """Case-insensitive category lookup. Returns Arabic label or None."""
    # Try exact match first
    if class_name in CATEGORY_MAP:
        return CATEGORY_MAP[class_name]
    # Try case-insensitive
    return _CATEGORY_MAP_LOWER.get(class_name.lower())


def classify_image(image_path: str) -> dict:
    """
    Run inference on an image via an external Hugging Face Space API.
    Uses direct HTTP requests to the Gradio REST API for maximum compatibility.
    """
    import requests
    import base64
    import json
    import mimetypes

    fallback = {
        'category': 'other',
        'category_label': 'أخرى',
        'confidence': 0.0,
        'detected_class': None,
    }

    # Default HF Space URL - hardcoded as fallback
    DEFAULT_HF_URL = "https://omarh353111-khorda-yolo.hf.space"

    hf_space_url = os.getenv("HF_SPACE_URL", "").strip().rstrip("/")

    # If not set or invalid, use the hardcoded default
    if not hf_space_url:
        hf_space_url = DEFAULT_HF_URL
    # Auto-convert Space ID format (e.g. "Omarh353111/khorda_yolo") to full URL
    elif not hf_space_url.startswith("http"):
        hf_space_url = "https://" + hf_space_url.replace("/", "-").replace("_", "-").lower() + ".hf.space"

    print(f"[AI] 🔗 Using HF Space URL: {hf_space_url}")

    is_url = image_path.startswith("http://") or image_path.startswith("https://")

    try:
        # ── Step 1: Get image data ready ──
        if is_url:
            # For Cloudinary URLs, we can pass the URL directly to Gradio
            # No need to upload - Gradio 6.x accepts URLs in the data payload
            image_data = {
                "url": image_path,
                "meta": {"_type": "gradio.FileData"}
            }
            print(f"[AI] 📤 Sending image URL directly: {image_path[:80]}...")
        else:
            # For local files, upload to the HF Space first
            upload_url = f"{hf_space_url}/gradio_api/upload"
            
            with open(image_path, "rb") as f:
                img_bytes = f.read()
            filename = os.path.basename(image_path)
            mime_type = mimetypes.guess_type(filename)[0] or "image/jpeg"
            
            upload_resp = requests.post(
                upload_url,
                files={"files": (filename, img_bytes, mime_type)},
                timeout=60,
            )
            upload_resp.raise_for_status()
            uploaded_files = upload_resp.json()
            
            if not uploaded_files or len(uploaded_files) == 0:
                logger.error("HF Space upload returned empty result")
                return fallback
            
            uploaded_path = uploaded_files[0]
            print(f"[AI] 📤 Uploaded to HF Space: {uploaded_path}")
            image_data = {
                "path": uploaded_path,
                "meta": {"_type": "gradio.FileData"}
            }

        # ── Step 2: Call the /gradio_api/call/predict endpoint ──
        predict_url = f"{hf_space_url}/gradio_api/call/predict"
        payload = {"data": [image_data]}

        predict_resp = requests.post(
            predict_url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=120,
        )
        predict_resp.raise_for_status()
        event_id_json = predict_resp.json()
        event_id = event_id_json.get("event_id")
        
        if not event_id:
            logger.error(f"No event_id in response: {event_id_json}")
            return fallback
        
        print(f"[AI] 🎫 Got event_id: {event_id}")

        # ── Step 3: Get result from event stream ──
        result_url = f"{hf_space_url}/gradio_api/call/predict/{event_id}"
        result_resp = requests.get(result_url, timeout=120, stream=True)
        result_resp.raise_for_status()
        
        # Parse SSE (Server-Sent Events) response
        result_data = None
        for line in result_resp.iter_lines(decode_unicode=True):
            if not line:
                continue
            if line.startswith("data:"):
                data_str = line[5:].strip()
                try:
                    result_data = json.loads(data_str)
                except json.JSONDecodeError:
                    continue

        if not result_data:
            logger.error("No result data received from HF Space SSE stream")
            return fallback

        print(f"[AI] 📥 HF Space raw response: {json.dumps(result_data, ensure_ascii=False)[:500]}")

        # ── Step 4: Extract the class name from response ──
        # Gradio returns [output1, output2, ...] in the SSE data
        data = result_data if isinstance(result_data, list) else result_data.get("data", [result_data])
        
        best_class = "other"
        if len(data) >= 2:
            # outputs=[gr.Image, gr.Text] -> data[1] is the text
            raw_val = data[1]
            best_class = str(raw_val).strip() if not isinstance(raw_val, dict) else "other"
        elif len(data) == 1:
            raw_val = data[0]
            best_class = str(raw_val).strip() if not isinstance(raw_val, dict) else "other"

        print(f"[AI] 🔍 Hugging Face API returned YOLO class: '{best_class}'")

        # ── Step 5: Normalize and Validate ──
        # Standardize to lowercase and underscores for reliable matching
        normalized_class = best_class.lower().replace(' ', '_')
        
        # Try to find the canonical key in our map
        canonical_key = None
        for k in CATEGORY_MAP.keys():
            if k.lower().replace(' ', '_') == normalized_class:
                canonical_key = k
                break
        
        if not canonical_key:
            # Try fuzzy match if exact normalized match fails
            for k in CATEGORY_MAP.keys():
                if k.lower() in normalized_class or normalized_class in k.lower():
                    canonical_key = k
                    break
        
        if not canonical_key:
            logger.warning(f"Unknown class predicted and couldn't normalize: {best_class}")
            return fallback

        best_class = canonical_key
        arabic_label = CATEGORY_MAP[best_class]
        category_id = ARABIC_TO_CATEGORY_ID.get(arabic_label, 'other')
        print(f"[AI] ✅ Normalized Result: '{best_class}' → '{arabic_label}' ({category_id})")

        return {
            'category': category_id,
            'category_label': arabic_label,
            'confidence': 0.95,
            'detected_class': best_class,
            'detected_class_ar': YOLO_CLASS_LABELS.get(best_class, best_class),
        }

    except requests.exceptions.Timeout:
        logger.error("HF Space request timed out - Space may be sleeping")
        return fallback
    except requests.exceptions.HTTPError as e:
        logger.error(f"HF Space HTTP error: {e.response.status_code} - {e.response.text[:200]}")
        return fallback
    except Exception as e:
        logger.error(f"Hugging Face inference error: {e}")
        import traceback
        traceback.print_exc()
        return fallback

