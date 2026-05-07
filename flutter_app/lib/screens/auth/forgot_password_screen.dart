import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/language_provider.dart';
import '../../shared/widgets/language_toggle_widget.dart';
import '../../core/widgets/app_logo.dart';
// ── Premium Light Theme Constants ──────────────────────────────────
const Color _bgLight = Colors.white; 
const Color _primaryTeal = Color(0xFF0D9488); // Teal 600
const Color _primaryTealDark = Color(0xFF0F766E); // Teal 700
const Color _textDarkSlate = Color(0xFF0F172A); // Slate 900
const Color _textSoftGray = Color(0xFF64748B); // Slate 500
const Color _inputFill = Color(0xFFF8FAFC); // Slate 50

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailC = TextEditingController();
  bool _loading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final lang = ref.read(languageProvider);
    final isAr = lang.locale == 'ar';
    final reqMsg = isAr ? 'مطلوب' : 'Required';
    
    if (_emailC.text.trim().isEmpty) {
      setState(() => _emailError = reqMsg);
      return;
    } else {
      setState(() => _emailError = null);
    }

    setState(() => _loading = true);
    
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _loading = false);
      // Show success dialog or snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'تم إرسال رابط استعادة كلمة السر إلى بريدك الإلكتروني' : 'Password reset link sent to your email'),
          backgroundColor: _primaryTeal,
        ),
      );
      // Optional: pop after success
      // context.pop();
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
                        // Back Button
                        Align(
                          alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textDarkSlate, size: 24.w),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(isAr),
                                SizedBox(height: 48.h),
                                
                                // Form Card
                                Container(
                                  padding: EdgeInsets.all(24.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(5),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      _CleanField(
                                        controller: _emailC,
                                        hintText: isAr ? 'البريد الإلكتروني' : 'Email Address',
                                        icon: Icons.email_outlined,
                                        errorText: _emailError,
                                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                                      
                                      SizedBox(height: 32.h),
                                      
                                      _PrimaryBtn(
                                        text: isAr ? 'استعادة كلمة السر' : 'Reset Password',
                                        isLoading: _loading,
                                        onTap: _submit,
                                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

                                SizedBox(height: 32.h),

                                // Footer Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isAr ? 'العودة لتسجيل الدخول؟ ' : 'Back to login? ',
                                      style: TextStyle(color: _textSoftGray, fontSize: 14.sp, fontWeight: FontWeight.w500),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.pop(),
                                      child: Text(
                                        isAr ? 'تسجيل الدخول' : 'Sign In',
                                        style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold, fontSize: 14.sp),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: 500.ms),
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
        const AppLogo(scale: 1.2),
        SizedBox(height: 32.h),
        Text(
          isAr ? 'نسيت كلمة السر' : 'Forgot Password',
          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: _textDarkSlate, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        SizedBox(height: 12.h),
        Text(
          isAr ? 'الرجاء إدخال البريد الإلكتروني المرتبط بحسابك لاستعادة كلمة المرور.' : 'Please enter the email address associated with your account to reset your password.',
          style: TextStyle(fontSize: 15.sp, color: _textSoftGray, fontWeight: FontWeight.w500, height: 1.5),
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
  final String? errorText;

  const _CleanField({
    required this.controller,
    required this.hintText,
    required this.icon,
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
              style: const TextStyle(color: _textDarkSlate, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: _textSoftGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                ),
                prefixIcon: Icon(widget.icon, color: _isFocused ? _primaryTeal : _textSoftGray, size: 22.w),
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
