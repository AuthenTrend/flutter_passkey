// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passkey_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PassKeyResponse _$PassKeyResponseFromJson(Map<String, dynamic> json) {
  return _PassKeyResponse.fromJson(json);
}

/// @nodoc
mixin _$PassKeyResponse {
  String get type => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get rawId => throw _privateConstructorUsedError;
  Map<String, dynamic> get response => throw _privateConstructorUsedError;
  String get authenticatorAttachment => throw _privateConstructorUsedError;
  Map<String, dynamic> get clientExtensionResults =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PassKeyResponseCopyWith<PassKeyResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PassKeyResponseCopyWith<$Res> {
  factory $PassKeyResponseCopyWith(
          PassKeyResponse value, $Res Function(PassKeyResponse) then) =
      _$PassKeyResponseCopyWithImpl<$Res, PassKeyResponse>;
  @useResult
  $Res call(
      {String type,
      String id,
      String rawId,
      Map<String, dynamic> response,
      String authenticatorAttachment,
      Map<String, dynamic> clientExtensionResults});
}

/// @nodoc
class _$PassKeyResponseCopyWithImpl<$Res, $Val extends PassKeyResponse>
    implements $PassKeyResponseCopyWith<$Res> {
  _$PassKeyResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? id = null,
    Object? rawId = null,
    Object? response = null,
    Object? authenticatorAttachment = null,
    Object? clientExtensionResults = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rawId: null == rawId
          ? _value.rawId
          : rawId // ignore: cast_nullable_to_non_nullable
              as String,
      response: null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      authenticatorAttachment: null == authenticatorAttachment
          ? _value.authenticatorAttachment
          : authenticatorAttachment // ignore: cast_nullable_to_non_nullable
              as String,
      clientExtensionResults: null == clientExtensionResults
          ? _value.clientExtensionResults
          : clientExtensionResults // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PassKeyResponseCopyWith<$Res>
    implements $PassKeyResponseCopyWith<$Res> {
  factory _$$_PassKeyResponseCopyWith(
          _$_PassKeyResponse value, $Res Function(_$_PassKeyResponse) then) =
      __$$_PassKeyResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      String id,
      String rawId,
      Map<String, dynamic> response,
      String authenticatorAttachment,
      Map<String, dynamic> clientExtensionResults});
}

/// @nodoc
class __$$_PassKeyResponseCopyWithImpl<$Res>
    extends _$PassKeyResponseCopyWithImpl<$Res, _$_PassKeyResponse>
    implements _$$_PassKeyResponseCopyWith<$Res> {
  __$$_PassKeyResponseCopyWithImpl(
      _$_PassKeyResponse _value, $Res Function(_$_PassKeyResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? id = null,
    Object? rawId = null,
    Object? response = null,
    Object? authenticatorAttachment = null,
    Object? clientExtensionResults = null,
  }) {
    return _then(_$_PassKeyResponse(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rawId: null == rawId
          ? _value.rawId
          : rawId // ignore: cast_nullable_to_non_nullable
              as String,
      response: null == response
          ? _value._response
          : response // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      authenticatorAttachment: null == authenticatorAttachment
          ? _value.authenticatorAttachment
          : authenticatorAttachment // ignore: cast_nullable_to_non_nullable
              as String,
      clientExtensionResults: null == clientExtensionResults
          ? _value._clientExtensionResults
          : clientExtensionResults // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PassKeyResponse
    with DiagnosticableTreeMixin
    implements _PassKeyResponse {
  const _$_PassKeyResponse(
      {required this.type,
      required this.id,
      required this.rawId,
      required final Map<String, dynamic> response,
      this.authenticatorAttachment = 'cross-platform',
      final Map<String, dynamic> clientExtensionResults = const {}})
      : _response = response,
        _clientExtensionResults = clientExtensionResults;

  factory _$_PassKeyResponse.fromJson(Map<String, dynamic> json) =>
      _$$_PassKeyResponseFromJson(json);

  @override
  final String type;
  @override
  final String id;
  @override
  final String rawId;
  final Map<String, dynamic> _response;
  @override
  Map<String, dynamic> get response {
    if (_response is EqualUnmodifiableMapView) return _response;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_response);
  }

  @override
  @JsonKey()
  final String authenticatorAttachment;
  final Map<String, dynamic> _clientExtensionResults;
  @override
  @JsonKey()
  Map<String, dynamic> get clientExtensionResults {
    if (_clientExtensionResults is EqualUnmodifiableMapView)
      return _clientExtensionResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_clientExtensionResults);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PassKeyResponse(type: $type, id: $id, rawId: $rawId, response: $response, authenticatorAttachment: $authenticatorAttachment, clientExtensionResults: $clientExtensionResults)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PassKeyResponse'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('rawId', rawId))
      ..add(DiagnosticsProperty('response', response))
      ..add(DiagnosticsProperty(
          'authenticatorAttachment', authenticatorAttachment))
      ..add(DiagnosticsProperty(
          'clientExtensionResults', clientExtensionResults));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PassKeyResponse &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rawId, rawId) || other.rawId == rawId) &&
            const DeepCollectionEquality().equals(other._response, _response) &&
            (identical(
                    other.authenticatorAttachment, authenticatorAttachment) ||
                other.authenticatorAttachment == authenticatorAttachment) &&
            const DeepCollectionEquality().equals(
                other._clientExtensionResults, _clientExtensionResults));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      id,
      rawId,
      const DeepCollectionEquality().hash(_response),
      authenticatorAttachment,
      const DeepCollectionEquality().hash(_clientExtensionResults));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PassKeyResponseCopyWith<_$_PassKeyResponse> get copyWith =>
      __$$_PassKeyResponseCopyWithImpl<_$_PassKeyResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PassKeyResponseToJson(
      this,
    );
  }
}

abstract class _PassKeyResponse implements PassKeyResponse {
  const factory _PassKeyResponse(
      {required final String type,
      required final String id,
      required final String rawId,
      required final Map<String, dynamic> response,
      final String authenticatorAttachment,
      final Map<String, dynamic> clientExtensionResults}) = _$_PassKeyResponse;

  factory _PassKeyResponse.fromJson(Map<String, dynamic> json) =
      _$_PassKeyResponse.fromJson;

  @override
  String get type;
  @override
  String get id;
  @override
  String get rawId;
  @override
  Map<String, dynamic> get response;
  @override
  String get authenticatorAttachment;
  @override
  Map<String, dynamic> get clientExtensionResults;
  @override
  @JsonKey(ignore: true)
  _$$_PassKeyResponseCopyWith<_$_PassKeyResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
