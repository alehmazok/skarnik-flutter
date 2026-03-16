import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/logging.dart';
import 'package:skarnik_flutter/supabase_client.dart';

import '../../domain/entity/api_word.dart';
import '../../domain/repository/cloud_translation_repository.dart';
import '../model/cloud_word_model.dart';

@LazySingleton(as: CloudTranslationRepository)
class SupabaseTranslationRepositoryImpl implements CloudTranslationRepository {
  final _logger = getLogger(SupabaseTranslationRepositoryImpl);

  @override
  Future<ApiWord> getWord(Word word) async {
    _logger.fine('Fetching translation for wordId: ${word.wordId}');

    final response = await SupabaseConfig.client
        .from('main_word')
        .select()
        .eq('external_id', word.wordId)
        .eq('direction', word.dictionary.path)
        .maybeSingle();

    if (response == null) {
      throw Exception('Translation not found for wordId: ${word.wordId}');
    }

    final model = CloudWordModel.fromJson(response);

    return model.toEntity();
  }

  @override
  Future<Translation> getTranslation(Word word) {
    throw UnimplementedError();
  }
}
