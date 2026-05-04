// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductImage {

 int get id; String get image;
/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductImageCopyWith<ProductImage> get copyWith => _$ProductImageCopyWithImpl<ProductImage>(this as ProductImage, _$identity);

  /// Serializes this ProductImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductImage&&(identical(other.id, id) || other.id == id)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,image);

@override
String toString() {
  return 'ProductImage(id: $id, image: $image)';
}


}

/// @nodoc
abstract mixin class $ProductImageCopyWith<$Res>  {
  factory $ProductImageCopyWith(ProductImage value, $Res Function(ProductImage) _then) = _$ProductImageCopyWithImpl;
@useResult
$Res call({
 int id, String image
});




}
/// @nodoc
class _$ProductImageCopyWithImpl<$Res>
    implements $ProductImageCopyWith<$Res> {
  _$ProductImageCopyWithImpl(this._self, this._then);

  final ProductImage _self;
  final $Res Function(ProductImage) _then;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? image = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductImage].
extension ProductImagePatterns on ProductImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductImage value)  $default,){
final _that = this;
switch (_that) {
case _ProductImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductImage value)?  $default,){
final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String image)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
return $default(_that.id,_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String image)  $default,) {final _that = this;
switch (_that) {
case _ProductImage():
return $default(_that.id,_that.image);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String image)?  $default,) {final _that = this;
switch (_that) {
case _ProductImage() when $default != null:
return $default(_that.id,_that.image);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductImage implements ProductImage {
  const _ProductImage({required this.id, required this.image});
  factory _ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);

@override final  int id;
@override final  String image;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductImageCopyWith<_ProductImage> get copyWith => __$ProductImageCopyWithImpl<_ProductImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductImage&&(identical(other.id, id) || other.id == id)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,image);

@override
String toString() {
  return 'ProductImage(id: $id, image: $image)';
}


}

