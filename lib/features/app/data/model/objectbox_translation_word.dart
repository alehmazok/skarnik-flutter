import 'package:objectbox/objectbox.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/api_word.dart';

@Entity(uid: 4)
class ObjectboxTranslationWord {
  @Id(assignable: false)
  int id = 0;

  @Index(type: IndexType.value)
  int langId;

  int wordId;

  // Composite uniqueness: `wordId` alone isn't unique across dictionaries
  // (each direction has its own external_id sequence). Replace-on-conflict
  // so re-downloading / re-caching a word overwrites in place.
  @Unique(onConflict: ConflictStrategy.replace)
  String key;

  String? stress;

  String translation;

  String? redirectTo;

  ObjectboxTranslationWord({
    required this.langId,
    required this.wordId,
    required this.translation,
    this.stress,
    this.redirectTo,
  }) : key = '$langId:$wordId';

  @override
  String toString() => 'ObjectboxTranslationWord(id: $id, $langId, $wordId)';
}

extension ObjectboxTranslationWordExt on ObjectboxTranslationWord {
  ApiWord toEntity() => ApiWord(
    externalId: wordId,
    stress: stress,
    translation: translation,
    redirectTo: redirectTo,
  );
}

extension ApiWordToObjectboxExt on ApiWord {
  ObjectboxTranslationWord toObjectbox(int langId) => ObjectboxTranslationWord(
    langId: langId,
    wordId: externalId,
    translation: translation,
    stress: stress,
    redirectTo: redirectTo,
  );
}
