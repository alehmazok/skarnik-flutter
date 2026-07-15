import '../entity/stress_row.dart';
import '../entity/stress_word_entry.dart';

/// Supabase-backed fallback for [StressRepository] (starnik.by), sourced
/// from GrammarDB (https://github.com/Belarus/GrammarDB). Distinct
/// interface rather than a second implementation of StressRepository,
/// mirroring how the translation feature keeps Api/Cloud/Website as
/// separate interfaces (see CloudTranslationRepository) -- this codebase
/// has no @Named-qualifier precedent for two impls of one interface.
abstract interface class CloudStressRepository {
  Future<List<StressWordEntry>> resolveWordList(String word);

  Future<List<StressRow>> getStressTable(int wordId);
}
