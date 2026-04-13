import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../services/agent_service.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_shimmer.dart';
import 'dart:math' as math;

class AgentScreen extends ConsumerStatefulWidget {
  const AgentScreen({super.key});
  @override
  ConsumerState<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends ConsumerState<AgentScreen>
    with TickerProviderStateMixin {
  List<dynamic> _agents = [];
  List<dynamic> _targets = [];
  bool _loading = true;
  late AnimationController _orbCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _fetch();
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      _agents = await AgentService.list();
      _targets = await AgentService.getTargets();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  int get _activeCount => _agents.where((a) => a['is_active'] == true).length;

  void _showCreateSheet() {
    String? selectedTarget =
        _targets.isNotEmpty ? _targets[0]['id']?.toString() : null;
    final budgetC = TextEditingController();
    final requirementsC = TextEditingController();
    final lang = ref.read(languageProvider);
    final dict = lang.dict['agent'] as Map<String, dynamic>;
    final isAr = lang.locale == 'ar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.fromLTRB(
              24.w, 12.h, 24.w, MediaQuery.of(ctx).viewInsets.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              // Title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.smart_toy_rounded,
                        size: 20.w, color: Colors.white),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dict['createAgent'] as String,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.slate900,
                        ),
                      ),
                      Text(
                        isAr
                            ? 'خلّي الوكيل يزايد بدلك'
                            : 'Let AI bid on your behalf',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Target selector
              _sheetField(
                child: DropdownButtonFormField<String>(
                  value: selectedTarget,
                  decoration: InputDecoration(
                    labelText: dict['targetItem'] as String,
                    labelStyle:
                        TextStyle(fontSize: 14.sp, color: AppColors.slate500),
                    prefixIcon: Icon(Icons.track_changes_rounded,
                        size: 20.w, color: const Color(0xFF7C3AED)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                  style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
                  items: _targets
                      .map((t) => DropdownMenuItem(
                            value: t['id']?.toString(),
                            child: Text(t['label']?.toString() ??
                                t['title']?.toString() ??
                                ''),
                          ))
                      .toList(),
                  onChanged: (v) => selectedTarget = v,
                ),
              ),
              SizedBox(height: 12.h),
              // Budget
              _sheetField(
                child: TextField(
                  controller: budgetC,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
                  decoration: InputDecoration(
                    labelText: dict['maxBudget'] as String,
                    labelStyle:
                        TextStyle(fontSize: 14.sp, color: AppColors.slate500),
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                        size: 20.w, color: const Color(0xFF7C3AED)),
                    suffixText: lang.dict['currency'] as String,
                    suffixStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7C3AED)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // Requirements
              _sheetField(
                child: TextField(
                  controller: requirementsC,
                  maxLines: 3,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
                  decoration: InputDecoration(
                    labelText: dict['requirements'] as String,
                    labelStyle:
                        TextStyle(fontSize: 14.sp, color: AppColors.slate500),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40.h),
                      child: Icon(Icons.description_outlined,
                          size: 20.w, color: const Color(0xFF7C3AED)),
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Create button
              _AgentGradientButton(
                text: dict['createAgent'] as String,
                onPressed: () async {
                  if (selectedTarget == null || budgetC.text.isEmpty) return;
                  HapticFeedback.mediumImpact();
                  await AgentService.create(
                    targetItem: selectedTarget!,
                    maxBudget: double.parse(budgetC.text),
                    requirementsPrompt: requirementsC.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _fetch();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['agent'] as Map<String, dynamic>;
    final currency = lang.dict['currency'] as String;
    final isAr = lang.locale == 'ar';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FC),
        body: _loading
            ? _buildLoadingState()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Hero Header ────────────────────────────
                  SliverToBoxAdapter(child: _buildHero(dict, isAr)),
                  // ── Stats Cards ────────────────────────────
                  SliverToBoxAdapter(child: _buildStats(dict, isAr, currency)),
                  // ── Agents List ────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
                      child: Row(
                        children: [
                          Text(
                            isAr ? 'الوكلاء النشطون' : 'Active Agents',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate800,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '${_agents.length}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ),
                  _agents.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyAgents(dict, isAr))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                              child: _AgentCard(
                                agent: _agents[i],
                                dict: dict,
                                currency: currency,
                                isAr: isAr,
                                onToggle: (v) async {
                                  HapticFeedback.lightImpact();
                                  await AgentService.update(
                                      _agents[i]['id'] as int,
                                      {'is_active': v});
                                  _fetch();
                                },
                                onDelete: () async {
                                  HapticFeedback.heavyImpact();
                                  await AgentService.delete(
                                      _agents[i]['id'] as int);
                                  _fetch();
                                },
                              ).animate()
                                  .fadeIn(
                                      delay: Duration(milliseconds: 600 + i * 100),
                                      duration: 350.ms)
                                  .slideY(begin: 0.08, end: 0),
                            ),
                            childCount: _agents.length,
                          ),
                        ),
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
        // FAB
        floatingActionButton: _loading
            ? null
            : Container(
                margin: EdgeInsets.only(bottom: 60.h),
                child: FloatingActionButton.extended(
                  onPressed: _showCreateSheet,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  label: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded,
                            color: Colors.white, size: 20.w),
                        SizedBox(width: 6.w),
                        Text(
                          dict['createAgent'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHero(Map<String, dynamic> dict, bool isAr) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Stack(
        children: [
          // Background gradient
          Container(
            height: 260.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                  Color(0xFF4C1D95),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
          // Animated orbs
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _orbCtrl,
              builder: (_, __) {
                final angle =
                    _orbCtrl.value * 2 * math.pi + (i * math.pi * 2 / 3);
                final x = math.cos(angle) * (40.w + i * 15.w);
                final y = math.sin(angle) * (25.h + i * 10.h);
                return Positioned(
                  top: 80.h + y + i * 30.h,
                  left: (MediaQuery.of(context).size.width / 2) +
                      x -
                      (20.w + i * 5.w),
                  child: Container(
                    width: (40 + i * 10).w,
                    height: (40 + i * 10).w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          [
                            const Color(0xFF7C3AED),
                            const Color(0xFF4F46E5),
                            const Color(0xFFA855F7)
                          ][i]
                              .withAlpha(40),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Column(
                children: [
                  // Back + title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              size: 20.w, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        dict['title'] as String,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                  SizedBox(height: 24.h),
                  // Robot icon with glow
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, child) {
                      return Container(
                        padding: EdgeInsets.all(22.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF7C3AED).withAlpha(
                                  (60 + _pulseCtrl.value * 40).toInt()),
                              Colors.transparent,
                            ],
                            radius: 1.2 + _pulseCtrl.value * 0.3,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withAlpha(30), width: 1.5),
                          ),
                          child: Icon(Icons.smart_toy_rounded,
                              size: 36.w, color: Colors.white),
                        ),
                      );
                    },
                  ).animate().scale(
                      duration: 600.ms, curve: Curves.easeOutBack),
                  SizedBox(height: 14.h),
                  // Tagline
                  Text(
                    isAr
                        ? 'وكيلك الذكي يعمل من أجلك'
                        : 'Your AI Agent works for you',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  SizedBox(height: 4.h),
                  Text(
                    isAr
                        ? 'يزايد ويتفاوض تلقائياً على المنتجات اللي تحبها'
                        : 'Auto-bids & negotiates on items you love',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withAlpha(160),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS CARDS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStats(
      Map<String, dynamic> dict, bool isAr, String currency) {
    final totalAgents = _agents.length;
    final active = _activeCount;
    final totalBudget = _agents.fold<double>(0, (sum, a) {
      return sum + (double.tryParse(a['max_budget']?.toString() ?? '0') ?? 0);
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Transform.translate(
        offset: Offset(0, -20.h),
        child: Row(
          children: [
            _StatChip(
              icon: Icons.smart_toy_rounded,
              value: '$totalAgents',
              label: isAr ? 'إجمالي' : 'Total',
              color: const Color(0xFF7C3AED),
            ),
            SizedBox(width: 10.w),
            _StatChip(
              icon: Icons.flash_on_rounded,
              value: '$active',
              label: isAr ? 'نشط' : 'Active',
              color: AppColors.successGreen,
            ),
            SizedBox(width: 10.w),
            _StatChip(
              icon: Icons.account_balance_wallet_rounded,
              value: totalBudget.toStringAsFixed(0),
              label: currency,
              color: AppColors.auctionOrange,
            ),
          ],
        ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyAgents(Map<String, dynamic> dict, bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy_outlined,
                size: 48.w, color: const Color(0xFF7C3AED).withAlpha(100)),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          SizedBox(height: 16.h),
          Text(
            dict['noAgents'] as String,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 6.h),
          Text(
            isAr
                ? 'أنشئ وكيل ذكي ليزايد بدلك تلقائياً'
                : 'Create an AI agent to auto-bid for you',
            style: TextStyle(fontSize: 13.sp, color: AppColors.slate400),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            AppShimmer(
                width: double.infinity,
                height: 200.h,
                borderRadius: BorderRadius.circular(24.r)),
            SizedBox(height: 16.h),
            Row(
              children: List.generate(
                  3,
                  (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: AppShimmer(
                              width: double.infinity,
                              height: 70.h,
                              borderRadius: BorderRadius.circular(14.r)),
                        ),
                      )),
            ),
            SizedBox(height: 16.h),
            ...List.generate(
                3,
                (i) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: AppShimmer(
                          width: double.infinity,
                          height: 120.h,
                          borderRadius: BorderRadius.circular(18.r)),
                    )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// STAT CHIP
// ═══════════════════════════════════════════════════════════════════════
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.w, color: color),
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.slate800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.slate400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// AGENT CARD
// ═══════════════════════════════════════════════════════════════════════
class _AgentCard extends StatefulWidget {
  final dynamic agent;
  final Map<String, dynamic> dict;
  final String currency;
  final bool isAr;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _AgentCard({
    required this.agent,
    required this.dict,
    required this.currency,
    required this.isAr,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.agent;
    final isActive = a['is_active'] == true;
    final title =
        a['target_label'] as String? ?? a['target_item']?.toString() ?? '';
    final budget = a['max_budget']?.toString() ?? '0';
    final requirements = a['requirements_prompt'] as String? ?? '';

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isActive
                  ? Color.lerp(
                      const Color(0xFF7C3AED).withAlpha(30),
                      const Color(0xFF7C3AED).withAlpha(60),
                      _glowCtrl.value,
                    )!
                  : AppColors.slate200,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: const Color(0xFF7C3AED)
                      .withAlpha((8 + _glowCtrl.value * 12).toInt()),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Agent icon with status
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF4F46E5)
                                  ],
                                )
                              : null,
                          color: isActive ? null : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.smart_toy_rounded,
                          size: 22.w,
                          color: isActive ? Colors.white : AppColors.slate400,
                        ),
                      ),
                      if (isActive)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  // Title + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.successGreen
                                    : AppColors.slate400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isActive
                                  ? (widget.isAr ? 'يعمل الآن' : 'Working now')
                                  : (widget.isAr ? 'متوقف' : 'Paused'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isActive
                                    ? AppColors.successGreen
                                    : AppColors.slate400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Toggle
                  Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: isActive,
                      onChanged: widget.onToggle,
                      activeThumbColor: const Color(0xFF7C3AED),
                      activeTrackColor:
                          const Color(0xFF7C3AED).withAlpha(40),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // Budget bar
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: const Color(0xFF7C3AED).withAlpha(10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 16.w, color: const Color(0xFF7C3AED)),
                    SizedBox(width: 8.w),
                    Text(
                      '${widget.dict['maxBudget']}: ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${double.tryParse(budget)?.toStringAsFixed(0) ?? budget} ${widget.currency}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
              // Requirements
              if (requirements.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 14.w, color: AppColors.slate400),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          requirements,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.slate500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 10.h),
              // Delete
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withAlpha(8),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 14.w, color: AppColors.errorRed),
                        SizedBox(width: 4.w),
                        Text(
                          widget.dict['deleteAgent'] as String,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// GRADIENT BUTTON
// ═══════════════════════════════════════════════════════════════════════
class _AgentGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  const _AgentGradientButton({required this.text, required this.onPressed});
  @override
  State<_AgentGradientButton> createState() => _AgentGradientButtonState();
}

class _AgentGradientButtonState extends State<_AgentGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _anim = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
