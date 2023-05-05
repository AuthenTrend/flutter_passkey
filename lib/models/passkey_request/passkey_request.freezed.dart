// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passkey_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PassKeyRequest _$PassKeyRequestFromJson(Map<String, dynamic> json) {
  return _PassKeyRequest.fromJson(json);
}

/// @nodoc
mixin _$PassKeyRequest {
  String get challenge => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get rpId => throw _privateConstructorUsedError;
  @JsonKey(name: 'allowed_credentials')
  List<AllowedCredential> get allowedCredentials =>
      throw _privateConstructorUsedError;
  int get timeout => throw _privateConstructorUsedError;
  String get userVerification => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PassKeyRequestCopyWith<PassKeyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PassKeyRequestCopyWith<$Res> {
  factory $PassKeyRequestCopyWith(
          PassKeyRequest value, $Res Function(PassKeyRequest) then) =
      _$PassKeyRequestCopyWithImpl<$Res, PassKeyRequest>;
  @useResult
  $Res call(
      {String challenge,
      String sessionId,
      String rpId,
      @JsonKey(name: 'allowed_credentials')
          List<AllowedCredential> allowedCredentials,
      int timeout,
      String userVerification});
}

/// @nodoc
class _$PassKeyRequestCopyWithImpl<$Res, $Val extends PassKeyRequest>
    implements $PassKeyRequestCopyWith<$Res> {
  _$PassKeyRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenge = null,
    Object? sessionId = null,
    Object? rpId = null,
    Object? allowedCredentials = null,
    Object? timeout = null,
    Object? userVerification = null,
  }) {
    return _then(_value.copyWith(
      challenge: null == challenge
          ? _value.challenge
          : challenge // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      rpId: null == rpId
          ? _value.rpId
          : rpId // ignore: cast_nullable_to_non_nullable
              as String,
      allowedCredentials: null == allowedCredentials
          ? _value.allowedCredentials
          : allowedCredentials // ignore: cast_nullable_to_non_nullable
              as List<AllowedCredential>,
      timeout: null == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int,
      userVerification: null == userVerification
          ? _value.userVerification
          : userVerification // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PassKeyRequestCopyWith<$Res>
    implements $PassKeyRequestCopyWith<$Res> {
  factory _$$_PassKeyRequestCopyWith(
          _$_PassKeyRequest value, $Res Function(_$_PassKeyRequest) then) =
      __$$_PassKeyRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String challenge,
      String sessionId,
      String rpId,
      @JsonKey(name: 'allowed_credentials')
          List<AllowedCredential> allowedCredentials,
      int timeout,
      String userVerification});
}

/// @nodoc
class __$$_PassKeyRequestCopyWithImpl<$Res>
    extends _$PassKeyRequestCopyWithImpl<$Res, _$_PassKeyRequest>
    implements _$$_PassKeyRequestCopyWith<$Res> {
  __$$_PassKeyRequestCopyWithImpl(
      _$_PassKeyRequest _value, $Res Function(_$_PassKeyRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenge = null,
    Object? sessionId = null,
    Object? rpId = null,
    Object? allowedCredentials = null,
    Object? timeout = null,
    Object? userVerification = null,
  }) {
    return _then(_$_PassKeyRequest(
      challenge: null == challenge
          ? _value.challenge
          : challenge // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      rpId: null == rpId
          ? _value.rpId
          : rpId // ignore: cast_nullable_to_non_nullable
              as String,
      allowedCredentials: null == allowedCredentials
          ? _value._allowedCredentials
          : allowedCredentials // ignore: cast_nullable_to_non_nullable
              as List<AllowedCredential>,
      timeout: null == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int,
      userVerification: null == userVerification
          ? _value.userVerification
          : userVerification // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PassKeyRequest implements _PassKeyRequest {
  const _$_PassKeyRequest(
      {required this.challenge,
      required this.sessionId,
      required this.rpId,
      @JsonKey(name: 'allowed_credentials')
          required final List<AllowedCredential> allowedCredentials,
      this.timeout = 90000,
      this.userVerification = 'discouraged'})
      : _allowedCredentials = allowedCredentials;

  factory _$_PassKeyRequest.fromJson(Map<String, dynamic> json) =>
      _$$_PassKeyRequestFromJson(json);

  @override
  final String challenge;
  @override
  final String sessionId;
  @override
  final String rpId;
  final List<AllowedCredential> _allowedCredentials;
  @override
  @JsonKey(name: 'allowed_credentials')
  List<AllowedCredential> get allowedCredentials {
    if (_allowedCredentials is EqualUnmodifiableListView)
      return _allowedCredentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allowedCredentials);
  }

  @override
  @JsonKey()
  final int timeout;
  @override
  @JsonKey()
  final String userVerification;

  @override
  String toString() {
    return 'PassKeyRequest(challenge: $challenge, sessionId: $sessionId, rpId: $rpId, allowedCredentials: $allowedCredentials, timeout: $timeout, userVerification: $userVerification)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PassKeyRequest &&
            (identical(other.challenge, challenge) ||
                other.challenge == challenge) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.rpId, rpId) || other.rpId == rpId) &&
            const DeepCollectionEquality()
                .equals(other._allowedCredentials, _allowedCredentials) &&
            (identical(other.timeout, timeout) || other.timeout == timeout) &&
            (identical(other.userVerification, userVerification) ||
                other.userVerification == userVerification));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      challenge,
      sessionId,
      rpId,
      const DeepCollectionEquality().hash(_allowedCredentials),
      timeout,
      userVerification);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PassKeyRequestCopyWith<_$_PassKeyRequest> get copyWith =>
      __$$_PassKeyRequestCopyWithImpl<_$_PassKeyRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PassKeyRequestToJson(
      this,
    );
  }
}

abstract class _PassKeyRequest implements PassKeyRequest {
  const factory _PassKeyRequest(
      {required final String challenge,
      required final String sessionId,
      required final String rpId,
      @JsonKey(name: 'allowed_credentials')
          required final List<AllowedCredential> allowedCredentials,
      final int timeout,
      final String userVerification}) = _$_PassKeyRequest;

  factory _PassKeyRequest.fromJson(Map<String, dynamic> json) =
      _$_PassKeyRequest.fromJson;

  @override
  String get challenge;
  @override
  String get sessionId;
  @override
  String get rpId;
  @override
  @JsonKey(name: 'allowed_credentials')
  List<AllowedCredential> get allowedCredentials;
  @override
  int get timeout;
  @override
  String get userVerification;
  @override
  @JsonKey(ignore: true)
  _$$_PassKeyRequestCopyWith<_$_PassKeyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}
