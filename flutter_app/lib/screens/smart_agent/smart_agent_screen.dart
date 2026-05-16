import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class SmartAgentScreen extends ConsumerStatefulWidget {
  const SmartAgentScreen({super.key});
  @override
  ConsumerState<SmartAgentScreen> createState() => _SmartAgentScreenState();
}

class _SmartAgentScreenState extends ConsumerState<SmartAgentScreen> {
  List<dynamic> _agents = [];
  List<dynamic> _targets = [];
  List<dynamic> _pendingBids = [];
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchAll();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchAll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        DioClient.instance.get(ApiConstants.agents),
        DioClient.instance.get(ApiConstants.agentTargets),
        DioClient.instance.get(ApiConstants.pendingBids),
      ]);

      final agentData = results[0].data;
      final List<dynamic> agents = agentData is Map && agentData.containsKey('results')
          ? agentData['results'] as List
          : agentData is List ? agentData : [];

      final List<dynamic> targets = results[1].data is List ? results[1].data as List : [];
      final List<dynamic> pending = results[2].data is List ? results[2].data as List : [];

      if (mounted) {
        setState(() {
          _agents = agents;
          _targets = targets;
          _pendingBids = pending;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteAgent(int id) async {
    try {
      await DioClient.instance.delete(ApiConstants.agentDetail(id));
      _fetchAll();
    } catch (_) {}
  }

  Future<void> _toggleAgent(int id, bool isActive) async {
    try {
      await DioClient.instance.patch(ApiConstants.agentDetail(id), data: {'is_active': !isActive});
      _fetchAll();
    } catch (_) {}
  }

  Future<void> _approveBid(int id) async {
    try {
      await DioClient.instance.post(ApiConstants.approvePendingBid(id));
      _fetchAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('✅ تمت المزايدة بنجاح!'), backgroundColor: AppColors.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ فشل: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  Future<void> _rejectBid(int id) async {
    try {
      await DioClient.instance.post(ApiConstants.rejectPendingBid(id));
      _fetchAll();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isAr = lang.locale == 'ar';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.slate800),
            onPressed: () => context.pop(),
          ),
          title: Text(
            isAr ? 'الوكيل الذكي' : 'Smart Agent',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.slate900),
          ),
          centerTitle: true,
          actions: [
            if (_pendingBids.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    const Icon(Icons.pending_actions_rounded, color: AppColors.warningAmber),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                      child: Text(
                        '${_pendingBids.length}',
                        style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        floatingActionButton: _loading
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showCreateAgentSheet(context, isAr),
                backgroundColor: AppColors.primary600,
                elevation: 4,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  isAr ? 'إضافة وكيل' : 'New Agent',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary600))
            : RefreshIndicator(
                onRefresh: _fetchAll,
                color: AppColors.primary600,
                child: CustomScrollView(
                  slivers: [
                    // ── Pending Approvals Section ──────────────────
                    if (_pendingBids.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: AppColors.warningAmber.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.pending_actions_rounded, size: 16.w, color: AppColors.warningAmber),
                                    SizedBox(width: 6.w),
                                    Text(
                                      isAr ? 'موافقات معلقة (${_pendingBids.length})' : 'Pending Approvals (${_pendingBids.length})',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: AppColors.warningAmber),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildPendingBidCard(_pendingBids[i] as Map<String, dynamic>, isAr, i),
                          childCount: _pendingBids.length,
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                    ],

                    // ── Agents Section ─────────────────────────────
                    if (_agents.isEmpty)
                      SliverFillRemaining(child: _buildEmptyState(isAr))
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                          child: Text(
                            isAr ? 'وكلائي' : 'My Agents',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.slate700),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _buildAgentCard(_agents[i] as Map<String, dynamic>, isAr, i),
                            childCount: _agents.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  // ── Pending Bid Card ────────────────────────────────────────────
  Widget _buildPendingBidCard(Map<String, dynamic> bid, bool isAr, int idx) {
    final id = bid['id'] as int;
    final title = bid['product_title'] as String? ?? '';
    final image = bid['product_image'] as String?;
    final proposed = bid['proposed_amount']?.toString() ?? '0';
    final delta = bid['delta_amount']?.toString() ?? proposed;
    final currentBid = bid['current_bid']?.toString() ?? '0';
    final isCounter = bid['is_counter_bid'] == true;
    final reasoning = bid['ai_reasoning'] as String? ?? '';
    final endTime = bid['auction_end_time'] as String?;
    final isActive = bid['auction_is_active'] == true;

    Duration? remaining;
    if (endTime != null) {
      try {
        final end = DateTime.parse(endTime).toLocal();
        remaining = end.difference(DateTime.now());
      } catch (_) {}
    }

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.warningAmber.withAlpha(60), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.warningAmber.withAlpha(15), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image + info row
          Row(
            children: [
              if (image != null)
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), bottomLeft: Radius.circular(20.r)),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    width: 90.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 90.w,
                      height: 100.h,
                      color: AppColors.slate100,
                      child: Icon(Icons.image_not_supported_rounded, color: AppColors.slate400, size: 28.w),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isCounter)
                            Container(
                              margin: EdgeInsets.only(left: 6.w),
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withAlpha(15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                isAr ? 'مزايدة مضادة' : 'Counter-bid',
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppColors.errorRed),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.slate900),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        isAr ? 'المزايدة الحالية: $currentBid ج.م' : 'Current: $currentBid EGP',
                        style: TextStyle(fontSize: 11.sp, color: AppColors.slate500),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        isAr ? 'المقترح: $proposed ج.م' : 'Proposed: $proposed EGP',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primary600),
                      ),
                      if (remaining != null && remaining.isNegative == false && isActive) ...[
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 12.w, color: AppColors.slate400),
                            SizedBox(width: 3.w),
                            Text(
                              _formatDuration(remaining),
                              style: TextStyle(fontSize: 10.sp, color: AppColors.slate500),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Delta chip
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isAr ? '💳 سيتم خصم $delta ج.م فقط من محفظتك' : '💳 Only $delta EGP will be charged',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.primary700),
              ),
            ),
          ),

          // AI reasoning
          if (reasoning.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
              child: Text(
                '🤖 $reasoning',
                style: TextStyle(fontSize: 11.sp, color: AppColors.slate500, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Approve / Reject buttons
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveBid(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                    icon: Icon(Icons.check_circle_rounded, size: 16.w, color: Colors.white),
                    label: Text(
                      isAr ? 'موافق' : 'Approve',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectBid(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                    icon: Icon(Icons.cancel_rounded, size: 16.w, color: Colors.white),
                    label: Text(
                      isAr ? 'رفض' : 'Reject',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 * idx)).slideY(begin: 0.1, end: 0);
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }

  // ── Agent Card ──────────────────────────────────────────────────
  Widget _buildAgentCard(Map<String, dynamic> agent, bool isAr, int i) {
    final id = agent['id'] as int;
    final targetItem = agent['target_label'] as String? ?? agent['target_item'] as String? ?? '';
    final maxBudget = agent['max_budget']?.toString() ?? '0';
    final isActive = agent['is_active'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isActive ? AppColors.primary200 : AppColors.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w, height: 48.w,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary50 : AppColors.slate100,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.smart_toy_rounded, size: 24.w, color: isActive ? AppColors.primary600 : AppColors.slate400),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(targetItem, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.slate900)),
                SizedBox(height: 4.h),
                Text(
                  isAr ? 'الحد الأقصى: $maxBudget ج.م' : 'Max: $maxBudget EGP',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.slate500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successGreen.withAlpha(15) : AppColors.slate100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'متوقف' : 'Paused'),
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: isActive ? AppColors.successGreen : AppColors.slate500),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  InkWell(
                    onTap: () => _toggleAgent(id, isActive),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.warningAmber.withAlpha(20) : AppColors.primary500.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 18.w, color: isActive ? AppColors.warningAmber : AppColors.primary600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () => _deleteAgent(id),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(color: AppColors.errorRed.withAlpha(15), shape: BoxShape.circle),
                      child: Icon(Icons.delete_outline_rounded, size: 18.w, color: AppColors.errorRed),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + (i * 60)));
  }

  // ── Empty State ─────────────────────────────────────────────────
  Widget _buildEmptyState(bool isAr) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w, height: 120.w,
              decoration: BoxDecoration(color: AppColors.recommendedPurple.withAlpha(15), shape: BoxShape.circle),
              child: Icon(Icons.smart_toy_rounded, size: 60.w, color: AppColors.recommendedPurple.withAlpha(150)),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            SizedBox(height: 32.h),
            Text(
              isAr ? 'لسه مفيش وكلاء' : 'No Agents Yet',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppColors.slate900),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 12.h),
            Text(
              isAr
                  ? 'أنشئ وكيل ذكي يقترح مزايدات تلقائيًا بالنيابة عنك وتوافق عليها!'
                  : 'Create a smart agent that proposes bids for you to approve!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.slate500, height: 1.6),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity, height: 56.h,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateAgentSheet(context, isAr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  isAr ? 'إضافة وكيل جديد +' : '+ Add New Agent',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  // ── Create Agent Sheet ──────────────────────────────────────────
  void _showCreateAgentSheet(BuildContext context, bool isAr) {
    final targetC = TextEditingController();
    final budgetC = TextEditingController();
    final requirementsC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String? selectedTarget;
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: EdgeInsets.only(
                left: 20.w, right: 20.w, top: 24.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40.w, height: 5.h, decoration: BoxDecoration(color: AppColors.slate300, borderRadius: BorderRadius.circular(10.r))),
                    SizedBox(height: 24.h),
                    Text(isAr ? 'إنشاء وكيل جديد' : 'Create New Agent',
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                    SizedBox(height: 24.h),
                    DropdownButtonFormField<String>(
                      value: selectedTarget,
                      decoration: InputDecoration(
                        labelText: isAr ? 'المنتج المستهدف' : 'Target Item',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                        prefixIcon: const Icon(Icons.category_rounded),
                      ),
                      items: _targets.map((t) {
                        return DropdownMenuItem<String>(
                          value: t['id'].toString(),
                          child: Text(isAr ? (t['label_ar'] ?? t['label']) : t['label']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateSheet(() { selectedTarget = val; targetC.text = val ?? ''; });
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: budgetC,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isAr ? 'الحد الأقصى للميزانية (ج.م)' : 'Max Budget (EGP)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: requirementsC,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: isAr ? 'شروط إضافية (اختياري)' : 'Additional Requirements (optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                        prefixIcon: const Icon(Icons.description_rounded),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity, height: 56.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary600,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        ),
                        onPressed: () async {
                          if (targetC.text.trim().isEmpty || budgetC.text.trim().isEmpty) return;
                          try {
                            await DioClient.instance.post(ApiConstants.agents, data: {
                              'target_item': targetC.text.trim(),
                              'max_budget': double.tryParse(budgetC.text.trim()) ?? 0,
                              'requirements_prompt': requirementsC.text.trim(),
                            });
                            if (ctx.mounted) Navigator.pop(ctx);
                            _fetchAll();
                          } catch (_) {}
                        },
                        child: Text(
                          isAr ? 'إنشاء الوكيل' : 'Create Agent',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
