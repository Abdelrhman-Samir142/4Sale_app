// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductImage _$ProductImageFromJson(Map<String, dynamic> json) =>
    _ProductImage(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String,
    );

Map<String, dynamic> _$ProductImageToJson(_ProductImage instance) =>
    <String, dynamic>{'id': instance.id, 'image': instance.image};

_ProductSeller _$ProductSellerFromJson(Map<String, dynamic> json) =>
    _ProductSeller(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      trustScore: (json['trust_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProductSellerToJson(_ProductSeller instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'trust_score': instance.trustScore,
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  price: json['price'] as String,
  category: json['category'] as String,
  condition: json['condition'] as String,
  location: json['location'] as String,
  phoneNumber: json['phone_number'] as String?,
  isAuction: json['is_auction'] as bool? ?? false,
  auctionEndTime: json['auction_end_time'] == null
      ? null
      : DateTime.parse(json['auction_end_time'] as String),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  seller: json['seller'] == null
      ? null
      : ProductSeller.fromJson(json['seller'] as Map<String, dynamic>),
  primaryImage: json['primary_image'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isWishlisted: json['is_wishlisted'] as bool? ?? false,
  aiAnalysisSummary: json['ai_analysis_summary'] as String?,
  fraudScore: (json['fraud_score'] as num?)?.toDouble(),
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  auction: json['auction'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'price': instance.price,
  'category': instance.category,
  'condition': instance.condition,
  'location': instance.location,
  'phone_number': instance.phoneNumber,
  'is_auction': instance.isAuction,
  'auction_end_time': instance.auctionEndTime?.toIso8601String(),
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'seller': instance.seller,
  'primary_image': instance.primaryImage,
  'images': instance.images,
  'is_wishlisted': instance.isWishlisted,
  'ai_analysis_summary': instance.aiAnalysisSummary,
  'fraud_score': instance.fraudScore,
  'views_count': instance.viewsCount,
  'auction': instance.auction,
};
