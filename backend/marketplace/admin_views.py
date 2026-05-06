"""
Admin-only API views.
All views require both IsAuthenticated AND IsAdminUser.
This provides server-side enforcement — Flutter's client-side GoRouter
redirect is a UX convenience, NOT a security boundary.
"""
import logging
from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.response import Response
from django.contrib.auth.models import User

from .models import Product, Auction, Conversation, Notification, UserAgent
from .serializers import (
    ProductListSerializer, AuctionSerializer,
    ConversationListSerializer, UserAgentSerializer,
    NotificationSerializer, UserSerializer,
)

logger = logging.getLogger(__name__)


class AdminProductViewSet(viewsets.ModelViewSet):
    """Admin-only product management. Full CRUD on all products."""
    queryset = Product.objects.select_related('owner').prefetch_related('images')
    serializer_class = ProductListSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class AdminAuctionViewSet(viewsets.ModelViewSet):
    """Admin-only auction management."""
    queryset = Auction.objects.select_related('product', 'highest_bidder')
    serializer_class = AuctionSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


class AdminUserViewSet(viewsets.ReadOnlyModelViewSet):
    """Admin-only user listing."""
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminUser])
def admin_stats(request):
    """Admin dashboard stats — server-side guarded."""
    return Response({
        'total_products': Product.objects.count(),
        'total_auctions': Auction.objects.count(),
        'total_users': User.objects.count(),
        'total_conversations': Conversation.objects.count(),
        'total_agents': UserAgent.objects.count(),
        'total_notifications': Notification.objects.count(),
    })
