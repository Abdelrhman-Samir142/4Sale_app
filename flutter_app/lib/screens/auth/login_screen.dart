import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/utils/app_snackbar.dart';
import '../../widgets/language_toggle_widget.dart';
import '../../core/widgets/app_logo.dart';
// ── Premium Light Theme Constants ──────────────────────────────────
const Color _bgLight = Colors.white; 
const Color _primaryTeal = Color(0xFF0D9488); // Teal 600
const Color _primaryTealDark = Color(0xFF0F766E); // Teal 700
const Color _textDarkSlate = Color(0xFF0F172A); // Slate 900
const Color _textSoftGray = Color(0xFF64748B); // Slate 500
const Color _inputFill = Color(0xFFF8FAFC); // Slate 50

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(isAr),
                                SizedBox(height: 48.h),
                                if (_error != null)
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    margin: EdgeInsets.only(bottom: 24.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(20),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.redAccent, size: 20.w),
                                        SizedBox(width: 8.w),
                                        Expanded(child: Text(_error!, style: TextStyle(color: Colors.redAccent, fontSize: 13.sp))),
                                      ],
                                    ),
                                  ).animate().fadeIn().shakeX(),

                                _CleanField(
                                  controller: _usernameC,
                                  hintText: isAr ? 'اسم المستخدم' : 'Username',
                                  icon: Icons.person_outline_rounded,
                                  errorText: _usernameError,
                                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                                
                                SizedBox(height: 20.h),
                                
                                _CleanField(
                                  controller: _passwordC,
                                  hintText: isAr ? 'كلمة المرور' : 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscure,
                                  errorText: _passwordError,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, 
                                      color: _textSoftGray,
                                      size: 20.w,
                                    ),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                                SizedBox(height: 16.h),
                                Align(
                                  alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push('/forgot-password'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: _textSoftGray,
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      isAr ? 'نسيت كلمة المرور؟' : 'Forgot password?',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 400.ms),

                                SizedBox(height: 36.h),
                                
                                _PrimaryBtn(
                                  text: isAr ? 'تسجيل الدخول' : 'Sign In',
                                  isLoading: _loading,
                                  onTap: _submit,
                                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                                SizedBox(height: 32.h),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isAr ? 'ليس لديك حساب؟ ' : 'Don\'t have an account? ',
                                      style: TextStyle(color: _textSoftGray, fontSize: 14.sp, fontWeight: FontWeight.w500),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.push('/register'),
                                      child: Text(
                                        isAr ? 'سجل الآن' : 'Sign up',
                                        style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold, fontSize: 14.sp),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: 600.ms),
                              ],
                            ),
                          ),
                        ),
                        // Footer Language Toggle
                        Padding(
                          padding: EdgeInsets.only(bottom: 24.h, top: 16.h),
                          child: const Center(child: LanguageToggleWidget()),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppLogo(),
        SizedBox(height: 24.h),
        Text(
          isAr ? 'مرحباً بك' : 'Welcome',
          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: _textDarkSlate, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        SizedBox(height: 8.h),
        Text(
          isAr ? 'سجل الدخول للمتابعة' : 'Sign in to continue',
          style: TextStyle(fontSize: 15.sp, color: _textSoftGray, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── CLEAN FIELD ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _CleanField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final String? errorText;

  const _CleanField({
    required this.controller,
    required this.hintText,
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
              color: _isFocused ? Colors.white : _inputFill,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _isFocused ? _primaryTeal : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: _isFocused
                  ? [BoxShadow(color: _primaryTeal.withAlpha(15), blurRadius: 10, spreadRadius: 0, offset: const Offset(0, 4))]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              style: const TextStyle(color: _textDarkSlate, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: _textSoftGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                ),
                prefixIcon: Icon(widget.icon, color: _isFocused ? _primaryTeal : _textSoftGray, size: 22.w),
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
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryBtn({required this.text, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [_primaryTeal, _primaryTealDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: _primaryTeal.withAlpha(60), blurRadius: 15, offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: isLoading 
            ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
        ),
      ),
    );
  }
}
