import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

const _blockTags = {'p', 'div', 'br', 'li'};

/// Converts translation HTML to plain text, turning block-level boundaries
/// (`p`/`div`/`br`/`li`) into newlines so multi-sense translations keep their
/// line structure — `Document.body?.text` would concatenate everything with
/// no separators and break newline-based sense splitting.
String htmlToPlainText(String html) {
  final document = parse(html);
  final buffer = StringBuffer();
  _walk(document.body ?? document.documentElement, buffer);
  return buffer
      .toString()
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
}

void _walk(Node? node, StringBuffer buffer) {
  if (node == null) return;
  for (final child in node.nodes) {
    if (child is Text) {
      buffer.write(child.text);
    } else if (child is Element) {
      final isBlock = _blockTags.contains(child.localName);
      if (isBlock) buffer.write('\n');
      _walk(child, buffer);
      if (isBlock) buffer.write('\n');
    }
  }
}