/// @nodoc
abstract mixin class _$ProductImageCopyWith<$Res> implements $ProductImageCopyWith<$Res> {
  factory _$ProductImageCopyWith(_ProductImage value, $Res Function(_ProductImage) _then) = __$ProductImageCopyWithImpl;
@override @useResult
$Res call({
 int id, String image
});




}
/// @nodoc
class __$ProductImageCopyWithImpl<$Res>
    implements _$ProductImageCopyWith<$Res> {
  __$ProductImageCopyWithImpl(this._self, this._then);

  final _ProductImage _self;
  final $Res Function(_ProductImage) _then;

/// Create a copy of ProductImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? image = null,}) {
  return _then(_ProductImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProductSeller {

 int get id; String get username;@JsonKey(name: 'first_name') String? get firstName;@JsonKey(name: 'last_name') String? get lastName;@JsonKey(name: 'trust_score') double? get trustScore;
/// Create a copy of ProductSeller
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductSellerCopyWith<ProductSeller> get copyWith => _$ProductSellerCopyWithImpl<ProductSeller>(this as ProductSeller, _$identity);

  /// Serializes this ProductSeller to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductSeller&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,firstName,lastName,trustScore);

@override
String toString() {
  return 'ProductSeller(id: $id, username: $username, firstName: $firstName, lastName: $lastName, trustScore: $trustScore)';
}


}

/// @nodoc
abstract mixin class $ProductSellerCopyWith<$Res>  {
  factory $ProductSellerCopyWith(ProductSeller value, $Res Function(ProductSeller) _then) = _$ProductSellerCopyWithImpl;
@useResult
$Res call({
 int id, String username,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName,@JsonKey(name: 'trust_score') double? trustScore
});




}
/// @nodoc
class _$ProductSellerCopyWithImpl<$Res>
    implements $ProductSellerCopyWith<$Res> {
  _$ProductSellerCopyWithImpl(this._self, this._then);

  final ProductSeller _self;
  final $Res Function(ProductSeller) _then;

/// Create a copy of ProductSeller
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? trustScore = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,trustScore: freezed == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductSeller].
extension ProductSellerPatterns on ProductSeller {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductSeller value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductSeller() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductSeller value)  $default,){
final _that = this;
switch (_that) {
case _ProductSeller():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductSeller value)?  $default,){
final _that = this;
switch (_that) {
case _ProductSeller() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String username, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'trust_score')  double? trustScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductSeller() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.trustScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String username, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'trust_score')  double? trustScore)  $default,) {final _that = this;
switch (_that) {
case _ProductSeller():
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.trustScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String username, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'trust_score')  double? trustScore)?  $default,) {final _that = this;
switch (_that) {
case _ProductSeller() when $default != null:
return $default(_that.id,_that.username,_that.firstName,_that.lastName,_that.trustScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductSeller implements ProductSeller {
  const _ProductSeller({required this.id, required this.username, @JsonKey(name: 'first_name') this.firstName, @JsonKey(name: 'last_name') this.lastName, @JsonKey(name: 'trust_score') this.trustScore});
  factory _ProductSeller.fromJson(Map<String, dynamic> json) => _$ProductSellerFromJson(json);

@override final  int id;
@override final  String username;
@override@JsonKey(name: 'first_name') final  String? firstName;
@override@JsonKey(name: 'last_name') final  String? lastName;
@override@JsonKey(name: 'trust_score') final  double? trustScore;

/// Create a copy of ProductSeller
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductSellerCopyWith<_ProductSeller> get copyWith => __$ProductSellerCopyWithImpl<_ProductSeller>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductSellerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductSeller&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,firstName,lastName,trustScore);

@override
String toString() {
  return 'ProductSeller(id: $id, username: $username, firstName: $firstName, lastName: $lastName, trustScore: $trustScore)';
}


}

/// @nodoc
abstract mixin class _$ProductSellerCopyWith<$Res> implements $ProductSellerCopyWith<$Res> {
  factory _$ProductSellerCopyWith(_ProductSeller value, $Res Function(_ProductSeller) _then) = __$ProductSellerCopyWithImpl;
@override @useResult
$Res call({
 int id, String username,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'last_name') String? lastName,@JsonKey(name: 'trust_score') double? trustScore
});




}
/// @nodoc
class __$ProductSellerCopyWithImpl<$Res>
    implements _$ProductSellerCopyWith<$Res> {
  __$ProductSellerCopyWithImpl(this._self, this._then);

  final _ProductSeller _self;
  final $Res Function(_ProductSeller) _then;

/// Create a copy of ProductSeller
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? firstName = freezed,Object? lastName = freezed,Object? trustScore = freezed,}) {
  return _then(_ProductSeller(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,trustScore: freezed == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$Product {

 int get id; String get title; String get description; String get price; String get category; String get condition; String get location;@JsonKey(name: 'phone_number') String? get phoneNumber;@JsonKey(name: 'is_auction') bool get isAuction;@JsonKey(name: 'auction_end_time') DateTime? get auctionEndTime; String get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt; ProductSeller? get seller;@JsonKey(name: 'primary_image') String? get primaryImage; List<ProductImage> get images;@JsonKey(name: 'is_wishlisted') bool get isWishlisted;@JsonKey(name: 'ai_analysis_summary') String? get aiAnalysisSummary;@JsonKey(name: 'fraud_score') double? get fraudScore;@JsonKey(name: 'views_count') int get viewsCount; Map<String, dynamic>? get auction;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.location, location) || other.location == location)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isAuction, isAuction) || other.isAuction == isAuction)&&(identical(other.auctionEndTime, auctionEndTime) || other.auctionEndTime == auctionEndTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.primaryImage, primaryImage) || other.primaryImage == primaryImage)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.isWishlisted, isWishlisted) || other.isWishlisted == isWishlisted)&&(identical(other.aiAnalysisSummary, aiAnalysisSummary) || other.aiAnalysisSummary == aiAnalysisSummary)&&(identical(other.fraudScore, fraudScore) || other.fraudScore == fraudScore)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&const DeepCollectionEquality().equals(other.auction, auction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,price,category,condition,location,phoneNumber,isAuction,auctionEndTime,status,createdAt,updatedAt,seller,primaryImage,const DeepCollectionEquality().hash(images),isWishlisted,aiAnalysisSummary,fraudScore,viewsCount,const DeepCollectionEquality().hash(auction)]);

@override
String toString() {
  return 'Product(id: $id, title: $title, description: $description, price: $price, category: $category, condition: $condition, location: $location, phoneNumber: $phoneNumber, isAuction: $isAuction, auctionEndTime: $auctionEndTime, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, seller: $seller, primaryImage: $primaryImage, images: $images, isWishlisted: $isWishlisted, aiAnalysisSummary: $aiAnalysisSummary, fraudScore: $fraudScore, viewsCount: $viewsCount, auction: $auction)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 int id, String title, String description, String price, String category, String condition, String location,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'is_auction') bool isAuction,@JsonKey(name: 'auction_end_time') DateTime? auctionEndTime, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, ProductSeller? seller,@JsonKey(name: 'primary_image') String? primaryImage, List<ProductImage> images,@JsonKey(name: 'is_wishlisted') bool isWishlisted,@JsonKey(name: 'ai_analysis_summary') String? aiAnalysisSummary,@JsonKey(name: 'fraud_score') double? fraudScore,@JsonKey(name: 'views_count') int viewsCount, Map<String, dynamic>? auction
});


