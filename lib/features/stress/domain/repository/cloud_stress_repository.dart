import '../entity/stress_row.dart';
import '../entity/stress_word_entry.dart';

/// Django/MariaDB-backed fallback for [StressRepository] (starnik.by),
/// served by skarnik_admin (https://github.com/alehmazok/skarnik_admin).
/// Data originates from a one-time bulk import from GrammarDB
/// (https://github.com/Belarus/GrammarDB); originally served from Supabase,
/// migrated off it once the stress_word table outgrew the free-tier quota.
/// Distinct interface rather than a second implementation of
/// StressRepository, mirroring how the translation feature keeps
/// Api/Cloud/Website as separate interfaces (see CloudTranslationRepository)
/// -- this codebase has no @Named-qualifier precedent for two impls of one
/// interface.
abstract interface class CloudStressRepository {
  Future<List<StressWordEntry>> resolveWordList(String word);

  Future<List<StressRow>> getStressTable(int wordId);
}
