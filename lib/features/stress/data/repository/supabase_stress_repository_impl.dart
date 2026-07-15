import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/logging.dart';
import 'package:skarnik_flutter/supabase_client.dart';

import '../../domain/entity/stress_row.dart';
import '../../domain/entity/stress_word_entry.dart';
import '../../domain/repository/cloud_stress_repository.dart';
import '../model/cloud_stress_word_model.dart';

@LazySingleton(as: CloudStressRepository)
class SupabaseStressRepositoryImpl implements CloudStressRepository {
  static const _table = 'stress_word';

  final _logger = getLogger(SupabaseStressRepositoryImpl);

  @override
  Future<List<StressWordEntry>> resolveWordList(String word) async {
    _logger.fine('Resolving word list from Supabase for: $word');
    // Plain equality against the always-lowercase `word` column (see
    // parse.py), not ilike() -- ilike can't use the btree index and full-
    // table-scans all ~246k rows, which timed out in practice.
    final response = await SupabaseConfig.client
        .from(_table)
        .select('id, word, lemma, table_name')
        .eq('word', word.toLowerCase());

    return response.map((row) => CloudStressWordModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<StressRow>> getStressTable(int wordId) async {
    _logger.fine('Fetching stress table from Supabase for wordId: $wordId');
    final response = await SupabaseConfig.client
        .from(_table)
        .select('rows')
        .eq('id', wordId)
        .maybeSingle();

    if (response == null) {
      throw Exception('Stress table not found for wordId: $wordId');
    }

    return CloudStressWordModel.fromJson({'id': wordId, 'rows': response['rows']}).toRows();
  }
}
