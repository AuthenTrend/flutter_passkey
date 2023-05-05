// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PassKeyRequest _$$_PassKeyRequestFromJson(Map<String, dynamic> json) =>
    _$_PassKeyRequest(
      challenge: json['challenge'] as String,
      sessionId: json['sessionId'] as String,
      rpId: json['rpId'] as String,
      allowedCredentials: (json['allowed_credentials'] as List<dynamic>)
          .map((e) => AllowedCredential.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeout: json['timeout'] as int? ?? 90000,
      userVerification: json['userVerification'] as String? ?? 'discouraged',
    );

Map<String, dynamic> _$$_PassKeyRequestToJson(_$_PassKeyRequest instance) =>
    <String, dynamic>{
      'challenge': instance.challenge,
      'sessionId': instance.sessionId,
      'rpId': instance.rpId,
      'allowed_credentials': instance.allowedCredentials,
      'timeout': instance.timeout,
      'userVerification': instance.userVerification,
    };
