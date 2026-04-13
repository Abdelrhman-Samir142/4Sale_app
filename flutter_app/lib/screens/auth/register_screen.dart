import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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
  bool _obscure1 = true;
  bool _obscure2 = true;

  // Validation errors
  String? _usernameError;
  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;
  String? _cityError;
  String? _passwordError;
  String? _password2Error;

  @override
  void dispose() {
    _usernameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _password2C.dispose();
    _firstNameC.dispose();
    _lastNameC.dispose();
    _cityC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  // ── Password strength ──────────────────────────────────────────
  int _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%\^&\*\.\-_]').hasMatch(password)) score++;
    if (score <= 1) return 1; // Weak
    if (score <= 3) return 2; // Medium
    return 3; // Strong
  }

  Color _strengthColor(int strength) {
    switch (strength) {
      case 1:
        return AppColors.errorRed;
      case 2:
        return AppColors.warningAmber;
      case 3:
        return AppColors.successGreen;
      default:
        return const Color(0xFFE8ECF0);
    }
  }

  String _strengthLabel(int strength, String locale) {
    if (locale == 'ar') {
      switch (strength) {
        case 1:
          return 'ضعيفة';
        case 2:
          return 'متوسطة';
        case 3:
          return 'قوية';
        default:
          return '';
      }
    } else {
      switch (strength) {
        case 1:
          return 'Weak';
        case 2:
          return 'Medium';
        case 3:
          return 'Strong';
        default:
          return '';
      }
    }
  }

  Future<void> _submit() async {
    bool isValid = true;
    setState(() {
      final reqStr = ref.read(languageProvider).locale == 'ar'
          ? 'مطلوب'
          : 'Required';
      _usernameError = _usernameC.text.trim().isEmpty ? reqStr : null;
      _emailError = _emailC.text.trim().isEmpty ? reqStr : null;
      _firstNameError = _firstNameC.text.trim().isEmpty ? reqStr : null;
      _lastNameError = _lastNameC.text.trim().isEmpty ? reqStr : null;
      _cityError = _cityC.text.trim().isEmpty ? reqStr : null;

      if (_passwordC.text.isEmpty) {
        _passwordError = reqStr;
      } else if (_passwordC.text.length < 8) {
        _passwordError = ref.read(languageProvider).locale == 'ar'
            ? 'كلمة المرور لازم 8 أحرف على الأقل'
            : 'Password must be at least 8 characters';
      } else {
        _passwordError = null;
      }

      if (_password2C.text != _passwordC.text) {
        _password2Error = ref.read(languageProvider).locale == 'ar'
            ? 'كلمة المرور مش متطابقة'
            : 'Passwords do not match';
      } else {
        _password2Error = null;
      }

      isValid = _usernameError == null &&
          _emailError == null &&
          _firstNameError == null &&
          _lastNameError == null &&
          _cityError == null &&
          _passwordError == null &&
          _password2Error == null;
    });

    if (!isValid) return;

    if (mounted) setState(() { _loading = true; _error = null; });

    try {
      await ref.read(authProvider.notifier).register(
            username: _usernameC.text.trim(),
            email: _emailC.text.trim(),
            password: _passwordC.text,
            password2: _password2C.text,
            city: _cityC.text.trim(),
            firstName: _firstNameC.text.trim(),
            lastName: _lastNameC.text.trim(),
            phone: _phoneC.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['register'] as Map<String, dynamic>;
    final isAr = lang.locale == 'ar';
    final passwordStrength = _getPasswordStrength(_passwordC.text);

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            _buildHeader(dict, isAr),

            // ── Form Body ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // ── Error Banner ────────────────────────────
                    if (_error != null)
                      _buildErrorBanner()
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .shakeX(hz: 3, amount: 4, duration: 400.ms),

                    // ═══ SECTION 1: Account Info ════════════════
                    _buildSectionLabel(
                      isAr ? 'معلومات الحساب' : 'ACCOUNT INFO',
                      Icons.account_circle_outlined,
                      200,
                    ),
                    SizedBox(height: 12.h),
                    _PremiumField(
                      controller: _usernameC,
                      hint: dict['username'] as String,
                      icon: Icons.alternate_email_rounded,
                      error: _usernameError,
                    ).animate().fadeIn(delay: 250.ms, duration: 350.ms).slideX(begin: 0.05),
                    SizedBox(height: 14.h),
                    _PremiumField(
                      controller: _emailC,
                      hint: dict['email'] as String,
                      icon: Icons.mail_outline_rounded,
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                    ).animate().fadeIn(delay: 320.ms, duration: 350.ms).slideX(begin: 0.05),

                    SizedBox(height: 24.h),

                    // ═══ SECTION 2: Personal Info ═══════════════
                    _buildSectionLabel(
                      isAr ? 'المعلومات الشخصية' : 'PERSONAL INFO',
                      Icons.person_outline_rounded,
                      400,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumField(
                            controller: _firstNameC,
                            hint: dict['firstName'] as String,
                            icon: Icons.badge_outlined,
                            error: _firstNameError,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _PremiumField(
                            controller: _lastNameC,
                            hint: dict['lastName'] as String,
                            icon: Icons.badge_outlined,
                            error: _lastNameError,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 450.ms, duration: 350.ms).slideX(begin: 0.05),
                    SizedBox(height: 14.h),
                    _PremiumField(
                      controller: _cityC,
                      hint: dict['city'] as String,
                      icon: Icons.location_on_outlined,
                      error: _cityError,
                    ).animate().fadeIn(delay: 520.ms, duration: 350.ms).slideX(begin: 0.05),
                    SizedBox(height: 14.h),
                    _PremiumField(
                      controller: _phoneC,
                      hint: dict['phone'] as String,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ).animate().fadeIn(delay: 590.ms, duration: 350.ms).slideX(begin: 0.05),

                    SizedBox(height: 24.h),

                    // ═══ SECTION 3: Security ════════════════════
                    _buildSectionLabel(
                      isAr ? 'الأمان' : 'SECURITY',
                      Icons.shield_outlined,
                      650,
                    ),
                    SizedBox(height: 12.h),
                    _PremiumField(
                      controller: _passwordC,
                      hint: dict['password'] as String,
                      icon: Icons.lock_outline_rounded,
                      error: _passwordError,
                      obscureText: _obscure1,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure1
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.slate400,
                          size: 20.w,
                        ),
                        onPressed: () =>
                            setState(() => _obscure1 = !_obscure1),
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 350.ms).slideX(begin: 0.05),

                    // ── Password Strength Bar ───────────────────
                    if (_passwordC.text.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      _buildPasswordStrengthBar(passwordStrength, isAr),
                    ],

                    SizedBox(height: 14.h),
                    _PremiumField(
                      controller: _password2C,
                      hint: dict['confirmPassword'] as String,
                      icon: Icons.lock_outline_rounded,
                      error: _password2Error,
                      obscureText: _obscure2,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure2
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.slate400,
                          size: 20.w,
                        ),
                        onPressed: () =>
                            setState(() => _obscure2 = !_obscure2),
                      ),
                    ).animate().fadeIn(delay: 770.ms, duration: 350.ms).slideX(begin: 0.05),

                    SizedBox(height: 28.h),

                    // ── Create Account Button ───────────────────
                    _GradientButton(
                      text: dict['submit'] as String,
                      isLoading: _loading,
                      onPressed: _submit,
                    ).animate().fadeIn(delay: 850.ms, duration: 400.ms).slideY(begin: 0.1),

                    SizedBox(height: 20.h),

                    // ── Login Link ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dict['hasAccount'] as String,
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            dict['loginLink'] as String,
                            style: TextStyle(
                              color: AppColors.primary600,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 920.ms, duration: 400.ms),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ── HEADER ────────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(Map<String, dynamic> dict, bool isAr) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary600.withAlpha(18),
            AppColors.primary400.withAlpha(8),
            Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/login');
                  }
                },
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.arrow_back_rounded,
                      color: AppColors.slate700, size: 20.w),
                ),
              ).animate().fadeIn(delay: 100.ms),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'app-logo',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 52.w,
                          height: 52.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms).scale(
                        begin: const Offset(0.7, 0.7),
                        duration: 400.ms,
                        curve: Curves.elasticOut),
                    SizedBox(height: 16.h),
                    Text(
                      dict['title'] as String,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),
                    SizedBox(height: 4.h),
                    Text(
                      isAr
                          ? 'انضم لآلاف البائعين والمشترين'
                          : 'Join thousands of buyers and sellers',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 280.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ── SECTION LABEL ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String text, IconData icon, int delayMs) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.w, color: AppColors.primary600),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.slate400,
            letterSpacing: 1.2,
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delayMs), duration: 350.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // ── ERROR BANNER ──────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════
  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withAlpha(15),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.errorRed.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.errorRed, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(_error!,
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ── PASSWORD STRENGTH BAR ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPasswordStrengthBar(int strength, bool isAr) {
    final color = _strengthColor(strength);
    final label = _strengthLabel(strength, isAr ? 'ar' : 'en');
    final fraction = strength / 3.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'قوة كلمة المرور' : 'Password strength',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.slate400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                child: Text(label),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SizedBox(
              height: 6.h,
              child: Stack(
                children: [
                  // Background
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFEEEEEE),
                  ),
                  // Progress
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    widthFactor: fraction,
                    alignment: isAr
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withAlpha(180)],
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── PREMIUM FIELD ───────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _PremiumField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? error;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _PremiumField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.error,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final _focus = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _hasFocus = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hasFocus ? Colors.white : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: hasError
                  ? AppColors.errorRed
                  : _hasFocus
                      ? AppColors.primary600
                      : const Color(0xFFE8ECF0),
              width: _hasFocus || hasError ? 1.8 : 1.2,
            ),
            boxShadow: _hasFocus && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.primary600.withAlpha(15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.slate800,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.slate400,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(left: 12.w, right: 8.w),
                child: Icon(
                  widget.icon,
                  color: _hasFocus
                      ? AppColors.primary600
                      : AppColors.slate400,
                  size: 20.w,
                ),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 42.w,
                minHeight: 42.h,
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 13.w, color: AppColors.errorRed),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    widget.error!,
                    style: TextStyle(
                      color: AppColors.errorRed,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate(key: ValueKey(widget.error))
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.3),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── GRADIENT BUTTON (shared with login) ─────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _GradientButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.text,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.forward(),
        onTapUp: (_) {
          _scaleCtrl.reverse();
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: () => _scaleCtrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            gradient: widget.isLoading
                ? LinearGradient(colors: [
                    AppColors.primary600.withAlpha(180),
                    AppColors.primary500.withAlpha(180),
                  ])
                : const LinearGradient(
                    colors: [
                      AppColors.primary700,
                      AppColors.primary500,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary600.withAlpha(50),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
