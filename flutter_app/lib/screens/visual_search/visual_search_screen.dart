import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/language_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class VisualSearchScreen extends ConsumerStatefulWidget {
  const VisualSearchScreen({super.key});
  @override
  ConsumerState<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends ConsumerState<VisualSearchScreen> {
  File? _selectedImage;
  List<dynamic> _results = [];
  bool _searching = false;
  String? _error;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _results = [];
          _error = null;
        });
        _search();
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _search() async {
    if (_selectedImage == null) return;
    setState(() {
      _searching = true;
      _error = null;
    });

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_selectedImage!.path),
      });

      final response = await DioClient.instance.post(
        ApiConstants.visualSearch,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          // Visual search needs more time (OpenRouter embedding calls)
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (mounted) {
        setState(() {
          _results = (response.data['results'] as List?) ?? [];
          _searching = false;
        });
      }
    } catch (e) {
      debugPrint('[VisualSearch] Error: $e');
      if (mounted) {
        final isAr = ref.read(languageProvider).locale == 'ar';
        String errorMsg;
        if (e is DioException && e.type == DioExceptionType.connectionTimeout) {
          errorMsg = isAr ? 'انتهت المهلة. حاول مرة أخرى.' : 'Request timed out. Try again.';
        } else if (e is DioException && e.type == DioExceptionType.receiveTimeout) {
          errorMsg = isAr ? 'الخادم بطيء. حاول مرة أخرى.' : 'Server is slow. Try again.';
        } else {
          errorMsg = isAr ? 'فشل البحث. حاول مرة أخرى.' : 'Search failed. Try again.';
        }
        setState(() {
          _error = errorMsg;
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isAr = lang.locale == 'ar';
    final currency = lang.dict['currency'] as String;

    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeader(isAr),
              ),
              // ── Image Preview ───────────────────────
              SliverToBoxAdapter(
                child: _buildImageSection(isAr),
              ),
              // ── Results ─────────────────────────────
              if (_searching)
                SliverToBoxAdapter(child: _buildLoading(isAr))
              else if (_error != null)
                SliverToBoxAdapter(child: _buildError())
              else if (_results.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    child: Text(
                      isAr ? '${_results.length} نتيجة مشابهة' : '${_results.length} similar results',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.slate700),
                    ),
                  ).animate().fadeIn(),
                ),
              if (_results.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ResultCard(
                        result: _results[i],
                        currency: currency,
                        isAr: isAr,
                      ).animate()
                          .fadeIn(delay: Duration(milliseconds: 100 + i * 80))
                          .slideY(begin: 0.08, end: 0),
                      childCount: _results.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 40.h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: 20.w, color: AppColors.slate700),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'بحث بالصورة' : 'Image Search',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.slate900),
                    ),
                    Text(
                      isAr ? 'ارفع صورة وهنلاقيلك منتجات مشابهة' : 'Upload an image to find similar products',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildImageSection(bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Image preview
          GestureDetector(
            onTap: () => _showPickerSheet(isAr),
            child: Container(
              height: 220.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppColors.successGreen.withAlpha(60)
                      : AppColors.slate200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _selectedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_selectedImage!, fit: BoxFit.cover),
                        Positioned(
                          top: 10.w, right: 10.w,
                          child: GestureDetector(
                            onTap: () => _showPickerSheet(isAr),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(100),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.refresh_rounded, size: 18.w, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withAlpha(12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_photo_alternate_rounded, size: 36.w, color: AppColors.successGreen),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          isAr ? 'اضغط لرفع صورة' : 'Tap to upload image',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.slate500),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          isAr ? 'التقط صورة أو اختر من المعرض' : 'Take a photo or pick from gallery',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.slate400),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 12.h),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.camera_alt_rounded,
                  label: isAr ? 'كاميرا' : 'Camera',
                  color: AppColors.latestBlue,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.photo_library_rounded,
                  label: isAr ? 'المعرض' : 'Gallery',
                  color: AppColors.successGreen,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  void _showPickerSheet(bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(2.r)),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: AppColors.latestBlue.withAlpha(15), borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.latestBlue),
              ),
              title: Text(isAr ? 'التقط صورة' : 'Take Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp)),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: AppColors.successGreen.withAlpha(15), borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.photo_library_rounded, color: AppColors.successGreen),
              ),
              title: Text(isAr ? 'اختر من المعرض' : 'Pick from Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp)),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(bool isAr) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          SizedBox(
            width: 40.w, height: 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.successGreen),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            isAr ? 'جاري البحث عن منتجات مشابهة...' : 'Searching for similar products...',
            style: TextStyle(fontSize: 13.sp, color: AppColors.slate500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildError() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 48.w, color: AppColors.errorRed.withAlpha(120)),
          SizedBox(height: 12.h),
          Text(_error!, style: TextStyle(fontSize: 14.sp, color: AppColors.slate600, fontWeight: FontWeight.w600)),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: _search,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.w, color: color),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final dynamic result;
  final String currency;
  final bool isAr;

  const _ResultCard({required this.result, required this.currency, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final title = result['title'] as String? ?? '';
    final price = result['price']?.toString() ?? '0';
    final imageUrl = result['primary_image'] as String?;
    final similarity = result['similarity']?.toString() ?? '0';
    final ownerName = result['owner_name'] as String? ?? '';
    final id = result['id'].toString();
    final isAuction = result['is_auction'] == true;

    return GestureDetector(
      onTap: () => context.push('/product/$id'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColors.slate100,
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                  : Icon(Icons.image_outlined, size: 32.w, color: AppColors.slate300),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.slate800)),
                  SizedBox(height: 4.h),
                  if (ownerName.isNotEmpty)
                    Row(children: [
                      Icon(Icons.person_outline_rounded, size: 12.w, color: AppColors.slate400),
                      SizedBox(width: 3.w),
                      Text(ownerName, style: TextStyle(fontSize: 11.sp, color: AppColors.slate500)),
                    ]),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        '${double.tryParse(price)?.toStringAsFixed(0) ?? price} $currency',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: isAuction ? AppColors.auctionOrange : AppColors.primary600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withAlpha(15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$similarity%',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.successGreen),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
