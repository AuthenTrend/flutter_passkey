import 'package:freezed_annotation/freezed_annotation.dart';

part 'allowed_credential.freezed.dart';
part 'allowed_credential.g.dart';

@freezed
class AllowedCredential with _$AllowedCredential {
  const factory AllowedCredential({
    required String id,
    required String type,
  }) = _AllowedCredential;



  factory AllowedCredential.fromJson(Map<String, dynamic> json) =>
      _$AllowedCredentialFromJson(json);
}