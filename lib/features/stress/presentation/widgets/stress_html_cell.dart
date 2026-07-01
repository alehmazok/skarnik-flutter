import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class StressHtmlCell extends StatelessWidget {
  final String html;

  const StressHtmlCell({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: html,
      shrinkWrap: true,
      style: {
        'body': Style(
          margin: Margins.zero,
          fontSize: FontSize.large,
        ),
        '.pytanne': Style(
          fontSize: FontSize.medium,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        '.skarot': Style(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          color: const Color(0xFFF44C3E),
        ),
      },
    );
  }
}
