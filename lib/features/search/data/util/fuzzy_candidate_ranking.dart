import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';

import 'damerau_levenshtein.dart';

/// Filters [candidates] to those within [maxDistance] edits of [searchQuery],
/// sorted by distance then alphabetically, capped at [limit].
List<ObjectboxSearchWord> rankFuzzyCandidates(
  Iterable<ObjectboxSearchWord> candidates, {
  required String searchQuery,
  required int maxDistance,
  required int limit,
}) {
  final scored =
      [
        for (final candidate in candidates)
          MapEntry(candidate, damerauLevenshteinDistance(searchQuery, candidate.lword)),
      ].where((entry) => entry.value <= maxDistance).toList()..sort((a, b) {
        final byDistance = a.value.compareTo(b.value);
        return byDistance != 0 ? byDistance : a.key.lword.compareTo(b.key.lword);
      });
  return scored.take(limit).map((entry) => entry.key).toList();
}
