// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_stress_word_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<CloudStressWordModel> _$cloudStressWordModelSerializer =
    _$CloudStressWordModelSerializer();

class _$CloudStressWordModelSerializer
    implements StructuredSerializer<CloudStressWordModel> {
  @override
  final Iterable<Type> types = const [
    CloudStressWordModel,
    _$CloudStressWordModel,
  ];
  @override
  final String wireName = 'CloudStressWordModel';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    CloudStressWordModel object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
    ];
    Object? value;
    value = object.word;
    if (value != null) {
      result
        ..add('word')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.lemma;
    if (value != null) {
      result
        ..add('lemma')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.tableName;
    if (value != null) {
      result
        ..add('table_name')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.rows;
    if (value != null) {
      result
        ..add('rows')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(JsonObject),
          ),
        );
    }
    return result;
  }

  @override
  CloudStressWordModel deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CloudStressWordModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'word':
          result.word =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'lemma':
          result.lemma =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'table_name':
          result.tableName =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'rows':
          result.rows =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(JsonObject),
                  )
                  as JsonObject?;
          break;
      }
    }

    return result.build();
  }
}

class _$CloudStressWordModel extends CloudStressWordModel {
  @override
  final int id;
  @override
  final String? word;
  @override
  final String? lemma;
  @override
  final String? tableName;
  @override
  final JsonObject? rows;

  factory _$CloudStressWordModel([
    void Function(CloudStressWordModelBuilder)? updates,
  ]) => (CloudStressWordModelBuilder()..update(updates))._build();

  _$CloudStressWordModel._({
    required this.id,
    this.word,
    this.lemma,
    this.tableName,
    this.rows,
  }) : super._();
  @override
  CloudStressWordModel rebuild(
    void Function(CloudStressWordModelBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CloudStressWordModelBuilder toBuilder() =>
      CloudStressWordModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CloudStressWordModel &&
        id == other.id &&
        word == other.word &&
        lemma == other.lemma &&
        tableName == other.tableName &&
        rows == other.rows;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, word.hashCode);
    _$hash = $jc(_$hash, lemma.hashCode);
    _$hash = $jc(_$hash, tableName.hashCode);
    _$hash = $jc(_$hash, rows.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CloudStressWordModel')
          ..add('id', id)
          ..add('word', word)
          ..add('lemma', lemma)
          ..add('tableName', tableName)
          ..add('rows', rows))
        .toString();
  }
}

class CloudStressWordModelBuilder
    implements Builder<CloudStressWordModel, CloudStressWordModelBuilder> {
  _$CloudStressWordModel? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _word;
  String? get word => _$this._word;
  set word(String? word) => _$this._word = word;

  String? _lemma;
  String? get lemma => _$this._lemma;
  set lemma(String? lemma) => _$this._lemma = lemma;

  String? _tableName;
  String? get tableName => _$this._tableName;
  set tableName(String? tableName) => _$this._tableName = tableName;

  JsonObject? _rows;
  JsonObject? get rows => _$this._rows;
  set rows(JsonObject? rows) => _$this._rows = rows;

  CloudStressWordModelBuilder();

  CloudStressWordModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _word = $v.word;
      _lemma = $v.lemma;
      _tableName = $v.tableName;
      _rows = $v.rows;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CloudStressWordModel other) {
    _$v = other as _$CloudStressWordModel;
  }

  @override
  void update(void Function(CloudStressWordModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CloudStressWordModel build() => _build();

  _$CloudStressWordModel _build() {
    final _$result =
        _$v ??
        _$CloudStressWordModel._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'CloudStressWordModel',
            'id',
          ),
          word: word,
          lemma: lemma,
          tableName: tableName,
          rows: rows,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
