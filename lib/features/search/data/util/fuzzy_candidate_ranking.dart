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
      candidates
          .map(
            (candidate) => (
              candidate,
              damerauLevenshteinDistance(searchQuery, candidate.lword),
            ),
          )
          .where(
            (pair) => pair.$2 <= maxDistance,
          )
          .toList()
        ..sort((a, b) {
          final byDistance = a.$2.compareTo(b.$2);
          return byDistance != 0 ? byDistance : a.$1.lword.compareTo(b.$1.lword);
        });
  return scored.take(limit).map((pair) => pair.$1).toList();
}
