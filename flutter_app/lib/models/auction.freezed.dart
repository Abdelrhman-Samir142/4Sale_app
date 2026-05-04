// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bid {

 int get id; ProductSeller get bidder; String get amount;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidCopyWith<Bid> get copyWith => _$BidCopyWithImpl<Bid>(this as Bid, _$identity);

  /// Serializes this Bid to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.bidder, bidder) || other.bidder == bidder)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bidder,amount,createdAt);

@override
String toString() {
  return 'Bid(id: $id, bidder: $bidder, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BidCopyWith<$Res>  {
  factory $BidCopyWith(Bid value, $Res Function(Bid) _then) = _$BidCopyWithImpl;
@useResult
$Res call({
 int id, ProductSeller bidder, String amount,@JsonKey(name: 'created_at') DateTime createdAt
});


$ProductSellerCopyWith<$Res> get bidder;

}
/// @nodoc
class _$BidCopyWithImpl<$Res>
    implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._self, this._then);

  final Bid _self;
  final $Res Function(Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bidder = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bidder: null == bidder ? _self.bidder : bidder // ignore: cast_nullable_to_non_nullable
as ProductSeller,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductSellerCopyWith<$Res> get bidder {
  
  return $ProductSellerCopyWith<$Res>(_self.bidder, (value) {
    return _then(_self.copyWith(bidder: value));
  });
}
}


/// Adds pattern-matching-related methods to [Bid].
extension BidPatterns on Bid {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bid value)  $default,){
final _that = this;
switch (_that) {
case _Bid():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bid value)?  $default,){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  ProductSeller bidder,  String amount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.bidder,_that.amount,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  ProductSeller bidder,  String amount, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Bid():
return $default(_that.id,_that.bidder,_that.amount,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  ProductSeller bidder,  String amount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.bidder,_that.amount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bid implements Bid {
  const _Bid({required this.id, required this.bidder, required this.amount, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

@override final  int id;
@override final  ProductSeller bidder;
@override final  String amount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidCopyWith<_Bid> get copyWith => __$BidCopyWithImpl<_Bid>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.bidder, bidder) || other.bidder == bidder)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bidder,amount,createdAt);

@override
String toString() {
  return 'Bid(id: $id, bidder: $bidder, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BidCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$BidCopyWith(_Bid value, $Res Function(_Bid) _then) = __$BidCopyWithImpl;
@override @useResult
$Res call({
 int id, ProductSeller bidder, String amount,@JsonKey(name: 'created_at') DateTime createdAt
});


@override $ProductSellerCopyWith<$Res> get bidder;

}
/// @nodoc
class __$BidCopyWithImpl<$Res>
    implements _$BidCopyWith<$Res> {
  __$BidCopyWithImpl(this._self, this._then);

  final _Bid _self;
  final $Res Function(_Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bidder = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_Bid(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bidder: null == bidder ? _self.bidder : bidder // ignore: cast_nullable_to_non_nullable
as ProductSeller,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductSellerCopyWith<$Res> get bidder {
  
  return $ProductSellerCopyWith<$Res>(_self.bidder, (value) {
    return _then(_self.copyWith(bidder: value));
  });
}
}


/// @nodoc
mixin _$Auction {

 int get id; Product get product;@JsonKey(name: 'current_highest_bid') String? get currentHighestBid;@JsonKey(name: 'end_time') DateTime get endTime;@JsonKey(name: 'is_active') bool get isActive; List<Bid> get bids;
/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionCopyWith<Auction> get copyWith => _$AuctionCopyWithImpl<Auction>(this as Auction, _$identity);

  /// Serializes this Auction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Auction&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.currentHighestBid, currentHighestBid) || other.currentHighestBid == currentHighestBid)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.bids, bids));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,currentHighestBid,endTime,isActive,const DeepCollectionEquality().hash(bids));

@override
String toString() {
  return 'Auction(id: $id, product: $product, currentHighestBid: $currentHighestBid, endTime: $endTime, isActive: $isActive, bids: $bids)';
}


}

/// @nodoc
abstract mixin class $AuctionCopyWith<$Res>  {
  factory $AuctionCopyWith(Auction value, $Res Function(Auction) _then) = _$AuctionCopyWithImpl;
@useResult
$Res call({
 int id, Product product,@JsonKey(name: 'current_highest_bid') String? currentHighestBid,@JsonKey(name: 'end_time') DateTime endTime,@JsonKey(name: 'is_active') bool isActive, List<Bid> bids
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class _$AuctionCopyWithImpl<$Res>
    implements $AuctionCopyWith<$Res> {
  _$AuctionCopyWithImpl(this._self, this._then);

  final Auction _self;
  final $Res Function(Auction) _then;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? currentHighestBid = freezed,Object? endTime = null,Object? isActive = null,Object? bids = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,currentHighestBid: freezed == currentHighestBid ? _self.currentHighestBid : currentHighestBid // ignore: cast_nullable_to_non_nullable
as String?,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,
  ));
}
/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [Auction].
extension AuctionPatterns on Auction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Auction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Auction value)  $default,){
final _that = this;
switch (_that) {
case _Auction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Auction value)?  $default,){
final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  Product product, @JsonKey(name: 'current_highest_bid')  String? currentHighestBid, @JsonKey(name: 'end_time')  DateTime endTime, @JsonKey(name: 'is_active')  bool isActive,  List<Bid> bids)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that.id,_that.product,_that.currentHighestBid,_that.endTime,_that.isActive,_that.bids);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  Product product, @JsonKey(name: 'current_highest_bid')  String? currentHighestBid, @JsonKey(name: 'end_time')  DateTime endTime, @JsonKey(name: 'is_active')  bool isActive,  List<Bid> bids)  $default,) {final _that = this;
switch (_that) {
case _Auction():
return $default(_that.id,_that.product,_that.currentHighestBid,_that.endTime,_that.isActive,_that.bids);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  Product product, @JsonKey(name: 'current_highest_bid')  String? currentHighestBid, @JsonKey(name: 'end_time')  DateTime endTime, @JsonKey(name: 'is_active')  bool isActive,  List<Bid> bids)?  $default,) {final _that = this;
switch (_that) {
case _Auction() when $default != null:
return $default(_that.id,_that.product,_that.currentHighestBid,_that.endTime,_that.isActive,_that.bids);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Auction implements Auction {
  const _Auction({required this.id, required this.product, @JsonKey(name: 'current_highest_bid') this.currentHighestBid, @JsonKey(name: 'end_time') required this.endTime, @JsonKey(name: 'is_active') this.isActive = true, final  List<Bid> bids = const []}): _bids = bids;
  factory _Auction.fromJson(Map<String, dynamic> json) => _$AuctionFromJson(json);

@override final  int id;
@override final  Product product;
@override@JsonKey(name: 'current_highest_bid') final  String? currentHighestBid;
@override@JsonKey(name: 'end_time') final  DateTime endTime;
@override@JsonKey(name: 'is_active') final  bool isActive;
 final  List<Bid> _bids;
@override@JsonKey() List<Bid> get bids {
  if (_bids is EqualUnmodifiableListView) return _bids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bids);
}


/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionCopyWith<_Auction> get copyWith => __$AuctionCopyWithImpl<_Auction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Auction&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.currentHighestBid, currentHighestBid) || other.currentHighestBid == currentHighestBid)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._bids, _bids));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,product,currentHighestBid,endTime,isActive,const DeepCollectionEquality().hash(_bids));

