// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_word.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ApiWord> _$apiWordSerializer = new _$ApiWordSerializer();

class _$ApiWordSerializer implements StructuredSerializer<ApiWord> {
  @override
  final Iterable<Type> types = const [ApiWord, _$ApiWord];
  @override
  final String wireName = 'ApiWord';

  @override
  Iterable<Object?> serialize(Serializers serializers, ApiWord object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'external_id',
      serializers.serialize(object.externalId,
          specifiedType: const FullType(int)),
      'translation',
      serializers.serialize(object.translation,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.redirectTo;
    if (value != null) {
      result
        ..add('redirect_to')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ApiWord deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ApiWordBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'external_id':
          result.externalId = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'translation':
          result.translation = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'redirect_to':
          result.redirectTo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ApiWord extends ApiWord {
  @override
  final int externalId;
  @override
  final String translation;
  @override
  final String? redirectTo;

  factory _$ApiWord([void Function(ApiWordBuilder)? updates]) =>
      (new ApiWordBuilder()..update(updates))._build();

  _$ApiWord._(
      {required this.externalId, required this.translation, this.redirectTo})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(externalId, r'ApiWord', 'externalId');
    BuiltValueNullFieldError.checkNotNull(
        translation, r'ApiWord', 'translation');
  }

  @override
  ApiWord rebuild(void Function(ApiWordBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApiWordBuilder toBuilder() => new ApiWordBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApiWord &&
        externalId == other.externalId &&
        translation == other.translation &&
        redirectTo == other.redirectTo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, externalId.hashCode);
    _$hash = $jc(_$hash, translation.hashCode);
    _$hash = $jc(_$hash, redirectTo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiWord')
          ..add('externalId', externalId)
          ..add('translation', translation)
          ..add('redirectTo', redirectTo))
        .toString();
  }
}

class ApiWordBuilder implements Builder<ApiWord, ApiWordBuilder> {
  _$ApiWord? _$v;

  int? _externalId;
  int? get externalId => _$this._externalId;
  set externalId(int? externalId) => _$this._externalId = externalId;

  String? _translation;
  String? get translation => _$this._translation;
  set translation(String? translation) => _$this._translation = translation;

  String? _redirectTo;
  String? get redirectTo => _$this._redirectTo;
  set redirectTo(String? redirectTo) => _$this._redirectTo = redirectTo;

  ApiWordBuilder();

  ApiWordBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _externalId = $v.externalId;
      _translation = $v.translation;
      _redirectTo = $v.redirectTo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApiWord other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ApiWord;
  }

  @override
  void update(void Function(ApiWordBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApiWord build() => _build();

  _$ApiWord _build() {
    final _$result = _$v ??
        new _$ApiWord._(
            externalId: BuiltValueNullFieldError.checkNotNull(
                externalId, r'ApiWord', 'externalId'),
            translation: BuiltValueNullFieldError.checkNotNull(
                translation, r'ApiWord', 'translation'),
            redirectTo: redirectTo);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
