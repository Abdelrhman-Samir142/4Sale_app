import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/widgets/app_logo.dart';
// ── Clean Premium Light Theme ──────────────────────────────────────
const Color _bgLight = Color(0xFFF7F9FC);
const Color _primaryTeal = Color(0xFF0F766E);
const Color _textDark = Color(0xFF1E212B);
const Color _textGrey = Color(0xFF9FA6B2);
const Color _surfaceWhite = Colors.white;
const Color _borderLight = Color(0xFFE5E7EB);

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with TickerProviderStateMixin {
  final _usernameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _password2C = TextEditingController();
  final _firstNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _cityC = TextEditingController();
  final _phoneC = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscure1 = true, _obscure2 = true;

  String? _usernameError, _emailError, _firstNameError,
      _lastNameError, _cityError, _passwordError, _password2Error;

  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameC.dispose(); _emailC.dispose(); _passwordC.dispose();
    _password2C.dispose(); _firstNameC.dispose(); _lastNameC.dispose();
    _cityC.dispose(); _phoneC.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    bool isValid = true;
    final reqMsg = ref.read(languageProvider).locale == 'ar' ? 'مطلوب' : 'Required';
    
    if (_usernameC.text.trim().isEmpty) { _usernameError = reqMsg; isValid = false; } else { _usernameError = null; }
    if (_emailC.text.trim().isEmpty || !_emailC.text.contains('@')) { _emailError = 'Invalid'; isValid = false; } else { _emailError = null; }
    if (_firstNameC.text.trim().isEmpty) { _firstNameError = reqMsg; isValid = false; } else { _firstNameError = null; }
    if (_lastNameC.text.trim().isEmpty) { _lastNameError = reqMsg; isValid = false; } else { _lastNameError = null; }
    if (_cityC.text.trim().isEmpty) { _cityError = reqMsg; isValid = false; } else { _cityError = null; }
    if (_passwordC.text.trim().isEmpty) { _passwordError = reqMsg; isValid = false; } else { _passwordError = null; }
    if (_password2C.text.trim() != _passwordC.text.trim()) { _password2Error = 'Mismatch'; isValid = false; } else { _password2Error = null; }

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).register(
        username: _usernameC.text.trim(),
        email: _emailC.text.trim(),
        password: _passwordC.text.trim(),
        password2: _password2C.text.trim(),
        firstName: _firstNameC.text.trim(),
        lastName: _lastNameC.text.trim(),
        city: _cityC.text.trim(),
        phone: _phoneC.text.trim(),
      );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      if (mounted) AppSnackbar.error(context, e.toString());
    } finally {
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
        backgroundColor: _bgLight,
        body: Stack(
          children: [
            _buildAnimatedBg(),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 30.h),
                          _buildHeader(isAr),
                          SizedBox(height: 40.h),
                          _buildForm(isAr),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              Positioned.fill(
                child: Container(
                  color: Colors.white54,
                  child: Center(
                    child: const CircularProgressIndicator(color: _primaryTeal).animate().scale(curve: Curves.easeOutBack),
                  ),
                ),
              ),
            Positioned(
              top: 40.h,
              right: isAr ? 20.w : null,
              left: isAr ? null : 20.w,
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(color: _surfaceWhite, shape: BoxShape.circle, border: Border.all(color: _borderLight)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 18),
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBg() {
    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (_, __) {
        return Stack(
          children: [
            Container(color: _bgLight),
            Positioned(
              top: -100.h + (40 * _bgCtrl.value),
              right: -50.w - (30 * _bgCtrl.value),
              child: Container(
                width: 350.w, height: 350.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [_primaryTeal.withAlpha(12), Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: -50.h - (50 * _bgCtrl.value),
              left: -50.w + (40 * _bgCtrl.value),
              child: Container(
                width: 300.w, height: 300.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [const Color(0xFF1E212B).withAlpha(8), Colors.transparent]),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ],
        );
      },
    );
  }



  Widget _buildHeader(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppLogo(),
        SizedBox(height: 36.h),
        Text(
          isAr ? 'إنشاء حساب جديد' : 'Create Account',
          style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w900, color: _textDark, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
        SizedBox(height: 8.h),
        Text(
          isAr ? 'انضم إلى منصة 4SALE المتميزة وتسوق بكل سهولة' : 'Join the premium 4SALE platform and shop easily',
          style: TextStyle(fontSize: 15.sp, color: _textGrey, height: 1.5, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildForm(bool isAr) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Column(
        children: [
          if (_error != null)
            Container(
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.redAccent, size: 20.w),
                  SizedBox(width: 8.w),
                  Expanded(child: Text(_error!, style: TextStyle(color: Colors.redAccent, fontSize: 13.sp))),
                ],
              ),
            ).animate().shakeX(),

          // ── Personal Info Section ──────────────────
          _SectionBadge(isAr ? 'المعلومات الشخصية' : 'Personal Info', Icons.person_outline).animate().fadeIn(delay: 300.ms),
          Row(
            children: [
              Expanded(child: _CleanField(controller: _firstNameC, labelText: isAr ? 'الاسم الأول' : 'First Name', icon: Icons.badge_outlined, errorText: _firstNameError).animate().fadeIn(delay: 350.ms).slideX()),
              SizedBox(width: 16.w),
              Expanded(child: _CleanField(controller: _lastNameC, labelText: isAr ? 'اسم العائلة' : 'Last Name', icon: Icons.badge_outlined, errorText: _lastNameError).animate().fadeIn(delay: 400.ms).slideX()),
            ],
          ),
          SizedBox(height: 16.h),
          _CleanField(controller: _usernameC, labelText: isAr ? 'اسم المستخدم' : 'Username', icon: Icons.alternate_email, errorText: _usernameError).animate().fadeIn(delay: 450.ms).slideX(),
          SizedBox(height: 16.h),
          _CleanField(controller: _emailC, labelText: isAr ? 'البريد الإلكتروني' : 'Email', icon: Icons.email_outlined, errorText: _emailError).animate().fadeIn(delay: 500.ms).slideX(),
          
          // ── Security Section ──────────────────────
          SizedBox(height: 24.h),
          _SectionBadge(isAr ? 'الأمان' : 'Security', Icons.shield_outlined).animate().fadeIn(delay: 550.ms),
          _CleanField(
            controller: _passwordC, labelText: isAr ? 'كلمة المرور' : 'Password', icon: Icons.lock_outline, obscureText: _obscure1, errorText: _passwordError,
            suffix: IconButton(icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, color: _textGrey), onPressed: () => setState(() => _obscure1 = !_obscure1)),
          ).animate().fadeIn(delay: 600.ms).slideX(),
          SizedBox(height: 16.h),
          _CleanField(
            controller: _password2C, labelText: isAr ? 'تأكيد المرور' : 'Confirm Password', icon: Icons.lock_reset, obscureText: _obscure2, errorText: _password2Error,
            suffix: IconButton(icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, color: _textGrey), onPressed: () => setState(() => _obscure2 = !_obscure2)),
          ).animate().fadeIn(delay: 650.ms).slideX(),

          // ── Additional Info Section ───────────────
          SizedBox(height: 24.h),
          _SectionBadge(isAr ? 'معلومات إضافية' : 'Additional Info', Icons.info_outline).animate().fadeIn(delay: 700.ms),
          _CleanField(controller: _cityC, labelText: isAr ? 'المدينة' : 'City', icon: Icons.location_city_outlined, errorText: _cityError).animate().fadeIn(delay: 750.ms).slideX(),
          SizedBox(height: 16.h),
          _CleanField(controller: _phoneC, labelText: isAr ? 'رقم الهاتف' : 'Phone (Optional)', icon: Icons.phone_outlined).animate().fadeIn(delay: 800.ms).slideX(),
          
          SizedBox(height: 40.h),
          _PrimaryBtn(text: isAr ? 'إنشاء حساب جديد' : 'Sign Up', onTap: _submit).animate().fadeIn(delay: 850.ms).scale(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── SECTION BADGE ────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _SectionBadge extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionBadge(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h, top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _primaryTeal.withAlpha(20),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _primaryTeal.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primaryTeal, size: 16.w),
          SizedBox(width: 8.w),
          Text(title, style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold, fontSize: 14.sp)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── CLEAN FIELD ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _CleanField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final String? errorText;

  const _CleanField({
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.errorText,
  });

  @override
  State<_CleanField> createState() => _CleanFieldState();
}

class _CleanFieldState extends State<_CleanField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (v) => setState(() => _isFocused = v),
          child: AnimatedContainer(
            duration: 200.ms,
            decoration: BoxDecoration(
              color: _surfaceWhite,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _isFocused ? _primaryTeal : _borderLight,
                width: _isFocused ? 1.5 : 1,
              ),
              boxShadow: _isFocused
                  ? [BoxShadow(color: _primaryTeal.withAlpha(20), blurRadius: 12, spreadRadius: 2)]
                  : [BoxShadow(color: Colors.black.withAlpha(3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              style: const TextStyle(color: _textDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: _isFocused ? _primaryTeal : _textGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
                floatingLabelStyle: TextStyle(
                  color: _primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(widget.icon, color: _isFocused ? _primaryTeal : _textGrey),
                suffixIcon: widget.suffix,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
              ),
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 12.w, right: 12.w),
            child: Text(widget.errorText!, style: TextStyle(color: Colors.redAccent, fontSize: 12.sp)),
          ).animate().fadeIn(),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── PRIMARY BUTTON ───────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _PrimaryBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryBtn({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: _primaryTeal,
          boxShadow: [
            BoxShadow(color: _primaryTeal.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white24);
  }
}
