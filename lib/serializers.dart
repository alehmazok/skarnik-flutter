import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'features/translation/domain/entity/api_word.dart';

part 'serializers.g.dart';

@SerializersFor([
  ApiWord,
])
final Serializers serializers = (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
