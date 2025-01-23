// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_word_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ApiWordModel> _$apiWordModelSerializer =
    new _$ApiWordModelSerializer();

class _$ApiWordModelSerializer implements StructuredSerializer<ApiWordModel> {
  @override
  final Iterable<Type> types = const [ApiWordModel, _$ApiWordModel];
  @override
  final String wireName = 'ApiWordModel';

  @override
  Iterable<Object?> serialize(Serializers serializers, ApiWordModel object,
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
    value = object.stress;
    if (value != null) {
      result
        ..add('stress')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
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
  ApiWordModel deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ApiWordModelBuilder();

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
        case 'stress':
          result.stress = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
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

class _$ApiWordModel extends ApiWordModel {
  @override
  final int externalId;
  @override
  final String? stress;
  @override
  final String translation;
  @override
  final String? redirectTo;

  factory _$ApiWordModel([void Function(ApiWordModelBuilder)? updates]) =>
      (new ApiWordModelBuilder()..update(updates))._build();

  _$ApiWordModel._(
      {required this.externalId,
      this.stress,
      required this.translation,
      this.redirectTo})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        externalId, r'ApiWordModel', 'externalId');
    BuiltValueNullFieldError.checkNotNull(
        translation, r'ApiWordModel', 'translation');
  }

  @override
  ApiWordModel rebuild(void Function(ApiWordModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApiWordModelBuilder toBuilder() => new ApiWordModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApiWordModel &&
        externalId == other.externalId &&
        stress == other.stress &&
        translation == other.translation &&
        redirectTo == other.redirectTo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, externalId.hashCode);
    _$hash = $jc(_$hash, stress.hashCode);
    _$hash = $jc(_$hash, translation.hashCode);
    _$hash = $jc(_$hash, redirectTo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiWordModel')
          ..add('externalId', externalId)
          ..add('stress', stress)
          ..add('translation', translation)
          ..add('redirectTo', redirectTo))
        .toString();
  }
}

class ApiWordModelBuilder
    implements Builder<ApiWordModel, ApiWordModelBuilder> {
  _$ApiWordModel? _$v;

  int? _externalId;
  int? get externalId => _$this._externalId;
  set externalId(int? externalId) => _$this._externalId = externalId;

  String? _stress;
  String? get stress => _$this._stress;
  set stress(String? stress) => _$this._stress = stress;

  String? _translation;
  String? get translation => _$this._translation;
  set translation(String? translation) => _$this._translation = translation;

  String? _redirectTo;
  String? get redirectTo => _$this._redirectTo;
  set redirectTo(String? redirectTo) => _$this._redirectTo = redirectTo;

  ApiWordModelBuilder();

  ApiWordModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _externalId = $v.externalId;
      _stress = $v.stress;
      _translation = $v.translation;
      _redirectTo = $v.redirectTo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApiWordModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ApiWordModel;
  }

  @override
  void update(void Function(ApiWordModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApiWordModel build() => _build();

  _$ApiWordModel _build() {
    final _$result = _$v ??
        new _$ApiWordModel._(
            externalId: BuiltValueNullFieldError.checkNotNull(
                externalId, r'ApiWordModel', 'externalId'),
            stress: stress,
            translation: BuiltValueNullFieldError.checkNotNull(
                translation, r'ApiWordModel', 'translation'),
            redirectTo: redirectTo);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
