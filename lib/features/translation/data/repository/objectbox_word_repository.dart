import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

@Injectable(as: WordRepository)
class ObjectboxWordRepository implements WordRepository {
  final ObjectboxStoreHolder objectboxService;

  ObjectboxWordRepository(this.objectboxService);

  @override
  Future<Word?> getWord({required langId, required wordId}) async {
    final box = objectboxService.searchBox;
    final query = box
        .query(
          ObjectboxSearchWord_.langId.equals(langId) & ObjectboxSearchWord_.wordId.equals(wordId),
        )
        .build();

    return query.findUnique()?.toEntity();
  }
}
