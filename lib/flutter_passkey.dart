import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_passkey/models/passkey_request/passkey_request.dart';
import 'package:flutter_passkey/models/passkey_response/passkey_response.dart';

import 'flutter_passkey_platform_interface.dart';

class FlutterPasskey {
  Future<bool> isSupported() async {
    final isSupported = await FlutterPasskeyPlatform.instance
        .getPlatformVersion()
        .then((osVersion) {
      if (osVersion == null) {
        return false;
      }
      final list = osVersion.split(' ');
      final version = int.tryParse(list[1].split('.').first) ?? 0;
      switch (list.first) {
        case 'iOS':
          return (version >= 15);
        case 'Android':
          return (version >= 9);
        default:
          return false;
      }
    });
    return isSupported;
  }

  Future<String> createCredential(String options) async {
    final response =
        await FlutterPasskeyPlatform.instance.createCredential(options);
    if (response == null) {
      throw PlatformException(
          code: "null-response",
          message: "Unable to get response from Passkey.");
    }
    return response;
  }

  Future<PassKeyResponse> getCredential(PassKeyRequest passKeyRequest) async {
    final response = await FlutterPasskeyPlatform.instance
        .getCredential(jsonEncode(passKeyRequest.toJson()));
    if (response == null) {
      throw PlatformException(
          code: "null-response",
          message: "Unable to get response from Passkey.");
    }
    return PassKeyResponse.fromJson(json.decode(response));
  }
}
