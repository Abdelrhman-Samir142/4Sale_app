"""
RAG API Views.
Made graceful: returns a clean error if RAG dependencies are missing.
"""

import logging
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status

logger = logging.getLogger(__name__)

# Lazy import — RAG engine requires openai, google-generativeai, etc.
_rag_available = True
try:
    from rag.hybrid_engine import rag_query
except ImportError:
    _rag_available = False
    logger.warning("[RAG] Dependencies not installed — RAG search disabled")


@api_view(['POST'])
@permission_classes([AllowAny])
def rag_query_view(request):
    """
    POST /api/rag/query/
    """
    if not _rag_available:
        return Response(
            {"error": "RAG search غير متاح حالياً (مطلوب تثبيت openai + google-generativeai)"},
            status=status.HTTP_503_SERVICE_UNAVAILABLE
        )

    query = request.data.get('query', '').strip()

    if not query:
        return Response(
            {"error": "الرجاء إدخال سؤال أو كلمة بحث."},
            status=status.HTTP_400_BAD_REQUEST
        )

    if len(query) > 500:
        return Response(
            {"error": "السؤال طويل أوي. حاول تختصر شوية."},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        result = rag_query(query, user=request.user)
        return Response(result, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"[RAG/View] Unexpected error: {e}")
        return Response(
            {"error": "حصلت مشكلة في السيرفر. جرب تاني."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
