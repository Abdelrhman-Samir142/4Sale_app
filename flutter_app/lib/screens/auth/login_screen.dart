import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

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

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    bool isValid = true;
    final reqMsg =
        ref.read(languageProvider).locale == 'ar' ? 'مطلوب' : 'Required';
    if (_usernameC.text.trim().isEmpty) {
      _usernameError = reqMsg;
      isValid = false;
    } else {
      _usernameError = null;
    }
    if (_passwordC.text.isEmpty) {
      _passwordError = reqMsg;
      isValid = false;
    } else {
      _passwordError = null;
    }
    if (mounted) setState(() {});

    if (!isValid) return;

    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).login(
            _usernameC.text.trim(),
            _passwordC.text,
          );
      // Router redirect handles navigation automatically when auth state changes
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
    final dict = lang.dict['login'] as Map<String, dynamic>;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Gradient Header Wave ─────────────────────────
              _buildHeaderWave(size, dict, theme),

              // ── Form Body ────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 28.h),

                    // ── Error Banner ───────────────────────────
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        margin: EdgeInsets.only(bottom: 20.h),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withAlpha(15),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                              color: AppColors.errorRed.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: AppColors.errorRed, size: 20.w),
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
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .shakeX(hz: 3, amount: 4, duration: 400.ms),

                    // ── Username / Email Field ─────────────────
                    _PremiumTextField(
                      controller: _usernameC,
                      focusNode: _usernameFocus,
                      hintText: dict['email'] as String,
                      prefixIcon: Icons.person_outline_rounded,
                      errorText: _usernameError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.15),
                    SizedBox(height: 16.h),

                    // ── Password Field ─────────────────────────
                    _PremiumTextField(
                      controller: _passwordC,
                      focusNode: _passwordFocus,
                      hintText: dict['password'] as String,
                      prefixIcon: Icons.lock_outline_rounded,
                      errorText: _passwordError,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.slate400,
                          size: 20.w,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.15),

                    // ── Forgot Password ────────────────────────
                    Align(
                      alignment: lang.locale == 'ar'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 4.w),
                        ),
                        child: Text(
                          dict['forgotPassword'] as String,
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 550.ms, duration: 400.ms),

                    SizedBox(height: 8.h),

                    // ── Login Button (Gradient) ────────────────
                    _GradientButton(
                      text: dict['submit'] as String,
                      isLoading: _loading,
                      onPressed: _submit,
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms)
                        .slideY(begin: 0.15),

                    SizedBox(height: 24.h),

                    // ── Divider ────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: AppColors.slate200, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            lang.locale == 'ar' ? 'أو' : 'or',
                            style: TextStyle(
                              color: AppColors.slate400,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: AppColors.slate200, thickness: 1)),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 400.ms),

                    SizedBox(height: 24.h),

                    // ── Register Link ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dict['noAccount'] as String,
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            dict['createAccount'] as String,
                            style: TextStyle(
                              color: AppColors.primary600,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 400.ms),
                    SizedBox(height: 40.h),
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
  // ── HEADER WAVE WITH LOGO ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeaderWave(
      Size size, Map<String, dynamic> dict, ThemeData theme) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Background gradient wave
        Container(
          width: size.width,
          height: 280.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary600.withAlpha(20),
                AppColors.primary400.withAlpha(10),
                Colors.white,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -40.h,
          right: -30.w,
          child: Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary500.withAlpha(8),
            ),
          ),
        ),
        Positioned(
          top: 20.h,
          left: -50.w,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary500.withAlpha(6),
            ),
          ),
        ),

        // Back button (top-left)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 8.w,
          child: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
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
          ),
        ).animate().fadeIn(delay: 100.ms),

        // Logo + Title column
        Positioned(
          bottom: -40.h,
          child: Column(
            children: [
              // Logo Card with shadow
              Hero(
                tag: 'app-logo',
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary600.withAlpha(25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 72.w,
                      height: 72.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                      delay: 200.ms,
                      duration: 500.ms,
                      begin: const Offset(0.6, 0.6),
                      curve: Curves.elasticOut)
                  .fadeIn(delay: 200.ms, duration: 300.ms),

              SizedBox(height: 12.h),

              // App Name
              Text(
                '4Sale',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary700,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3),

              SizedBox(height: 4.h),

              // Tagline
              Text(
                ref.watch(languageProvider).locale == 'ar'
                    ? 'اشتري وبيع أي حاجة'
                    : 'Buy & Sell Anything',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.slate400,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 450.ms),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── PREMIUM TEXT FIELD ──────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════
class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData prefixIcon;
  final String? errorText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;

  const _PremiumTextField({
    required this.controller,
    this.focusNode,
    required this.hintText,
    required this.prefixIcon,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<_PremiumTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hasFocus
                ? Colors.white
                : const Color(0xFFF8F9FA),
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
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.slate800,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.slate400,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(left: 12.w, right: 8.w),
                child: Icon(
                  widget.prefixIcon,
                  color: _hasFocus
                      ? AppColors.primary600
                      : AppColors.slate400,
                  size: 22.w,
                ),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 44.w,
                minHeight: 44.h,
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14.w, color: AppColors.errorRed),
                SizedBox(width: 4.w),
                Text(
                  widget.errorText!,
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              .animate(key: ValueKey(widget.errorText))
              .fadeIn(duration: 200.ms)
              .slideY(begin: -0.3),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ── GRADIENT BUTTON ─────────────────────────────────────────────
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
