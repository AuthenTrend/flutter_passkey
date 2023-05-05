import 'package:freezed_annotation/freezed_annotation.dart';

import '../allowed_credential/allowed_credential.dart';

part 'passkey_request.freezed.dart';

part 'passkey_request.g.dart';

@freezed
class PassKeyRequest with _$PassKeyRequest {
  const factory PassKeyRequest({
    required String challenge,
    required String sessionId,
    required String rpId,
    @JsonKey(name: 'allowed_credentials')
        required List<AllowedCredential> allowedCredentials,
    @Default(90000) int timeout,
    @Default('discouraged') String userVerification,
  }) = _PassKeyRequest;

  factory PassKeyRequest.fromJson(Map<String, dynamic> json) =>
      _$PassKeyRequestFromJson(json);
}
