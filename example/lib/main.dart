
import 'package:flutter/material.dart';
import 'package:flutter_passkey/flutter_passkey.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterPasskeyPlugin = FlutterPasskey();
  bool _isPasskeySupported = false;

  String _getCredentialCreationOptions() {
    // Obtain this from the server
    return '';
  }

  String _getCredentialRequestOptions() {
    // Obtain this from the server
    return '';
  }

  @override
  void initState() {
    super.initState();
    _flutterPasskeyPlugin.isSupported().then((value) => setState(() {_isPasskeySupported = value;}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isPasskeySupported)
                const Center(
                  child: Text("This platform doesn't support Passkey."),
                ),
              if (_isPasskeySupported)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(
                      onPressed: () {
                        final options = _getCredentialCreationOptions();
                        _flutterPasskeyPlugin.createCredential(options).then((response) {
                          // Send response to the server
                        }).catchError((error) {
                          // Handle error
                        });
                      },
                      child: const Text("Register Passkey"),
                    ),
                    FilledButton(
                      onPressed: () {
                        final options = _getCredentialRequestOptions();
                        _flutterPasskeyPlugin.getCredential(options).then((response) {
                          // Send response to the server
                        }).catchError((error) {
                          // Handle error
                        });
                      },
                      child: const Text("Verify Passkey"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
