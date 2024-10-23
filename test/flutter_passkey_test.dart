import 'package:flutter/services.dart' show PlatformException;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_passkey/flutter_passkey.dart';
import 'package:flutter_passkey/flutter_passkey_platform_interface.dart';
import 'package:flutter_passkey/flutter_passkey_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPasskeyPlatformNull
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value(null);

  @override
  Future<String?> createCredential(String options) => Future.value(null);

  @override
  Future<String?> getCredential(String options) => Future.value(null);
}

class MockFlutterPasskeyPlatformAndroidOk
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('Android 9');

  @override
  Future<String?> createCredential(String options) => Future.value("");

  @override
  Future<String?> getCredential(String options) => Future.value("");
}

class MockFlutterPasskeyPlatformAndroidKo
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('Android 5');

  @override
  Future<String?> createCredential(String options) => Future.value("");

  @override
  Future<String?> getCredential(String options) => Future.value("");
}

class MockFlutterPasskeyPlatformIosOk
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('iOS 15');

  @override
  Future<String?> createCredential(String options) => Future.value("");

  @override
  Future<String?> getCredential(String options) => Future.value("");
}

class MockFlutterPasskeyPlatformIosKo
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('iOS 14');

  @override
  Future<String?> createCredential(String options) => Future.value("");

  @override
  Future<String?> getCredential(String options) => Future.value("");
}

void main() {
  final FlutterPasskeyPlatform initialPlatform =
      FlutterPasskeyPlatform.instance;

  test('$MethodChannelFlutterPasskey is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPasskey>());
  });

  test('isSupportedNull', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    FlutterPasskeyPlatform.instance = MockFlutterPasskeyPlatformNull();

    expect(await flutterPasskeyPlugin.isSupported(), false);
  });

  test('isSupportedAndroidTrue', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    FlutterPasskeyPlatform.instance = MockFlutterPasskeyPlatformAndroidOk();

    expect(await flutterPasskeyPlugin.isSupported(), true);
  });

  test('isSupportedAndroidFalse', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    FlutterPasskeyPlatform.instance = MockFlutterPasskeyPlatformAndroidKo();

    expect(await flutterPasskeyPlugin.isSupported(), false);
  });

  test('isSupportedIosTrue', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    FlutterPasskeyPlatform.instance = MockFlutterPasskeyPlatformIosOk();

    expect(await flutterPasskeyPlugin.isSupported(), true);
  });

  test('isSupportedIosFalse', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    FlutterPasskeyPlatform.instance = MockFlutterPasskeyPlatformIosKo();

    expect(await flutterPasskeyPlugin.isSupported(), false);
  });

  test('createCredentialNull', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    FlutterPasskeyPlatform.instance = MockFlutterPasskeyPlatformNull();

    final future = flutterPasskeyPlugin.createCredential('');
    await expectLater(future, throwsA(isA<PlatformException>()));
  });

  test('getCredentialNull', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    FlutterPasskeyPlatform.instance = MockFlutterPasskeyPlatformNull();

    final future = flutterPasskeyPlugin.getCredential('');
    await expectLater(future, throwsA(isA<PlatformException>()));
  });
}
