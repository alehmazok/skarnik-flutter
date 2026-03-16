import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:skarnik_flutter/serializers.dart';

import '../../domain/entity/api_word.dart';

part 'cloud_word_model.g.dart';

abstract class CloudWordModel implements Built<CloudWordModel, CloudWordModelBuilder> {
  @BuiltValueField(wireName: 'external_id')
  int get externalId;

  String? get stress;

  String get translation;

  @BuiltValueField(wireName: 'redirect_to')
  String? get redirectTo;

  CloudWordModel._();

  factory CloudWordModel([void Function(CloudWordModelBuilder) updates]) = _$CloudWordModel;

  static CloudWordModel fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(CloudWordModel.serializer, json)!;
  }

  static Serializer<CloudWordModel> get serializer => _$cloudWordModelSerializer;
}

extension CloudWordModelExt on CloudWordModel {
  ApiWord toEntity() => ApiWord(
    externalId: externalId,
    stress: stress,
    translation: translation,
    redirectTo: redirectTo,
  );
}
