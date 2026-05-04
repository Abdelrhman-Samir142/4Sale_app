import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';

part 'auction.freezed.dart';
part 'auction.g.dart';

@freezed
abstract class Bid with _$Bid {
  const factory Bid({
    required int id,
    required ProductSeller bidder,
    required String amount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Bid;

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
}

@freezed
abstract class Auction with _$Auction {
  const factory Auction({
    required int id,
    required Product product,
    @JsonKey(name: 'current_highest_bid') String? currentHighestBid,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @Default([]) List<Bid> bids,
  }) = _Auction;

  factory Auction.fromJson(Map<String, dynamic> json) => _$AuctionFromJson(json);
}
