import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:skarnik_flutter/serializers.dart';

import '../../domain/entity/api_word.dart';

part 'api_word_model.g.dart';

abstract class ApiWordModel implements Built<ApiWordModel, ApiWordModelBuilder> {
  @BuiltValueField(wireName: 'external_id')
  int get externalId;

  String? get stress;

  String get translation;

  @BuiltValueField(wireName: 'redirect_to')
  String? get redirectTo;

  ApiWordModel._();

  factory ApiWordModel([void Function(ApiWordModelBuilder) updates]) = _$ApiWordModel;

  static ApiWordModel fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(ApiWordModel.serializer, json)!;
  }

  static Serializer<ApiWordModel> get serializer => _$apiWordModelSerializer;
}

extension ApiWordModelExt on ApiWordModel {
  ApiWord toEntity() => ApiWord(
        externalId: externalId,
        stress: stress,
        translation: translation,
        redirectTo: redirectTo,
      );
}
