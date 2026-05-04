import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required String username,
    required String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int id,
    @JsonKey(name: 'user') required UserProfile profile,
    String? phone,
    String? location,
    @JsonKey(name: 'profile_picture') String? profilePicture,
    @JsonKey(name: 'trust_score') @Default(0.0) double trustScore,
    @JsonKey(name: 'wallet_balance') @Default(0.0) double walletBalance,
    @JsonKey(name: 'is_admin') @Default(false) bool isAdmin,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
}