$ProductSellerCopyWith<$Res>? get seller;

}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? price = null,Object? category = null,Object? condition = null,Object? location = null,Object? phoneNumber = freezed,Object? isAuction = null,Object? auctionEndTime = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? seller = freezed,Object? primaryImage = freezed,Object? images = null,Object? isWishlisted = null,Object? aiAnalysisSummary = freezed,Object? fraudScore = freezed,Object? viewsCount = null,Object? auction = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isAuction: null == isAuction ? _self.isAuction : isAuction // ignore: cast_nullable_to_non_nullable
as bool,auctionEndTime: freezed == auctionEndTime ? _self.auctionEndTime : auctionEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as ProductSeller?,primaryImage: freezed == primaryImage ? _self.primaryImage : primaryImage // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,isWishlisted: null == isWishlisted ? _self.isWishlisted : isWishlisted // ignore: cast_nullable_to_non_nullable
as bool,aiAnalysisSummary: freezed == aiAnalysisSummary ? _self.aiAnalysisSummary : aiAnalysisSummary // ignore: cast_nullable_to_non_nullable
as String?,fraudScore: freezed == fraudScore ? _self.fraudScore : fraudScore // ignore: cast_nullable_to_non_nullable
as double?,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,auction: freezed == auction ? _self.auction : auction // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductSellerCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $ProductSellerCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String description,  String price,  String category,  String condition,  String location, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'is_auction')  bool isAuction, @JsonKey(name: 'auction_end_time')  DateTime? auctionEndTime,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  ProductSeller? seller, @JsonKey(name: 'primary_image')  String? primaryImage,  List<ProductImage> images, @JsonKey(name: 'is_wishlisted')  bool isWishlisted, @JsonKey(name: 'ai_analysis_summary')  String? aiAnalysisSummary, @JsonKey(name: 'fraud_score')  double? fraudScore, @JsonKey(name: 'views_count')  int viewsCount,  Map<String, dynamic>? auction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.category,_that.condition,_that.location,_that.phoneNumber,_that.isAuction,_that.auctionEndTime,_that.status,_that.createdAt,_that.updatedAt,_that.seller,_that.primaryImage,_that.images,_that.isWishlisted,_that.aiAnalysisSummary,_that.fraudScore,_that.viewsCount,_that.auction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String description,  String price,  String category,  String condition,  String location, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'is_auction')  bool isAuction, @JsonKey(name: 'auction_end_time')  DateTime? auctionEndTime,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  ProductSeller? seller, @JsonKey(name: 'primary_image')  String? primaryImage,  List<ProductImage> images, @JsonKey(name: 'is_wishlisted')  bool isWishlisted, @JsonKey(name: 'ai_analysis_summary')  String? aiAnalysisSummary, @JsonKey(name: 'fraud_score')  double? fraudScore, @JsonKey(name: 'views_count')  int viewsCount,  Map<String, dynamic>? auction)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.title,_that.description,_that.price,_that.category,_that.condition,_that.location,_that.phoneNumber,_that.isAuction,_that.auctionEndTime,_that.status,_that.createdAt,_that.updatedAt,_that.seller,_that.primaryImage,_that.images,_that.isWishlisted,_that.aiAnalysisSummary,_that.fraudScore,_that.viewsCount,_that.auction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String description,  String price,  String category,  String condition,  String location, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'is_auction')  bool isAuction, @JsonKey(name: 'auction_end_time')  DateTime? auctionEndTime,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  ProductSeller? seller, @JsonKey(name: 'primary_image')  String? primaryImage,  List<ProductImage> images, @JsonKey(name: 'is_wishlisted')  bool isWishlisted, @JsonKey(name: 'ai_analysis_summary')  String? aiAnalysisSummary, @JsonKey(name: 'fraud_score')  double? fraudScore, @JsonKey(name: 'views_count')  int viewsCount,  Map<String, dynamic>? auction)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.category,_that.condition,_that.location,_that.phoneNumber,_that.isAuction,_that.auctionEndTime,_that.status,_that.createdAt,_that.updatedAt,_that.seller,_that.primaryImage,_that.images,_that.isWishlisted,_that.aiAnalysisSummary,_that.fraudScore,_that.viewsCount,_that.auction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.title, required this.description, required this.price, required this.category, required this.condition, required this.location, @JsonKey(name: 'phone_number') this.phoneNumber, @JsonKey(name: 'is_auction') this.isAuction = false, @JsonKey(name: 'auction_end_time') this.auctionEndTime, required this.status, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.seller, @JsonKey(name: 'primary_image') this.primaryImage, final  List<ProductImage> images = const [], @JsonKey(name: 'is_wishlisted') this.isWishlisted = false, @JsonKey(name: 'ai_analysis_summary') this.aiAnalysisSummary, @JsonKey(name: 'fraud_score') this.fraudScore, @JsonKey(name: 'views_count') this.viewsCount = 0, final  Map<String, dynamic>? auction}): _images = images,_auction = auction;
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  int id;
@override final  String title;
@override final  String description;
@override final  String price;
@override final  String category;
@override final  String condition;
@override final  String location;
@override@JsonKey(name: 'phone_number') final  String? phoneNumber;
@override@JsonKey(name: 'is_auction') final  bool isAuction;
@override@JsonKey(name: 'auction_end_time') final  DateTime? auctionEndTime;
@override final  String status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override final  ProductSeller? seller;
@override@JsonKey(name: 'primary_image') final  String? primaryImage;
 final  List<ProductImage> _images;
