import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAgents();
  }

  Future<void> _fetchAgents() async {
    setState(() => _loading = true);
    try {
      final res = await DioClient.instance.get(ApiConstants.agents);
      final data = res.data;
      final List<dynamic> items;
      if (data is Map && data.containsKey('results')) {
        items = data['results'] as List;
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }
      if (mounted) setState(() { _agents = items; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.slate900,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showCreateAgentSheet(context, isAr);
          },
          backgroundColor: AppColors.primary600,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            isAr ? 'إضافة وكيل جديد' : 'New Agent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary600))
            : _agents.isEmpty
                ? _buildEmptyState(isAr)
                : _buildAgentsList(isAr),
      ),
    );
  }

  Widget _buildEmptyState(bool isAr) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.recommendedPurple.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 60.w,
                color: AppColors.recommendedPurple.withAlpha(150),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            SizedBox(height: 32.h),
            Text(
              isAr ? 'لسه مفيش وكلاء' : 'No Agents Yet',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.slate900,
              ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 12.h),
            Text(
              isAr
                  ? 'أنشئ وكيل ذكي يزايد تلقائيًا بالنيابة عنك على المنتجات اللي تهمك!'
                  : 'Create a smart agent to automatically bid on products that match your interests!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.slate500,
                height: 1.6,
              ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
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

  Widget _buildAgentsList(bool isAr) {
    return RefreshIndicator(
      onRefresh: _fetchAgents,
      color: AppColors.primary600,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _agents.length,
        itemBuilder: (_, i) {
          final agent = _agents[i] as Map<String, dynamic>;
          final targetItem = agent['target_item'] as String? ?? '';
          final maxBudget = agent['max_budget']?.toString() ?? '0';
          final isActive = agent['is_active'] == true;

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isActive ? AppColors.primary200 : AppColors.slate200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary50 : AppColors.slate100,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    size: 24.w,
                    color: isActive ? AppColors.primary600 : AppColors.slate400,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        targetItem,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slate900,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isAr ? 'الحد الأقصى: $maxBudget ج.م' : 'Max Budget: $maxBudget EGP',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.slate500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.successGreen.withAlpha(15) : AppColors.slate100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'متوقف' : 'Paused'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.successGreen : AppColors.slate500,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 + (i * 60)));
        },
      ),
    );
  }

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
                Text(isAr ? 'إنشاء وكيل جديد' : 'Create New Agent', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                SizedBox(height: 24.h),
                TextField(
                  controller: targetC,
                  decoration: InputDecoration(
                    labelText: isAr ? 'المنتج المستهدف (مثل: لابتوب، هاتف)' : 'Target Item (e.g. laptop, phone)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
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
                  width: double.infinity,
                  height: 56.h,
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
                        _fetchAgents();
                      } catch (_) {}
                    },
                    child: Text(isAr ? 'إنشاء الوكيل' : 'Create Agent', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
