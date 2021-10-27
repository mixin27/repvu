import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Entity class
///
@freezed
class User with _$User {
  const User._();
  const factory User({
    required String name,
    required String avatarUrl,
  }) = _User;

  String get avatarUrlSmall => '$avatarUrl&s=64';
}
