# flutter_passkey

Use passkeys authentication for Android and iOS.

| Android | iOS | MacOS | Web | Linux | Windows |
|:-------:|:---:|:-----:|:---:|:-----:|:-------:|
|   ✅     |  ✅ |   ❌   |  ❌  |   ❌  |    ❌    |

## Usage

To use this plugin, add `flutter_passkey` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

### Example

``` dart
final flutterPasskeyPlugin = FlutterPasskey();

final isPasskeySupported = await flutterPasskeyPlugin.isSupported();

// Obtain creationOptions from the server
final creationOptions = getCredentialCreationOptions();
flutterPasskeyPlugin.createCredential(creationOptions).then((response) {
    // Send response to the server
}).catchError((error) {
    // Handle error
});

// Obtain requestOptions from the server
final requestOptions = getCredentialRequestOptions();
flutterPasskeyPlugin.getCredential(requestOptions).then((response) {
    // Send response to the server
}).catchError((error) {
    // Handle error
});
```

See the example app for more complex examples.

## Learn more
- https://github.com/AuthenTrend/rp-app-example
