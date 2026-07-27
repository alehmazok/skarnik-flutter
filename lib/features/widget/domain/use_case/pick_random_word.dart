import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

@injectable
class PickRandomWordUseCase {
  final ObjectboxStoreHolder _storeHolder;
  final _random = Random();

  PickRandomWordUseCase(this._storeHolder);

  Word call() {
    final box = _storeHolder.searchBox;
    final query = box.query(ObjectboxSearchWord_.langId.equals(Dictionary.belRus.langId)).build();
    final total = query.count();
    if (total == 0) {
      query.close();
      throw StateError('Пусты слоўнік бел-рус, немагчыма выбраць выпадковае слова.');
    }
    query.offset = _random.nextInt(total);
    query.limit = 1;
    final word = query.find().first.toEntity();
    query.close();
    return word;
  }
}
