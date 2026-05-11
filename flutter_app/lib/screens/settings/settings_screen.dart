import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/auth/auth_guard.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifBids = true;
  bool _notifMessages = true;
  bool _notifAgent = true;
  bool _notifPromo = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final auth = ref.watch(authProvider);
    final isAr = lang.locale == 'ar';
    final user = auth.user;
    final userInfo = user?['user'] as Map<String, dynamic>? ?? {};
    final username = userInfo['username'] as String? ?? '';
    final email = userInfo['email'] as String? ?? '';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(isAr)),
            // ── Account Section ─────────────────────────
            SliverToBoxAdapter(
              child: _buildSection(
                title: isAr ? 'الحساب' : 'Account',
                icon: Icons.person_rounded,
                color: AppColors.primary600,
                delay: 100,
                children: [
                  _profileTile(username, email, isAr),
                  _settingsTile(
                    icon: Icons.lock_outline_rounded,
                    label: isAr ? 'تغيير كلمة المرور' : 'Change Password',
                    color: AppColors.slate600,
                    onTap: () {},
                  ),
                  _settingsTile(
                    icon: Icons.phone_outlined,
                    label: isAr ? 'رقم الهاتف' : 'Phone Number',
                    subtitle: userInfo['phone'] as String? ?? (isAr ? 'غير محدد' : 'Not set'),
                    color: AppColors.slate600,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            // ── Appearance ──────────────────────────────
            SliverToBoxAdapter(
              child: _buildSection(
                title: isAr ? 'المظهر' : 'Appearance',
                icon: Icons.palette_rounded,
                color: const Color(0xFF7C3AED),
                delay: 200,
                children: [
                  _switchTile(
                    icon: Icons.language_rounded,
                    label: isAr ? 'اللغة' : 'Language',
                    subtitle: isAr ? 'العربية' : 'English',
                    color: const Color(0xFF2563EB),
                    trailing: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(languageProvider.notifier).toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          isAr ? 'English' : 'عربي',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Notifications ───────────────────────────
            SliverToBoxAdapter(
              child: _buildSection(
                title: isAr ? 'الإشعارات' : 'Notifications',
                icon: Icons.notifications_rounded,
                color: AppColors.warningAmber,
                delay: 300,
                children: [
                  _switchTile(
                    icon: Icons.gavel_rounded,
                    label: isAr ? 'إشعارات المزادات' : 'Bid Notifications',
                    subtitle: isAr ? 'تنبيه عند المزايدة عليك' : 'Alert when outbid',
                    color: AppColors.auctionOrange,
                    trailing: Switch.adaptive(
                      value: _notifBids,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _notifBids = v);
                      },
                      activeColor: AppColors.primary600,
                      activeTrackColor: AppColors.primary200,
                    ),
                  ),
                  _switchTile(
                    icon: Icons.chat_bubble_rounded,
                    label: isAr ? 'إشعارات الرسائل' : 'Message Notifications',
                    subtitle: isAr ? 'رسائل جديدة من المشترين' : 'New messages from buyers',
                    color: AppColors.primary600,
                    trailing: Switch.adaptive(
                      value: _notifMessages,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _notifMessages = v);
                      },
                      activeColor: AppColors.primary600,
                      activeTrackColor: AppColors.primary200,
                    ),
                  ),
                  _switchTile(
                    icon: Icons.smart_toy_rounded,
                    label: isAr ? 'إشعارات الوكيل الذكي' : 'AI Agent Notifications',
                    subtitle: isAr ? 'تحديثات من الوكيل' : 'Agent activity updates',
                    color: const Color(0xFF7C3AED),
                    trailing: Switch.adaptive(
                      value: _notifAgent,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _notifAgent = v);
                      },
                      activeColor: AppColors.primary600,
                      activeTrackColor: AppColors.primary200,
                    ),
                  ),
                  _switchTile(
                    icon: Icons.campaign_rounded,
                    label: isAr ? 'العروض الترويجية' : 'Promotions',
                    subtitle: isAr ? 'خصومات وعروض خاصة' : 'Discounts & special offers',
                    color: AppColors.errorRed,
                    trailing: Switch.adaptive(
                      value: _notifPromo,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _notifPromo = v);
                      },
                      activeColor: AppColors.primary600,
                      activeTrackColor: AppColors.primary200,
                    ),
                  ),
                ],
              ),
            ),
            // ── Support ─────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSection(
                title: isAr ? 'الدعم والمساعدة' : 'Help & Support',
                icon: Icons.help_outline_rounded,
                color: AppColors.latestBlue,
                delay: 400,
                children: [
                  _settingsTile(
                    icon: Icons.quiz_outlined,
                    label: isAr ? 'الأسئلة الشائعة' : 'FAQ',
                    color: AppColors.latestBlue,
                    onTap: () {},
                  ),
                  _settingsTile(
                    icon: Icons.mail_outline_rounded,
                    label: isAr ? 'تواصل معنا' : 'Contact Us',
                    color: AppColors.primary600,
                    onTap: () {},
                  ),
                  _settingsTile(
                    icon: Icons.bug_report_outlined,
                    label: isAr ? 'الإبلاغ عن مشكلة' : 'Report a Problem',
                    color: AppColors.warningAmber,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            // ── About ───────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSection(
                title: isAr ? 'حول التطبيق' : 'About',
                icon: Icons.info_outline_rounded,
                color: AppColors.slate600,
                delay: 500,
                children: [
                  _settingsTile(
                    icon: Icons.description_outlined,
                    label: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                    color: AppColors.slate500,
                    onTap: () {},
                  ),
                  _settingsTile(
                    icon: Icons.gavel_outlined,
                    label: isAr ? 'الشروط والأحكام' : 'Terms & Conditions',
                    color: AppColors.slate500,
                    onTap: () {},
                  ),
                  _settingsTile(
                    icon: Icons.code_rounded,
                    label: isAr ? 'الإصدار' : 'Version',
                    subtitle: '1.0.0 (Build 1)',
                    color: AppColors.slate400,
                    showArrow: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            // ── Admin (only for staff/superuser) ──────
            if (auth.isAdmin)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/admin');
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withAlpha(40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.admin_panel_settings_rounded,
                              size: 22.w, color: Colors.white),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'لوحة التحكم' : 'Admin Dashboard',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                isAr
                                    ? 'إدارة المنصة والمستخدمين'
                                    : 'Manage platform & users',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white.withAlpha(120),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 16.w, color: Colors.white.withAlpha(100)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.05, end: 0),
              ),
            ),
            // ── Danger Zone ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: Column(
                  children: [
                    // Logout
                    _dangerButton(
                      icon: Icons.logout_rounded,
                      label: isAr ? 'تسجيل الخروج' : 'Log Out',
                      color: AppColors.auctionOrange,
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        final confirm = await _showConfirmDialog(
                          context,
                          isAr ? 'تسجيل الخروج' : 'Log Out',
                          isAr
                              ? 'هل تريد تسجيل الخروج من حسابك؟'
                              : 'Are you sure you want to log out?',
                          isAr ? 'تسجيل الخروج' : 'Log Out',
                          AppColors.auctionOrange,
                        );
                        if (confirm == true && context.mounted) {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            await AuthGuard.performStrictLogout(context);
                          }
                        }
                      },
                    ).animate().fadeIn(delay: 600.ms),
                    SizedBox(height: 10.h),
                    // Delete account
                    _dangerButton(
                      icon: Icons.delete_forever_rounded,
                      label: isAr ? 'حذف الحساب' : 'Delete Account',
                      color: AppColors.errorRed,
                      onTap: () async {
                        HapticFeedback.heavyImpact();
                        await _showConfirmDialog(
                          context,
                          isAr ? 'حذف الحساب' : 'Delete Account',
                          isAr
                              ? 'هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك نهائياً.'
                              : 'This action cannot be undone. All your data will be permanently deleted.',
                          isAr ? 'حذف نهائياً' : 'Delete Permanently',
                          AppColors.errorRed,
                        );
                      },
                    ).animate().fadeIn(delay: 650.ms),
                  ],
                ),
              ),
            ),
            // ── Footer ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
                child: Column(
                  children: [
                    Text(
                      '4Sale',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isAr
                          ? 'مشروع تخرج جامعة مصر © 2024'
                          : 'Egypt University Graduation Project © 2024',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20.w, MediaQuery.of(context).padding.top + 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: 20.w, color: AppColors.slate700),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.settings_rounded,
                size: 20.w, color: Colors.white),
          ),
          SizedBox(width: 10.w),
          Text(
            isAr ? 'الإعدادات' : 'Settings',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.slate900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required int delay,
    required List<Widget> children,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: color.withAlpha(12),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Icon(icon, size: 14.w, color: color),
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _addDividers(children),
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 350.ms)
        .slideY(begin: 0.05, end: 0);
  }

  List<Widget> _addDividers(List<Widget> children) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Divider(
          height: 0.5,
          thickness: 0.5,
          color: const Color(0xFFF1F5F9),
          indent: 56.w,
        ));
      }
    }
    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  // PROFILE TILE
  // ═══════════════════════════════════════════════════════════════
  Widget _profileTile(String username, String email, bool isAr) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.slate400,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isAr ? 'عرض الملف' : 'View Profile',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SETTINGS TILE
  // ═══════════════════════════════════════════════════════════════
  Widget _settingsTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withAlpha(10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.w, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.slate400,
                      ),
                    ),
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right_rounded,
                  size: 20.w, color: AppColors.slate300),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SWITCH TILE
  // ═══════════════════════════════════════════════════════════════
  Widget _switchTile({
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.w, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.slate400,
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DANGER BUTTON
  // ═══════════════════════════════════════════════════════════════
  Widget _dangerButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withAlpha(6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withAlpha(20)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withAlpha(12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.w, color: color),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20.w, color: color.withAlpha(120)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CONFIRM DIALOG
  // ═══════════════════════════════════════════════════════════════
  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    String confirmLabel,
    Color color,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isAr = ref.read(languageProvider).locale == 'ar';
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: color.withAlpha(10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      size: 32.w, color: color),
                ),
                SizedBox(height: 16.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.slate500,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Center(
                            child: Text(
                              isAr ? 'إلغاء' : 'Cancel',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(30),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              confirmLabel,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
