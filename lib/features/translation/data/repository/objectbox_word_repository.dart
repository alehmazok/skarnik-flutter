import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

@Injectable(as: WordRepository)
class ObjectboxWordRepository implements WordRepository {
  final ObjectboxService objectboxService;

  ObjectboxWordRepository(this.objectboxService);

  @override
  Future<Word?> getWord({required langId, required wordId}) async {
    final box = objectboxService.wordBox;
    final query = box
        .query(
          ObjectboxWord_.langId.equals(langId) & ObjectboxWord_.wordId.equals(wordId),
        )
        .build();

    return query.findUnique();
  }
}
