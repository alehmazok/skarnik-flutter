import 'package:skarnik_flutter/features/search/data/util/damerau_levenshtein.dart';
import 'package:test/test.dart';

void main() {
  group('damerauLevenshteinDistance()', () {
    test('returns 0 for two empty strings', () {
      expect(damerauLevenshteinDistance('', ''), equals(0));
    });

    test('returns length of the other string when one is empty', () {
      expect(damerauLevenshteinDistance('', 'abc'), equals(3));
      expect(damerauLevenshteinDistance('abc', ''), equals(3));
    });

    test('returns 0 for identical strings', () {
      expect(damerauLevenshteinDistance('скарнік', 'скарнік'), equals(0));
    });

    test('returns 1 for a single substitution', () {
      expect(damerauLevenshteinDistance('кот', 'кат'), equals(1));
    });

    test('returns 1 for a single insertion', () {
      expect(damerauLevenshteinDistance('кот', 'корт'), equals(1));
    });

    test('returns 1 for a single deletion', () {
      expect(damerauLevenshteinDistance('корт', 'кот'), equals(1));
    });

    test('counts an adjacent transposition as a single edit', () {
      expect(damerauLevenshteinDistance('teh', 'the'), equals(1));
    });

    test('adjacent transposition scores lower than plain substitution-based distance', () {
      // Plain Levenshtein would score 'teh' -> 'the' as 2 (two substitutions).
      // Damerau-Levenshtein must recognize the transposition as a single edit.
      final distance = damerauLevenshteinDistance('teh', 'the');
      expect(distance, lessThan(2));
    });

    test('handles realistic Belarusian typo pairs', () {
      // Deletion of one letter.
      expect(damerauLevenshteinDistance('скарнік', 'скарнк'), equals(1));
      // Substitution of one letter.
      expect(damerauLevenshteinDistance('слоўнік', 'слоўнык'), equals(1));
      // Adjacent transposition.
      expect(damerauLevenshteinDistance('слоўнік', 'слоунік'), equals(1));
    });

    test('is case-sensitive (callers are expected to lowercase beforehand)', () {
      expect(damerauLevenshteinDistance('Кот', 'кот'), equals(1));
    });

    test('computes correct distance for mismatched-length inputs without error', () {
      expect(damerauLevenshteinDistance('ы', 'слоўнік'), equals(7));
      expect(damerauLevenshteinDistance('слоўнік', 'ы'), equals(7));
    });

    test('accumulates multiple edits correctly', () {
      expect(damerauLevenshteinDistance('kitten', 'sitting'), equals(3));
    });
  });
}
