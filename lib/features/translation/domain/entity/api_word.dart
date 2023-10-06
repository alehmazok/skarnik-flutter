import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:skarnik_flutter/serializers.dart';

part 'api_word.g.dart';

abstract class ApiWord implements Built<ApiWord, ApiWordBuilder> {
  @BuiltValueField(wireName: 'external_id')
  int get externalId;

  String get translation;

  ApiWord._();

  factory ApiWord([void Function(ApiWordBuilder) updates]) = _$ApiWord;

  static ApiWord fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ApiWord.serializer, json)!;
  }

  static Serializer<ApiWord> get serializer => _$apiWordSerializer;
}
