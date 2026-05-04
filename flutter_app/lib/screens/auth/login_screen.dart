import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/utils/app_snackbar.dart';

// ── Clean Premium Light Theme ──────────────────────────────────────
const Color _bgLight = Color(0xFFF7F9FC);
const Color _primaryTeal = Color(0xFF0F766E);
const Color _textDark = Color(0xFF1E212B);
const Color _textGrey = Color(0xFF9FA6B2);
const Color _surfaceWhite = Colors.white;
const Color _borderLight = Color(0xFFE5E7EB);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _usernameError;
  String? _passwordError;

  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    bool isValid = true;
    final reqMsg = ref.read(languageProvider).locale == 'ar' ? 'مطلوب' : 'Required';
    
    if (_usernameC.text.trim().isEmpty) {
      _usernameError = reqMsg;
      isValid = false;
    } else {
      _usernameError = null;
    }

    if (_passwordC.text.trim().isEmpty) {
      _passwordError = reqMsg;
      isValid = false;
    } else {
      _passwordError = null;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).login(
        _usernameC.text.trim(),
        _passwordC.text.trim(),
      );
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
        resizeToAvoidBottomInset: true,
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
                          SizedBox(height: 50.h),
                          _buildHeader(isAr),
                          SizedBox(height: 50.h),
                          _buildLoginForm(isAr),
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
                    child: CircularProgressIndicator(color: _primaryTeal).animate().scale(curve: Curves.easeOutBack),
                  ),
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
      builder: (_, _) {
        return Stack(
          children: [
            Container(color: _bgLight),
            Positioned(
              top: -100.h + (30 * _bgCtrl.value),
              left: -50.w - (20 * _bgCtrl.value),
              child: Container(
                width: 400.w, height: 400.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [_primaryTeal.withAlpha(12), Colors.transparent]),
                ),
              ),
            ),
            Positioned(
              bottom: -100.h - (20 * _bgCtrl.value),
              right: -50.w + (30 * _bgCtrl.value),
              child: Container(
                width: 350.w, height: 350.h,
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

  Widget _buildOfficialLogo() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: _primaryTeal,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: _primaryTeal.withAlpha(50),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Center(
            child: Text(
              '4',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34.sp,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sale',
              style: TextStyle(
                color: _textDark,
                fontSize: 34.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            Text(
              'MARKETPLACE',
              style: TextStyle(
                color: _textGrey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    )).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildHeader(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildOfficialLogo(),
        SizedBox(height: 36.h),
        Text(
          isAr ? 'مرحباً بعودتك' : 'Welcome back',
          style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w900, color: _textDark, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
        SizedBox(height: 8.h),
        Text(
          isAr ? 'سجل الدخول لمواصلة التسوق وتصفح العروض' : 'Sign in to continue shopping and exploring',
          style: TextStyle(fontSize: 15.sp, color: _textGrey, height: 1.5, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildLoginForm(bool isAr) {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 40, offset: const Offset(0, 20)),
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

          _CleanField(
            controller: _usernameC,
            labelText: isAr ? 'اسم المستخدم' : 'Username',
            icon: Icons.person_outline_rounded,
            errorText: _usernameError,
          ).animate().fadeIn(delay: 300.ms).slideX(),
          
          SizedBox(height: 20.h),
          
          _CleanField(
            controller: _passwordC,
            labelText: isAr ? 'كلمة المرور' : 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscure,
            errorText: _passwordError,
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: _textGrey),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(),

          SizedBox(height: 16.h),
          Align(
            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: _primaryTeal,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              ),
              child: Text(
                isAr ? 'نسيت كلمة المرور؟' : 'Forgot password?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),

          SizedBox(height: 24.h),
          _PrimaryBtn(
            text: isAr ? 'تسجيل الدخول' : 'Sign In',
            onTap: _submit,
          ).animate().fadeIn(delay: 600.ms).scale(),

          SizedBox(height: 32.h),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: _borderLight, thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  isAr ? 'أو' : 'OR',
                  style: TextStyle(color: _textGrey, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Divider(color: _borderLight, thickness: 1)),
            ],
          ).animate().fadeIn(delay: 700.ms),

          SizedBox(height: 32.h),

          // Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isAr ? 'ليس لديك حساب؟ ' : 'Don\'t have an account? ',
                style: TextStyle(color: _textGrey, fontSize: 15.sp, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text(
                  isAr ? 'سجل الآن' : 'Sign up',
                  style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 800.ms),
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
