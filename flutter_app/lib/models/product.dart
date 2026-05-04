import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class ProductImage with _$ProductImage {
  const factory ProductImage({
    required int id,
    required String image,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
}

@freezed
abstract class ProductSeller with _$ProductSeller {
  const factory ProductSeller({
    required int id,
    required String username,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'trust_score') double? trustScore,
  }) = _ProductSeller;

  factory ProductSeller.fromJson(Map<String, dynamic> json) => _$ProductSellerFromJson(json);
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    required int id,
    required String title,
    required String description,
    required String price,
    required String category,
    required String condition,
    required String location,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'is_auction') @Default(false) bool isAuction,
    @JsonKey(name: 'auction_end_time') DateTime? auctionEndTime,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    ProductSeller? seller,
    @JsonKey(name: 'primary_image') String? primaryImage,
    @Default([]) List<ProductImage> images,
    @JsonKey(name: 'is_wishlisted') @Default(false) bool isWishlisted,
    @JsonKey(name: 'ai_analysis_summary') String? aiAnalysisSummary,
    @JsonKey(name: 'fraud_score') double? fraudScore,
    @JsonKey(name: 'views_count') @Default(0) int viewsCount,
    Map<String, dynamic>? auction,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
