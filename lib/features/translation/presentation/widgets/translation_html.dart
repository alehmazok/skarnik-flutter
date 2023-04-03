import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_bloc.dart';

class TranslationHtml extends StatelessWidget {
  static const colorReplacements = {
    'FFFFFF': {'light': 'F2F2F7', 'dark': '1C1C1E'},
    '831b03': {'light': 'F44C3E', 'dark': 'F44C3E'},
    '0000A0': {'light': 'F44C3E', 'dark': 'F44C3E'},
    '4863A0': {'light': 'F44C3E', 'dark': 'F44C3E'},
    '008000': {'light': '5856D6', 'dark': '5E5CE6'},
    'A52A2A': {'light': '5856D6', 'dark': '5E5CE6'},
    'CC33FF': {'light': '5856D6', 'dark': '5E5CE6'},
    '000000': {'light': '000000', 'dark': 'FFFFFF'},
    '5f5f5f': {'light': '68686E', 'dark': '98989F'},
    '151B54': {'light': '68686E', 'dark': '98989F'},
  };

  final String content;

  const TranslationHtml({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (context, mode, child) {
        return SelectableHtml(
          data: _modifyContentForBrightness(Theme.of(context).brightness),
          shrinkWrap: true,
          style: {'div#skarnik': Style(fontSize: FontSize.large)},
          scrollPhysics: const NeverScrollableScrollPhysics(),
          onAnchorTap: (url, ctx, attrs, element) {
            if (url != null) {
              context.read<SkarnikAppBloc>().add(SkarnikAppAppLinkReceived(url));
            }
          },
        );
      },
    );
  }

  String _modifyContentForBrightness(Brightness brightness) {
    String content = this.content;
    for (final entry in colorReplacements.entries) {
      content = content.replaceAll(RegExp(entry.key, caseSensitive: false), entry.value[brightness.name]!);
    }
    return content;
  }
}
