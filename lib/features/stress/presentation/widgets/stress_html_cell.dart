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
          padding: HtmlPaddings.only(left: 8, right: 8, top: 4, bottom: 4),
          fontSize: FontSize.medium,
        ),
      },
    );
  }
}
