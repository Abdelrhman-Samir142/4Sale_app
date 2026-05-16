import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_session_service.dart';
import '../../services/rag_service.dart';

// ── Message model ─────────────────────────────────────────────────
class _Message {
  final String role; // 'user' | 'assistant'
  final String text;
  final List<dynamic> products;
  final bool isLoading;
  const _Message({
    required this.role,
    required this.text,
    this.products = const [],
    this.isLoading = false,
  });
}

// ── Main Screen ──────────────────────────────────────────────────
class SmartSearchScreen extends ConsumerStatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  ConsumerState<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends ConsumerState<SmartSearchScreen> {
  // ── State ─────────────────────────────────────────────────────
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int? _sessionId;
  List<_Message> _messages = [];
  bool _sending = false;

  // Sidebar: list of sessions
  List<Map<String, dynamic>> _sessions = [];
  bool _loadingSessions = false;

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initSession();
    _loadSessions();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Initialise a new chat session ─────────────────────────────
  Future<void> _initSession() async {
    // Check if user is logged in
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) return;

    try {
      final session = await ChatService.createSession();
      if (mounted) {
        setState(() => _sessionId = session['id'] as int?);
      }
    } catch (_) {
      // Fallback: session-less mode (use legacy endpoint)
    }
  }

  // ── Load sidebar sessions ─────────────────────────────────────
  Future<void> _loadSessions() async {
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) return;

    setState(() => _loadingSessions = true);
    try {
      final sessions = await ChatService.getSessions();
      if (mounted) setState(() => _sessions = sessions);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingSessions = false);
    }
  }

  // ── Load a specific session (history) ────────────────────────
  Future<void> _loadSession(int sessionId) async {
    try {
      final data = await ChatService.getSession(sessionId);
      final rawMessages = (data['messages'] as List?) ?? [];

      setState(() {
        _sessionId = sessionId;
        _messages = rawMessages.map((m) {
          final prods = (m['products_data'] as List?) ?? [];
          return _Message(
            role: m['role'] ?? 'user',
            text: m['content'] ?? '',
            products: prods,
          );
        }).toList();
      });
      _scrollToBottom();
      if (mounted) Navigator.of(context).pop(); // close drawer
    } catch (_) {}
  }

  // ── Delete a session ─────────────────────────────────────────
  Future<void> _deleteSession(int sessionId) async {
    try {
      await ChatService.deleteSession(sessionId);
      await _loadSessions();
      // If we deleted the active session, start fresh
      if (_sessionId == sessionId) {
        setState(() {
          _sessionId = null;
          _messages = [];
        });
        await _initSession();
      }
    } catch (_) {}
  }

  // ── Send a message ────────────────────────────────────────────
  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    HapticFeedback.lightImpact();
    _inputCtrl.clear();
    setState(() {
      _messages.add(_Message(role: 'user', text: text));
      _messages.add(const _Message(role: 'assistant', text: '', isLoading: true));
      _sending = true;
    });
    _scrollToBottom();

    try {
      Map<String, dynamic> result;
      if (_sessionId != null) {
        result = await ChatService.sendMessage(_sessionId!, text);
      } else {
        // Not logged in — use legacy stateless endpoint
        result = await RagService.query(text);
        // Wrap legacy format into session format
        result = {
          'answer': result,
          'products_data': result['products_data'] ?? [],
          'meta': {},
        };
      }

      final answer = result['answer'] as Map<String, dynamic>? ?? {};
      final summary = answer['summary'] as String? ?? 'لم أفهم السؤال. ممكن تكرره؟';
      final products = (result['products_data'] as List?) ?? [];

      setState(() {
        _messages.removeLast(); // remove loading
        _messages.add(_Message(
          role: 'assistant',
          text: summary,
          products: products,
        ));
      });

      // Refresh sessions sidebar (title may have auto-updated)
      _loadSessions();
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(_Message(
          role: 'assistant',
          text: 'حصلت مشكلة في الاتصال. جرب تاني.',
        ));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isAr = lang.locale == 'ar';
    final auth = ref.watch(authProvider);

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        // ── Sidebar Drawer
        drawer: _buildDrawer(isAr, lang),

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withAlpha(10),
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.slate700),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: AppColors.primary600, size: 18.w),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'المساعد الذكي' : 'Smart Assistant',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900),
                  ),
                  Text(
                    isAr ? 'مساعد 4Sale' : '4Sale AI Assistant',
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (auth.isLoggedIn)
              IconButton(
                icon: Icon(Icons.add_comment_rounded,
                    color: AppColors.primary600, size: 22.w),
                tooltip: isAr ? 'محادثة جديدة' : 'New Chat',
                onPressed: () async {
                  setState(() {
                    _sessionId = null;
                    _messages = [];
                  });
                  await _initSession();
                  await _loadSessions();
                },
              ),
            SizedBox(width: 4.w),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.slate100),
          ),
        ),

        body: Column(
          children: [
            // ── Chat messages
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(isAr)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _buildMessageBubble(_messages[i], isAr),
                    ),
            ),

            // ── Input bar
            _buildInputBar(isAr),
          ],
        ),
      ),
    );
  }

  // ── Sidebar Drawer ────────────────────────────────────────────
  Widget _buildDrawer(bool isAr, LanguageState lang) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 280.w,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary600, AppColors.primary500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: Colors.white, size: 22.w),
                  SizedBox(width: 10.w),
                  Text(
                    isAr ? 'سجل المحادثات' : 'Chat History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Sessions list
            Expanded(
              child: _loadingSessions
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary500))
                  : _sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 40.w, color: AppColors.slate300),
                              SizedBox(height: 12.h),
                              Text(
                                isAr ? 'مفيش محادثات سابقة' : 'No previous chats',
                                style: TextStyle(
                                    color: AppColors.slate400, fontSize: 14.sp),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: _sessions.length,
                          itemBuilder: (_, i) {
                            final s = _sessions[i];
                            final sid = s['id'] as int;
                            final isActive = sid == _sessionId;
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 4.h),
                              leading: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary50
                                      : AppColors.slate50,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.chat_rounded,
                                  size: 18.w,
                                  color: isActive
                                      ? AppColors.primary600
                                      : AppColors.slate400,
                                ),
                              ),
                              title: Text(
                                s['title'] ?? 'محادثة',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.primary700
                                      : AppColors.slate700,
                                ),
                              ),
                              selected: isActive,
                              selectedTileColor: AppColors.primary50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline_rounded,
                                    size: 18.w, color: AppColors.slate400),
                                onPressed: () => _deleteSession(sid),
                              ),
                              onTap: () => _loadSession(sid),
                            );
                          },
                        ),
            ),

            // Back to home
            Divider(color: AppColors.slate100, height: 1.h),
            ListTile(
              leading: Icon(Icons.arrow_back_rounded,
                  color: AppColors.slate600, size: 20.w),
              title: Text(
                isAr ? 'الرئيسية' : 'Home',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────
  Widget _buildEmptyState(bool isAr) {
    final suggestions = isAr
        ? ['لاب توب مستعمل بحالة جيدة', 'تلاجة بأقل من 3000 جنيه', 'موبايل Samsung في القاهرة', 'أثاث مكتبي للبيع']
        : ['Used laptop in good condition', 'Fridge under 3000 EGP', 'Samsung phone in Cairo', 'Office furniture for sale'];

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 40.w, color: AppColors.primary500),
            ),
            SizedBox(height: 20.h),
            Text(
              isAr ? 'ابدأ محادثتك' : 'Start a conversation',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate800),
            ),
            SizedBox(height: 8.h),
            Text(
              isAr
                  ? 'اسأل عن أي منتج وهنلاقيه ليك\nمن آلاف الإعلانات في مصر'
                  : 'Ask about any product and we\'ll find it\nfrom thousands of listings in Egypt',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.slate500,
                  height: 1.6,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 28.h),
            // Suggestion chips
            Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center,
              children: suggestions.map((s) {
                return GestureDetector(
                  onTap: () {
                    _inputCtrl.text = s;
                    _send();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.slate200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_rounded,
                            size: 14.w, color: AppColors.primary500),
                        SizedBox(width: 6.w),
                        Text(s,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.slate700,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Message bubble ────────────────────────────────────────────
  Widget _buildMessageBubble(_Message msg, bool isAr) {
    final isUser = msg.role == 'user';

    if (msg.isLoading) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r).copyWith(
              bottomLeft: Radius.circular(4.r),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary500),
              ),
              SizedBox(width: 10.w),
              Text(isAr ? 'جاري البحث...' : 'Searching...',
                  style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bubble
          Container(
            margin: EdgeInsets.only(bottom: 4.h),
            constraints: BoxConstraints(maxWidth: 0.78.sw),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary600 : Colors.white,
              borderRadius: BorderRadius.circular(18.r).copyWith(
                bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(18.r),
                bottomLeft: isUser ? Radius.circular(18.r) : Radius.circular(4.r),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(isUser ? 20 : 8),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 14.sp,
                color: isUser ? Colors.white : AppColors.slate800,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),

          // Product cards (for assistant messages)
          if (!isUser && msg.products.isNotEmpty) ...[
            SizedBox(height: 8.h),
            SizedBox(
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: msg.products.length,
                itemBuilder: (_, i) => _ProductCard(
                  product: msg.products[i] as Map<String, dynamic>,
                  isAr: isAr,
                ),
              ),
            ),
          ],
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────
  Widget _buildInputBar(bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.slate200),
              ),
              child: TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: isAr
                      ? 'اسأل عن أي منتج...'
                      : 'Ask about any product...',
                  hintStyle: TextStyle(
                      color: AppColors.slate400,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: _sending ? AppColors.slate300 : AppColors.primary600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary600.withAlpha(_sending ? 0 : 60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _sending
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Icon(Icons.send_rounded,
                      color: Colors.white, size: 20.w),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Card ─────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isAr;

  const _ProductCard({required this.product, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final title = product['title'] ?? '';
    final price = product['price'] ?? '';
    final image = product['primary_image'] ?? product['image_url'] ?? '';
    final id = product['id']?.toString() ?? '';
    final condition = product['condition'] ?? '';

    final condMap = {
      'new': isAr ? 'جديد' : 'New',
      'like-new': isAr ? 'شبه جديد' : 'Like New',
      'good': isAr ? 'جيد' : 'Good',
      'fair': isAr ? 'مقبول' : 'Fair',
    };

    return GestureDetector(
      onTap: () {
        if (id.isNotEmpty) context.push('/product/$id');
      },
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.r)),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      height: 110.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                          height: 1.3),
                    ),
                    const Spacer(),
                    if (condMap[condition] != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 4.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          condMap[condition]!,
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primary600,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    Text(
                      '$price ${isAr ? 'ج.م' : 'EGP'}',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 110.h,
      width: double.infinity,
      color: AppColors.slate100,
      child: Icon(Icons.image_outlined,
          size: 32.w, color: AppColors.slate300),
    );
  }
}
