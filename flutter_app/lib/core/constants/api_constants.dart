/// All API endpoint paths matching the Django REST backend.
class ApiConstants {
  ApiConstants._();

  // ── Base URL ──────────────────────────────────────────────────
  // Override at build time: flutter run --dart-define=API_BASE_URL=https://your-domain.com/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://4-sale-i4pb4pu1p-abdelrhman-samir142s-projects.vercel.app/api/v1',
  );

  // ── Auth ──────────────────────────────────────────────────────
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String refreshToken = '/auth/refresh/';
  static const String currentUser = '/auth/me/';

  // ── Categories ────────────────────────────────────────────────
  static const String categories = '/categories/';

  // ── Products ──────────────────────────────────────────────────
  static const String products = '/products/';
  static String productDetail(String id) => '/products/$id/';
  static const String myListings = '/products/my_listings/';
  static String aiAnalysis(String id) => '/products/$id/ai_analysis/';

  // ── Auctions ──────────────────────────────────────────────────
  static const String auctions = '/auctions/';
  static String auctionDetail(String id) => '/auctions/$id/';
  static String placeBid(String id) => '/auctions/$id/place_bid/';

  // ── Profiles ──────────────────────────────────────────────────
  static const String profileMe = '/profiles/me/';

  // ── Conversations / Chat ──────────────────────────────────────
  static const String conversations = '/conversations/';
  static String conversationDetail(int id) => '/conversations/$id/';
  static const String startConversation = '/conversations/start_conversation/';
  static String sendMessage(int id) => '/conversations/$id/send_message/';
  static const String unreadCount = '/conversations/unread_count/';
  static String deleteConversation(int id) =>
      '/conversations/$id/delete_conversation/';
  static String deleteMessage(int convId, int msgId) =>
      '/conversations/$convId/delete_message/$msgId/';
  static String editMessage(int convId, int msgId) =>
      '/conversations/$convId/edit_message/$msgId/';

  // ── Wishlist ──────────────────────────────────────────────────
  static const String wishlist = '/wishlist/';
  static const String wishlistIds = '/wishlist/ids/';
  static String wishlistToggle(int productId) =>
      '/wishlist/toggle/$productId/';
  static String wishlistCheck(int productId) =>
      '/wishlist/check/$productId/';

  // ── AI classification ─────────────────────────────────────────
  static const String classifyImage = '/classify-image/';

  // ── AI Agent ──────────────────────────────────────────────────
  static const String agents = '/agents/';
  static String agentDetail(int id) => '/agents/$id/';
  static const String agentTargets = '/agent-targets/';

  // ── Notifications ─────────────────────────────────────────────
  static const String notifications = '/notifications/';
  static const String notificationsMarkRead = '/notifications/mark-read/';
  static const String notificationsUnreadCount = '/notifications/unread-count/';

  // ── General Stats ─────────────────────────────────────────────
  static const String generalStats = '/general-stats/';

  // ── RAG Smart Search ──────────────────────────────────────────
  static const String ragQuery = '/rag/query/';
}
