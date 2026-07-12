import 'package:injectable/injectable.dart' show Injectable;
import 'package:skarnik_flutter/features/app/data/model/objectbox_translation_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/entity/api_word.dart';
import '../../domain/repository/local_translation_repository.dart';

@Injectable(as: LocalTranslationRepository)
class ObjectboxTranslationRepository implements LocalTranslationRepository {
  final ObjectboxStoreHolder _objectboxStoreHolder;

  ObjectboxTranslationRepository(this._objectboxStoreHolder);

  @override
  Future<ApiWord?> getWord({required int langId, required int wordId}) async {
    final box = _objectboxStoreHolder.translationBox;
    final query = box
        .query(
          ObjectboxTranslationWord_.key.equals('$langId:$wordId'),
        )
        .build();
    final word = query.findUnique();
    query.close();
    return word?.toEntity();
  }

  @override
  Future<void> putMany(int langId, List<ApiWord> words) async {
    final store = _objectboxStoreHolder.translationStore;
    final box = _objectboxStoreHolder.translationBox;
    store.runInTransaction(
      TxMode.write,
      () => box.putMany(words.map((it) => it.toObjectbox(langId)).toList()),
    );
  }

  @override
  Future<int> count(int langId) async {
    final query = _objectboxStoreHolder.translationBox
        .query(
          ObjectboxTranslationWord_.langId.equals(langId),
        )
        .build();
    final total = query.count();
    query.close();
    return total;
  }

  @override
  Future<void> clear(int langId) async {
    final query = _objectboxStoreHolder.translationBox
        .query(
          ObjectboxTranslationWord_.langId.equals(langId),
        )
        .build();
    query.remove();
    query.close();
  }
}