@override
String toString() {
  return 'Auction(id: $id, product: $product, currentHighestBid: $currentHighestBid, endTime: $endTime, isActive: $isActive, bids: $bids)';
}


}

/// @nodoc
abstract mixin class _$AuctionCopyWith<$Res> implements $AuctionCopyWith<$Res> {
  factory _$AuctionCopyWith(_Auction value, $Res Function(_Auction) _then) = __$AuctionCopyWithImpl;
@override @useResult
$Res call({
 int id, Product product,@JsonKey(name: 'current_highest_bid') String? currentHighestBid,@JsonKey(name: 'end_time') DateTime endTime,@JsonKey(name: 'is_active') bool isActive, List<Bid> bids
});


@override $ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$AuctionCopyWithImpl<$Res>
    implements _$AuctionCopyWith<$Res> {
  __$AuctionCopyWithImpl(this._self, this._then);

  final _Auction _self;
  final $Res Function(_Auction) _then;

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? currentHighestBid = freezed,Object? endTime = null,Object? isActive = null,Object? bids = null,}) {
  return _then(_Auction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,currentHighestBid: freezed == currentHighestBid ? _self.currentHighestBid : currentHighestBid // ignore: cast_nullable_to_non_nullable
as String?,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,bids: null == bids ? _self._bids : bids // ignore: cast_nullable_to_non_nullable
as List<Bid>,
  ));
}

/// Create a copy of Auction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

// dart format on
