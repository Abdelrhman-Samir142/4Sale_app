import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../../core/constants/app_colors.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameC;
  late final TextEditingController _lastNameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _locationC;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    final info = user?['user'] as Map<String, dynamic>? ?? {};
    _firstNameC = TextEditingController(text: info['first_name'] as String? ?? '');
    _lastNameC = TextEditingController(text: info['last_name'] as String? ?? '');
    _phoneC = TextEditingController(text: user?['phone'] as String? ?? '');
    _locationC = TextEditingController(text: user?['location'] as String? ?? '');
  }

  @override
  void dispose() {
    _firstNameC.dispose();
    _lastNameC.dispose();
    _phoneC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    try {
      await ProfileService.update({
        'first_name': _firstNameC.text.trim(),
        'last_name': _lastNameC.text.trim(),
        'phone': _phoneC.text.trim(),
        'location': _locationC.text.trim(),
      });
      // Refresh auth state to reflect changes
      await ref.read(authProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ref.read(languageProvider).locale == 'ar'
              ? 'تم تحديث البيانات بنجاح'
              : 'Profile updated successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isAr = lang.locale == 'ar';

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ─────────────────────────────────
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.arrow_back_rounded, size: 22.w, color: AppColors.slate700),
                      ),
                      Text(
                        isAr ? 'تعديل الملف الشخصي' : 'Edit Profile',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.slate900),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

            // ── Form ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _firstNameC,
                        label: isAr ? 'الاسم الأول' : 'First Name',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? (isAr ? 'مطلوب' : 'Required')
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildField(
                        controller: _lastNameC,
                        label: isAr ? 'الاسم الأخير' : 'Last Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      SizedBox(height: 16.h),
                      _buildField(
                        controller: _phoneC,
                        label: isAr ? 'رقم الهاتف' : 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),
                      _buildField(
                        controller: _locationC,
                        label: isAr ? 'الموقع' : 'Location',
                        icon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: 32.h),

                      // ── Save Button ───────────────────────
                      GestureDetector(
                        onTap: _saving ? null : _save,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            gradient: _saving ? null : AppColors.primaryGradient,
                            color: _saving ? AppColors.slate300 : null,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: _saving ? [] : [
                              BoxShadow(
                                color: AppColors.primary600.withAlpha(40),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _saving
                                ? SizedBox(
                                    width: 22.w, height: 22.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  )
                                : Text(
                                    isAr ? 'حفظ التغييرات' : 'Save Changes',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 350.ms).slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10, offset: const Offset(0, 3)),
        ],
        border: Border.all(color: const Color(0xFFEEF0F2)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.slate800),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13.sp, color: AppColors.slate400, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, size: 20.w, color: AppColors.primary600),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }
}
