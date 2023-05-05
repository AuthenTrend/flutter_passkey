// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allowed_credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AllowedCredential _$AllowedCredentialFromJson(Map<String, dynamic> json) {
  return _AllowedCredential.fromJson(json);
}

/// @nodoc
mixin _$AllowedCredential {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AllowedCredentialCopyWith<AllowedCredential> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllowedCredentialCopyWith<$Res> {
  factory $AllowedCredentialCopyWith(
          AllowedCredential value, $Res Function(AllowedCredential) then) =
      _$AllowedCredentialCopyWithImpl<$Res, AllowedCredential>;
  @useResult
  $Res call({String id, String type});
}

/// @nodoc
class _$AllowedCredentialCopyWithImpl<$Res, $Val extends AllowedCredential>
    implements $AllowedCredentialCopyWith<$Res> {
  _$AllowedCredentialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AllowedCredentialCopyWith<$Res>
    implements $AllowedCredentialCopyWith<$Res> {
  factory _$$_AllowedCredentialCopyWith(_$_AllowedCredential value,
          $Res Function(_$_AllowedCredential) then) =
      __$$_AllowedCredentialCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String type});
}

/// @nodoc
class __$$_AllowedCredentialCopyWithImpl<$Res>
    extends _$AllowedCredentialCopyWithImpl<$Res, _$_AllowedCredential>
    implements _$$_AllowedCredentialCopyWith<$Res> {
  __$$_AllowedCredentialCopyWithImpl(
      _$_AllowedCredential _value, $Res Function(_$_AllowedCredential) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
  }) {
    return _then(_$_AllowedCredential(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AllowedCredential implements _AllowedCredential {
  const _$_AllowedCredential({required this.id, required this.type});

  factory _$_AllowedCredential.fromJson(Map<String, dynamic> json) =>
      _$$_AllowedCredentialFromJson(json);

  @override
  final String id;
  @override
  final String type;

  @override
  String toString() {
    return 'AllowedCredential(id: $id, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AllowedCredential &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AllowedCredentialCopyWith<_$_AllowedCredential> get copyWith =>
      __$$_AllowedCredentialCopyWithImpl<_$_AllowedCredential>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AllowedCredentialToJson(
      this,
    );
  }
}

abstract class _AllowedCredential implements AllowedCredential {
  const factory _AllowedCredential(
      {required final String id,
      required final String type}) = _$_AllowedCredential;

  factory _AllowedCredential.fromJson(Map<String, dynamic> json) =
      _$_AllowedCredential.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  @JsonKey(ignore: true)
  _$$_AllowedCredentialCopyWith<_$_AllowedCredential> get copyWith =>
      throw _privateConstructorUsedError;
}
