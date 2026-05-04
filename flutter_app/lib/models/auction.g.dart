// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bid _$BidFromJson(Map<String, dynamic> json) => _Bid(
  id: (json['id'] as num).toInt(),
  bidder: ProductSeller.fromJson(json['bidder'] as Map<String, dynamic>),
  amount: json['amount'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BidToJson(_Bid instance) => <String, dynamic>{
  'id': instance.id,
  'bidder': instance.bidder,
  'amount': instance.amount,
  'created_at': instance.createdAt.toIso8601String(),
};

_Auction _$AuctionFromJson(Map<String, dynamic> json) => _Auction(
  id: (json['id'] as num).toInt(),
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  currentHighestBid: json['current_highest_bid'] as String?,
  endTime: DateTime.parse(json['end_time'] as String),
  isActive: json['is_active'] as bool? ?? true,
  bids:
      (json['bids'] as List<dynamic>?)
          ?.map((e) => Bid.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AuctionToJson(_Auction instance) => <String, dynamic>{
  'id': instance.id,
  'product': instance.product,
  'current_highest_bid': instance.currentHighestBid,
  'end_time': instance.endTime.toIso8601String(),
  'is_active': instance.isActive,
  'bids': instance.bids,
};
