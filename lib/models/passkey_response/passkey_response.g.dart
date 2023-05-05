// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PassKeyResponse _$$_PassKeyResponseFromJson(Map<String, dynamic> json) =>
    _$_PassKeyResponse(
      type: json['type'] as String,
      id: json['id'] as String,
      rawId: json['rawId'] as String,
      response: json['response'] as Map<String, dynamic>,
      authenticatorAttachment:
          json['authenticatorAttachment'] as String? ?? 'cross-platform',
      clientExtensionResults:
          json['clientExtensionResults'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$_PassKeyResponseToJson(_$_PassKeyResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'rawId': instance.rawId,
      'response': instance.response,
      'authenticatorAttachment': instance.authenticatorAttachment,
      'clientExtensionResults': instance.clientExtensionResults,
    };
