import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_passkey/flutter_passkey.dart';
import 'package:flutter_passkey/flutter_passkey_platform_interface.dart';
import 'package:flutter_passkey/flutter_passkey_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPasskeyPlatform
    with MockPlatformInterfaceMixin
    implements FlutterPasskeyPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value("Android 13");

  @override
  Future<String?> createCredential(String options) => Future.value("");

  @override
  Future<String?> getCredential(String options) => Future.value("");
}

void main() {
  final FlutterPasskeyPlatform initialPlatform = FlutterPasskeyPlatform.instance;

  test('$MethodChannelFlutterPasskey is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPasskey>());
  });

  test('isSupported', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    MockFlutterPasskeyPlatform fakePlatform = MockFlutterPasskeyPlatform();
    FlutterPasskeyPlatform.instance = fakePlatform;

    expect(await flutterPasskeyPlugin.isSupported(), true);
  });

  test('createCredential', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    MockFlutterPasskeyPlatform fakePlatform = MockFlutterPasskeyPlatform();
    FlutterPasskeyPlatform.instance = fakePlatform;

    expect(await flutterPasskeyPlugin.createCredential(""), "");
  });

  test('getCredential', () async {
    FlutterPasskey flutterPasskeyPlugin = FlutterPasskey();
    MockFlutterPasskeyPlatform fakePlatform = MockFlutterPasskeyPlatform();
    FlutterPasskeyPlatform.instance = fakePlatform;

    expect(await flutterPasskeyPlugin.getCredential(""), "");
  });
}
