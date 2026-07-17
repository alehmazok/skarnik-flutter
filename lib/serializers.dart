import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'features/stress/data/model/cloud_stress_word_model.dart';
import 'features/translation/data/model/api_word_model.dart';
import 'features/translation/data/model/cloud_word_model.dart';

part 'serializers.g.dart';

@SerializersFor([
  ApiWordModel,
  CloudWordModel,
  CloudStressWordModel,
])
final Serializers serializers = (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin()))
    .build();
