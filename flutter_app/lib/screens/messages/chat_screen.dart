import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import 'dart:async';

class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  const ChatScreen({super.key, required this.conversationId});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _conversation;
  List<dynamic> _messages = [];
  bool _loading = true;
  final _msgC = TextEditingController();
  final _scroll = ScrollController();
  Timer? _pollTimer;
  bool _showScrollDown = false;
  bool _isSending = false;
  late AnimationController _typingCtrl;

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _scroll.addListener(() {
      final atBottom = _scroll.hasClients &&
          _scroll.offset >= _scroll.position.maxScrollExtent - 100;
      if (_showScrollDown == atBottom) {
        setState(() => _showScrollDown = !atBottom);
      }
    });
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgC.dispose();
    _scroll.dispose();
    _typingCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ChatService.getConversation(widget.conversationId);
      if (mounted) {
        final oldCount = _messages.length;
        setState(() {
          _conversation = data;
          _messages = (data['messages'] as List?) ?? [];
          _loading = false;
        });
        // Auto-scroll if new messages and user is near bottom
        if (_messages.length > oldCount && !_showScrollDown) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        if (_messages.isEmpty) {
          final isAr = ref.read(languageProvider).locale == 'ar';
          AppSnackbar.error(context, isAr ? 'فشل تحميل المحادثة' : 'Failed to load chat');
        }
      }
    }
  }

  void _scrollToBottom({bool animate = true}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        if (animate) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        } else {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _send() async {
    final text = _msgC.text.trim();
    if (text.isEmpty || _isSending) return;
    _msgC.clear();
    setState(() => _isSending = true);
    try {
      await ChatService.sendMessage(widget.conversationId, text);
      await _load();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        final isAr = ref.read(languageProvider).locale == 'ar';
        AppSnackbar.error(context, isAr ? 'فشل إرسال الرسالة' : 'Failed to send message');
      }
    }
    if (mounted) setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['chat'] as Map<String, dynamic>;
    final auth = ref.watch(authProvider);
    final isAr = lang.locale == 'ar';
    final myId = auth.user?['user']?['id'] as int?;

    final other = _conversation?['other_participant'];
    final otherName = other?['username'] as String? ?? dict['title'] as String;
    final product = _conversation?['product_title'] as String? ?? '';
    final initial = otherName.isNotEmpty ? otherName[0].toUpperCase() : '?';

    // Generate color from name
    final hue =
        (otherName.codeUnits.fold<int>(0, (s, c) => s + c) * 37) % 360;
    final avatarColor =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.6).toColor();
    final avatarBg =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.4, 0.94).toColor();

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        // ── App Bar ──────────────────────────────────
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(product.isNotEmpty ? 70.h : 60.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 6.h, 12.w, 6.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded,
                          color: AppColors.slate700, size: 22.w),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Avatar
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: avatarBg,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: avatarColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Name + product
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate800,
                            ),
                          ),
                          if (product.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.shopping_bag_outlined,
                                    size: 11.w, color: AppColors.primary500),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    product,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.primary500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary600))
            : Column(
                children: [
                  // ── Messages ──────────────────────────
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scroll,
                          padding: EdgeInsets.fromLTRB(
                              16.w, 12.h, 16.w, 12.h),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final msg = _messages[i];
                            final isMine = msg['sender'] == myId;
                            final showDate = _shouldShowDate(i);

                            return Column(
                              children: [
                                if (showDate) _dateSeparator(msg, isAr),
                                _MessageBubble(
                                  message: msg,
                                  isMine: isMine,
                                  isAr: isAr,
                                  isFirst: i == 0 ||
                                      _messages[i - 1]['sender'] !=
                                          msg['sender'],
                                  isLast: i == _messages.length - 1 ||
                                      _messages[i + 1]['sender'] !=
                                          msg['sender'],
                                ),
                              ],
                            );
                          },
                        ),
                        // Scroll-to-bottom FAB
                        if (_showScrollDown)
                          Positioned(
                            bottom: 12.h,
                            right: 16.w,
                            child: GestureDetector(
                              onTap: () => _scrollToBottom(),
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 22.w,
                                  color: AppColors.primary600,
                                ),
                              ),
                            ).animate().fadeIn().scale(),
                          ),
                      ],
                    ),
                  ),
                  // ── Input Bar ─────────────────────────
                  _buildInputBar(dict, isAr),
                ],
              ),
      ),
    );
  }

  bool _shouldShowDate(int index) {
    if (index == 0) return true;
    final curr = _messages[index]['created_at'] as String?;
    final prev = _messages[index - 1]['created_at'] as String?;
    if (curr == null || prev == null) return false;
    try {
      final d1 = DateTime.parse(curr).toLocal();
      final d2 = DateTime.parse(prev).toLocal();
      return d1.day != d2.day || d1.month != d2.month || d1.year != d2.year;
    } catch (_) {
      return false;
    }
  }

  Widget _dateSeparator(dynamic msg, bool isAr) {
    final iso = msg['created_at'] as String?;
    String label = '';
    if (iso != null) {
      try {
        final dt = DateTime.parse(iso).toLocal();
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inDays == 0) {
          label = isAr ? 'اليوم' : 'Today';
        } else if (diff.inDays == 1) {
          label = isAr ? 'أمس' : 'Yesterday';
        } else {
          label = '${dt.day}/${dt.month}/${dt.year}';
        }
      } catch (_) {}
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.slate200, thickness: 0.8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate500,
                ),
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.slate200, thickness: 0.8)),
        ],
      ),
    );
  }

  Widget _buildInputBar(Map<String, dynamic> dict, bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Message input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFE8ECF0)),
                ),
                child: TextField(
                  controller: _msgC,
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
                  decoration: InputDecoration(
                    hintText: dict['typeMessage'] as String,
                    hintStyle:
                        TextStyle(fontSize: 13.sp, color: AppColors.slate400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Send button
            GestureDetector(
              onTap: _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary600.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSending
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.send_rounded,
                          size: 19.w, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── MESSAGE BUBBLE ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMine;
  final bool isAr;
  final bool isFirst;
  final bool isLast;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.isAr,
    required this.isFirst,
    required this.isLast,
  });

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = message['content'] as String? ?? '';
    final time = _formatTime(message['created_at'] as String?);

    // Bubble shape — rounded on all sides except the tail corner
    final corners = BorderRadius.only(
      topLeft: Radius.circular(isMine
          ? 18.r
          : isFirst
              ? 18.r
              : 6.r),
      topRight: Radius.circular(isMine
          ? isFirst
              ? 18.r
              : 6.r
          : 18.r),
      bottomLeft: Radius.circular(isMine
          ? 18.r
          : isLast
              ? 4.r
              : 6.r),
      bottomRight: Radius.circular(isMine
          ? isLast
              ? 4.r
              : 6.r
          : 18.r),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          Clipboard.setData(ClipboardData(text: content));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAr ? 'تم النسخ' : 'Copied'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(
            top: isFirst ? 8.h : 2.h,
            bottom: isLast ? 8.h : 2.h,
          ),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 10.w, 6.h),
          decoration: BoxDecoration(
            color: isMine ? AppColors.primary600 : Colors.white,
            borderRadius: corners,
            boxShadow: [
              BoxShadow(
                color: isMine
                    ? AppColors.primary600.withAlpha(20)
                    : Colors.black.withAlpha(6),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Message text
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isMine ? Colors.white : AppColors.slate800,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              // Time + read status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isMine
                          ? Colors.white.withAlpha(170)
                          : AppColors.slate400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMine) ...[
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.done_all_rounded,
                      size: 14.w,
                      color: Colors.white.withAlpha(170),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
          duration: 200.ms,
          curve: Curves.easeOutBack,
          alignment: isMine ? Alignment.bottomRight : Alignment.bottomLeft,
        );
  }
}
