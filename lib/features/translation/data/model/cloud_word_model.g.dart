// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_word_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<CloudWordModel> _$cloudWordModelSerializer =
    _$CloudWordModelSerializer();

class _$CloudWordModelSerializer
    implements StructuredSerializer<CloudWordModel> {
  @override
  final Iterable<Type> types = const [CloudWordModel, _$CloudWordModel];
  @override
  final String wireName = 'CloudWordModel';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    CloudWordModel object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'external_id',
      serializers.serialize(
        object.externalId,
        specifiedType: const FullType(int),
      ),
      'translation',
      serializers.serialize(
        object.translation,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.stress;
    if (value != null) {
      result
        ..add('stress')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.redirectTo;
    if (value != null) {
      result
        ..add('redirect_to')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  CloudWordModel deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CloudWordModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'external_id':
          result.externalId =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'stress':
          result.stress =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'translation':
          result.translation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'redirect_to':
          result.redirectTo =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$CloudWordModel extends CloudWordModel {
  @override
  final int externalId;
  @override
  final String? stress;
  @override
  final String translation;
  @override
  final String? redirectTo;

  factory _$CloudWordModel([void Function(CloudWordModelBuilder)? updates]) =>
      (CloudWordModelBuilder()..update(updates))._build();

  _$CloudWordModel._({
    required this.externalId,
    this.stress,
    required this.translation,
    this.redirectTo,
  }) : super._();
  @override
  CloudWordModel rebuild(void Function(CloudWordModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CloudWordModelBuilder toBuilder() => CloudWordModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CloudWordModel &&
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
    return (newBuiltValueToStringHelper(r'CloudWordModel')
          ..add('externalId', externalId)
          ..add('stress', stress)
          ..add('translation', translation)
          ..add('redirectTo', redirectTo))
        .toString();
  }
}

class CloudWordModelBuilder
    implements Builder<CloudWordModel, CloudWordModelBuilder> {
  _$CloudWordModel? _$v;

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

  CloudWordModelBuilder();

  CloudWordModelBuilder get _$this {
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
  void replace(CloudWordModel other) {
    _$v = other as _$CloudWordModel;
  }

  @override
  void update(void Function(CloudWordModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CloudWordModel build() => _build();

  _$CloudWordModel _build() {
    final _$result =
        _$v ??
        _$CloudWordModel._(
          externalId: BuiltValueNullFieldError.checkNotNull(
            externalId,
            r'CloudWordModel',
            'externalId',
          ),
          stress: stress,
          translation: BuiltValueNullFieldError.checkNotNull(
            translation,
            r'CloudWordModel',
            'translation',
          ),
          redirectTo: redirectTo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