@override@JsonKey() List<ProductImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'is_wishlisted') final  bool isWishlisted;
@override@JsonKey(name: 'ai_analysis_summary') final  String? aiAnalysisSummary;
@override@JsonKey(name: 'fraud_score') final  double? fraudScore;
@override@JsonKey(name: 'views_count') final  int viewsCount;
 final  Map<String, dynamic>? _auction;
@override Map<String, dynamic>? get auction {
  final value = _auction;
  if (value == null) return null;
  if (_auction is EqualUnmodifiableMapView) return _auction;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.location, location) || other.location == location)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isAuction, isAuction) || other.isAuction == isAuction)&&(identical(other.auctionEndTime, auctionEndTime) || other.auctionEndTime == auctionEndTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.primaryImage, primaryImage) || other.primaryImage == primaryImage)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.isWishlisted, isWishlisted) || other.isWishlisted == isWishlisted)&&(identical(other.aiAnalysisSummary, aiAnalysisSummary) || other.aiAnalysisSummary == aiAnalysisSummary)&&(identical(other.fraudScore, fraudScore) || other.fraudScore == fraudScore)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&const DeepCollectionEquality().equals(other._auction, _auction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,price,category,condition,location,phoneNumber,isAuction,auctionEndTime,status,createdAt,updatedAt,seller,primaryImage,const DeepCollectionEquality().hash(_images),isWishlisted,aiAnalysisSummary,fraudScore,viewsCount,const DeepCollectionEquality().hash(_auction)]);

@override
String toString() {
  return 'Product(id: $id, title: $title, description: $description, price: $price, category: $category, condition: $condition, location: $location, phoneNumber: $phoneNumber, isAuction: $isAuction, auctionEndTime: $auctionEndTime, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, seller: $seller, primaryImage: $primaryImage, images: $images, isWishlisted: $isWishlisted, aiAnalysisSummary: $aiAnalysisSummary, fraudScore: $fraudScore, viewsCount: $viewsCount, auction: $auction)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String description, String price, String category, String condition, String location,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'is_auction') bool isAuction,@JsonKey(name: 'auction_end_time') DateTime? auctionEndTime, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, ProductSeller? seller,@JsonKey(name: 'primary_image') String? primaryImage, List<ProductImage> images,@JsonKey(name: 'is_wishlisted') bool isWishlisted,@JsonKey(name: 'ai_analysis_summary') String? aiAnalysisSummary,@JsonKey(name: 'fraud_score') double? fraudScore,@JsonKey(name: 'views_count') int viewsCount, Map<String, dynamic>? auction
});


@override $ProductSellerCopyWith<$Res>? get seller;

}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? price = null,Object? category = null,Object? condition = null,Object? location = null,Object? phoneNumber = freezed,Object? isAuction = null,Object? auctionEndTime = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? seller = freezed,Object? primaryImage = freezed,Object? images = null,Object? isWishlisted = null,Object? aiAnalysisSummary = freezed,Object? fraudScore = freezed,Object? viewsCount = null,Object? auction = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isAuction: null == isAuction ? _self.isAuction : isAuction // ignore: cast_nullable_to_non_nullable
as bool,auctionEndTime: freezed == auctionEndTime ? _self.auctionEndTime : auctionEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as ProductSeller?,primaryImage: freezed == primaryImage ? _self.primaryImage : primaryImage // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImage>,isWishlisted: null == isWishlisted ? _self.isWishlisted : isWishlisted // ignore: cast_nullable_to_non_nullable
as bool,aiAnalysisSummary: freezed == aiAnalysisSummary ? _self.aiAnalysisSummary : aiAnalysisSummary // ignore: cast_nullable_to_non_nullable
as String?,fraudScore: freezed == fraudScore ? _self.fraudScore : fraudScore // ignore: cast_nullable_to_non_nullable
as double?,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,auction: freezed == auction ? _self._auction : auction // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductSellerCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $ProductSellerCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}

// dart format on
