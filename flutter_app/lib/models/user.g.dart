// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: (json['id'] as num).toInt(),
  profile: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
  phone: json['phone'] as String?,
  location: json['location'] as String?,
  profilePicture: json['profile_picture'] as String?,
  trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
  walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
  isAdmin: json['is_admin'] as bool? ?? false,
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.profile,
  'phone': instance.phone,
  'location': instance.location,
  'profile_picture': instance.profilePicture,
  'trust_score': instance.trustScore,
  'wallet_balance': instance.walletBalance,
  'is_admin': instance.isAdmin,
};
