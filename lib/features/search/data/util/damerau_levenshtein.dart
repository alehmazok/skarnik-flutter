/// Damerau-Levenshtein edit distance between [a] and [b]. Insertions,
/// deletions, substitutions, and adjacent transpositions each count as
/// a single edit.
int damerauLevenshteinDistance(String a, String b) {
  final lengthA = a.length;
  final lengthB = b.length;

  if (lengthA == 0) return lengthB;
  if (lengthB == 0) return lengthA;

  final distances = List.generate(
    lengthA + 1,
    (i) => List<int>.filled(lengthB + 1, 0),
  );

  for (var i = 0; i <= lengthA; i++) {
    distances[i][0] = i;
  }
  for (var j = 0; j <= lengthB; j++) {
    distances[0][j] = j;
  }

  for (var i = 1; i <= lengthA; i++) {
    for (var j = 1; j <= lengthB; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;

      var value = [
        distances[i - 1][j] + 1,
        distances[i][j - 1] + 1,
        distances[i - 1][j - 1] + cost,
      ].reduce((min, current) => current < min ? current : min);

      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
        value = value < distances[i - 2][j - 2] + cost ? value : distances[i - 2][j - 2] + cost;
      }

      distances[i][j] = value;
    }
  }

  return distances[lengthA][lengthB];
}
