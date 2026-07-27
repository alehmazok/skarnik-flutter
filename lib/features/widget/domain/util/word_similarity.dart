import 'html_to_plain_text.dart';

const _apostropheVariants = ['❛', '❜', '`', '‛', '‘', '’'];
const _dashChars = ['­', '–', '‑', '—', '‒'];

/// Lowercase, trim, then collapse Belarusian/Russian cognate letter
/// differences so near-identical word/translation pairs compare as similar.
/// Order matters — later substitutions can act on the output of earlier ones.
String normalize(String input) {
  var result = input.toLowerCase().trim();
  result = result.replaceAll('о', 'а');
  result = result.replaceAll('щ', 'шч');
  result = result.replaceAll('ъ', "'");
  result = result.replaceAll('ў', 'у');
  for (final variant in _apostropheVariants) {
    result = result.replaceAll(variant, "'");
  }
  result = result.replaceAll('ся', 'ца');
  result = result.replaceAll('ый', 'і');
  result = result.replaceAll('ы', 'і');
  result = result.replaceAll('ий', 'і');
  result = result.replaceAll('и', 'і');
  result = result.replaceAll('т', 'ц');
  result = result.replaceAll('ё', 'е');
  return result;
}

/// Splits plain-text translation into lines, taking the first sense (text
/// before the first dash char, if any) of each line.
List<String> _firstSensePerLine(String plainText) {
  return plainText
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) {
        var cutIndex = line.length;
        for (final dash in _dashChars) {
          final index = line.indexOf(dash);
          if (index != -1 && index < cutIndex) cutIndex = index;
        }
        return line.substring(0, cutIndex).trim();
      })
      .where((sense) => sense.isNotEmpty)
      .toList();
}

int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (i) => i);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = [current[j - 1] + 1, previous[j] + 1, previous[j - 1] + cost].reduce(
        (x, y) => x < y ? x : y,
      );
    }
    final tmp = previous;
    previous = current;
    current = tmp;
  }
  return previous[b.length];
}

/// `similarity = word.length / minDistance` (infinite when distance is 0),
/// `isSimilar = similarity > 1.8` — flags translations that are basically
/// the same word as the source (no educational value in a widget pick).
bool isSimilar(String word, String translationHtml) {
  final senses = _firstSensePerLine(htmlToPlainText(translationHtml));
  if (senses.isEmpty) return false;

  final normalizedWord = normalize(word);
  var minDistance = -1;
  for (final sense in senses) {
    final distance = levenshtein(normalizedWord, normalize(sense));
    if (minDistance == -1 || distance < minDistance) {
      minDistance = distance;
    }
  }

  if (minDistance == 0) return true;
  final similarity = normalizedWord.length / minDistance;
  return similarity > 1.8;
}
