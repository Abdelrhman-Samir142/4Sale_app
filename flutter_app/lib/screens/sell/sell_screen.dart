import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/language_provider.dart';
import '../../services/products_service.dart';
import '../../services/classify_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});
  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _priceC = TextEditingController();
  final _locationC = TextEditingController();
  final _phoneC = TextEditingController();
  String _category = 'electronics';
  String _condition = 'good';
  bool _isAuction = false;
  DateTime? _auctionEnd;
  List<XFile> _images = [];
  String? _aiCategory;
  bool _loading = false;
  String? _error;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _priceC.dispose();
    _locationC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked));
      if (_images.isNotEmpty) {
        try {
          final result = await ClassifyService.classifyImage(_images.first.path);
          setState(() {
            _aiCategory = result['category'] as String?;
            if (_aiCategory != null) _category = _aiCategory!;
          });
        } catch (_) {}
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ProductsService.create(
        title: _titleC.text.trim(),
        description: _descC.text.trim(),
        price: double.parse(_priceC.text.trim()),
        category: _category,
        condition: _condition,
        location: _locationC.text.trim(),
        phoneNumber: _phoneC.text.trim(),
        isAuction: _isAuction,
        auctionEndTime: _auctionEnd?.toIso8601String(),
        imagePaths: _images.map((x) => x.path).toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(languageProvider).locale == 'ar'
                ? 'تم نشر الإعلان بنجاح ✅'
                : 'Listing Published Successfully ✅'),
            backgroundColor: AppColors.primary600,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final dict = lang.dict['addItem'] as Map<String, dynamic>;

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              _buildHeader(dict, lang),
              // ── Stepper ─────────────────────────────────
              _buildStepper(dict).animate().fadeIn(delay: 100.ms, duration: 350.ms),
              // ── Content ─────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: [
                    _buildStep0(dict),
                    _buildStep1(dict, lang),
                    _buildStep2(dict, lang),
                  ][_step],
                ),
              ),
              // ── Bottom buttons ──────────────────────────
              _buildBottomButtons(dict),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(Map<String, dynamic> dict, LanguageState lang) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8.w, MediaQuery.of(context).padding.top + 8.h, 8.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.close_rounded, size: 20.w, color: AppColors.slate700),
            ),
            onPressed: () => context.pop(),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dict['title'] as String,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.slate900)),
              Text(lang.locale == 'ar' ? 'أنشر إعلانك في ثوانٍ' : 'List your item in seconds',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.slate400)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepper(Map<String, dynamic> dict) {
    final labels = [dict['step1'] as String, dict['step2'] as String, dict['step3'] as String];
    final icons = [Icons.photo_camera_outlined, Icons.edit_note_rounded, Icons.check_circle_outline_rounded];

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 12.h),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _step;
          final isDone = i < _step;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: isActive ? AppColors.primary500 : const Color(0xFFE2E8F0),
                    ),
                  ),
                Column(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.primary600
                            : isActive
                                ? AppColors.primary600
                                : const Color(0xFFE2E8F0),
                        boxShadow: isActive
                            ? [BoxShadow(color: AppColors.primary600.withAlpha(30), blurRadius: 8, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(Icons.check_rounded, size: 18.w, color: Colors.white)
                            : Icon(icons[i], size: 16.w,
                                color: isActive ? Colors.white : AppColors.slate400),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(labels[i],
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.primary700 : AppColors.slate400,
                        )),
                  ],
                ),
                if (i < 2 && i == 0)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      color: i < _step ? AppColors.primary500 : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 0: Images
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStep0(Map<String, dynamic> dict) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dict['uploadImages'] as String,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.slate800))
            .animate().fadeIn(delay: 100.ms),
        SizedBox(height: 16.h),

        // Upload area
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary500.withAlpha(80),
                width: 1.5,
                // Dashed effect via decoration
              ),
            ),
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: AppColors.primary500.withAlpha(80),
                borderRadius: 16.r,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_photo_alternate_outlined,
                        size: 40.w, color: AppColors.primary600),
                  ),
                  SizedBox(height: 12.h),
                  Text(ref.read(languageProvider).locale == 'ar' ? 'أضف صور' : 'Add Photos',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.slate800)),
                  SizedBox(height: 4.h),
                  Text(ref.read(languageProvider).locale == 'ar'
                          ? 'اضغط لرفع حتى 5 صور'
                          : 'Tap to upload up to 5 photos',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.slate400)),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.97),

        // Image thumbnails
        if (_images.isNotEmpty) ...[
          SizedBox(height: 16.h),
          SizedBox(
            height: 90.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, i) => Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(File(_images[i].path),
                      width: 90.w, height: 90.w, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4.w, right: 4.w,
                  child: GestureDetector(
                    onTap: () => setState(() => _images.removeAt(i)),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed, shape: BoxShape.circle),
                      child: Icon(Icons.close, size: 12.w, color: Colors.white),
                    ),
                  ),
                ),
              ]).animate().fadeIn(delay: (300 + (i * 80)).ms).slideX(begin: 0.15),
            ),
          ),
        ],

        // AI detection badge
        if (_aiCategory != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary200),
            ),
            child: Row(children: [
              Icon(Icons.auto_awesome, size: 18.w, color: AppColors.primary600),
              SizedBox(width: 8.w),
              Text('AI detected: $_aiCategory',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.primary700, fontWeight: FontWeight.w600)),
            ]),
          ).animate().fadeIn(delay: 400.ms),
        ],

        // Tips card
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.primary600.withAlpha(8),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.primary600.withAlpha(30)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lightbulb_outline_rounded, size: 20.w, color: AppColors.primary600),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ref.read(languageProvider).locale == 'ar' ? 'نصائح للصور' : 'Photo Tips',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primary700)),
                SizedBox(height: 4.h),
                Text(ref.read(languageProvider).locale == 'ar'
                        ? '• الصور الجيدة بتجيب 3x مشاهدات أكتر\n• استخدم إضاءة طبيعية'
                        : '• Good photos get 3x more views\n• Use natural lighting',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.slate500, height: 1.5)),
              ]),
            ),
          ]),
        ).animate().fadeIn(delay: 350.ms),

        if (_error != null) ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withAlpha(15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.errorRed.withAlpha(50)),
            ),
            child: Row(children: [
              Icon(Icons.error_outline, size: 18.w, color: AppColors.errorRed),
              SizedBox(width: 8.w),
              Expanded(child: Text(_error!, style: TextStyle(color: AppColors.errorRed, fontSize: 12.sp))),
            ]),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 1: Details
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStep1(Map<String, dynamic> dict, LanguageState lang) {
    final reqMsg = lang.locale == 'ar' ? 'مطلوب' : 'Required';
    return Column(children: [
      _styledField(_titleC, dict['productName'] as String, dict['productNamePlaceholder'] as String,
          Icons.label_outline_rounded, reqMsg),
      SizedBox(height: 14.h),
      _styledField(_descC, dict['description'] as String, null,
          Icons.description_outlined, reqMsg, maxLines: 4),
      SizedBox(height: 14.h),
      _styledField(_priceC, dict['expectedPrice'] as String, null,
          Icons.attach_money_rounded, reqMsg, keyboardType: TextInputType.number,
          suffix: lang.dict['currency'] as String),
      SizedBox(height: 14.h),
      _styledDropdown(dict['category'] as String, Icons.category_outlined, _category,
          [
            DropdownMenuItem(value: 'electronics', child: Text(dict['electronics'] as String)),
            DropdownMenuItem(value: 'furniture', child: Text(dict['furniture'] as String)),
            DropdownMenuItem(value: 'scrap_metals', child: Text(dict['scrap'] as String)),
            DropdownMenuItem(value: 'other', child: Text(dict['other'] as String)),
          ], (v) => setState(() => _category = v!)),
      SizedBox(height: 14.h),
      _styledDropdown(dict['condition'] as String, Icons.verified_outlined, _condition,
          [
            DropdownMenuItem(value: 'new', child: Text(dict['conditionNew'] as String)),
            DropdownMenuItem(value: 'like-new', child: Text(dict['conditionLikeNew'] as String)),
            DropdownMenuItem(value: 'good', child: Text(dict['conditionGood'] as String)),
            DropdownMenuItem(value: 'fair', child: Text(dict['conditionFair'] as String)),
          ], (v) => setState(() => _condition = v!)),
      SizedBox(height: 14.h),
      _styledField(_locationC, dict['location'] as String, null,
          Icons.location_on_outlined, reqMsg),
      SizedBox(height: 14.h),
      _styledField(_phoneC, dict['phone'] as String, null,
          Icons.phone_outlined, null, keyboardType: TextInputType.phone),
    ]);
  }

  Widget _styledField(TextEditingController controller, String label, String? hint,
      IconData icon, String? requiredMsg, {int maxLines = 1, TextInputType? keyboardType, String? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(fontSize: 14.sp, color: AppColors.slate500),
          hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.slate400),
          prefixIcon: Icon(icon, size: 20.w, color: AppColors.primary600),
          suffixText: suffix,
          suffixStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        validator: requiredMsg != null
            ? (v) => v == null || v.isEmpty ? requiredMsg : null
            : null,
      ),
    );
  }

  Widget _styledDropdown(String label, IconData icon, String value,
      List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14.sp, color: AppColors.slate500),
          prefixIcon: Icon(icon, size: 20.w, color: AppColors.primary600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        style: TextStyle(fontSize: 14.sp, color: AppColors.slate800),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 2: Review
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStep2(Map<String, dynamic> dict, LanguageState lang) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Auction toggle
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: SwitchListTile(
          value: _isAuction,
          onChanged: (v) => setState(() => _isAuction = v),
          title: Text(dict['isAuction'] as String,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          secondary: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.auctionOrange.withAlpha(20),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.gavel_rounded, color: AppColors.auctionOrange, size: 20.w),
          ),
          activeThumbColor: AppColors.primary600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
      if (_isAuction) ...[
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            leading: Icon(Icons.calendar_today_rounded, color: AppColors.primary600),
            title: Text(dict['auctionEndTime'] as String,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            subtitle: Text(_auctionEnd?.toString() ??
                (lang.locale == 'ar' ? 'اختر وقت الانتهاء' : 'Select End Time'),
                style: TextStyle(fontSize: 12.sp, color: AppColors.slate400)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null && mounted) {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) {
                  setState(() => _auctionEnd = DateTime(
                      date.year, date.month, date.day, time.hour, time.minute));
                }
              }
            },
          ),
        ),
      ],
      SizedBox(height: 20.h),

      // AI notice
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primary200),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome, color: AppColors.primary600, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(child: Text(dict['aiNotice'] as String,
              style: TextStyle(fontSize: 12.sp, color: AppColors.primary700, height: 1.4))),
        ]),
      ),
      SizedBox(height: 20.h),

      // Summary
      Text(lang.locale == 'ar' ? 'ملخص الإعلان' : 'Listing Summary',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.slate800)),
      SizedBox(height: 12.h),
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          _summaryRow(dict['productName'] as String, _titleC.text),
          _summaryRow(dict['expectedPrice'] as String, '${_priceC.text} ${lang.dict['currency']}'),
          _summaryRow(dict['category'] as String, _category),
          _summaryRow(dict['condition'] as String, _condition),
          _summaryRow(dict['location'] as String, _locationC.text),
          _summaryRow(dict['uploadImages'] as String,
              '${_images.length} ${lang.locale == 'ar' ? 'صور' : 'Images'}'),
        ]),
      ),
    ]);
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(children: [
        Text('$label:', style: TextStyle(fontSize: 13.sp, color: AppColors.slate400, fontWeight: FontWeight.w500)),
        SizedBox(width: 8.w),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.slate800))),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomButtons(Map<String, dynamic> dict) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).padding.bottom + 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        if (_step > 0) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _step--),
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(dict['previous'] as String,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.slate600)),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          flex: _step > 0 ? 2 : 1,
          child: _GradientButton(
            text: _step < 2 ? dict['next'] as String : dict['publish'] as String,
            isLoading: _loading,
            onPressed: _step < 2 ? () => setState(() => _step++) : _submit,
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DASHED BORDER PAINTER
// ═══════════════════════════════════════════════════════════════════
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(borderRadius)));

    // Draw dashed path
    final dashWidth = 8.0;
    final dashSpace = 5.0;
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final length = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, length), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
// GRADIENT BUTTON
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
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.forward(),
        onTapUp: (_) { _scaleCtrl.reverse(); if (!widget.isLoading) widget.onPressed(); },
        onTapCancel: () => _scaleCtrl.reverse(),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary700, AppColors.primary500],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(color: AppColors.primary600.withAlpha(50), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(widget.text,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
