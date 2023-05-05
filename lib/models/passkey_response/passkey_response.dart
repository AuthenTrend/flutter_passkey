import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'passkey_response.freezed.dart';

part 'passkey_response.g.dart';

@freezed
class PassKeyResponse with _$PassKeyResponse {
  const factory PassKeyResponse({
    required String type,
    required String id,
    required String rawId,
    required Map<String, dynamic> response,
    @Default('cross-platform') String authenticatorAttachment,
    @Default({}) Map<String, dynamic> clientExtensionResults,
  }) = _PassKeyResponse;

  factory PassKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$PassKeyResponseFromJson(json);
}
